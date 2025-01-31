class Vehicle {
  final String make;
  final String model;
  final String color;
  final String registration;

  Vehicle({required this.make, required this.model, required this.color, required this.registration});

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      make: map['make'] ?? 'Unknown',
      model: map['model'] ?? 'Unknown',
      color: map['color'] ?? 'Unknown',
      registration: map['registration'] ?? 'Unknown',
    );
  }
}