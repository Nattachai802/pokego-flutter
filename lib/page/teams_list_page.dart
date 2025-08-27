import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pokego/team_detail_page.dart';
import '../team_controller.dart';
import 'playerselection.dart';
import 'package:google_fonts/google_fonts.dart';

class TeamsListPage extends StatelessWidget {
  const TeamsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TeamController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Teams',
          style: TextStyle(
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
      ),
      body: Obx(() {
        if (c.teams.isEmpty) {
          return Center(
            child: ElevatedButton.icon(
              onPressed: () => Get.to(() => const PlayerSelection()),
              icon: const Icon(Icons.add),
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
          );
        }
        return ListView.separated(
          itemCount: c.teams.length,
          separatorBuilder: (_, __) => const Divider(height: 0, color: Colors.white24),
          itemBuilder: (_, i) {
            final t = c.teams[i];
            return Card(
              color: const Color(0xFF1C1C1C),
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: () => Get.to(() => TeamDetailPage(teamId: t.id)), // เพิ่มการนำทางไปยัง TeamDetailPage
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            for (var j = 0; j < t.members.take(3).length; j++)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: CircleAvatar(
                                  radius: 24,
                                  backgroundImage: NetworkImage(t.members[j].imageUrl),
                                  backgroundColor: Colors.red.shade200,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.name,
                              style: GoogleFonts.pixelifySans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${t.members.length} members',
                              style: GoogleFonts.pixelifySans(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => c.deleteTeam(t.id),
                        tooltip: 'Delete',
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const PlayerSelection()),
        icon: const Icon(Icons.add),
        label: const Text('New Team'),
        backgroundColor: const Color(0xFFE50914),
      ),
      backgroundColor: const Color.fromARGB(255, 124, 124, 124),
    );
  }
}
