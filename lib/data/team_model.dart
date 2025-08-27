class TeamMemberSnapshot {
  final int id;
  final String name;
  final String imageUrl;
  TeamMemberSnapshot({required this.id, required this.name, required this.imageUrl});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'imageUrl': imageUrl};
  factory TeamMemberSnapshot.fromJson(Map<String, dynamic> j)
    => TeamMemberSnapshot(id: j['id'], name: j['name'], imageUrl: j['imageUrl']);
}

class Team {
  final String id;     
  String name;
  final List<TeamMemberSnapshot> members;

  Team({required this.id, required this.name, required this.members});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'members': members.map((m) => m.toJson()).toList(),
  };

  factory Team.fromJson(Map<String, dynamic> j) => Team(
    id: j['id'],
    name: j['name'],
    members: (j['members'] as List).map((e) => TeamMemberSnapshot.fromJson(Map<String, dynamic>.from(e))).toList(),
  );
}
