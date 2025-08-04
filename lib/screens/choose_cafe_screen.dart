import 'dart:ui';
import 'package:flutter/material.dart';

class ChooseCafeScreen extends StatefulWidget {
  const ChooseCafeScreen({Key? key}) : super(key: key);

  @override
  State<ChooseCafeScreen> createState() => _ChooseCafeScreenState();
}

class _ChooseCafeScreenState extends State<ChooseCafeScreen> {
  String? _selectedCafe;

  void _selectCafe(String cafeName) {
    setState(() {
      _selectedCafe = cafeName;
    });
  }

  void _resetSelection() {
    setState(() {
      _selectedCafe = null;
    });
  }

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
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              child: _selectedCafe == null
                  ? _buildCafeList()
                  : _buildConfirmationView(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCafeList() {
    return Column(
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
            children: [
              CafeTile(name: 'Starbucks', onSelect: _selectCafe),
              CafeTile(name: 'Cafe Coffee Day', onSelect: _selectCafe),
              CafeTile(name: 'The Coffee Bean & Tea Leaf', onSelect: _selectCafe),
              CafeTile(name: 'Costa Coffee', onSelect: _selectCafe),
              CafeTile(name: 'Barista', onSelect: _selectCafe),
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
    );
  }

  Widget _buildConfirmationView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Invite Senorita to $_selectedCafe',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'First tea is on us',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'First maggie is on us',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            // Handle confirmation logic
            Navigator.pop(context); // Close the dialog
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          ),
          child: const Text('Confirm', style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: _resetSelection,
          child: const Text(
            'Back to list',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class CafeTile extends StatelessWidget {
  final String name;
  final Function(String) onSelect;

  const CafeTile({Key? key, required this.name, required this.onSelect})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        name,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: () => onSelect(name),
    );
  }
}
