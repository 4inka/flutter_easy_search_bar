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
          isFloating: false,
          onSearch: (value) => setState(() => searchValue = value),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.person,
              ),
              onPressed: () {},
            )
          ],
          suggestions: const [
            'Suggestion 1',
            'Suggestion 2',
            'Suggestion 3',
            'Suggestion 4',
            'Suggestion 5',
            'Suggestion 6',
            'Suggestion 7',
            'Suggestion 8',
            'Suggestion 9',
            'Suggestion 10'
          ]
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
