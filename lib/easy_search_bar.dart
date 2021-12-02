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

class EasySearchBar extends StatefulWidget {
  /// The title to be displayed inside appBar
  final String title;
  /// Returns the current search value
  /// When search is closed, this method returns an empty value to clear the current search
  final Function(String) onSearch;
  /// Executes extra actions when search is closed
  final Function? onClose;
  /// Centers the appBar title
  final bool centerTitle;
  /// Duration for the appBar search show and hide
  final Duration animationDuration;
  /// Sets custom input decoration for the search TextField
  final InputDecoration inputDecoration;
  /// Sets custom style for the search TextField search text
  final TextStyle inputTextStyle;
  /// Sets custom title style
  final TextStyle titleStyle;
  /// Sets custom cursor color
  final Color? cursorColor;

  /// Creates a widget that can be used to manage search inside your application
  EasySearchBar({
    required this.title,
    required this.onSearch,
    this.onClose,
    this.centerTitle = false,
    this.animationDuration = const Duration(milliseconds: 350),
    this.inputDecoration = const InputDecoration(
      border: InputBorder.none
    ),
    this.inputTextStyle = const TextStyle(
      color: Colors.white,
      fontStyle: FontStyle.italic
    ),
    this.titleStyle = const TextStyle(
      color: Colors.white
    ),
    this.cursorColor
  });

  @override
  _EasySearchBarState createState() => _EasySearchBarState();
}

class _EasySearchBarState extends State<EasySearchBar> with SingleTickerProviderStateMixin {
  bool _searchOpened = false;
  late Widget _animatedIcon;
  late TextField _textField;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animatedIcon = Icon(
      Icons.search,
      key: ValueKey('search')
    );
  }

  void _onButtonPressed() {
    setState(() {
      _searchOpened = !_searchOpened;
    });
    if (_searchOpened) {
      setState(() {
        _animatedIcon = Icon(
          Icons.close,
          key: ValueKey('close_icon')
        );
      });
    }
    else {
      setState(() {
        _animatedIcon = Icon(Icons.search, key: ValueKey('search_icon'));
        _textEditingController.text = '';
        widget.onSearch('');
        if (widget.onClose != null) widget.onClose!();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: AnimatedCrossFade(
            duration: widget.animationDuration,
            reverseDuration: widget.animationDuration,
            firstChild: Align(
              alignment: widget.centerTitle ? Alignment.center : Alignment.centerLeft,
              child: Text(
                widget.title,
                textAlign: TextAlign.end,
                style: widget.titleStyle
              )
            ),
            secondChild: TextField(
              controller: _textEditingController,
              cursorColor: widget.cursorColor ?? Colors.white,
              autofocus: true,
              decoration: widget.inputDecoration,
              style: widget.inputTextStyle,
              onChanged:  (value) => widget.onSearch(value)
            ),
            crossFadeState: _searchOpened ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          )
        ),
        IconButton(
          icon: AnimatedSwitcher(
            duration: widget.animationDuration,
            child: _animatedIcon,
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: child
              );
            }
          ),
          onPressed: () => _onButtonPressed()
        )
      ]
    );
  }
}