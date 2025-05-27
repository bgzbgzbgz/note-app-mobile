// lib/main.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart'; 
import 'models/note.dart';         
import 'screens/add_note_screen.dart'; 
import 'screens/edit_note_screen.dart';
import 'screens/note_view_screen.dart'; 

// --- TEMA ---
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
  colorScheme: ColorScheme.light(
    primary: Colors.blue.shade700,
    secondary: Colors.lightBlue.shade300,
    surface: Colors.white,
    background: Colors.grey.shade200,
    error: Colors.red.shade700,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: Colors.black,
    onBackground: Colors.black,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: Colors.grey.shade200, //
  appBarTheme: AppBarTheme(
    color: Colors.blue.shade700,
    elevation: 4,
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  cardTheme: CardTheme(
    elevation: 1.5,
    margin: EdgeInsets.all(8.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    color: Colors.white,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.blue.shade700,
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue.shade600,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      textStyle: TextStyle(fontSize: 16),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: Colors.blue.shade700, width: 2.0),
    ),
    labelStyle: TextStyle(color: Colors.blue.shade800),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.blue,
  colorScheme: ColorScheme.dark(
    primary: Colors.blue.shade400,
    secondary: Colors.lightBlue.shade700,
    surface: Color(0xFF2c2c2e),
    background: Color(0xFF1c1c1e),
    error: Colors.red.shade400,
    onPrimary: Colors.black,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    onBackground: Colors.white,
    onError: Colors.black,
  ),
  scaffoldBackgroundColor: Color(0xFF1c1c1e), //
  appBarTheme: AppBarTheme(
    color: Color(0xFF1F1F1F),
    elevation: 4,
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  cardTheme: CardTheme(
    elevation: 1.5,
    margin: EdgeInsets.all(8.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    color: Color(0xFF2c2c2e),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.blue.shade500,
    foregroundColor: Colors.black,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue.shade500,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      textStyle: TextStyle(fontSize: 16),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: Colors.blue.shade400, width: 2.0),
    ),
    labelStyle: TextStyle(color: Colors.blue.shade300),
  ),
);
// --- AKHIR TEMA ---

const String _themeModeKey = 'themeMode';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  void _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString(_themeModeKey);
    if (themeModeString != null) {
      setState(() {
        _themeMode = ThemeMode.values.firstWhere(
          (e) => e.toString() == themeModeString,
          orElse: () => ThemeMode.system,
        );
      });
    }
  }

  void _changeThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, themeMode.toString());
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan App Flutter',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      home: NotesScreen(
        currentThemeMode: _themeMode,
        onThemeModeChanged: _changeThemeMode,
      ),
    );
  }
}

class NotesScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final Function(ThemeMode) onThemeModeChanged;

  NotesScreen({
    required this.currentThemeMode,
    required this.onThemeModeChanged,
  });

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

  void _navigateToViewNoteScreen(Note note) async {
    final resultFromView = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteViewScreen(note: note)),
    );

    if (resultFromView == true) { // Jika NoteViewScreen di-pop dan memberi sinyal ada perubahan
      _loadNotes();
    }
  }

  // Fungsi _navigateToEditNoteScreen mungkin tidak dipanggil langsung dari sini lagi,
  // tapi kita biarkan untuk referensi atau penggunaan lain jika ada.
  void _navigateToEditNoteScreen(Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditNoteScreen(note: note)),
    );

    if (result is Note || result == true) {
      _loadNotes();
    }
  }

  Future<void> _showDeleteConfirmationDialog(String noteId, String noteTitle) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
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
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text('Hapus', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await apiService.deleteNote(noteId);
                  _loadNotes();
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

  void _showThemePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Pilih Tema Aplikasi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile<ThemeMode>(
                title: const Text('Terang'),
                value: ThemeMode.light,
                groupValue: widget.currentThemeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    widget.onThemeModeChanged(value);
                    Navigator.pop(dialogContext);
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Gelap'),
                value: ThemeMode.dark,
                groupValue: widget.currentThemeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    widget.onThemeModeChanged(value);
                    Navigator.pop(dialogContext);
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Sistem'),
                value: ThemeMode.system,
                groupValue: widget.currentThemeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    widget.onThemeModeChanged(value);
                    Navigator.pop(dialogContext);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenPadding = MediaQuery.of(context).padding;
    final horizontalPadding = 12.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Catatan Saya'),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6_outlined),
            tooltip: 'Ganti Tema',
            onPressed: _showThemePickerDialog,
          ),
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

            return GridView.builder(
              padding: EdgeInsets.only(
                left: horizontalPadding,
                right: horizontalPadding,
                top: 16.0,
                bottom: screenPadding.bottom + 80,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.85,
              ),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return InkWell(
                  onTap: () {
                    _navigateToViewNoteScreen(note);
                  },
                  borderRadius: BorderRadius.circular(12.0), // Sesuai CardTheme
                  child: Card(
                    // Margin, shape, dan color diambil dari CardTheme
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            note.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6.0),
                          Expanded(
                            child: Text(
                              note.content,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete_outline, size: 20, color: Theme.of(context).colorScheme.error),
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                tooltip: 'Hapus Catatan',
                                onPressed: () {
                                  _showDeleteConfirmationDialog(note.id, note.title);
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
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