import 'package:flutter/material.dart';
import 'dart:async'; // For Timer

void main() {
  runApp(MyGameApp());
}

class MyGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _isTimerRunning = false;
  bool _isGameOver = false;
  int _timerSeconds = 180; // 3 minutes in seconds
  late Timer _timer;

  void _startTimer() {
    setState(() {
      _isTimerRunning = true;
      _isGameOver = false;
    });

    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_timerSeconds == 0) {
          setState(() {
            timer.cancel();
            _isTimerRunning = false;
            _isGameOver = true;
          });
        } else {
          setState(() {
            _timerSeconds--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Game'),
        actions: [
          if (_isTimerRunning || _isGameOver)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  _isGameOver ? 'Game Over' : 'Time: $_timerSeconds',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (!_isTimerRunning && !_isGameOver)
              ElevatedButton(
                onPressed: _startTimer,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20), // Bigger button
                  textStyle: TextStyle(fontSize: 24), // Bigger text
                ),
                child: Text('Play'),
              ),
            if (_isGameOver)
              Text(
                'Game Over!',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}