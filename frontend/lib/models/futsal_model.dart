class Futsal {
  final String id;
  final String owner;
  final String name;
  final String location;
  final int price;
  final List<String> facilities;
  final List<String> timeSlots;
  final String approvalStatus;
  final DateTime createdAt;

  Futsal({
    required this.id,
    required this.owner,
    required this.name,
    required this.location,
    required this.price,
    required this.facilities,
    required this.timeSlots,
    required this.approvalStatus,
    required this.createdAt,
  });

  // Convert JSON to Futsal object
  factory Futsal.fromJson(Map<String, dynamic> json) {
    return Futsal(
      id: json['_id'],
      owner: json['owner'],
      name: json['name'],
      location: json['location'],
      price: json['price'],
      facilities: List<String>.from(json['facilities'] ?? []),
      timeSlots: List<String>.from(json['timeSlots'] ?? []),
      approvalStatus: json['approvalStatus'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Convert Futsal object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location': location,
      'name': name,
      'price': price,
      'owner': owner,
      'facilities': facilities,
      'timeSlots': timeSlots,
      'approvalStatus': approvalStatus,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
