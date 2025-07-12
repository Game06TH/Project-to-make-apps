import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

// --------- Student Model ---------
class Student {
  final String id;
  final String name;
  final String room;
  Uint8List? image;

  Student({required this.id, required this.name, required this.room, this.image});
}

// --------- Main ---------
void main() {
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
      home: const ListScreen(),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('สมมติว่าบันทึกรูปภาพทั้งหมดเรียบร้อย')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = students.where((s) {
      bool matchLevel = (level == 'ระดับชั้น') || (extractLevel(s.room) == level);
      bool matchYear  = (year == 'ชั้นปี')     || (extractYear(s.room) == year);
      bool matchRoom  = (room == 'ห้อง')      || (extractRoom(s.room) == room);
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
        backgroundColor: Color(0xFF263238),
        title: Text(
          'รายการนักเรียน',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
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
                    SizedBox(width: 8),
                    Expanded(child: DropdownMenuBox(value: year, options: yearOptions, onChanged: (v) {
                      setState(() {
                        year = v;
                        room = 'ห้อง';
                      });
                    })),
                    SizedBox(width: 8),
                    Expanded(child: DropdownMenuBox(value: room, options: roomOptions, onChanged: (v) {
                      setState(() => room = v);
                    })),
                  ],
                ),
                SizedBox(height: 8),
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
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  color: Color(0xFFE0F7FA),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(0xFFB2EBF2),
                      child: Text('${index + 1}', style: TextStyle(color: Colors.black)),
                    ),
                    title: Text(s.name, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('รหัส: ${s.id}  |  ห้อง: ${s.room}'),
                    trailing: Icon(Icons.camera_alt),
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
                    duration: Duration(milliseconds: 160),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.12),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
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