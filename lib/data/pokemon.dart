class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final int height;
  final int weight;
  final List<String> types; // ex ["electric"] or ["grass","poison"]
  final Map<String, int> baseStats; // hp/attack/defense/sp-attack/sp-defense/speed


  Pokemon({required this.id,
   required this.name, 
   required this.imageUrl,
   required this.height,
   required this.weight,
   required this.types,
   required this.baseStats,
   });

   int get hp  => baseStats['hp'] ?? 0;
   int get atk => baseStats['attack'] ?? 0;
   int get def => baseStats['defense'] ?? 0;
   int get spa => baseStats['special-attack'] ?? 0;
   int get spd => baseStats['special-defense'] ?? 0;
   int get spe => baseStats['speed'] ?? 0;


  double get heightM => height / 10.0;  // dm -> m
  double get weightKg => weight / 10.0; // hg -> kg
  
  static Map<String, int> _parseBaseStats(List statsJson) {
  final m = <String, int>{};
  for (final e in statsJson) {
    final name = (e['stat']['name'] as String).toLowerCase(); // hp / attack / ...
    final val  = e['base_stat'] as int;
    m[name] = val;
  }
  // กัน key หาย ใส่ค่าเริ่มต้น 0 ให้ครบชุด
  for (final k in const [
    'hp','attack','defense','special-attack','special-defense','speed'
  ]) {
    m.putIfAbsent(k, () => 0);
  }
  return m;
}


  factory Pokemon.fromDetailJson(Map<String,dynamic> j) {
    final id = j['id'] as int;
    final name = j['name'] as String;

    final img = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

    final types = (j['types'] as List).map((e) => (e['type']['name'] as String)).toList();

    final baseStats = _parseBaseStats(j['stats'] as List);

    
    return Pokemon(
      id: id,
      name: name,
      imageUrl: img,
      height: j['height'] as int,
      weight: j['weight'] as int,
      types: types,
      baseStats: baseStats,

    );



  }




}