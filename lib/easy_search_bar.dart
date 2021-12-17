// Copyright 2021 4inka

// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:

// 1. Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.

// 2. Redistributions in binary form must reproduce the above copyright
// notice, this list of conditions and the following disclaimer in the
// documentation and/or other materials provided with the distribution.

// 3. Neither the name of the copyright holder nor the names of its contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission.

// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
// NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

library easy_search_bar;

import 'dart:async';

import 'package:easy_search_bar/widgets/filterable_list.dart';
import 'package:flutter/material.dart';

class EasySearchBar extends StatefulWidget implements PreferredSizeWidget {
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final double toolbarHeight;
  final double suggestionsElevation;
  final List<String>? suggestions;
  final Future<List<String>> Function(String value)? asyncSuggestions;
  final IconThemeData? iconTheme;
  /// The title to be displayed inside appBar
  final Text title;
  final List<Widget> actions;
  /// Returns the current search value
  /// When search is closed, this method returns an empty value to clear the current search
  final Function(String) onSearch;
  final bool centerTitle;
  /// Duration for the appBar search show and hide
  final Duration animationDuration;
  final bool isFloating;
  /// Sets custom cursor color
  final Color? cursorColor;
  final TextStyle? titleTextStyle;
  final String searchHintText;
  final IconThemeData? searchBackIconTheme;
  final Color? searchCursorColor;
  final TextStyle? searchHintStyle;
  final TextStyle searchTextStyle;
  final Duration debounceDuration;
  final TextStyle suggestionTextStyle;
  final Color? suggestionBackgroundColor;

  const EasySearchBar({
    Key? key,
    required this.title,
    required this.onSearch,
    this.actions = const [],
    this.searchHintStyle,
    this.searchTextStyle = const TextStyle(),
    this.suggestions,
    this.asyncSuggestions,
    this.searchCursorColor,
    this.searchHintText = '',
    this.suggestionsElevation = 5,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.toolbarHeight = 56,
    this.centerTitle = false,
    this.cursorColor,
    this.isFloating = false,
    this.titleTextStyle,
    this.iconTheme,
    this.searchBackIconTheme,
    this.suggestionTextStyle = const TextStyle(),
    this.suggestionBackgroundColor,
    this.animationDuration = const Duration(milliseconds: 450),
    this.debounceDuration = const Duration(milliseconds: 400)
  }) : super(key: key);

  @override
  State<EasySearchBar> createState() => _EasySearchBarState();

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

class _EasySearchBarState extends State<EasySearchBar> with TickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  bool _hasOpenedOverlay = false;
  bool _isLoading = false;
  OverlayEntry? _overlayEntry;
  List<String> _suggestions = [];
  Timer? _debounce;
  String _previousAsyncSearchText = '';
  final FocusNode _focusNode = FocusNode();

  late AnimationController _controller;
  late Animation _containerSizeAnimation;
  late Animation _containerBorderRadiusAnimation;
  late Animation _textfieldOpacityAnimation;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync:  this ,
      duration: widget.animationDuration
    );
    _containerSizeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeIn),
      ),
    );
    _containerBorderRadiusAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeIn),
      ),
    );
    _textfieldOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 1, curve: Curves.easeIn),
      ),
    );
    _searchController.addListener(() async {
      widget.onSearch(_searchController.text);
      if (widget.suggestions != null) {
        updateSyncSuggestions(_searchController.text);
      }
      else if (widget.asyncSuggestions != null) {
         updateAsyncSuggestions(_searchController.text);
      }
    });
    // TODO: detect key enter press to dismiss suggestions
    // TODO: set suggestions list animation
    // TODO: add custom suggestion builder
  }

  void openOverlay() {
    if (_overlayEntry == null && (widget.suggestions != null || widget.asyncSuggestions != null)) {
      RenderBox renderBox = context.findRenderObject() as RenderBox;
      Size size = renderBox.size;
      Offset offset = renderBox.localToGlobal(Offset.zero);

      _overlayEntry ??= OverlayEntry(
        builder: (context) => Positioned(
          left: offset.dx,
          top: offset.dy + size.height,
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0.0, size.height),
            child: Container(
              constraints: const BoxConstraints(
                maxHeight: 150
              ),
              margin: const EdgeInsets.all(5),
              child: FilterableList(
                loading: _isLoading,
                items: _suggestions,
                elevation: widget.suggestionsElevation,
                suggestionTextStyle: widget.suggestionTextStyle,
                suggestionBackgroundColor: widget.suggestionBackgroundColor,
                onItemTapped: (value) {
                  _searchController.value = TextEditingValue(
                    text: value,
                    selection: TextSelection.collapsed(
                      offset: value.length
                    )
                  );
                  widget.onSearch(value);
                  closeOverlay();
                }
              )
            )
          )
        )
      );
    }
    if (!_hasOpenedOverlay && (widget.suggestions != null || widget.asyncSuggestions != null)) {
      Overlay.of(context)!.insert(_overlayEntry!);
      setState(() => _hasOpenedOverlay = true );
    }
  }

  void closeOverlay() {
    if (_hasOpenedOverlay) {
      _overlayEntry!.remove();
      setState(() => _hasOpenedOverlay = false );
    }
  }

  void updateSyncSuggestions(String input) {
    openOverlay();
    _suggestions = widget.suggestions!.where((element) {
      return element.toLowerCase().contains(input.toLowerCase());
    }).toList();
    rebuildOverlay();
  }

  Future<void> updateAsyncSuggestions(String input) async {
    openOverlay();
    if (_debounce != null && _debounce!.isActive) {
      _debounce!.cancel();
    }
    setState(() => _isLoading = true);
    _debounce = Timer(widget.debounceDuration, () async {
      if (_previousAsyncSearchText != input || _previousAsyncSearchText.isEmpty || input.isEmpty) {
        _suggestions = await widget.asyncSuggestions!(input);
        setState(() {
          _isLoading = false;
          _previousAsyncSearchText = input;
        });
        rebuildOverlay();
      }
    });
  }

  void rebuildOverlay() {
    if(_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppBarTheme appBarTheme = AppBarTheme.of(context);
    final ScaffoldState? scaffold = Scaffold.maybeOf(context);
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);

    final bool canPop = parentRoute?.canPop ?? false;

    Color? backgroundColor = widget.backgroundColor ?? appBarTheme.backgroundColor ?? theme.primaryColor;

    Color? foregroundColor = widget.foregroundColor ?? appBarTheme.foregroundColor;

    IconThemeData iconTheme = widget.iconTheme ?? appBarTheme.iconTheme ?? theme.iconTheme.copyWith(color: foregroundColor);

    TextStyle? titleTextStyle = widget.titleTextStyle ?? appBarTheme.titleTextStyle ?? theme.textTheme.headline6!.copyWith(color: foregroundColor);

    double? elevation = widget.elevation ?? appBarTheme.elevation ?? 5;

    Color searchColor = theme.brightness == Brightness.light ? Colors.white : Colors.black;

    Color cursorColor = widget.searchCursorColor ?? theme.primaryColor;

    IconThemeData searchIconThemeData = widget.searchBackIconTheme ?? IconThemeData(
      size: 24,
      color: Theme.of(context).primaryColor
    );

    TextStyle searchHintStyle = widget.searchHintStyle ?? theme.inputDecorationTheme.hintStyle ?? const TextStyle(
      color: Colors.grey,
      fontStyle: FontStyle.italic
    );

    return CompositedTransformTarget(
      link: _layerLink,
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              margin: EdgeInsets.all(widget.isFloating ? 5 : 0),
              child: Material(
                elevation: elevation,
                color: backgroundColor,
                child: Stack(
                  children: [
                    Container(
                      height: widget.toolbarHeight,
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        top: 10,
                        left: 5,
                        right: 3,
                        bottom: 10
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Visibility(
                            visible: scaffold?.hasDrawer ?? false,
                            child: IconTheme(
                              data: iconTheme,
                              child: IconButton(
                                icon: const Icon(Icons.menu),
                                iconSize: iconTheme.size ?? 24,
                                onPressed: () => scaffold!.openDrawer(),
                                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                              ),
                            ),
                            replacement: Visibility(
                              visible: canPop,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_outlined),
                                iconSize: iconTheme.size ?? 24,
                                onPressed: () => Navigator.pop(context),
                                tooltip: MaterialLocalizations.of(context).backButtonTooltip
                              ),
                              replacement: const SizedBox()
                            )
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(left: 20),
                              child: DefaultTextStyle(
                                style: titleTextStyle,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                child: widget.title,
                              ),
                            )
                          ),
                          ...List.generate(widget.actions.length + 1, (index) {
                            if (widget.actions.length == index) {
                              return IconTheme(
                                data: iconTheme,
                                child: IconButton(
                                  icon: const Icon(Icons.search),
                                  iconSize: iconTheme.size ?? 24,
                                  onPressed: () {
                                    _controller.forward();
                                    _focusNode.requestFocus();
                                  },
                                  tooltip: MaterialLocalizations.of(context).searchFieldLabel,
                                ),
                              );
                            }
                
                            return IconTheme(
                              data: iconTheme,
                              child: widget.actions[index]
                            );
                          })
                        ]
                      )
                    ),
                    Positioned(
                      right: 0,
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Container(
                            alignment: Alignment.center,
                            height: constraints.maxHeight,
                            width: _containerSizeAnimation.value * constraints.maxWidth,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(_containerBorderRadiusAnimation.value * 30),
                                topLeft: Radius.circular(_containerBorderRadiusAnimation.value * 30),
                              ),
                              color: searchColor
                            ),
                            child: Opacity(
                              opacity: _textfieldOpacityAnimation.value,
                              child: TextField(
                                controller: _searchController,
                                cursorColor: cursorColor,
                                focusNode: _focusNode,
                                textAlignVertical: TextAlignVertical.center,
                                style: widget.searchTextStyle,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(
                                    left: 20,
                                    right: 10
                                  ),
                                  hintText: widget.searchHintText,
                                  hintMaxLines: 1,
                                  hintStyle: searchHintStyle,
                                  border: InputBorder.none,
                                  prefixIcon: IconTheme(
                                    data: searchIconThemeData,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.arrow_back_outlined
                                      ),
                                      onPressed: () {
                                        _controller.reverse();
                                        _searchController.clear();
                                        closeOverlay();
                                      }
                                    )
                                  )
                                )
                              )
                            )
                          );
                        }
                      )
                    )
                  ]
                )
              )
            );
          }
        )
      )
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
