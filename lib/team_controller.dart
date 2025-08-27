import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pokego/data/pokemon.dart';
import 'package:pokego/data/team_model.dart';

class TeamController extends GetxController {
  // --- Storage Keys ---
  static const kTeamsKey = 'teams';
  static const kDraftSelectedIds = 'draftSelectedIds';
  static const kDraftTeamName = 'draftTeamName';

  final _storage = GetStorage();

  // --- State ---
  final teams = <Team>[].obs;
  final draftSelectedIds = <int>[].obs;
  final draftTeamName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // โหลดข้อมูลทั้งหมดจาก Storage เมื่อ Controller เริ่มทำงาน
    _loadFromStorage();

    // ตั้งค่าให้บันทึกข้อมูลทีมอัตโนมัติเมื่อมีการเปลี่ยนแปลง
    ever(teams, (_) => _saveTeamsToStorage());
  }

  // [ใหม่] โหลดข้อมูลทั้งหมดจาก Storage
  void _loadFromStorage() {
    // โหลดลิสต์ทีม
    final teamsData = _storage.read<List>(kTeamsKey);
    if (teamsData != null) {
      teams.assignAll(teamsData.map((e) => Team.fromJson(e)).toList());
    }

    // โหลดข้อมูลร่าง
    final draftIdsData = _storage.read<List>(kDraftSelectedIds);
    if (draftIdsData != null) {
      draftSelectedIds.assignAll(draftIdsData.cast<int>());
    }
    draftTeamName.value = _storage.read(kDraftTeamName) ?? '';
  }

  // [ใหม่] บันทึกข้อมูลทีมลง Storage
  Future<void> _saveTeamsToStorage() async {
    await _storage.write(kTeamsKey, teams.map((t) => t.toJson()).toList());
  }

  // บันทึกข้อมูลร่าง (สำหรับหน้าเลือกตัว)
  void saveDraftData() {
    _storage.write(kDraftSelectedIds, draftSelectedIds.toList());
    _storage.write(kDraftTeamName, draftTeamName.value);
  }

  // ล้างข้อมูลร่าง (เมื่อสร้างทีมสำเร็จ)
  void clearDraftData() {
    draftSelectedIds.clear();
    draftTeamName.value = '';
    _storage.remove(kDraftSelectedIds);
    _storage.remove(kDraftTeamName);
  }

  // สร้างทีมใหม่
  String createTeam({required String name, required List<Pokemon> selected}) {
    final sanitized = name.trim().isEmpty ? 'My Team' : name.trim();
    final snapshots = selected
        .map((p) =>
            TeamMemberSnapshot(id: p.id, name: p.name, imageUrl: p.imageUrl))
        .toList();

    final team =
        Team(id: _genId(), name: sanitized, members: snapshots);

    teams.add(team); // ever() จะทำการบันทึกให้โดยอัตโนมัติ
    clearDraftData(); // ล้างข้อมูลร่างหลังสร้างทีมสำเร็จ

    return team.id;
  }

  // เปลี่ยนชื่อทีม
  void renameTeam(String teamId, String newName) {
    final index = teams.indexWhere((e) => e.id == teamId);
    if (index != -1) {
      final updatedTeam = teams[index];
      updatedTeam.name = newName.trim().isEmpty ? 'My Team' : newName.trim();
      teams[index] = updatedTeam; // การทำแบบนี้จะ trigger 'ever()' ให้ทำงาน
    }
  }

  // ลบทีม
  void deleteTeam(String teamId) {
    teams.removeWhere((e) => e.id == teamId); // ever() จะทำการบันทึกให้โดยอัตโนมัติ
  }

  // ดึงทีมตาม id
  Team? getTeam(String teamId) =>
      teams.firstWhereOrNull((e) => e.id == teamId);

  String _genId() => 't_${DateTime.now().millisecondsSinceEpoch}';
}
