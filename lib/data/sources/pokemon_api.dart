import 'dart:convert';
import 'package:http/http.dart' as http;
import '../pokemon.dart';

class PokemonApi {
  static Future<List<Pokemon>> fetchPokemonsWithDetails({int limit = 151}) async {
    final listUri = Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=$limit');
    final listRes = await http.get(listUri);
    if (listRes.statusCode != 200) {
      throw Exception('Failed to load list: ${listRes.statusCode}');
    }

    final map = jsonDecode(listRes.body) as Map<String, dynamic>;
    final results = (map['results'] as List).cast<Map<String, dynamic>>();

    // ทำเป็น batch เพื่อลดโหลด (เช่น ชุดละ 20)
    const batchSize = 20;
    final pokemons = <Pokemon>[];

    for (var i = 0; i < results.length; i += batchSize) {
      final chunk = results.sublist(
        i,
        (i + batchSize > results.length) ? results.length : i + batchSize,
      );

      final futures = chunk.map((e) async {
        final detailUrl = Uri.parse(e['url'] as String); // เป็น detail endpoint
        final res = await http.get(detailUrl);
        if (res.statusCode != 200) {
          throw Exception('Detail failed: ${res.statusCode}');
        }
        final j = jsonDecode(res.body) as Map<String, dynamic>;
        return Pokemon.fromDetailJson(j);
      });

      final batch = await Future.wait(futures);
      pokemons.addAll(batch);
    }

    // (ทางเลือก) เรียงตาม id
    pokemons.sort((a, b) => a.id.compareTo(b.id));
    return pokemons;
  }
}
