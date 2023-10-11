import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum WordStatus { correct, incorrect, mid }

class CardProvider extends ChangeNotifier {
  List<String> _words = [];
  List<String> _paths = [];
  List<String> _imagePaths = [];
  Offset _position = Offset.zero;
  double _angle = 0;
  bool _isDragging = false;
  Size _screenSize = Size.zero;
  bool _areCardsLeft = true;

  List<String> get words => _words;
  List<String> get paths => _paths;
  List<String> get imagePaths => _imagePaths;
  Offset get position => _position;
  bool get isDragging => _isDragging;
  double get angle => _angle;
  bool get areCardsLeft => _areCardsLeft;

  CardProvider() {
    resetWords();
  }

  void setScreenSize(Size screenSize) {
    _screenSize = screenSize;
  }

  void startPosition(DragStartDetails details) {
    _isDragging = true;
    notifyListeners();

    print('Start Position ${details.globalPosition}');
  }

  void updatePosition(DragUpdateDetails details) {
    _position += details.delta;

    final x = _position.dx;
    _angle = 10 * x / _screenSize.width;

    notifyListeners();

    print('Update Position ${details.globalPosition}');
  }

  void endPosition(DragEndDetails details) {
    _isDragging = false;

    final status = getStatus();

    if (status != null) {
      Fluttertoast.cancel();
      Fluttertoast.showToast(
        msg: status.toString().split('.').last.toUpperCase(),
      );
    }

    switch (status) {
      case WordStatus.correct:
        correctSwipe();
        break;
      case WordStatus.incorrect:
        incorrectSwipe();
        break;
      case WordStatus.mid:
        midSwipe();
        break;
      default:
        resetPosition();
    }

    // resetPosition();

    print('End Position velocity ${details.velocity}');
  }

  void resetPosition() {
    _isDragging = false;
    _position = Offset.zero;
    _angle = 0;
    notifyListeners();
  }

  WordStatus? getStatus() {
    final x = _position.dx;
    final y = _position.dy;
    final forceMid = x.abs() < 20;
    const delta = 200;

    // print('x: $x, delta: $delta');
    if (x >= delta) {
      return WordStatus.correct;
    } else if (x <= -delta) {
      return WordStatus.incorrect;
    } else if (y <= -delta / 2 && forceMid) {
      return WordStatus.mid;
    }
  }

  // iPhone 14 Pro _screenSize: Size(393.0, 852.0)
  void correctSwipe() {
    _angle = 20;
    print(_position);
    _position += Offset(_screenSize.width, 0);
    print(_position);
    _nextCard();

    notifyListeners();
  }

  void incorrectSwipe() {
    _angle = -20;
    _position -= Offset(_screenSize.width, 0);
    _nextCard();
    notifyListeners();
  }

  void midSwipe() {
    _angle = 0;
    _position -= Offset(0, _screenSize.height);
    _nextCard();
    notifyListeners();
  }

  Future _nextCard() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _words.removeLast();
    _paths.removeLast();
    _imagePaths.removeLast();
    if (_words.isEmpty) _areCardsLeft = false;
    resetPosition();
  }

  void resetWords() {
    _words = <String>[
      'Piłka',
      'Czapka',
      'Czepek',
      'Książka',
      'Ksiądz',
      'Księżniczka',
      'Księga'
    ].reversed.toList();

    _paths = <String>[
      'assets/exampleAudios/pilka.mp3',
      'assets/exampleAudios/czapka.mp3',
      'assets/exampleAudios/czepek.mp3',
      'assets/exampleAudios/ksiazka.mp3',
      'assets/exampleAudios/ksiadz.mp3',
      'assets/exampleAudios/ksiezniczka.mp3',
      'assets/exampleAudios/ksiega.mp3'
    ].reversed.toList();

    _imagePaths = <String>[
      'assets/exampleImages/pilka.jpeg',
      'assets/exampleImages/czapka.jpeg',
      'assets/exampleImages/czepek.jpeg',
      'assets/exampleImages/ksiazka.jpeg',
      'assets/exampleImages/ksiadz.jpeg',
      'assets/exampleImages/ksiezniczka.jpeg',
      'assets/exampleImages/ksiega.jpeg'
    ].reversed.toList();

    notifyListeners();
  }
}