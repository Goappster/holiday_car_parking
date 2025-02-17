// Email validation function
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your email';
  }
  // Simple email regex for validation
  if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(value)) {
    return 'Please enter a valid email';
  }
  return null;
}

// Password validation function (You can reuse this as well)
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your password';
  }
  if (value.length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null;
}