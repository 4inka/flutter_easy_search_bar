# Easy Search Bar

<a href="https://www.buymeacoffee.com/4inka" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-violet.png" alt="Buy Me A Pizza" style="height: 60px !important;width: 217px !important;" ></a>


A Flutter plugin to help you handle search inside your application. Can be used inside appBar or inside your application body depending on your necessities.

## Preview
![Preview](https://raw.githubusercontent.com/4inka/flutter_easy_search_bar/main/preview/preview.gif)

## Usage

In the `pubspec.yaml` of your flutter project, add the following dependency:

``` yaml
dependencies:
  ...
  easy_search_bar: ^2.0.0
```

You can create a simple searchbar widget with the following example:

``` dart
import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyHomePage());
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String searchValue = '';

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Example',
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      home: Scaffold(
        appBar: AppBar(
          title: EasySearchBar(
            title: 'Example',
            onSearch: (value) => setState(() => searchValue = value)
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

## API
| Attribute | Type | Required | Description | Default value |
|:---|:---|:---:|:---|:---|
| title | `String` | :heavy_check_mark: | The title to be displayed inside appBar |  |
| onSearch | `Function(String)` | :heavy_check_mark: | Returns the current search value<br/>When search is closed, this method returns an empty value to clear the current search |  |
| onClose | `Function` | :x: | Executes extra actions when search is closed |  |
| centerTitle | `bool` | :x: | Centers the appBar title | false |
| animationDuration | `Duration` | :x: | Duration for the appBar search show and hide | Duration(milliseconds: 350) |
| inputDecoration | `InputDecoration` | :x: | Sets custom input decoration for the search TextField | InputDecoration( border: InputBorder.none ) |
| inputTextStyle | `TextStyle` | :x: | Sets custom style for the search TextField search text | TextStyle( color: Colors.white, fontStyle: FontStyle.italic ) |
| titleStyle | `TextStyle` | :x: | Sets custom title style | TextStyle( color: Colors.white ) |
| cursorColor | `Color` | :x: | Sets custom cursor color | Colors.white |

## Issues & Suggestions
If you encounter any issue you or want to leave a suggestion you can do it by filling an [issue](https://github.com/4inka/flutter_easy_search_bar/issues).

### Thank you for the support!
