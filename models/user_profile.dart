class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String homeCity;
  final String preferredMode; // All, Bus, Metro, Train
  final bool hasStudentPass;
  final bool hasSeniorConcession;
  final bool enableNotifications;

  UserProfile({
    required this.name,
    required this.email,
    this.phone = '',
    this.homeCity = 'New Delhi',
    this.preferredMode = 'All',
    this.hasStudentPass = false,
    this.hasSeniorConcession = false,
    this.enableNotifications = true,
  });

  factory UserProfile.defaultUser() => UserProfile(
        name: 'Siddhant Panchauri',
        email: 'siddhant@example.com',
        phone: '+91 98765 43210',
        homeCity: 'New Delhi',
        preferredMode: 'All',
        hasStudentPass: true,
        hasSeniorConcession: false,
        enableNotifications: true,
      );

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] ?? 'Transit Traveler',
        email: json['email'] ?? 'traveler@example.com',
        phone: json['phone'] ?? '',
        homeCity: json['homeCity'] ?? 'New Delhi',
        preferredMode: json['preferredMode'] ?? 'All',
        hasStudentPass: json['hasStudentPass'] ?? false,
        hasSeniorConcession: json['hasSeniorConcession'] ?? false,
        enableNotifications: json['enableNotifications'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'homeCity': homeCity,
        'preferredMode': preferredMode,
        'hasStudentPass': hasStudentPass,
        'hasSeniorConcession': hasSeniorConcession,
        'enableNotifications': enableNotifications,
      };

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? homeCity,
    String? preferredMode,
    bool? hasStudentPass,
    bool? hasSeniorConcession,
    bool? enableNotifications,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      homeCity: homeCity ?? this.homeCity,
      preferredMode: preferredMode ?? this.preferredMode,
      hasStudentPass: hasStudentPass ?? this.hasStudentPass,
      hasSeniorConcession: hasSeniorConcession ?? this.hasSeniorConcession,
      enableNotifications: enableNotifications ?? this.enableNotifications,
    );
  }
}
