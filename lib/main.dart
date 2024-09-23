import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'ping_pong_game.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ping Pong Game',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            // Pass BuildContext to the GameWidget
            return GameWidget(game: PingPongGame(context));
          },
        ),
      ),
    );
  }
}
