import 'package:flutter/material.dart';

// class CustomTextField extends StatefulWidget {
//   final String label;
//   final String hintText;
//   final bool obscureText;
//   final IconData icon;
//   final Widget? suffixIcon;
//   final TextEditingController controller;
//   final String? Function(String?)? validator;
//   final List<String>? suggestions; // Optional suggestions
//
//   const CustomTextField({
//     required this.label,
//     required this.hintText,
//     required this.obscureText,
//     required this.icon,
//     required this.controller,
//     this.suffixIcon,
//     this.validator,
//     this.suggestions,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   _CustomTextFieldState createState() => _CustomTextFieldState();
// }
//
// class _CustomTextFieldState extends State<CustomTextField> {
//   late FocusNode _focusNode;
//   bool _isFocused = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _focusNode = FocusNode();
//     _focusNode.addListener(() {
//       setState(() {
//         _isFocused = _focusNode.hasFocus;
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     _focusNode.dispose();
//     super.dispose();
//   }
//
//   Iterable<String> _getOptions(TextEditingValue textEditingValue) {
//     if (widget.suggestions == null || widget.suggestions!.isEmpty) {
//       return const Iterable<String>.empty();
//     }
//     if (textEditingValue.text.isEmpty) {
//       return const Iterable<String>.empty();
//     }
//     return widget.suggestions!.where((String option) =>
//         option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           widget.label,
//           style: const TextStyle(fontSize: 16),
//         ),
//         const SizedBox(height: 8),
//         Autocomplete<String>(
//           optionsBuilder: (TextEditingValue textEditingValue) {
//             return _getOptions(textEditingValue);
//           },
//           onSelected: (String selection) {
//             widget.controller.text = selection;
//             widget.controller.selection = TextSelection.collapsed(offset: selection.length);
//           },
//           fieldViewBuilder: (BuildContext context,
//               TextEditingController textEditingController,
//               FocusNode focusNode,
//               VoidCallback onFieldSubmitted) {
//             // Sync the internal controller with the provided controller
//             textEditingController.text = widget.controller.text;
//             textEditingController.selection = widget.controller.selection;
//             return TextFormField(
//               controller: textEditingController,
//               focusNode: focusNode,
//               obscureText: widget.obscureText,
//               decoration: InputDecoration(
//                 hintText: widget.hintText,
//                 hintStyle: const TextStyle(color: Colors.grey),
//                 prefixIcon: Icon(
//                   widget.icon,
//                   color: _isFocused ? Colors.red : Colors.grey,
//                 ),
//                 suffixIcon: widget.suffixIcon,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Colors.grey),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: const BorderSide(color: Colors.red),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               validator: widget.validator,
//             );
//           },
//         ),
//       ],
//     );
//   }
// }


class CustomTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final bool obscureText;
  final IconData icon;
  final Widget? suffixIcon;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final List<String>? suggestions; // Optional suggestions

  const CustomTextField({
    required this.label,
    required this.hintText,
    required this.obscureText,
    required this.icon,
    required this.controller,
    this.suffixIcon,
    this.validator,
    this.suggestions,
    Key? key,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  late TextEditingController _internalController;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _internalController = TextEditingController(text: widget.controller.text);

    // Sync internal controller with the provided controller
    widget.controller.addListener(_syncControllers);

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  void _syncControllers() {
    if (_internalController.text != widget.controller.text) {
      _internalController.text = widget.controller.text;
      _internalController.selection = widget.controller.selection;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _internalController.dispose();
    widget.controller.removeListener(_syncControllers);
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
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            return _getOptions(textEditingValue);
          },
          onSelected: (String selection) {
            widget.controller.text = selection;
            widget.controller.selection =
                TextSelection.collapsed(offset: selection.length);
          },
          fieldViewBuilder: (BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted) {
            // Assign internal controller only once to prevent build conflicts
            if (textEditingController.text != _internalController.text) {
              textEditingController.text = _internalController.text;
              textEditingController.selection = _internalController.selection;
            }

            return TextFormField(
              controller: _internalController, // Use internal controller
              focusNode: _focusNode,
              obscureText: widget.obscureText,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: Icon(
                  widget.icon,
                  color: _isFocused ? Colors.red : Colors.grey,
                ),
                suffixIcon: widget.suffixIcon,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: widget.validator,
            );
          },
        ),
      ],
    );
  }

  Iterable<String> _getOptions(TextEditingValue textEditingValue) {
    if (widget.suggestions == null || widget.suggestions!.isEmpty) {
      return const Iterable<String>.empty();
    }
    if (textEditingValue.text.isEmpty) {
      return const Iterable<String>.empty();
    }
    return widget.suggestions!.where((String option) =>
        option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
  }
}

