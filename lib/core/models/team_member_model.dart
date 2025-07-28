import 'package:json_annotation/json_annotation.dart';

part 'team_member_model.g.dart';

@JsonSerializable()
class TeamMember {
  final String id;
  final String userId;
  final String projectId;
  final TeamRole role;
  final DateTime joinedAt;
  final bool isActive;
  final List<String> permissions;
  
  const TeamMember({
    required this.id,
    required this.userId,
    required this.projectId,
    required this.role,
    required this.joinedAt,
    required this.isActive,
    required this.permissions,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) => _$TeamMemberFromJson(json);
  Map<String, dynamic> toJson() => _$TeamMemberToJson(this);

  TeamMember copyWith({
    String? id,
    String? userId,
    String? projectId,
    TeamRole? role,
    DateTime? joinedAt,
    bool? isActive,
    List<String>? permissions,
  }) {
    return TeamMember(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      projectId: projectId ?? this.projectId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      isActive: isActive ?? this.isActive,
      permissions: permissions ?? this.permissions,
    );
  }
}

enum TeamRole { owner, admin, member, viewer }