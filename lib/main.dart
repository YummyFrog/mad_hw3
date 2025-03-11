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
  List<List<bool>> _cards = List.generate(4, (_) => List.filled(4, false)); // 4x4 grid of cards

  void _startTimer() {
    setState(() {
      _isTimerRunning = true;
      _isGameOver = false;
      _timerSeconds = 180; // Reset timer
      _cards = List.generate(4, (_) => List.filled(4, false)); // Reset cards
    });

    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_timerSeconds == 0 || _areAllCardsGreen()) {
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

  void _goToHomeScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => GameScreen()),
    );
  }

  bool _areAllCardsGreen() {
    for (var row in _cards) {
      if (row.contains(false)) {
        return false;
      }
    }
    return true;
  }

  void _toggleCard(int row, int col) {
    setState(() {
      _cards[row][col] = !_cards[row][col];
    });

    // Check if all cards are green
    if (_areAllCardsGreen()) {
      _timer.cancel();
      setState(() {
        _isTimerRunning = false;
        _isGameOver = true;
      });
    }
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
            if (_isTimerRunning || _isGameOver)
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // 4x4 grid
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 16,
                  itemBuilder: (context, index) {
                    int row = index ~/ 4;
                    int col = index % 4;
                    return GestureDetector(
                      onTap: () => _toggleCard(row, col),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _cards[row][col] ? Colors.green : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${row + 1}-${col + 1}',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (_isGameOver)
              Column(
                children: [
                  Text(
                    _areAllCardsGreen() ? 'You Win!' : 'Game Over!',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20), // Space between text and button
                  ElevatedButton(
                    onPressed: _goToHomeScreen,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20), // Bigger button
                      textStyle: TextStyle(fontSize: 24), // Bigger text
                    ),
                    child: Text('Try Again'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}