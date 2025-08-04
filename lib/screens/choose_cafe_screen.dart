import 'dart:ui';
import 'package:flutter/material.dart';

class ChooseCafeScreen extends StatelessWidget {
  const ChooseCafeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 61, 60, 60).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Choose a Cafe to Meet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: const [
                        CafeTile(name: 'Starbucks'),
                        CafeTile(name: 'Cafe Coffee Day'),
                        CafeTile(name: 'The Coffee Bean & Tea Leaf'),
                        CafeTile(name: 'Costa Coffee'),
                        CafeTile(name: 'Barista'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Close'),
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

class CafeTile extends StatelessWidget {
  final String name;

  const CafeTile({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        name,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: () {
        // Handle cafe selection
      },
    );
  }
}