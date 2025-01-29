class Vehicle {
  final String make;
  final String model;
  final String color;
  final String imageUrl;

  Vehicle({required this.make, required this.model, required this.color, required this.imageUrl});

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      make: map['make'] ?? 'Unknown',
      model: map['model'] ?? 'Unknown',
      color: map['color'] ?? 'Unknown',
      imageUrl: map['imageUrl'] ?? 'assets/images/car.png',
    );
  }
}