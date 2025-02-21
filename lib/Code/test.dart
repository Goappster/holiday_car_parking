// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'AutoComplete Test',
//       home: const ExampleScreen(),
//     );
//   }
// }
//
// class ExampleScreen extends StatelessWidget {
//   const ExampleScreen({Key? key}) : super(key: key);
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     final TextEditingController countryController = TextEditingController();
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('AutoComplete Test')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: CustomAutoCompleteTextField(
//           label: "Country",
//           hintText: "Select your country",
//           obscureText: false,
//           icon: Icons.flag,
//           controller: countryController,
//           suggestions: countrySuggestions,
//         ),
//       ),
//     );
//   }
// }
//
// class CustomAutoCompleteTextField extends StatefulWidget {
//   final String label;
//   final String hintText;
//   final bool obscureText;
//   final IconData icon;
//   final Widget? suffixIcon;
//   final TextEditingController controller;
//   final String? Function(String?)? validator;
//   final List<String>? suggestions;
//
//   const CustomAutoCompleteTextField({
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
//   _CustomAutoCompleteTextFieldState createState() =>
//       _CustomAutoCompleteTextFieldState();
// }
//
// class _CustomAutoCompleteTextFieldState
//     extends State<CustomAutoCompleteTextField> {
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
//     print('User typed: ${textEditingValue.text}');
//     if (widget.suggestions == null || widget.suggestions!.isEmpty) {
//       return const Iterable<String>.empty();
//     }
//     if (textEditingValue.text.isEmpty) {
//       return const Iterable<String>.empty();
//     }
//     final options = widget.suggestions!.where((String option) =>
//         option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
//     print('Matching options: $options');
//     return options;
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
//           },
//           fieldViewBuilder: (
//               BuildContext context,
//               TextEditingController textEditingController,
//               FocusNode focusNode,
//               VoidCallback onFieldSubmitted,
//               ) {
//             // Synchronize controllers
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
