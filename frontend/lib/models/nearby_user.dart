class NearbyUser {
  final int userId;
  final String displayName;
  final String? profilePicture;
  final double distanceMeters;

  NearbyUser({
    required this.userId,
    required this.displayName,
    required this.profilePicture,
    required this.distanceMeters,
  });

  factory NearbyUser.fromJson(
      Map<String, dynamic> json,
      ) {
    return NearbyUser(
      userId: (json['userId'] as num).toInt(),
      displayName: json['displayName'] as String,
      profilePicture: json['profilePicture'] as String?,
      distanceMeters:
      (json['distanceMeters'] as num).toDouble(),
    );
  }
}