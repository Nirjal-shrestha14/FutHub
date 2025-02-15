// class User {
//   final String id;
//   final String name;
//   final String email;
//   final String role; // 'admin', 'futsal_owner', 'player'
//   final String phoneNumber;
//   final String? profilePicture;

//   User({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.role,
//     required this.phoneNumber,
//     this.profilePicture,
//   });

//   // Convert JSON to User object
//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['id'],
//       name: json['name'],
//       email: json['email'],
//       role: json['role'],
//       phoneNumber: json['phone_number'] ?? '', // Default empty string if phone number is missing
//       profilePicture: json['profile_picture'] ?? 'https://example.com/default-profile.png',
//     );
//   }

//   // Convert User object to JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'email': email,
//       'role': role,
//       'phone_number': phoneNumber,
//       'profile_picture': profilePicture,
//     };
//   }
// }




// class User {
//   final String id;
//   final String name;
//   final String email;
//   final String role; // 'admin', 'futsal_owner', 'player'
//   final String phoneNumber;
//   final String? profilePicture;

//   User({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.role,
//     required this.phoneNumber,
//     this.profilePicture,
//   });

//   // Convert JSON to User object
//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['id'],
//       name: json['name'],
//       email: json['email'],
//       role: json['role'],
//       phoneNumber: json['phone_number'] ?? '', // Default empty string if phone number is missing
//       profilePicture: json['profile_picture'] ?? 'https://example.com/default-profile.png',
//     );
//   }

//   // Convert User object to JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'email': email,
//       'role': role,
//       'phone_number': phoneNumber,
//       'profile_picture': profilePicture,
//     };
//   }
// }

class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String phoneNumber;
  final String? profilePicture;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phoneNumber,
    this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Debug print to see the raw JSON
    print('Raw JSON data: $json');

    // Safely extract id, handling potential null or non-string values
    String safeId = '';
    if (json['_id'] != null) {
      safeId = json['_id'].toString();
    } else if (json['id'] != null) {
      safeId = json['id'].toString();
    }

    // Safely extract other fields with null checking
    String safeName = json['name']?.toString() ?? 'Unknown';
    String safeEmail = json['email']?.toString() ?? 'No email';
    String safeRole = json['role']?.toString() ?? 'unknown';
    String safePhone = '';

    // Handle phone number with multiple possible field names
    if (json['phone_number'] != null) {
      safePhone = json['phone_number'].toString();
    } else if (json['phoneNumber'] != null) {
      safePhone = json['phoneNumber'].toString();
    } else {
      safePhone = 'No phone';
    }

    // Handle profile picture with multiple possible field names
    String? safeProfilePicture;
    if (json['profile_picture'] != null) {
      safeProfilePicture = json['profile_picture'].toString();
    } else if (json['profilePicture'] != null) {
      safeProfilePicture = json['profilePicture'].toString();
    }

    // Debug print for extracted values
    print('Extracted values:');
    print('ID: $safeId');
    print('Name: $safeName');
    print('Email: $safeEmail');
    print('Role: $safeRole');
    print('Phone: $safePhone');
    print('Profile Picture: $safeProfilePicture');

    return User(
      id: safeId,
      name: safeName,
      email: safeEmail,
      role: safeRole,
      phoneNumber: safePhone,
      profilePicture: safeProfilePicture,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone_number': phoneNumber,
      'profile_picture': profilePicture,
    };
  }
}
