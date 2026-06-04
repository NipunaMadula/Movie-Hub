import 'package:flutter/material.dart';
// Removed advanced search and settings actions per user request
import '../screens/favorites_screen.dart';
import '../utils/page_transitions.dart';

class QuickActionsWidget extends StatefulWidget {
  const QuickActionsWidget({Key? key}) : super(key: key);

  @override
  _QuickActionsWidgetState createState() => _QuickActionsWidgetState();
}

class _QuickActionsWidgetState extends State<QuickActionsWidget> {

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [

        // (advanced search & settings buttons removed)
        // Favorites Button (aligned with AppBar favorite)
        Container(
          width: 56,
          height: 56,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: () {
                Navigator.push(
                  context,
                  SlidePageRoute(child: FavoritesScreen(), beginOffset: const Offset(1.0, 0.0)),
                );
              },
              child: Center(
                child: Hero(
                  tag: 'favorites-icon',
                  child: Icon(Icons.favorite, size: 20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
