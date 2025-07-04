import 'package:flutter/material.dart';
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
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
                    onPressed: () => Navigator.pushReplacementNamed(context, '/list'),
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

  // --- ฟังก์ชันเลือก/ถ่ายรูป (context ต้องส่งมาด้วย) ---
  Future<Uint8List?> pickAndCropImage(BuildContext context) async {
    final picker = ImagePicker();

    // ให้ผู้ใช้เลือกว่าจะใช้กล้องหรือเลือกรูปจากแกลเลอรี่
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
      bool matchYear  = (year == 'ชั้นปี')     || (extractYear(n.room) == year);
      bool matchRoom  = (room == 'ห้อง')      || (extractRoom(n.room) == room);
      final q = query.trim().toLowerCase();
      bool matchQuery = n.name.toLowerCase().contains(q)
          || n.id.contains(q)
          || n.room.toLowerCase().contains(q);
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

    final studentsWithImage = students.where((s) => s.image != null).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF263238),
        title: Text('รายการนักเรียน', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: DropdownMenuBox(value: level, options: levelOptions, onChanged: (v) => setState(() {
                  level = v;
                  year = 'ชั้นปี';
                  room = 'ห้อง';
                }))),
                SizedBox(width: 8),
                Expanded(child: DropdownMenuBox(value: year, options: yearOptions, onChanged: (v) => setState(() {
                  year = v;
                  room = 'ห้อง';
                }))),
                SizedBox(width: 8),
                Expanded(child: DropdownMenuBox(value: room, options: roomOptions, onChanged: (v) => setState(() { room = v; }))),
              ],
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: 'ค้นหา...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (v) => setState(() => query = v),
            ),
            SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final student = filtered[index];
                  return Card(
                    color: Color(0xFFE0F7FA),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(0xFFB2EBF2),
                        child: student.image != null
                            ? ClipOval(child: Image.memory(student.image!, fit: BoxFit.cover, width: 40, height: 40))
                            : Text('${index + 1}', style: TextStyle(color: Colors.black)),
                      ),
                      title: Text(student.name, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('รหัส: ${student.id}  |  ห้อง: ${student.room}'),
                      trailing: IconButton(
                        icon: Icon(Icons.camera_alt),
                        onPressed: () async {
                          Uint8List? img = await pickAndCropImage(context);
                          if (img != null) {
                            setState(() {
                              student.image = img;
                            });
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // -------- ปุ่มดาวน์โหลดสไตล์ใหม่ (โชว์ตลอดเวลา) --------
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: SizedBox(
                  width: 280,
                  height: 90,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF42A5F5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 6,
                      shadowColor: Colors.blueAccent.withOpacity(0.2),
                    ),
                    onPressed: downloadAllImages,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_downward, color: Colors.white, size: 34),
                        SizedBox(height: 8),
                        Text(
                          'DOWNLOAD',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 22,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------- DropdownMenuBox Widget ---------
class DropdownMenuBox extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const DropdownMenuBox({required this.value, required this.options, required this.onChanged});

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
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dropdownColor: Colors.blue.shade50,
      icon: Icon(Icons.arrow_drop_down, color: Colors.black),
      style: TextStyle(color: Colors.black),
    );
  }
}
