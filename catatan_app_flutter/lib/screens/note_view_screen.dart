// lib/screens/note_view_screen.dart
import 'package:flutter/material.dart'; // IMPORT INI SANGAT PENTING
import '../models/note.dart';
import '../services/api_service.dart';
import 'edit_note_screen.dart';

class NoteViewScreen extends StatefulWidget {
  final Note note;

  NoteViewScreen({required this.note});

  @override
  _NoteViewScreenState createState() => _NoteViewScreenState();
}

class _NoteViewScreenState extends State<NoteViewScreen> {
  late Note _currentNote;
  final ApiService apiService = ApiService(); // Instance ApiService

  @override
  void initState() {
    super.initState();
    _currentNote = widget.note; // Simpan note awal
  }

  // Fungsi untuk dialog konfirmasi hapus
  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Pengguna harus memilih salah satu aksi
      builder: (BuildContext dialogContext) { // Menggunakan dialogContext agar tidak bentrok
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Apakah Anda yakin ingin menghapus catatan "${_currentNote.title}"?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Tutup dialog
              },
            ),
            TextButton(
              child: Text('Hapus', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Tutup dialog dulu
                try {
                  await apiService.deleteNote(_currentNote.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Catatan "${_currentNote.title}" berhasil dihapus')),
                    );
                    // Kembali ke NotesScreen dan signal untuk refresh
                    Navigator.of(context).pop(true);
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

  @override
  Widget build(BuildContext context) {
    // WillPopScope untuk mengirim sinyal refresh ke NotesScreen jika ada perubahan
    return WillPopScope(
      onWillPop: () async {
        // Cek apakah _currentNote (yang mungkin sudah diupdate setelah kembali dari EditScreen)
        // berbeda dengan widget.note (note awal saat layar ini dibuka).
        // Jika berbeda, berarti ada update, kita kirim true agar NotesScreen refresh.
        // Perbandingan updatedAt adalah cara yang baik untuk mendeteksi perubahan.
        if (_currentNote.updatedAt != widget.note.updatedAt || 
            _currentNote.title != widget.note.title || 
            _currentNote.content != widget.note.content) {
           Navigator.pop(context, true); // Kirim true untuk refresh NotesScreen
        } else {
           Navigator.pop(context, false); // Tidak ada perubahan, tidak perlu refresh
        }
        return false; // Kita sudah handle pop secara manual, jadi return false
                      // agar sistem tidak melakukan pop default.
      },
      child: Scaffold(
        appBar: AppBar(
          // Tombol back AppBar juga akan dihandle oleh WillPopScope
          // atau kita bisa provide handler manual jika perlu:
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              if (_currentNote.updatedAt != widget.note.updatedAt || 
                  _currentNote.title != widget.note.title || 
                  _currentNote.content != widget.note.content) {
                 Navigator.pop(context, true);
              } else {
                 Navigator.pop(context, false);
              }
            },
          ),
          title: Text(
            _currentNote.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.edit_outlined),
              tooltip: 'Edit Catatan',
              onPressed: () async {
                 final resultFromEdit = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditNoteScreen(note: _currentNote)),
                );
                // Jika EditNoteScreen di-pop (baik dengan tombol back atau setelah save)
                // dan mengembalikan objek Note yang sudah diupdate.
                if (resultFromEdit is Note) {
                  setState(() {
                    _currentNote = resultFromEdit;
                  });
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.delete_outline),
              tooltip: 'Hapus Catatan',
              onPressed: _showDeleteConfirmationDialog,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0), // Padding bawah lebih besar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _currentNote.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 8.0),
              Text(
                'Terakhir diubah: ${_formatDateTime(_currentNote.updatedAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
              ),
              Divider(height: 24.0, thickness: 0.5),
              SelectableText(
                _currentNote.content,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi helper untuk memformat tanggal
  String _formatDateTime(String dateTimeString) {
    try {
      final DateTime dateTime = DateTime.parse(dateTimeString);
      // Format sederhana, bisa menggunakan package 'intl' untuk format yang lebih baik
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString; // Kembalikan string asli jika parsing gagal
    }
  }
}