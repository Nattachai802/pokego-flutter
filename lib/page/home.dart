import 'package:flutter/material.dart';
import 'package:pokego/page/detail.dart';
import 'package:pokego/page/playerselection.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String _imagePath = 'images/logo.jpg';

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    // create and push new instance of Detail page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Detail()),
    );
  }

  void setImagePath(String path) {
    setState(() {
      _imagePath = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('build MyHomePage: $_counter, $_imagePath');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(
              height: 200,
              width:  200,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context,MaterialPageRoute(builder: (ctx) => const PlayerSelection()));
                },
                child: const Text('Go to player selection page'),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Hero(
          tag: 'logoHero',
          child: Image(image: AssetImage('images/logo.jpg'), width: 200, height: 200),
        ),
      ),
    );
  }
}
