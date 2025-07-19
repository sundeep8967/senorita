import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const DatingProfileApp());

class DatingProfileApp extends StatelessWidget {
  const DatingProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const ProfileScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  
  final String name = "Kate";
  final int age = 30;
  final String bio =
      "Hey there! My name is Kate and I'm a designer. I love exploring new places, trying out new diving spots, and spending time outdoors.";

  final List<String> tags = const ["Outdoor", "Design", "Diving"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/kate.jpg'), // <-- Add image in assets
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Dark overlay
          Container(color: Colors.black.withValues(alpha: 0.3)),

          // Profile details
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$name $age",
                  style: GoogleFonts.montserrat(
                    fontSize: 34,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),

                // Tags
                Wrap(
                  spacing: 8,
                  children: tags
                      .map((tag) => Chip(
                            label: Text(tag),
                            labelStyle: const TextStyle(color: Colors.white),
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                          ))
                      .toList(),
                ),

                const SizedBox(height: 12),
                Text(
                  bio,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Bottom navigation
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  child: const Icon(Icons.close, size: 28, color: Colors.white),
                ),
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.local_fire_department, size: 32, color: Colors.black),
                ),
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  child: const Icon(Icons.star, size: 28, color: Colors.white),
                ),
              ],
            ),
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.close, color: Colors.white, size: 28),
                  Icon(Icons.more_vert, color: Colors.white, size: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}