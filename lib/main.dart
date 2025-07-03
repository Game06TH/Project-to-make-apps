import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show rootBundle;

// --------- Student Model ---------
class Student {
  final String id;
  final String name;

  Student({required this.id, required this.name});
}

// --------- Main App & Routing ---------
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
                Text('โดนGuหลอกja', style: TextStyle(fontSize: 26, color: Colors.white)),
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
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Text('ลืมรหัสผ่าน?', style: TextStyle(color: Color(0xFF2196F3), decoration: TextDecoration.underline)),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text('สมัครสมาชิก', style: TextStyle(color: Color(0xFF2196F3), decoration: TextDecoration.underline)),
                    ),
                  ],
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
    final data = await rootBundle.load('assets/students.xlsx');
    final bytes = data.buffer.asUint8List();
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables[excel.tables.keys.first]!;

    List<Student> loaded = [];
    for (var row in sheet.rows.skip(1)) {
      final id = row[0]?.value.toString() ?? '';
      final name = row[1]?.value.toString() ?? '';
      if (id.isNotEmpty && name.isNotEmpty) {
        loaded.add(Student(id: id, name: name));
      }
    }
    setState(() {
      students = loaded;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = students.where((n) {
      final name = n.name.trim().toLowerCase();
      final id = n.id.trim();
      final q = query.trim().toLowerCase();
      return name.contains(q) || id.contains(query.trim());
    }).toList();

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
                Expanded(child: DropdownMenuBox(value: level, options: ['อนุบาล', 'ประถม', 'มัธยม'], onChanged: (v) => setState(() { level = v; year = 'ชั้นปี'; room = 'ห้อง'; }))),
                SizedBox(width: 8),
                Expanded(child: DropdownMenuBox(value: year, options: level == 'อนุบาล' ? ['อนุบาล1', 'อนุบาล2', 'อนุบาล3'] : level == 'ประถม' ? List.generate(6, (i) => 'ป.${i + 1}') : level == 'มัธยม' ? List.generate(6, (i) => 'ม.${i + 1}') : [], onChanged: (v) => setState(() { year = v; room = 'ห้อง'; }))),
                SizedBox(width: 8),
                Expanded(child: DropdownMenuBox(value: room, options: ['1/1', '1/2', '1/3', '1/4', '1/5', '1/6'], onChanged: (v) => setState(() { room = v; }))),
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
                        child: Text('${index + 1}', style: TextStyle(color: Colors.black)),
                      ),
                      title: Text(student.name, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('รหัส: ${student.id}'),
                      trailing: IconButton(
                        icon: Icon(Icons.camera_alt),
                        onPressed: () {
                          // Handle camera tap
                        },
                      ),
                    ),
                  );
                },
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