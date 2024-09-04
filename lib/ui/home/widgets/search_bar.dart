import 'package:docibry/constants/string_constants.dart';
import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final void Function(String) onSearchQueryChanged;

  const CustomSearchBar({super.key, required this.onSearchQueryChanged});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar>
    with SingleTickerProviderStateMixin {
  bool _isActive = false;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!_isActive)
          Text(
            StringConstants.appName,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              child: _isActive
                  ? Container(
                      width: double.infinity,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSecondary,
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: TextField(
                        controller: _controller,
                        onChanged: (query) {
                          widget.onSearchQueryChanged(query);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search for document names',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isActive = false;
                                _controller.clear();
                                widget.onSearchQueryChanged('');
                              });
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ),
                      ),
                    )
                  : IconButton(
                      onPressed: () {
                        setState(() {
                          _isActive = true;
                        });
                      },
                      icon: const Icon(Icons.search),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
