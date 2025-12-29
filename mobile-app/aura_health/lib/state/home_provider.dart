import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

enum BottomNavigator { HOME, HISTORY, INSIGHT, PROFILE }

class BottomProvider extends Notifier<BottomNavigator> {
  @override
  BottomNavigator build() {
    // TODO: implement build
    return BottomNavigator.HOME;
  }

  void goToNextScreen(BottomNavigator nav) {
    state = nav;
  }


}

final bottomProvider = NotifierProvider<BottomProvider, BottomNavigator>(
  () => BottomProvider(),
);
