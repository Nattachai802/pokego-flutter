import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'team_controller.dart';

class TeamDetailPage extends StatelessWidget {
  const TeamDetailPage({super.key, required this.teamId});
  final String teamId;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TeamController>();
    final team = c.getTeam(teamId);
    if (team == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF111111), // สีพื้นหลังดำ
        body: Center(
          child: Text(
            'Team not found',
            style: GoogleFonts.pixelifySans(
              fontSize: 18,
              color: Colors.redAccent, // สีแดง
            ),
          ),
        ),
      );
    }
    final nameCtrl = TextEditingController(text: team.name);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          team.name,
          style: GoogleFonts.pixelifySans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white, // สีขาว
          ),
        ),
        backgroundColor: const Color(0xFF111111), // สีดำ
        elevation: 4,
        shadowColor: Colors.redAccent, // เงาสีแดง
        iconTheme: const IconThemeData(color: Colors.white), // ปรับสีของปุ่ม Back เป็นสีขาว
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Rename',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: const Color(0xFF1C1C1C), // สีดำเข้ม
                  title: Text(
                    'Rename team',
                    style: GoogleFonts.pixelifySans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // สีขาว
                    ),
                  ),
                  content: TextField(
                    controller: nameCtrl,
                    autofocus: true,
                    style: GoogleFonts.pixelifySans(
                      fontSize: 14,
                      color: Colors.white, // สีขาว
                    ),
                    decoration: const InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.redAccent), // เส้นสีแดง
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.redAccent), // เส้นสีแดง
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.pixelifySans(
                          fontSize: 14,
                          color: Colors.white70, // สีขาวจาง
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        c.renameTeam(teamId, nameCtrl.text);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Save',
                        style: GoogleFonts.pixelifySans(
                          fontSize: 14,
                          color: Colors.redAccent, // สีแดง
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              c.deleteTeam(teamId);
              Get.back();
            },
            color: Colors.redAccent, // สีแดง
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: team.members.length,
        itemBuilder: (_, i) {
          final m = team.members[i];
          return Card(
            color: const Color(0xFF1C1C1C), // สีดำเข้ม
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(m.imageUrl),
                  backgroundColor: Colors.red.shade200, // สีแดงจาง
                ),
                const SizedBox(height: 8),
                Text(
                  '${m.id}. ${m.name[0].toUpperCase()}${m.name.substring(1)}',
                  style: GoogleFonts.pixelifySans(
                    fontSize: 14,
                    color: Colors.white, // สีขาว
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
      backgroundColor: const Color(0xFF111111), // สีพื้นหลังดำ
    );
  }
}
