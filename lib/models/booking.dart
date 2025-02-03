import 'dart:convert';

class Booking {
  final String referenceNo;
  final String airportName;
  final DateTime departureDate;
  final DateTime returnDate;
  final double totalAmount;
  final int numberOfDays;
  final String companyName;
  final String companyLogo;
  final DateTime createdAt;

  Booking({
    required this.referenceNo,
    required this.airportName,
    required this.departureDate,
    required this.returnDate,
    required this.totalAmount,
    required this.numberOfDays,
    required this.companyName,
    required this.companyLogo,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      referenceNo: json['reference_no'] as String,
      airportName: json['airport_name'] as String,
      departureDate: DateTime.parse(json['departure_date'].replaceAll(" ", "T")),
      returnDate: DateTime.parse(json['return_date'].replaceAll(" ", "T")),
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      numberOfDays: json['number_of_days'] as int,
      companyName: json['company_name'] as String,
      companyLogo: json['company_logo'] ?? '',
      createdAt: DateTime.parse(json['created_at'].replaceAll(" ", "T")),
    );
  }

  Map<String, dynamic> toJson() => {
    'reference_no': referenceNo,
    'airport_name': airportName,
    'departure_date': departureDate.toIso8601String(),
    'return_date': returnDate.toIso8601String(),
    'total_amount': totalAmount,
    'number_of_days': numberOfDays,
    'company_name': companyName,
    'company_logo': companyLogo,
    'created_at': createdAt.toIso8601String(),
  };
}
