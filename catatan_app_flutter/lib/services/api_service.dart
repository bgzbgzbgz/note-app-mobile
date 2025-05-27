// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note.dart'; //

class ApiService {
  static const String _baseUrl = 'http://10.252.133.79/note_api/index.php/api/'; // SESUAIKAN INI!
  // Jika pakai emulator Android Studio/AVD default, ganti dengan:
  // static const String _baseUrl = 'http://10.0.2.2/note_api/index.php/api/';
  // Jika pakai HP fisik di WiFi yang sama, ganti dengan IP komputermu:
  // static const String _baseUrl = 'http://IP_KOMPUTER_KAMU/note_api/index.php/api/';

  Future<List<Note>> fetchNotes() async {
    final response = await http.get(Uri.parse('${_baseUrl}notes'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['data'] != null && jsonResponse['data'] is List) {
        List<dynamic> notesJson = jsonResponse['data'];
        return notesJson.map((noteJson) => Note.fromJson(noteJson)).toList();
      } else if (jsonResponse['data'] == null && jsonResponse['status'] == true) {
        return [];
      } else {
        throw Exception('Format data dari API tidak sesuai. Respons: ${response.body}');
      }
    } else {
      throw Exception('Gagal mengambil catatan dari API. Status code: ${response.statusCode}. Respons: ${response.body}');
    }
  }

  Future<Note> createNote(String title, String content) async {
    final response = await http.post(
      Uri.parse('${_baseUrl}notes'), //
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8', //
      },
      body: jsonEncode(<String, String>{ //
        'title': title,
        'content': content,
      }),
    );

    if (response.statusCode == 201) { //
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return Note.fromJson(jsonResponse['data']); //
    } else {
      throw Exception('Gagal membuat catatan. Status: ${response.statusCode}. Body: ${response.body}');
    }
  }

  Future<Note> updateNote(String id, String title, String content) async {
    final response = await http.put(
      Uri.parse('${_baseUrl}notes/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'title': title,
        'content': content,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return Note.fromJson(jsonResponse['data']);
    } else {
      print('Failed to update note. Status: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Gagal memperbarui catatan. Status: ${response.statusCode}. Body: ${response.body}');
    }
  }

  // --- FUNGSI BARU UNTUK DELETE NOTE ---
  Future<void> deleteNote(String id) async {
    final response = await http.delete(
      Uri.parse('${_baseUrl}notes/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8', // Meskipun delete mungkin tidak butuh body, header ini umum
      },
    );

    if (response.statusCode == 200) {
      // Berhasil dihapus, tidak perlu mengembalikan data spesifik
      // API kita mengembalikan: { "status": true, "message": "Note deleted successfully." }
      // Kita bisa cek `json.decode(response.body)['status'] == true` jika perlu
      print('Note deleted successfully. Response: ${response.body}');
    } else {
      // Gagal menghapus
      print('Failed to delete note. Status: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Gagal menghapus catatan. Status: ${response.statusCode}. Body: ${response.body}');
    }
  }
  // --- AKHIR FUNGSI DELETE NOTE ---
}