import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'modal.dart';

void main() => runApp(MyApp());

const simpleTaskKey = "simpleTask";
const simpleDelayedTask = "simpleDelayedTask";
const simplePeriodicTask = "simplePeriodicTask";
const simplePeriodic1HourTask = "simplePeriodic1HourTask";

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    switch (task) {
      case simplePeriodicTask:
      {
        print("HEY ITS A PERIODIC TASK!!");
        FlutterRingtonePlayer.playRingtone(volume: 15.0, looping: false);
        await new Future.delayed(const Duration(seconds : 10));        
        FlutterRingtonePlayer.stop();
        //Navigator.pushNamed(context, '/second');
        developer.log("$simplePeriodicTask was executed");
        break;
      }

      case Workmanager.iOSBackgroundTask:
        developer.log("The iOS background fetch was triggered");
        break;
    }

    return Future.value(true);
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

enum _Platform { android, ios }

class PlatformEnabledButton extends RaisedButton {
  final _Platform platform;

  PlatformEnabledButton({
    this.platform,
    @required Widget child,
    @required VoidCallback onPressed,
  })  : assert(child != null, onPressed != null),
        super(
            child: child,
            onPressed: (Platform.isAndroid && platform == _Platform.android ||
                    Platform.isIOS && platform == _Platform.ios)
                ? onPressed
                : null);
}

class FirstPage extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Alarm teste"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text("Plugin initialization",
                  style: Theme.of(context).textTheme.headline),
              RaisedButton(
                  child: Text("Start the Flutter background service"),
                  onPressed: () {
                    Workmanager.initialize(
                      callbackDispatcher,
                      isInDebugMode: true,
                    );
                  }),
              Text("Periodic Tasks (Android only)",
                  style: Theme.of(context).textTheme.headline),
              //This task runs periodically
              //It will wait at least 10 seconds before its first launch
              //Since we have not provided a frequency it will be the default 15 minutes
              PlatformEnabledButton(
                  platform: _Platform.android,
                  child: Text("Register Periodic Task"),
                  onPressed: () {
                    Workmanager.registerPeriodicTask(
                      "3",
                      simplePeriodicTask,
                      initialDelay: Duration(seconds: 10),
                    );
                    Navigator.pushNamed(context, '/second');
                  }),
              PlatformEnabledButton(
                platform: _Platform.android,
                child: Text("Cancel All"),
                onPressed: () async {
                  await Workmanager.cancelAll();
                  developer.log('Cancel all tasks completed');
                },
              ),
            ],
          ),
        ),
      );
  }
}


class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/second': (context) => Modal(),
      },
      home: FirstPage(),
    );
  }
}
