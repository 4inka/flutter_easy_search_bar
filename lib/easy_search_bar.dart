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
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EasySearchBar extends StatefulWidget implements PreferredSizeWidget {
  /// The title to be displayed inside AppBar
  final Widget title;

  /// Returns the current search value
  /// When search is closed, this method returns an empty value to clear the current search
  final Function(String) onSearch;

  /// Can be used to add leading icon to AppBar
  final Widget? leading;

  /// Extra custom actions that can be displayed inside AppBar
  final List<Widget> actions;

  /// Can be used to change AppBar background color
  final Color? backgroundColor;

  /// Can be used to change AppBar foreground color
  final Color? foregroundColor;

  /// Can be used to change AppBar elevation
  final double? elevation;

  /// Can be used to set custom icon theme for AppBar icons
  final IconThemeData? iconTheme;

  /// Can be used to change AppBar height
  final double appBarHeight;

  /// Can be used to set a duration for the AppBar search show and hide animation
  final Duration animationDuration;

  /// Can be used to determine if it will be a normal or floating AppBar
  final bool isFloating;

  /// Can be used to determine if the suggestions overlay will be opened when clicking search
  final bool openOverlayOnSearch;

  /// Can be used to determine if the actions button will be placed at right of the appbar
  final bool putActionsOnRight;

  /// Can be used to set the AppBar title style
  final TextStyle? titleTextStyle;

  /// Can be used to set the search input background color
  final Color? searchBackgroundColor;

  /// Can be used to set search textField cursor color
  final Color? searchCursorColor;

  /// Can be used to set search textField hint text
  final String searchHintText;

  /// Can be used to set search textField hint style
  final TextStyle? searchHintStyle;

  /// Can be used to set search textField text style
  final TextStyle searchTextStyle;

  /// Can be used to set search textField keyboard type
  final TextInputType searchTextKeyboardType;

  /// Can be used to set custom icon theme for the search textField back button
  final IconThemeData? searchBackIconTheme;
  
  /// Can be used to show search clear textField button
  final bool showClearSearchIcon;
  
  /// Can be used to set custom icon theme for the search clear textField button
  final IconThemeData? searchClearIconTheme;

  /// Can be used to set SystemUiOverlayStyle to the AppBar
  final SystemUiOverlayStyle? systemOverlayStyle;

  /// Can be used to create a suggestions list
  final List<String>? suggestions;

  /// Can be used to set async suggestions list
  final Future<List<String>> Function(String value)? asyncSuggestions;

  /// Can be used to change suggestion list elevation
  final double suggestionsElevation;

  /// A function that can be used to create a widget to display a custom suggestions loader
  final Widget Function()? suggestionLoaderBuilder;

  /// Can be used to change the suggestions text style
  final TextStyle suggestionTextStyle;

  /// Can be used to change suggestions list background color
  final Color? suggestionBackgroundColor;

  /// Can be used to create custom suggestion item widget
  final Widget Function(String data)? suggestionBuilder;

  /// Instead of using the default suggestion tap action that fills the textField, you can set your own custom action for it
  final Function(String data)? onSuggestionTap;

  /// Can be used to set the debounce time for async data fetch
  final Duration debounceDuration;
  
  /// Can be used to change text direction
  final TextDirection searchTextDirection;

  const EasySearchBar(
      {Key? key,
      required this.title,
      required this.onSearch,
      this.suggestionBuilder,
      this.leading,
      this.actions = const [],
      this.searchHintStyle,
      this.searchTextStyle = const TextStyle(),
      this.systemOverlayStyle,
      this.suggestions,
      this.onSuggestionTap,
      this.searchBackIconTheme,
      this.showClearSearchIcon = false,
      this.searchClearIconTheme,
      this.asyncSuggestions,
      this.searchCursorColor,
      this.searchHintText = '',
      this.searchBackgroundColor,
      this.suggestionLoaderBuilder,
      this.suggestionsElevation = 5,
      this.backgroundColor,
      this.foregroundColor,
      this.elevation,
      this.appBarHeight = 56,
      this.isFloating = false,
      this.openOverlayOnSearch = false,
      this.putActionsOnRight = false,
      this.titleTextStyle,
      this.iconTheme,
      this.suggestionTextStyle = const TextStyle(),
      this.suggestionBackgroundColor,
      this.animationDuration = const Duration(milliseconds: 450),
      this.debounceDuration = const Duration(milliseconds: 400),
      this.searchTextKeyboardType = TextInputType.text,
      this.searchTextDirection = TextDirection.ltr})
      : assert(elevation == null || elevation >= 0.0),
        super(key: key);

  @override
  State<EasySearchBar> createState() => _EasySearchBarState();

  @override
  Size get preferredSize =>
      Size.fromHeight(appBarHeight + (isFloating ? 5 : 0));
}

class _EasySearchBarState extends State<EasySearchBar>
    with TickerProviderStateMixin {
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
  late Animation _textFieldOpacityAnimation;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: widget.animationDuration);
    _containerSizeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeIn),
      ),
    );
    _containerBorderRadiusAnimation =
        Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.55, curve: Curves.easeIn),
    ));
    _textFieldOpacityAnimation =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 1, curve: Curves.easeIn),
    ));
    _searchController.addListener(() async {
      if (_focusNode.hasFocus) {
        widget.onSearch(_searchController.text);
        if (widget.suggestions != null) {
          openOverlay();
          updateSyncSuggestions(_searchController.text);
        } else if (widget.asyncSuggestions != null) {
          openOverlay();
          updateAsyncSuggestions(_searchController.text);
        }
      }
    });
  }

  Widget? _suggestionLoaderBuilder() {
    Widget? child;

    if (widget.suggestionLoaderBuilder != null) {
      child = widget.suggestionLoaderBuilder!();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      child = const CupertinoActivityIndicator();
    } else {
      child = const CircularProgressIndicator();
    }

    return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: child);
  }

  void openOverlay() {
    if (_overlayEntry == null &&
        (widget.suggestions != null || widget.asyncSuggestions != null)) {
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
                      constraints: const BoxConstraints(maxHeight: 150),
                      margin: const EdgeInsets.all(5),
                      child: FilterableList(
                          loading: _isLoading,
                          loader: _suggestionLoaderBuilder(),
                          items: _suggestions,
                          suggestionBuilder: widget.suggestionBuilder,
                          elevation: widget.suggestionsElevation,
                          suggestionTextStyle: widget.suggestionTextStyle,
                          suggestionBackgroundColor:
                              widget.suggestionBackgroundColor,
                          onItemTapped: (value) {
                            _searchController.value = TextEditingValue(
                                text: value,
                                selection: TextSelection.collapsed(
                                    offset: value.length));
                            if (widget.onSuggestionTap != null) {
                              widget.onSuggestionTap!(value);
                            }
                            widget.onSearch(value);
                            closeOverlay();
                          })))));
    }
    if (!_hasOpenedOverlay &&
        (widget.suggestions != null || widget.asyncSuggestions != null)) {
      Overlay.of(context)!.insert(_overlayEntry!);
      setState(() => _hasOpenedOverlay = true);
    }
  }

  void closeOverlay() {
    if (_hasOpenedOverlay) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      setState(() => _hasOpenedOverlay = false);
    }
  }

  void updateSyncSuggestions(String input) {
    _suggestions = widget.suggestions!.where((element) {
      return element.toLowerCase().contains(input.toLowerCase());
    }).toList();
    rebuildOverlay();
  }

  Future<void> updateAsyncSuggestions(String input) async {
    if (_debounce != null && _debounce!.isActive) {
      _debounce!.cancel();
    }
    setState(() => _isLoading = true);
    _debounce = Timer(widget.debounceDuration, () async {
      if (_previousAsyncSearchText != input ||
          _previousAsyncSearchText.isEmpty ||
          input.isEmpty) {
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
    if (_overlayEntry != null) {
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

    assert(widget.leading == null || !scaffold!.hasDrawer,
        'Cannot use leading with drawer');
    assert(widget.leading == null || !canPop,
        'Cannot use leading when back button exists');

    Color? backgroundColor = widget.backgroundColor ??
        appBarTheme.backgroundColor ??
        theme.primaryColor;

    Color? foregroundColor =
        widget.foregroundColor ?? appBarTheme.foregroundColor;

    Color? searchBackgroundColor = widget.searchBackgroundColor ??
        scaffold!.widget.backgroundColor ??
        theme.inputDecorationTheme.fillColor ??
        theme.scaffoldBackgroundColor;

    IconThemeData iconTheme = widget.iconTheme ??
        appBarTheme.iconTheme ??
        theme.iconTheme.copyWith(color: foregroundColor);

    TextStyle? titleTextStyle = widget.titleTextStyle ??
        appBarTheme.titleTextStyle ??
        theme.textTheme.headline6!.copyWith(color: foregroundColor);

    double? elevation = widget.elevation ?? appBarTheme.elevation ?? 5;

    Color cursorColor = widget.searchCursorColor ?? theme.primaryColor;

    TextStyle searchHintStyle = widget.searchHintStyle ??
        theme.inputDecorationTheme.hintStyle ??
        const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic);

    IconThemeData searchBackIconTheme = widget.searchBackIconTheme ??
        IconThemeData(size: 24, color: Theme.of(context).primaryColor);

    IconThemeData searchClearIconTheme = widget.searchClearIconTheme ??
        IconThemeData(size: 24, color: Theme.of(context).primaryColor);

    SystemUiOverlayStyle systemOverlayStyle = widget.systemOverlayStyle ??
        appBarTheme.systemOverlayStyle ??
        (theme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark);

    return CompositedTransformTarget(
        link: _layerLink,
        child: Semantics(
            container: true,
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: systemOverlayStyle,
              child: Material(
                color: backgroundColor,
                elevation: elevation,
                child: Semantics(
                  explicitChildNodes: true,
                  child: SafeArea(
                    child: LayoutBuilder(builder: (context, constraints) {
                      return Container(
                          margin: EdgeInsets.only(
                              top: widget.isFloating ? 5 : 0,
                              left: widget.isFloating ? 5 : 0,
                              right: widget.isFloating ? 5 : 0),
                          height: 66,
                          child: Material(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(
                                  widget.isFloating ? 5 : 0),
                              child: Stack(children: [
                                Container(
                                    height: widget.appBarHeight +
                                        (widget.isFloating ? 5 : 0),
                                    width: double.infinity,
                                    padding: const EdgeInsets.only(
                                        top: 10, left: 5, right: 3, bottom: 10),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Visibility(
                                              visible: scaffold!.hasDrawer,
                                              child: IconTheme(
                                                  data: iconTheme,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 10),
                                                    child: IconButton(
                                                        icon: const Icon(
                                                            Icons.menu),
                                                        onPressed: () =>
                                                            scaffold
                                                                .openDrawer(),
                                                        tooltip:
                                                            MaterialLocalizations
                                                                    .of(context)
                                                                .openAppDrawerTooltip),
                                                  )),
                                              replacement: Visibility(
                                                  visible: canPop,
                                                  child: IconTheme(
                                                    data: iconTheme,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10),
                                                      child: IconButton(
                                                          icon: const Icon(Icons
                                                              .arrow_back_outlined),
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context),
                                                          tooltip: MaterialLocalizations
                                                                  .of(context)
                                                              .backButtonTooltip),
                                                    ),
                                                  ),
                                                  replacement: Visibility(
                                                    visible:
                                                        widget.leading != null,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10),
                                                      child: widget.leading,
                                                    ),
                                                    replacement:
                                                        const SizedBox(),
                                                  ))),
                                          Expanded(
                                              child: Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 10),
                                                  child: DefaultTextStyle(
                                                    style: titleTextStyle,
                                                    softWrap: false,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    child: widget.title,
                                                  ))),
                                          ...List.generate(
                                              widget.actions.length + 1,
                                              (index) {
                                            if (widget.actions.length == index && !widget.putActionsOnRight || index == 0 && widget.putActionsOnRight) {
                                              return IconTheme(
                                                  data: iconTheme,
                                                  child: IconButton(
                                                      icon: const Icon(
                                                          Icons.search),
                                                      iconSize:
                                                          iconTheme.size ?? 24,
                                                      onPressed: () {
                                                        _controller.forward();
                                                        _focusNode
                                                            .requestFocus();

                                                        if (widget
                                                            .openOverlayOnSearch) {
                                                          openOverlay();
                                                        }
                                                      },
                                                      tooltip:
                                                          MaterialLocalizations
                                                                  .of(context)
                                                              .searchFieldLabel));
                                            }
                                            return IconTheme(
                                              data: iconTheme,
                                              child: widget.actions[widget.putActionsOnRight ? (index - 1) : index]
                                            );
                                          },
                                          //tooltip: MaterialLocalizations.of(context).searchFieldLabel
                                        )
                                        ])),
                                Positioned(
                                    right: 0,
                                    top: 0,
                                    child: AnimatedBuilder(
                                        animation: _controller,
                                        builder: (context, child) {
                                          return Container(
                                              alignment: Alignment.center,
                                              height: constraints.maxHeight -
                                                  (widget.isFloating ? 5 : 0),
                                              width: _containerSizeAnimation.value *
                                                      constraints.maxWidth -
                                                  (_containerSizeAnimation.value *
                                                      (widget.isFloating
                                                          ? 10
                                                          : 0)),
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.only(
                                                      bottomLeft: Radius.circular(
                                                          _containerBorderRadiusAnimation.value *
                                                                  30 +
                                                              (widget.isFloating
                                                                  ? 5
                                                                  : 0)),
                                                      topLeft: Radius.circular(
                                                          _containerBorderRadiusAnimation.value * 30 + (widget.isFloating ? 5 : 0)),
                                                      topRight: Radius.circular(widget.isFloating ? 5 : 0),
                                                      bottomRight: Radius.circular(widget.isFloating ? 5 : 0)),
                                                  color: searchBackgroundColor),
                                              child: Opacity(
                                                  opacity: _textFieldOpacityAnimation.value,
                                                  child:Directionality(
                                                    textDirection: widget.searchTextDirection,
                                                    child: TextField(
                                                        onSubmitted: (value) {
                                                          widget.onSearch(
                                                              _searchController
                                                                  .text);
                                                          _focusNode.unfocus();
                                                          closeOverlay();
                                                        },
                                                        maxLines: 1,
                                                        controller: _searchController,
                                                        textInputAction: TextInputAction.search,
                                                        cursorColor: cursorColor,
                                                        focusNode: _focusNode,
                                                        textAlignVertical: TextAlignVertical.center,
                                                        style: widget.searchTextStyle,
                                                        keyboardType: widget.searchTextKeyboardType,
                                                        decoration: InputDecoration(
                                                            contentPadding: const EdgeInsets.only(left: 20, right: 10),
                                                            fillColor: searchBackgroundColor,
                                                            filled: true,
                                                            hintText: widget.searchHintText,
                                                            hintMaxLines: 1,
                                                            hintStyle: searchHintStyle,
                                                            border: InputBorder.none,
                                                            prefixIcon: IconTheme(
                                                                data: searchBackIconTheme,
                                                                child: IconButton(
                                                                    icon: const Icon(Icons.arrow_back_outlined),
                                                                    onPressed: () {
                                                                      _controller
                                                                          .reverse();
                                                                      _searchController
                                                                          .clear();
                                                                      widget.onSearch(
                                                                          _searchController
                                                                              .text);
                                                                      _focusNode
                                                                          .unfocus();
                                                                      closeOverlay();
                                                                    })),
                                                            suffixIcon: IconTheme(
                                                                data: searchClearIconTheme,
                                                                child: IconButton(
                                                                    icon: const Icon(Icons.close_rounded),
                                                                    onPressed: () {
                                                                      _searchController
                                                                        .clear();
                                                                      widget.onSearch(_searchController.text);
                                                                    })))),
                                                  )));
                                        }))
                              ])));
                    }),
                  ),
                ),
              ),
            )));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
