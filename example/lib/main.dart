import 'package:flutter/material.dart';
import 'package:flutter_grid_delegate_ext/flutter_grid_delegate_ext.dart';

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isFirstCellBig = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () => setState(() {_isFirstCellBig = !_isFirstCellBig;}),
      child: Material(
        child: GridView.builder(
            gridDelegate: XSliverGridDelegate(
                crossAxisCount: 3,
                smallCellExtent: 100,
                bigCellExtent: 200,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
                isFirstCellBig: _isFirstCellBig
            ),
            itemCount: 500,
            itemBuilder: (context, index){
              return Container(
                  color: color[index % 10],
                  alignment: Alignment.center,
                  child: Text("${index+1}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))
              );
            }
        ),
      ),
    );
  }

  List<Color> color = [
    Color(0xFF00a8b5),
    Color(0xFF774898),
    Color(0xFFe62a76),
    Color(0xFFfbb901),
    Color(0xFFff5d5d),
    Color(0xFF952e4b),
    Color(0xFF6b76ff),
    Color(0xFF43c0ac),
    Color(0xFFa93199),
    Color(0xFFff9280),
    Color(0xFFff2400),
    Color(0xFF45315d),
  ];
}

