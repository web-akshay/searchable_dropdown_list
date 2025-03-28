// lib/searchable_dropdown_list.dart

library searchable_dropdown_list;

import 'package:flutter/material.dart';

class SearchableDropdownList<T> extends StatefulWidget {
  const SearchableDropdownList({
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.onSaved,
    required this.title,
    this.selectedItem,
    this.validator,
    this.hintText = "Please select",
    this.itemBuilder,
    super.key,
  });

  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T?)? onChanged;
  final void Function(T?)? onSaved;
  final String title;
  final T? selectedItem;
  final String? Function(T?)? validator;
  final String hintText;
  final Widget Function(T)? itemBuilder;

  @override
  State<SearchableDropdownList<T>> createState() =>
      _SearchableDropdownListState<T>();
}

class _SearchableDropdownListState<T> extends State<SearchableDropdownList<T>> {
  final TextEditingController searchController = TextEditingController();
  late List<T> filteredItems;
  T? selectedValue;

  @override
  void initState() {
    filteredItems = widget.items;
    selectedValue = widget.selectedItem;
    super.initState();
  }

  void filterList(String query) {
    setState(() {
      filteredItems = widget.items
          .where((item) => widget
              .itemLabel(item)
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showDropdown() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  title: Text(widget.title),
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                    onChanged: (value) {
                      setModalState(() => filterList(value));
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedValue = item;
                          });
                          widget.onChanged?.call(item);
                          Navigator.pop(context);
                        },
                        child: widget.itemBuilder != null
                            ? widget.itemBuilder!(item)
                            : ListTile(title: Text(widget.itemLabel(item))),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      validator: widget.validator,
      onSaved: widget.onSaved,
      builder: (FormFieldState<T> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: _showDropdown,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: state.hasError ? Colors.red : Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedValue != null
                          ? widget.itemLabel(selectedValue!)
                          : widget.hintText,
                      style: TextStyle(
                          color: selectedValue != null
                              ? Colors.black
                              : Colors.grey),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 5.0, left: 8.0),
                child: Text(state.errorText!,
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
          ],
        );
      },
    );
  }
}
