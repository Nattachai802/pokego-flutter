// stateful widget to select 3 pokémon from API results
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pokego/data/pokemon.dart';
import 'package:pokego/data/sources/pokemon_api.dart';
import 'package:pokego/page/teams_list_page.dart';
import 'package:pokego/team_controller.dart';

class PlayerSelection extends StatefulWidget {
  const PlayerSelection({super.key});
  @override
  State<PlayerSelection> createState() => _PlayerSelectionState();
}

class _PlayerSelectionState extends State<PlayerSelection> {
  final _searchController = TextEditingController();
  final teamC = Get.find<TeamController>();
  late Future<List<Pokemon>> futurePokemons;
  String query = '';

  List<Pokemon> _cache = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  void initState() {
    super.initState();
    futurePokemons = PokemonApi.fetchPokemonsWithDetails(limit: 151);
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);



  void _toggle(Pokemon p) {
    setState(() {
      if (teamC.draftSelectedIds.contains(p.id)) {
        teamC.draftSelectedIds.remove(p.id);
      } else {
        if (teamC.draftSelectedIds.length >= 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('เลือกได้สูงสุด 3 ตัว')),
          );
          return;
        }
        teamC.draftSelectedIds.add(p.id);
      }
    });
    teamC.saveDraftData(); // เรียกเมธอดจาก Controller เพื่อบันทึก
  }

void _askTeamNameAndCreate() {
  // ต้องเลือกให้ครบ 3 ก่อน
  if (teamC.draftSelectedIds.length != 3) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('กรุณาเลือกให้ครบ 3 ตัวก่อน')),
    );
    return;
  }

  final nameCtrl = TextEditingController(
    text: teamC.draftTeamName.value, // อ่านค่าจาก Controller
  );

  bool isSubmitting = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          final canSubmit = nameCtrl.text.trim().isNotEmpty && !isSubmitting;

          return Padding(
            padding: EdgeInsets.only(
              left: 16, right: 16, top: 16,
              bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  maxLength: 30,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'เช่น Team Rocket',
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (v) {
                    teamC.draftTeamName.value = v; // เซฟระหว่างพิมพ์
                    setState(() {}); // อัปเดตปุ่มให้เปิด/ปิดตามข้อความ
                  },
                  onSubmitted: (_) {
                    if (canSubmit) {
                      setState(() => isSubmitting = true);
                      _confirmCreate(nameCtrl.text.trim());
                    }
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // ออปชัน: ถ้าอยากลบร่างเมื่อยกเลิกให้ uncomment บรรทัดถัดไป
                          // box.remove(TeamController.kDraftTeamName);
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('ยกเลิก'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: canSubmit
                            ? () {
                                setState(() => isSubmitting = true);
                                _confirmCreate(nameCtrl.text.trim());
                              }
                            : null,
                        icon: const Icon(Icons.check , color: Color.fromARGB(255, 96, 195, 92),),
                        label: Text(isSubmitting ? 'กำลังยืนยัน...' : 'ยืนยัน'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

  void _confirmCreate(String name) {
    final selected = _cache.where((p) => teamC.draftSelectedIds.contains(p.id)).toList();
    final newId = teamC.createTeam(name: name, selected: selected); // เพิ่มทีมใหม่เข้า list
    Navigator.of(context).pop(); // ปิด bottom sheet

    teamC.clearDraftData(); // ล้างข้อมูลร่าง

    Get.offAll(() => const TeamsListPage()); // กลับไปหน้ารายการทีม เห็นทีมใหม่เพิ่มแล้ว
    // หรือถ้าอยากเข้าไปดูทีมที่สร้างทันที:
    // Get.offAll(() => TeamDetailPage(teamId: newId));
  }

  Widget _statRow(String label, int value, Color color) {
    const maxBase = 255;
    final ratio = (value / maxBase).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(width: 28, child: Text(label, style: GoogleFonts.pixelifySans(fontSize: 10, color: Colors.white))),
        const SizedBox(width: 6),
        Expanded(
          child: Stack(children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            FractionallySizedBox(
              widthFactor: ratio,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 28,
          child: Text(
            '$value',
            textAlign: TextAlign.right,
            style: GoogleFonts.pixelifySans(fontSize: 10, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Color _statColor(String key) {
    switch (key) {
      case 'hp':
        return Colors.green;
      case 'attack':
        return Colors.red;
      case 'defense':
        return Colors.blue;
      case 'special-attack':
        return Colors.deepPurple;
      case 'special-defense':
        return Colors.teal;
      case 'speed':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _resetSelection() {
    setState(() {
      teamC.draftSelectedIds.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('รีเซ็ตทีมที่เลือกเรียบร้อย')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'เลือกโปเกมอน (3 ตัว)',
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
        iconTheme: const IconThemeData(color: Colors.white), // ปรับสีของปุ่ม Back เป็นสีขาว
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _resetSelection,
            tooltip: 'รีเซ็ตทีมที่เลือก',
          ),
        ],
      ),
      body: Column(
        children: [
          // ชิปตัวที่เลือก
          SizedBox(
            height: 100,
            child: FutureBuilder<List<Pokemon>>(
              future: futurePokemons,
              builder: (_, snap) {
                final data = snap.data ?? [];
                final sel = data.where((p) => teamC.draftSelectedIds.contains(p.id)).toList();
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: sel.length,
                  itemBuilder: (_, i) {
                    final p = sel[i];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InputChip(
                        avatar: CircleAvatar(backgroundImage: NetworkImage(p.imageUrl)),
                        label: Text(
                          '${p.id}. ${_cap(p.name)}',
                          style: GoogleFonts.pixelifySans(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        onDeleted: () => _toggle(p),
                        backgroundColor: const Color(0xFFE50914).withOpacity(0.25),
                        side: const BorderSide(color: Colors.white24),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) {
                setState(() {
                  query = v.trim().toLowerCase(); // อัปเดต query
                });
              },
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'ค้นหาโปเกมอน (ชื่อหรือประเภท)',
                hintStyle: GoogleFonts.pixelifySans(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => query = ''); // ล้าง query
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                filled: true,
                fillColor: const Color(0xFF1C1C1C),
              ),
              style: GoogleFonts.pixelifySans(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),

          // ลิสต์ทั้งหมด
          Expanded(
            child: FutureBuilder<List<Pokemon>>(
              future: futurePokemons,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('ผิดพลาด: ${snap.error}'));
                }

                final pokes = snap.data ?? [];
                _cache = pokes;

                bool _matchesQuery(Pokemon p, String q) {
                  final nameMatch = p.name.toLowerCase().contains(q);
                  final typeMatch = p.types.any((t) => t.toLowerCase().contains(q));
                  return nameMatch || typeMatch;
                }

                final q = query.toLowerCase();
                final filtered = q.isEmpty
                    ? pokes
                    : pokes.where((p) => _matchesQuery(p, q)).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('ไม่พบโปเกมอนที่ตรงกับคำค้นหา'));
                }

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.8, // ปรับให้การ์ดไม่อ้วนเกินไป
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final p = filtered[i];
                    final isSelected = teamC.draftSelectedIds.contains(p.id);

                    return Card(
                      color: const Color(0xFF1C1C1C),
                      margin: const EdgeInsets.all(4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(p.imageUrl),
                          backgroundColor: Colors.red.shade200,
                        ),
                        title: Text(
                          '${p.id}. ${_cap(p.name)}',
                          style: GoogleFonts.pixelifySans(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ht ${p.heightM.toStringAsFixed(1)} m · Wt ${p.weightKg.toStringAsFixed(1)} kg',
                              style: GoogleFonts.pixelifySans(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 4,
                              children: p.types.map((type) {
                                return Chip(
                                  label: Text(
                                    _cap(type),
                                    style: GoogleFonts.pixelifySans(
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: _getTypeColor(type),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 6),
                            _statRow('HP', p.hp, _statColor('hp')),
                            const SizedBox(height: 4),
                            _statRow('ATK', p.atk, _statColor('attack')),
                            const SizedBox(height: 4),
                            _statRow('SPE', p.spe, _statColor('speed')),
                          ],
                        ),
                        trailing: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                        onTap: () => _toggle(p),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // ปุ่ม "สร้างทีม" ด้านล่าง
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton.icon(
            onPressed: teamC.draftSelectedIds.length == 3 ? _askTeamNameAndCreate : null,
            icon: const Icon(Icons.catching_pokemon, color: Colors.white),
            label: Text(
              'สร้างทีม (${teamC.draftSelectedIds.length}/3)',
              style: GoogleFonts.pixelifySans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE50914),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 130, 130, 130),
    );
  }

  Color _getTypeColor(String type) {
  switch (type.toLowerCase()) {
    case 'fire':
      return Colors.red.shade300;
    case 'water':
      return Colors.blue.shade300;
    case 'grass':
      return Colors.green.shade300;
    case 'electric':
      return Colors.yellow.shade300;
    case 'poison':
      return Colors.purple.shade300;
    case 'rock':
      return Colors.brown.shade300;
    case 'psychic':
      return Colors.pink.shade300;
    case 'ice':
      return Colors.cyan.shade300;
    case 'dragon':
      return Colors.indigo.shade300;
    case 'dark':
      return Colors.black54;
    case 'fairy':
      return Colors.pinkAccent.shade100;
    case 'ground':
      return Colors.brown.shade400;
    case 'fighting':
      return Colors.red.shade400;
    case 'bug':
      return Colors.lightGreen.shade300;
    case 'ghost':
      return Colors.deepPurple.shade300;
    case 'flying':
      return Colors.blue.shade200;
    default:
      return Colors.grey.shade300;
  }
}}