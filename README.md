# Easy Search Bar

<a href="https://www.buymeacoffee.com/4inka" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-violet.png" alt="Buy Me A Pizza" style="height: 60px !important;width: 217px !important;" ></a>

A Flutter plugin to help you handle search inside your application. Can be used inside appBar or inside your application body depending on your necessities.

## Preview
![Preview](https://raw.githubusercontent.com/4inka/flutter_easy_search_bar/main/preview/preview.gif)
![Preview](https://raw.githubusercontent.com/4inka/flutter_easy_search_bar/main/preview/preview2.gif)

## Installation

In the `pubspec.yaml` of your flutter project, add the following dependency:

``` yaml
dependencies:
  ...
  easy_search_bar: ^2.0.0
```

## Migrating from 1.x.x to 2.0.0

Now instead of using the EasySearchBar widget inside AppBar widget, you can replace the AppBar with it.

This is what you used before:

``` dart
Scaffold(
  appBar: AppBar(
    title: EasySearchBar(
      title: 'Example',
      onSearch: (value) => setState(() => searchValue = value)
    )
  )
)
```

And this is what it is supposed to look like now:

``` dart
Scaffold(
  appBar: EasySearchBar(
    title: Text('Example'),
    onSearch: (value) => setState(() => searchValue = value)
  )
)
```

## Basic example with suggestions

You can create a simple searchbar example widget with suggestions with the following example:

``` dart
import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyHomePage());
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String searchValue = '';
  final List<String> _suggestions = ['Afeganistan', 'Albania', 'Algeria', 'Australia', 'Brazil', 'German', 'Madagascar', 'Mozambique', 'Portugal', 'Zambia'];

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Example',
      theme: ThemeData(
        primarySwatch: Colors.orange
      ),
      home: Scaffold(
        appBar: EasySearchBar(
          title: const Text('Example'),
          onSearch: (value) => setState(() => searchValue = value),
          suggestions: _suggestions
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text('Drawer Header'),
              ),
              ListTile(
                title: const Text('Item 1'),
                onTap: () => Navigator.pop(context)
              ),
              ListTile(
                title: const Text('Item 2'),
                onTap: () => Navigator.pop(context)
              )
            ]
          )
        ),
        body: Center(
          child: Text('Value: $searchValue')
        )
      )
    );
  }
}
```

*Note:* If you want to create a FloatingAppBar and want the body content to go behing the AppBar you need to set `extendBodyBehindAppBar` Scaffold property to true. And it's also recommended to wrap your Scaffold inside a SafeArea.

## API
| Attribute | Type | Required | Description | Default value |
|:---|:---|:---:|:---|:---|
| title | `Widget` | :heavy_check_mark: | The title to be displayed inside AppBar |  |
| onSearch | `Function(String)` | :heavy_check_mark: | Returns the current search value.When search is closed, this method returns an empty value to clear the current search |  |
| actions | `List<Widget>` | :x: | Extra custom actions that can be displayed inside AppBar |  |
| backgroundColor | `Color` | :x: | Can be used to change AppBar background color |  |
| foregroundColor | `Color` | :x: | Can be used to change AppBar foreground color |  |
| elevation | `double` | :x: | Can be used to change AppBar elevation | 5 |
| iconTheme | `IconThemeData` | :x: | Can be used to set custom icon theme for AppBar icons |  |
| appBarHeight | `double` | :x: | Can be used to change AppBar height | 56 |
| animationDuration | `Duration` | :x: | Can be used to set a duration for the AppBar search show and hide animation | Duration(milliseconds: 450) |
| isFloating | `bool` | :x: | Can be used to determine if it will be a normal or floating AppBar | false |
| titleTextStyle | `TextStyle` | :x: | Can be used to set the AppBar title style |  |
| searchCursorColor | `Color` | :x: | Can be used to set search textfield cursor color |  |
| searchHintText | `String` | :x: | Can be used to set search textfield hint text |  |
| searchHintStyle | `TextStyle` | :x: | Can be used to set search textfield hint style |  |
| searchTextStyle | `TextStyle` | :x: | Can be used to set search textfield text style |  |
| searchBackIconTheme | `IconThemeData` | :x: | Can be used to set custom icon theme for the search textfield back button |  |
| suggestions | `List<String>` | :x: | Can be used to create a suggestions list |  |
| asyncSuggestions | `Future<List<String>> Function(String value)` | :x: | Can be used to set async suggestions list |  |
| suggestionsElevation | `double` | :x: | Can be used to change suggestion list elevation |  |
| suggestionLoaderBuilder | `Widget Function()` | :x: | A function that can be used to create a widget to display a custom suggestions loader |  |
| suggestionTextStyle | `TextStyle` | :x: | Can be used to change the suggestions text style |  |
| suggestionBackgroundColor | `Color` | :x: | Can be used to change suggestions list background color |  |
| suggestionBuilder | `Widget Function(String data)` | :x: | Can be used to create custom suggestion item widget |  |
| onSuggestionTap | `Function(String data)` | :x: | Instead of using the default suggestion tap action that fills the textfield, you can set your own custom action for it |  |
| debounceDuration | `Duration` | :x: | Can be used to set the debounce time for async data fetch |  |

## Issues & Suggestions
If you encounter any issue you or want to leave a suggestion you can do it by filling an [issue](https://github.com/4inka/flutter_easy_search_bar/issues).

### Thank you for the support!
