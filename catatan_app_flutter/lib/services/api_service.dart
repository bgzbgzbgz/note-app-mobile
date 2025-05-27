import 'dart:convert'; // Untuk json.decode
import 'package:http/http.dart' as http; // Package http yang tadi kita tambahkan
import '../models/note.dart'; // Import model Note kita

class ApiService {
  // =======================================================================
  // PENTING: Sesuaikan _baseUrl dengan alamat IP komputermu!
  // =======================================================================
  // Jika kamu menjalankan Flutter di EMULATOR ANDROID:
  // Gunakan 'http://10.0.2.2/nama_folder_api_mu/index.php/api/'
  //
  // Jika kamu menjalankan Flutter di HP ANDROID FISIK (via USB debugging)
  // dan HP terkoneksi ke WiFi yang SAMA dengan komputermu:
  // 1. Cari tahu IP Address komputermu di jaringan WiFi tersebut.
  //    - Di Windows: buka CMD, ketik `ipconfig`, cari "IPv4 Address" di bawah adapter WiFi.
  //    - Di macOS/Linux: buka Terminal, ketik `ifconfig` atau `ip addr`, cari IP di interface WiFi.
  // 2. Gunakan IP tersebut, contoh: 'http://192.168.1.10/nama_folder_api_mu/index.php/api/'
  //
  // Nama folder API-mu adalah 'note_api'
  // Jadi contohnya:
  // static const String _baseUrl = 'http://10.0.2.2/note_api/index.php/api/'; // Untuk Emulator
  // atau
  // static const String _baseUrl = 'http://192.168.YOUR.IP/note_api/index.php/api/'; // Untuk HP Fisik
  // =======================================================================
  static const String _baseUrl = 'http://localhost/note_api/index.php/api/'; // <--- SESUAIKAN INI!

  // Fungsi untuk mengambil semua catatan
  Future<List<Note>> fetchNotes() async {
    // ... (kode fetchNotes tetap sama seperti yang sudah berhasil) ...
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

  // --- FUNGSI BARU UNTUK CREATE NOTE ---
  Future<Note> createNote(String title, String content) async {
    final response = await http.post(
      Uri.parse('${_baseUrl}notes'), // Endpoint untuk POST adalah /notes
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8', // Penting untuk mengirim body JSON
      },
      body: jsonEncode(<String, String>{ // Encode data Dart Map menjadi String JSON
        'title': title,
        'content': content,
      }),
    );

    if (response.statusCode == 201) { // API kita mengembalikan 201 Created saat sukses
      // Jika server membuat catatan baru dengan sukses, parse JSON responsnya
      // API kita mengembalikan { "status": true, "message": "...", "data": {note_baru} }
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return Note.fromJson(jsonResponse['data']); // Ambil objek note dari field 'data'
    } else {
      // Jika server gagal, lempar exception dengan detail error
      throw Exception('Gagal membuat catatan. Status: ${response.statusCode}. Body: ${response.body}');
    }
  }

  // --- NANTI KAMU BISA TAMBAH FUNGSI LAIN DI SINI UNTUK CREATE, UPDATE, DELETE ---
  // Contoh (belum diimplementasikan sepenuhnya):
  //
  // Future<Note> createNote(String title, String content) async {
  //   final response = await http.post(
  //     Uri.parse('${_baseUrl}notes'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(<String, String>{
  //       'title': title,
  //       'content': content,
  //     }),
  //   );
  //   if (response.statusCode == 201) { // 201 Created
  //     Map<String, dynamic> jsonResponse = json.decode(response.body);
  //     return Note.fromJson(jsonResponse['data']);
  //   } else {
  //     throw Exception('Gagal membuat catatan. Status: ${response.statusCode}. Body: ${response.body}');
  //   }
  // }
}