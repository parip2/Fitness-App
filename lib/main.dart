import 'dart:io';

import 'package:flutter/material.dart';
import 'vision_detector_views/pose_detector_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF23253C),
        primarySwatch: Colors.blue,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          elevation: 0,
        ),
      ),
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  final Color textColor = Color(0xFFFF5F05);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Pose detector portion',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: textColor,
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(0),
        child: ClipRRect(
          borderRadius: BorderRadiusDirectional.circular(24),
          child: BottomAppBar(
            color: Color(0xFF373856),
            elevation: 8,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: textColor.withOpacity(0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PoseDetectorView()),
                      );
                    },
                    icon: Icon(
                      Icons.visibility,
                      color: textColor,
                    ),
                    label: Text(
                      'Pose Detection',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}