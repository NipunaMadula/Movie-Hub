import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRatingService {
  static const String _ratingShownKey = 'rating_dialog_shown';
  static const String _appOpenCountKey = 'app_open_count';
  static const int _openCountThreshold = 5;

  static Future<void> checkAndShowRating(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    
    final bool ratingShown = prefs.getBool(_ratingShownKey) ?? false;
    final int openCount = prefs.getInt(_appOpenCountKey) ?? 0;
    
    // Increment open count
    await prefs.setInt(_appOpenCountKey, openCount + 1);
    
    // Show rating dialog if conditions are met
    if (!ratingShown && openCount >= _openCountThreshold) {
      _showRatingDialog(context);
      await prefs.setBool(_ratingShownKey, true);
    }
  }

  static void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 28),
              SizedBox(width: 8),
              Text('Rate Movie Hub'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you enjoying Movie Hub? Please take a moment to rate us!',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 30,
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Not Now',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showThankYouDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Rate Now'),
            ),
          ],
        );
      },
    );
  }

  static void _showThankYouDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.favorite, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text('Thank You!'),
            ],
          ),
          content: Text(
            'Thank you for using Movie Hub! Your feedback helps us improve.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  // Force show rating dialog (for testing or manual trigger)
  static void showRatingDialog(BuildContext context) {
    _showRatingDialog(context);
  }
}
