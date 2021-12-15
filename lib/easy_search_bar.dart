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

import 'package:flutter/material.dart';

class EasySearchBar extends StatefulWidget implements PreferredSizeWidget {
  final Color? foregroundColor;
  final double toolbarHeight;
  final FutureOr<List<String>>? suggestions;
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

  const EasySearchBar({
    Key? key,
    required this.title,
    required this.onSearch,
    this.actions = const [],
    this.suggestions,
    this.foregroundColor,
    this.toolbarHeight = 56,
    this.centerTitle = false,
    this.cursorColor,
    this.isFloating = false,
    this.animationDuration = const Duration(milliseconds: 450),
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

  late AnimationController _controller;
  late Animation _containerSizeAnimation;
  late Animation _containerBorderRadiusAnimation;
  late Animation _textfieldOpacityAnimation;
  late TextEditingController _searchController;

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
   // _controller.forward();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      widget.onSearch(_searchController.text);
    });
    // TODO: set async suggestions
    // TODO: detect key enter press to dismiss suggestions
    // TODO: set suggestions list animation

    // TODO: add suppirt for back button in appbar
    Future.delayed(Duration.zero, () async {  _suggestions = await widget.suggestions!; });
  }

  void openOverlay() {
    if (_overlayEntry == null && widget.suggestions != null) {
      RenderBox renderBox = context.findRenderObject() as RenderBox;
      var size = renderBox.size;
      var offset = renderBox.localToGlobal(Offset.zero);

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
              child: Material(
                elevation: 5,
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          _suggestions[index],
                          // thisstyle: suggestionTextStyle
                        )
                      ),
                      onTap: () => _searchController.text = _suggestions[index]
                    );
                  },
                ),
              ),
            )
          )
        )
      );
    }
    if (!_hasOpenedOverlay && widget.suggestions != null) {
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

  Future<void> updateSuggestions(String input) async {
    rebuildOverlay();
    if (widget.suggestions != null) {
      _suggestions = await widget.suggestions!;
      _suggestions = _suggestions.where((element) {
        return element.toLowerCase().contains(input.toLowerCase());
      }).toList();
      rebuildOverlay();
    }
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

    Color? foregroundColor = widget.foregroundColor ?? appBarTheme.foregroundColor ?? theme.primaryColor;
    IconThemeData overallIconTheme = appBarTheme.iconTheme
        ?? theme.iconTheme.copyWith(color: foregroundColor);

    TextStyle? titleTextStyle = appBarTheme.titleTextStyle
        ?? theme.textTheme.headline6;

    return CompositedTransformTarget(
      link: _layerLink,
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              margin: EdgeInsets.all(widget.isFloating ? 5 : 0),
              child: Material(
                elevation: 5,
                color: foregroundColor,
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
                            child: IconButton(
                              icon: const Icon(Icons.menu),
                              iconSize: overallIconTheme.size ?? 24,
                              onPressed: () => scaffold!.openDrawer(),
                              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                            )
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(left: 20),
                              child: DefaultTextStyle(
                                style: titleTextStyle!,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                child: widget.title,
                              ),
                            )
                          ),
                          ...List.generate(widget.actions.length + 1, (index) {
                            if (widget.actions.length == index) {
                              return IconButton(
                                icon: const Icon(Icons.search),
                                iconSize: overallIconTheme.size ?? 24,
                                onPressed: () {
                                  _controller.forward();
                                  openOverlay();
                                },
                                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                              );
                            }
                
                            return widget.actions[index];
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
                                bottomLeft: Radius.circular(_containerBorderRadiusAnimation.value * 50),
                                topLeft: Radius.circular(_containerBorderRadiusAnimation.value * 50),
                              ),
                              color: Colors.white
                            ),
                            child: Opacity(
                              opacity: _textfieldOpacityAnimation.value,
                              child: TextField(
                                controller: _searchController,
                                autofocus: true,
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(
                                    left: 20,
                                    right: 10,
                                  ),
                                  border: InputBorder.none,
                                  suffixIcon: IconButton(
                                    color: Colors.red,
                                    icon: const Icon(
                                      Icons.close
                                    ),
                                    onPressed: () {
                                      closeOverlay();
                                      _controller.reverse();
                                      _searchController.clear();
                                    }
                                  )
                                )
                              ),
                            )
                          );
                        },
                      ),
                    )
                  ]
                )
              ),
            );
          }
        )
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
