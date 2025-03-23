import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final String? initialQuery;

  CustomSearchBar({
    required this.onSearch,
    this.initialQuery,
  });

  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _isSearching = widget.initialQuery?.isNotEmpty ?? false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSearch() {
    final query = _controller.text.trim();
    widget.onSearch(query);
    setState(() {
      _isSearching = query.isNotEmpty;
    });
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearch('');
    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Search for courses...',
            prefixIcon: Icon(Icons.search),
            suffixIcon: _isSearching
                ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: _clearSearch,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
          onSubmitted: (_) => _handleSearch(),
          onChanged: (text) {
            setState(() {
              _isSearching = text.isNotEmpty;
            });
            if (text.isEmpty) {
              widget.onSearch('');
            }
          },
          textInputAction: TextInputAction.search,
        ),
      ),
    );
  }
}
