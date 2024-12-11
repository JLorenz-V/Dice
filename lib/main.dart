import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Dice Application'),
          backgroundColor: Color(0XFF453d36),
        ),
        body: DicePage(),
      ),
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFFedd1b4),
      ),
    ),
  );
}

class DicePage extends StatefulWidget {
  @override
  State<DicePage> createState() => _DicePageState();
}

class _DicePageState extends State<DicePage> with TickerProviderStateMixin {
  int left = 1;
  int right = 1;
  String message = "Shake the phone or tap the dice to roll";
  bool shakeCooldown = false;

  // Accelerometer values to detect shake motion
  double x = 0, y = 0, z = 0;

  // Animation Controllers for dice movement
  late AnimationController _leftDiceController;
  late AnimationController _rightDiceController;

  late Animation<Offset> _leftDiceAnimation;
  late Animation<Offset> _rightDiceAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controllers
    _leftDiceController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _rightDiceController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    // Define animations for the dice movement
    _leftDiceAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, 0.1), // slight bounce effect
    ).animate(CurvedAnimation(
      parent: _leftDiceController,
      curve: Curves.elasticOut,
    ));

    _rightDiceAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, 0.1),
    ).animate(CurvedAnimation(
      parent: _rightDiceController,
      curve: Curves.elasticOut,
    ));

    // Listen to accelerometer sensor
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        x = event.x;
        y = event.y;
        z = event.z;

        // Compute magnitude of acceleration
        double magnitude = sqrt(x * x + y * y + z * z);

        // Debugging: Print values to console
        print('Accelerometer readings: x=$x, y=$y, z=$z, magnitude=$magnitude');

        // Simple shake detection logic
        if (magnitude > 12 && !shakeCooldown) {
          shakeCooldown = true;
          message = "Shake detected!";
          ChangeValue(); // Roll both dice on shake

          // Add a cooldown of 1 second before allowing another shake detection
          Future.delayed(Duration(seconds: 1), () {
            shakeCooldown = false;
          });
        }
      });
    });
  }

  // Method to change dice values
  void ChangeValue({String? dice}) {
    setState(() {
      if (dice == "left") {
        left = 1 + Random().nextInt(6);
        _leftDiceController.forward(from: 0); // Play animation for left dice
      } else if (dice == "right") {
        right = 1 + Random().nextInt(6);
        _rightDiceController.forward(from: 0); // Play animation for right dice
      } else {
        // Roll both dice (for shake)
        left = 1 + Random().nextInt(6);
        right = 1 + Random().nextInt(6);
        _leftDiceController.forward(from: 0);
        _rightDiceController.forward(from: 0);
      }
      message = "Shake the phone or tap the dice to roll!";
    });
  }

  @override
  void dispose() {
    // Dispose the controllers when not needed
    _leftDiceController.dispose();
    _rightDiceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      ChangeValue(dice: "left"); // Roll left dice only
                    },
                    child: SlideTransition(
                      position: _leftDiceAnimation, // Apply animation to left dice
                      child: Image.asset('images/dice$left.png'),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      ChangeValue(dice: "right"); // Roll right dice only
                    },
                    child: SlideTransition(
                      position: _rightDiceAnimation, // Apply animation to right dice
                      child: Image.asset('images/dice$right.png'),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            'The total roll is ${left + right}',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          Text(
            '${left > right ? "Left" : "Right"} dice has the higher roll',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
