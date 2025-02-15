class TeamRequest {
  int id;
  int playerId; // Player requesting or looking for a team
  String teamName;
  String requestStatus; // Example: 'pending', 'accepted', 'rejected'

  TeamRequest({
    required this.id,
    required this.playerId,
    required this.teamName,
    required this.requestStatus,
  });

  // Convert JSON to TeamRequest object
  factory TeamRequest.fromJson(Map<String, dynamic> json) {
    return TeamRequest(
      id: json['id'],
      playerId: json['player_id'],
      teamName: json['team_name'],
      requestStatus: json['request_status'],
    );
  }

  // Convert TeamRequest object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'player_id': playerId,
      'team_name': teamName,
      'request_status': requestStatus,
    };
  }
}
