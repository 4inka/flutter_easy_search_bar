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

import 'package:flutter/material.dart';

class EasySearchBar extends StatefulWidget implements PreferredSizeWidget {
  final Color? foregroundColor;
  final double toolbarHeight;
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
    _controller.forward();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      widget.onSearch(_searchController.text);
    });
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

    return SafeArea(
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
                      left: 10,
                      right: 10,
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
                          child: DefaultTextStyle(
                            style: titleTextStyle!,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            child: widget.title,
                          )
                        ),
                        ...List.generate(widget.actions.length + 1, (index) {
                          if (widget.actions.length == index) {
                            return IconButton(
                              icon: const Icon(Icons.search),
                              iconSize: overallIconTheme.size ?? 24,
                              onPressed: () => _controller.forward(),
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
                              bottomLeft: Radius.circular((50 * _containerBorderRadiusAnimation.value).toDouble()),
                              topLeft: Radius.circular((50 * _containerBorderRadiusAnimation.value).toDouble()),
                            ),
                            color: Colors.white
                          ),
                          child: Opacity(
                            opacity: _textfieldOpacityAnimation.value,
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                suffixIcon: IconButton(
                                  color: Colors.red,
                                  icon: const Icon(
                                    Icons.close
                                  ),
                                  onPressed: () {
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
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
