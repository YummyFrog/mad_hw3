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

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  bool _isTimerRunning = false;
  bool _isGameOver = false;
  int _timerSeconds = 180;
  late Timer _timer;
  int _startTime = 0; // Track when the game started
  int _finishTime = 0; // Track when the game finished

  // List of card values (pairs of numbers)
  List<int> _cardValues = [1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8];
  List<bool> _cardRevealed = List.filled(16, false); // Track if cards are revealed
  List<bool> _cardMatched = List.filled(16, false); // Track if cards are matched
  List<int> _selectedIndices = []; // Track currently selected card indices

  // Animation controllers for each card
  List<AnimationController> _controllers = [];
  List<Animation<double>> _animations = [];

  @override
  void initState() {
    super.initState();
    _cardValues.shuffle(); // Shuffle the card values

    for (int i = 0; i < 16; i++) {
      _controllers.add(AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500), // Animation duration
      ));

      _animations.add(Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controllers[i],
          curve: Curves.easeInOut,
        ),
      ));
    }
  }

  void _startTimer() {
    setState(() {
      _isTimerRunning = true;
      _isGameOver = false;
      _timerSeconds = 180;
      _startTime = DateTime.now().millisecondsSinceEpoch;
      _cardRevealed = List.filled(16, false); // Reset revealed cards
      _cardMatched = List.filled(16, false); // Reset matched cards
      _selectedIndices = [];
      _cardValues.shuffle();
    });

    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_timerSeconds == 0 || _areAllCardsMatched()) {
          setState(() {
            timer.cancel();
            _isTimerRunning = false;
            _isGameOver = true;
            _finishTime = DateTime.now().millisecondsSinceEpoch;
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

  bool _areAllCardsMatched() {
    return !_cardMatched.contains(false);
  }

  void _onCardPressed(int index) {
    if (_selectedIndices.length == 2 || _cardRevealed[index] || _cardMatched[index]) {
      return;
    }

    setState(() {
      _cardRevealed[index] = true; // Reveal the card
      _selectedIndices.add(index); // Add the card to the selected list
    });

    _controllers[index].reset();
    _controllers[index].forward();

    if (_selectedIndices.length == 2) {
      // Check if the two selected cards match
      if (_cardValues[_selectedIndices[0]] == _cardValues[_selectedIndices[1]]) {
        // Match found
        setState(() {
          _cardMatched[_selectedIndices[0]] = true;
          _cardMatched[_selectedIndices[1]] = true;
        });
        _selectedIndices.clear();
      } else {
        Future.delayed(Duration(milliseconds: 1000), () {
          setState(() {
            _cardRevealed[_selectedIndices[0]] = false;
            _cardRevealed[_selectedIndices[1]] = false;
            _selectedIndices.clear();
          });
          _controllers[_selectedIndices[0]].reverse();
          _controllers[_selectedIndices[1]].reverse();
        });
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int timeTaken = (_finishTime - _startTime) ~/ 1000;

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
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  textStyle: TextStyle(fontSize: 24),
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
                    return GestureDetector(
                      onTap: () => _onCardPressed(index),
                      child: AnimatedBuilder(
                        animation: _animations[index],
                        builder: (context, child) {
                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(_animations[index].value * 3.14159),
                            alignment: Alignment.center,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _cardMatched[index]
                                    ? Colors.green
                                    : (_cardRevealed[index] ? Colors.orange : Colors.grey[300]),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: _cardRevealed[index] || _cardMatched[index]
                                    ? Transform(
                                        transform: Matrix4.identity()
                                          ..rotateY(_animations[index].value * 3.14159), // Counter-rotate the text
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${_cardValues[index]}',
                                          style: TextStyle(fontSize: 24, color: Colors.black),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            if (_isGameOver)
              Column(
                children: [
                  Text(
                    _areAllCardsMatched()
                        ? 'You finished in $timeTaken seconds!'
                        : 'Game Over!',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _goToHomeScreen,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      textStyle: TextStyle(fontSize: 24), 
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