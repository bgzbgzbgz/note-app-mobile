// lib/main.dart

import 'package:flutter/material.dart';
import 'services/api_service.dart'; //
import 'models/note.dart';         //
import 'screens/add_note_screen.dart'; //
import 'screens/edit_note_screen.dart';

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

  void _navigateToAddNoteScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddNoteScreen()),
    );

    if (result == true) {
      _loadNotes();
    }
  }

  void _navigateToEditNoteScreen(Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditNoteScreen(note: note)),
    );

    if (result == true) {
      _loadNotes();
    }
  }

  // --- FUNGSI BARU UNTUK DIALOG KONFIRMASI HAPUS ---
  Future<void> _showDeleteConfirmationDialog(String noteId, String noteTitle) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Pengguna harus memilih salah satu aksi
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Apakah Anda yakin ingin menghapus catatan "$noteTitle"?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
            ),
            TextButton(
              child: Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop(); // Tutup dialog dulu
                try {
                  await apiService.deleteNote(noteId);
                  _loadNotes(); // Refresh daftar catatan
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Catatan "$noteTitle" berhasil dihapus')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menghapus catatan: $e')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
  // --- AKHIR FUNGSI DIALOG HAPUS ---

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
                    // Ganti trailing Text dengan Row untuk tombol Edit dan Delete
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min, // Agar Row tidak memakan semua space
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          tooltip: 'Edit Catatan',
                          onPressed: () {
                            _navigateToEditNoteScreen(note);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Hapus Catatan',
                          onPressed: () {
                            _showDeleteConfirmationDialog(note.id, note.title);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      // Kamu bisa biarkan onTap untuk edit, atau hapus jika sudah ada tombol edit khusus
                      // _navigateToEditNoteScreen(note);
                      // Atau jika ingin onTap tetap berfungsi sebagai view detail (jika ada halaman detail)
                      print('Tapped on note ID: ${note.id}');
                    },
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
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddNoteScreen,
        child: Icon(Icons.add),
        tooltip: 'Tambah Catatan Baru',
      ),
    );
  }
}