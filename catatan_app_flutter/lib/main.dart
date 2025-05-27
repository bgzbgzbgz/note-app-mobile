// lib/main.dart

import 'package:flutter/material.dart';
import 'services/api_service.dart'; // Pastikan path ini benar ke api_service.dart
import 'models/note.dart';         // Pastikan path ini benar ke note.dart
import 'screens/add_note_screen.dart'; // <--- IMPORT LAYAR BARU KITA

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan App Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: NotesScreen(), 
    );
  }
}

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late Future<List<Note>> _futureNotes;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadNotes(); 
  }

  void _loadNotes() {
    setState(() {
      _futureNotes = apiService.fetchNotes();
    });
  }

  // Fungsi untuk navigasi ke halaman tambah dan handle hasil kembaliannya
  void _navigateToAddNoteScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddNoteScreen()),
    );

    // Jika AddNoteScreen mengirim 'true' (artinya ada penambahan/perubahan data)
    // maka kita panggil _loadNotes() lagi untuk refresh daftar
    if (result == true) {
      _loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Catatan Saya'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadNotes,
          ),
        ],
      ),
      body: FutureBuilder<List<Note>>(
        future: _futureNotes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } 
          else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error saat mengambil data:\n${snapshot.error}\n\nPastikan backend API berjalan dan _baseUrl di api_service.dart sudah benar (termasuk http://). Jika menjalankan di web, cek juga console browser (F12) untuk error CORS.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } 
          else if (snapshot.hasData) {
            final notes = snapshot.data!;

            if (notes.isEmpty) {
              return Center(child: Text('Belum ada catatan. Silakan tambahkan!'));
            }

            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: ListTile(
                    title: Text(note.title, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      note.content.length > 100 
                          ? '${note.content.substring(0, 100)}...' 
                          : note.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text('ID: ${note.id}'),
                    // onTap: () {
                    //   // Navigasi ke halaman detail/edit note dengan membawa data 'note'
                    // },
                  ),
                );
              },
            );
          } 
          else {
            return Center(child: Text('Tidak ada data catatan.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton( // <--- INI TOMBOL TAMBAHNYA
        onPressed: _navigateToAddNoteScreen,
        child: Icon(Icons.add),
        tooltip: 'Tambah Catatan Baru',
      ),
    );
  }
}