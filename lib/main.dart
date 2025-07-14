import 'dart:ui';
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as excel;
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

const firebaseConfig = FirebaseOptions(
  apiKey: "AIzaSyCSac8qdkg8CBFrYMQM9i46V5b4mcEIw7I",
  authDomain: "idphoto-e5a75.firebaseapp.com",
  projectId: "idphoto-e5a75",
  storageBucket: "idphoto-e5a75.appspot.com",
  messagingSenderId: "925678225145",
  appId: "1:925678225145:android:e74038cd1c14353ae8c428",
);

// --------- Student Model ---------
class Student {
  final String id;
  final String name;
  final String room;
  Uint8List? image;

  Student({required this.id, required this.name, required this.room, this.image});
}

// --------- Main ---------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseConfig);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ระบบรายชื่อนักเรียน',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/list': (context) => const ListScreen(),
      },
    );
  }
}

// --------- Login Screen (พื้นหลังภาพ + Glassmorphism) ---------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    setState(() => loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/list');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เข้าสู่ระบบไม่สำเร็จ: $e')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ---- ภาพพื้นหลัง (แฟนตาซี) ----
          Positioned.fill(
            child: Image.asset(
              'assets/fantasy_bg.png', // <<--- ชื่อไฟล์ภาพของคุณ
              fit: BoxFit.cover,
            ),
          ),
          // ---- กล่อง login glassmorphism ----
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Container(
                      width: 360,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.24),
                          width: 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.09),
                            blurRadius: 16,
                            offset: Offset(0, 7),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'EasyCrop',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 18),
                          const CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            backgroundImage: AssetImage('assets/mylogo.png'), // โลโก้
                          ),
                          const SizedBox(height: 26),
                          TextField(
                            controller: emailController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email, color: Colors.white70),
                              hintText: 'อีเมลผู้ใช้งาน',
                              hintStyle: TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: Colors.white30),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock, color: Colors.white70),
                              hintText: 'รหัสผ่าน',
                              hintStyle: TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: Colors.white30),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: loading ? null : login,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                                backgroundColor: Colors.blue.shade600.withOpacity(0.83),
                                elevation: 0,
                                foregroundColor: Colors.white,
                              ),
                              child: loading
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                'เข้าสู่ระบบ',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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

  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadStudentsFromExcel();
  }

  Future<void> loadStudentsFromExcel() async {
    final data = await rootBundle.load('assets/students_by_class_fixed.xlsx');
    final bytes = data.buffer.asUint8List();
    final excelFile = excel.Excel.decodeBytes(bytes);
    final sheet = excelFile.tables[excelFile.tables.keys.first]!;

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

  String extractLevel(String room) {
    if (room.contains('อนุบาล')) return 'อนุบาล';
    if (room.contains('ประถม')) return 'ประถม';
    if (room.contains('มัธยม')) return 'มัธยม';
    return 'อื่นๆ';
  }

  String extractYear(String room) {
    final reg = RegExp(r'(อนุบาล|ประถม|มัธยม)\s?(\d+)');
    final m = reg.firstMatch(room);
    if (m != null) {
      switch (m.group(1)) {
        case 'อนุบาล': return 'อนุบาล${m.group(2)}';
        case 'ประถม': return 'ป.${m.group(2)}';
        case 'มัธยม': return 'ม.${m.group(2)}';
      }
    }
    return 'อื่นๆ';
  }

  String extractRoom(String room) {
    final reg = RegExp(r'(\d+/\d+)');
    final m = reg.firstMatch(room);
    return m?.group(1) ?? room;
  }

  void downloadAllImages() {
    final int countHasImage = students.where((s) => s.image != null).length;
    final int countAll = students.length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('มีภาพสำหรับ $countHasImage จาก $countAll คน'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  // ---------- ถ่าย/เลือกรูป ----------
  Future<void> pickImageForStudent(Student student) async {
    final picked = await picker.pickImage(source: ImageSource.camera); // เปลี่ยนเป็น .gallery ได้
    if (picked != null) {
      final imgBytes = await picked.readAsBytes();
      setState(() {
        student.image = imgBytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = students.where((s) {
      bool matchLevel = (level == 'ระดับชั้น') || (extractLevel(s.room) == level);
      bool matchYear = (year == 'ชั้นปี') || (extractYear(s.room) == year);
      bool matchRoom = (room == 'ห้อง') || (extractRoom(s.room) == room);
      final q = query.trim().toLowerCase();
      bool matchQuery = s.name.toLowerCase().contains(q)
          || s.id.contains(q)
          || s.room.toLowerCase().contains(q);
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
        backgroundColor: const Color(0xFF263238),
        title: const Text(
          'รายการนักเรียน',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: logout,
            icon: Icon(Icons.logout, color: Colors.white),
            tooltip: "ออกจากระบบ",
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: DropdownMenuBox(value: level, options: levelOptions, onChanged: (v) {
                      setState(() {
                        level = v;
                        year = 'ชั้นปี';
                        room = 'ห้อง';
                      });
                    })),
                    const SizedBox(width: 8),
                    Expanded(child: DropdownMenuBox(value: year, options: yearOptions, onChanged: (v) {
                      setState(() {
                        year = v;
                        room = 'ห้อง';
                      });
                    })),
                    const SizedBox(width: 8),
                    Expanded(child: DropdownMenuBox(value: room, options: roomOptions, onChanged: (v) {
                      setState(() => room = v);
                    })),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'ค้นหา...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                  ),
                  onChanged: (v) => setState(() => query = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final s = filtered[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  color: const Color(0xFFE0F7FA),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFB2EBF2),
                      child: Text('${index + 1}', style: const TextStyle(color: Colors.black)),
                    ),
                    title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('รหัส: ${s.id}  |  ห้อง: ${s.room}'),
                    trailing: IconButton(
                      icon: s.image != null
                          ? CircleAvatar(
                        backgroundImage: MemoryImage(s.image!),
                        radius: 20,
                      )
                          : Icon(Icons.camera_alt, color: Colors.grey[700]),
                      onPressed: () => pickImageForStudent(s),
                      tooltip: "ถ่าย/เลือกรูป",
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 48,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: downloadAllImages,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download_for_offline_rounded, color: Colors.white, size: 26),
                        SizedBox(width: 12),
                        Text(
                          'ดาวน์โหลดภาพทั้งหมด',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --------- DropdownMenuBox ---------
class DropdownMenuBox extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const DropdownMenuBox({required this.value, required this.options, required this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: options.contains(value) ? value : null,
      hint: Text(value),
      items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
      onChanged: (v) { if (v != null) onChanged(v); },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.blue.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dropdownColor: Colors.blue.shade50,
      icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
      style: const TextStyle(color: Colors.black),
    );
  }
}
