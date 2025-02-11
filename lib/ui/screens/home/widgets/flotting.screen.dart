import 'package:flutter/material.dart';

void main() => runApp(const PopupMenuApp());

class PopupMenuApp extends StatelessWidget {
  const PopupMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PopupMenu(),
    );
  }
}

class PopupMenu extends StatefulWidget {
  const PopupMenu({super.key});

  @override
  State<PopupMenu> createState() => _PopupMenuState();
}

class _PopupMenuState extends State<PopupMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: PopupMenuTheme(
          data: PopupMenuThemeData(
            color: const Color.fromRGBO(
                32, 29, 29, 0.40), // Set the background color of the popup menu
          ),
          child: PopupMenuButton(
            offset: Offset(0, -155),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              const PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.brush,
                        color: Colors.white), // Set icon color to white
                    SizedBox(width: 8),
                    Text(
                      'Draw',
                      style: TextStyle(
                          color: Colors.white), // Set text color to white
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.directions_walk,
                        color: Colors.white), // Set icon color to white
                    SizedBox(width: 8),
                    Text(
                      'Walk',
                      style: TextStyle(
                          color: Colors.white), // Set text color to white
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.explore,
                        color: Colors.white), // Set icon color to white
                    SizedBox(width: 8),
                    Text(
                      'Marking',
                      style: TextStyle(
                          color: Colors.white), // Set text color to white
                    ),
                  ],
                ),
              ),
            ],
            child: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(239, 14, 138, 14)),
                  ),
                  onPressed: null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.white), // Plus icon
                      // Set text color to white
                      SizedBox(width: 10),
                      const Text('Create',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
