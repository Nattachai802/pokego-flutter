import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'team_controller.dart';
import 'package:pokego/page/playerselection.dart';
import 'package:google_fonts/google_fonts.dart';

class TeamOverviewPage extends StatelessWidget {
  final String teamId;
  const TeamOverviewPage({super.key, required this.teamId});

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TeamController>();
    final team = c.getTeam(teamId);

    if (team == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('ทีมไม่พบ')),
        body: const Center(child: Text('ไม่พบทีมนี้')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ทีมของฉัน — ${team.name}',
          style: const TextStyle(
            fontFamily: 'PixelifySans',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF111111),
        elevation: 4,
        shadowColor: Colors.redAccent,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'แก้ทีม',
            onPressed: () => Get.to(() => const PlayerSelection()),
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
          IconButton(
            tooltip: 'ลบทีม',
            onPressed: () async {
              c.deleteTeam(teamId);
              Get.back();
              Get.snackbar('ลบทีมแล้ว', 'ทีมถูกลบเรียบร้อย');
            },
            icon: const Icon(Icons.delete, color: Colors.white),
          ),
        ],
      ),
      body: team.members.isEmpty
          ? Center(
              child: ElevatedButton.icon(
                onPressed: () => Get.to(() => const PlayerSelection()),
                icon: const Icon(Icons.catching_pokemon),
                label: const Text('สร้างทีมใหม่'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE50914),
                  foregroundColor: Colors.white,
                  textStyle: GoogleFonts.pixelifySans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8,
              ),
              itemCount: team.members.length,
              itemBuilder: (_, i) {
                final m = team.members[i];
                return Card(
                  color: const Color(0xFF1C1C1C),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundImage: NetworkImage(m.imageUrl),
                        backgroundColor: Colors.red.shade200,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${m.id}. ${_cap(m.name)}',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.pixelifySans(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      backgroundColor: const Color(0xFFF5F5F5),
    );
  }
}
