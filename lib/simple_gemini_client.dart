import 'package:http/http.dart' as http;
import 'dart:convert';

class SimpleGeminiClient {
  final String apiKey;
  final String model;
  
  SimpleGeminiClient({
    required this.apiKey,
    this.model = 'gemini-1.5-flash',
  });
  
  Future<String> chat(String prompt, {String? systemPrompt}) async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey"
    );
    
    final Map<String, dynamic> requestBody = {
      "contents": [
        {
          "parts": [
            {"text": systemPrompt ?? "You are a helpful assistant."},
            {"text": prompt}
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.7,
        "maxOutputTokens": 1500,
      }
    };
    
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );
    
    if (response.statusCode != 200) {
      throw Exception("Gemini API error (${response.statusCode}): ${response.body}");
    }
    
    final data = jsonDecode(response.body);
    try {
      return data["candidates"][0]["content"]["parts"][0]["text"];
    } catch (e) {
      throw Exception("Failed to parse Gemini response: $e\nResponse body: ${response.body}");
    }
  }
}