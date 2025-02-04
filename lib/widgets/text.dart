// Custom Text Field Widget
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final bool obscureText;
  final IconData icon;
  final Widget? suffixIcon;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const CustomTextField({
    required this.label,
    required this.hintText,
    required this.obscureText,
    required this.icon,
    required this.controller,
    this.suffixIcon,
    this.validator,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextFormField(
          focusNode: _focusNode,
          controller: widget.controller,
          obscureText: widget.obscureText,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(
              widget.icon,
              color: _isFocused ? Colors.red : Colors.grey, // Change icon color
            ),
            suffixIcon: widget.suffixIcon,
            // border: OutlineInputBorder(
            //   borderRadius: BorderRadius.circular(10),
            //     borderSide: const BorderSide(color: Colors.redAccent)
            // ),
            // focusedBorder: OutlineInputBorder(
            //   borderSide: const BorderSide(color: Colors.red), // Focused border color
            //   borderRadius: BorderRadius.circular(10),
            // ),
          ),
          validator: widget.validator, // Use validator
        ),
      ],
    );
  }
}
