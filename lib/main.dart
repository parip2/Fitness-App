import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'vision_detector_views/bench_detector_view.dart';
import 'vision_detector_views/biceps_detector_view.dart';
import 'vision_detector_views/pushup_detector_view.dart';
import 'vision_detector_views/squat_detector_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WakelockPlus.enable();
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

  final Map<String, Widget> exerciseViews = {
    'Curls': BicepsDetectorView(),
    'Push up': PushupDetectorView(),
    'Squat': SquatDetectorView(),
    'Bench': BenchDetectorView(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Choose your exercise',
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
              height: 80, // Reduced height since we only need one line
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.transparent,
                  width: 0.8,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row( // Changed from Wrap to Row
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute buttons evenly
                children: exerciseViews.entries.map((entry) => 
                  Expanded( // Added Expanded to give equal width to all buttons
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _buildExerciseButton(context, entry.key, entry.value),
                    ),
                  ),
                ).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseButton(BuildContext context, String exerciseName, Widget detectorView) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => detectorView),
        );
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16), // Reduced horizontal padding
        backgroundColor: Color(0xFF373856),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: textColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: FittedBox( // Added FittedBox to ensure text fits
        fit: BoxFit.scaleDown,
        child: Text(
          exerciseName,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}