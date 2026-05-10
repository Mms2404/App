import 'package:app/api/keys.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

Future<String> geminiSearch(String prompt) async {
  final model = GenerativeModel(
    model: 'gemini-2.0-flash',
    apiKey: GEMINI_API,
  );

  final query = [Content.text(prompt)];
  final result = await model.generateContent(query);

  return result.text ?? 'No response received.';
}


