import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';  // Firebase Analytics
import 'package:firebase_auth/firebase_auth.dart';  // Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart';  // Firebase Firestore
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

// --------- Student Model ---------
class Student {
  final String id;
  final String name;
  final String room;
  Uint8List? image;

  Student({required this.id, required this.name, required this.room, this.image});
}

// --------- main() ---------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // Firebase initialization

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/list': (context) => ListScreen(),
      },
    );
  }
}

// --------- Login Screen ---------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = '', password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF263238), Color(0xFF37474F), Color(0xFF00BCD4), Color(0xFFF5F5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('ระบบรายชื่อนักเรียน', style: TextStyle(fontSize: 26, color: Colors.white)),
                SizedBox(height: 16),
                CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/mylogo.png'),
                ),
                SizedBox(height: 32),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'อีเมลผู้ใช้งาน',
                    prefixIcon: Icon(Icons.email, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (v) => setState(() => email = v),
                ),
                SizedBox(height: 16),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'รหัสผ่าน',
                    prefixIcon: Icon(Icons.lock, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (v) => setState(() => password = v),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Color(0xFF42A5F5),
                      elevation: 8,
                    ),
                    onPressed: () async {
                      // Firebase Authentication
                      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      Navigator.pushReplacementNamed(context, '/list');
                    },
                    child: Text('เข้าสู่ระบบ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --------- List Screen ---------
class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  String level = 'ระดับชั้น';
  String year = 'ชั้นปี';
  String room = 'ห้อง';
  String query = '';

  List<Student> students = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadStudentsFromExcel();
  }

  Future<void> loadStudentsFromExcel() async {
    final data = await rootBundle.load('assets/students_by_class_fixed.xlsx');
    final bytes = data.buffer.asUint8List();
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables[excel.tables.keys.first]!;

    List<Student> loaded = [];
    for (var row in sheet.rows.skip(1)) {
      final id = row[0]?.value.toString() ?? '';
      final name = row[1]?.value.toString() ?? '';
      final room = row[2]?.value.toString() ?? '';
      if (id.isNotEmpty && name.isNotEmpty && room.isNotEmpty) {
        loaded.add(Student(id: id, name: name, room: room));
      }
    }
    setState(() {
      students = loaded;
      loading = false;
    });
  }

  // ฟังก์ชันเลือก/ถ่ายรูป (context ต้องส่งมาด้วย)
  Future<Uint8List?> pickAndCropImage(BuildContext context) async {
    final picker = ImagePicker();

    final source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('เลือกแหล่งรูปภาพ'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, ImageSource.camera),
            child: Row(
              children: [Icon(Icons.camera_alt), SizedBox(width: 8), Text('ถ่ายรูปด้วยกล้อง')],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, ImageSource.gallery),
            child: Row(
              children: [Icon(Icons.image), SizedBox(width: 8), Text('เลือกรูปจากแกลเลอรี่')],
            ),
          ),
        ],
      ),
    );
    if (source == null) return null;
    final XFile? pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      return await pickedFile.readAsBytes();
    }
    return null;
  }

  void downloadAllImages() {
    final readyImages = students.where((s) => s.image != null).toList();
    if (readyImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ยังไม่มีรูปภาพที่ถ่ายหรืออัปโหลด!')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('รวมรูปทั้งหมด'),
        content: Text('สมมติว่าบันทึกรูป ${readyImages.length} ไฟล์ไปยังเครื่องแล้ว'),
      ),
    );
  }

  String extractLevel(String room) {
    if (room.contains('อนุบาล')) return 'อนุบาล';
    if (room.contains('ประถม')) return 'ประถม';
    if (room.contains('มัธยม')) return 'มัธยม';
    return 'อื่นๆ';
  }

  String extractYear(String room) {
    final reg = RegExp(r'(อนุบาล|ประถม|มัธยม) ?(\d+)');
    final m = reg.firstMatch(room);
    if (m != null) {
      if (m.group(1) == 'อนุบาล') return 'อนุบาล${m.group(2)}';
      if (m.group(1) == 'ประถม') return 'ป.${m.group(2)}';
      if (m.group(1) == 'มัธยม') return 'ม.${m.group(2)}';
    }
    return 'อื่นๆ';
  }

  String extractRoom(String room) {
    final reg = RegExp(r'(\d+/\d+)');
    final m = reg.firstMatch(room);
    if (m != null) return m.group(1) ?? room;
    return room;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = students.where((n) {
      bool matchLevel = (level == 'ระดับชั้น') || (extractLevel(n.room) == level);
      bool matchYear = (year == 'ชั้นปี') || (extractYear(n.room) == year);
      bool matchRoom = (room == 'ห้อง') || (extractRoom(n.room) == room);
      final q = query.trim().toLowerCase();
      bool matchQuery = n.name.toLowerCase().contains(q) ||
          n.id.contains(q) ||
          n.room.toLowerCase().contains(q);
      return matchLevel && matchYear && matchRoom && matchQuery;
    }).toList();

    final levelOptions = ['ระดับชั้น', ...{
      ...students.map((s) => extractLevel(s.room))
    }..remove('อื่นๆ')];
    final yearOptions = ['ชั้นปี', ...{
      ...students.where((s) => level == 'ระดับชั้น' || extractLevel(s.room) == level)
          .map((s) => extractYear(s.room))
    }..remove('อื่นๆ')];
    final roomOptions = ['ห้อง', ...{
      ...students.where((s) =>
          (level == 'ระดับชั้น' || extractLevel(s.room) == level) &&
          (year == 'ชั้นปี' || extractYear(s.room) == year)
      ).map((s) => extractRoom(s.room))
    }];

    return Scaffold(
      appBar: AppBar(
        title: Text('รายการนักเรียน'),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final student = filtered[index];
                return ListTile(
                  title: Text(student.name),
                  subtitle: Text('รหัส: ${student.id} | ห้อง: ${student.room}'),
                );
              },
            ),
    );
  }
}
