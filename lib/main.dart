import 'package:flutter/material.dart'; // นำเข้าแพ็กเกจ Material Design ของ Flutter

void main() {
  runApp(MyApp()); // เรียกใช้แอป โดยเริ่มจาก Widget หลักชื่อ MyApp
}

// --------- MyApp & Routing ---------
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue, // ตั้งค่าสีธีมหลักของแอป
        useMaterial3: true, // ใช้ Material Design 3
      ),
      debugShowCheckedModeBanner: false, // ปิดแถบ Debug ที่มุมขวาบน
      initialRoute: '/', // เส้นทางเริ่มต้นของแอป
      routes: {
        '/': (context) => LoginScreen(), // เส้นทางไปหน้าล็อกอิน
        '/list': (context) => ListScreen(), // เส้นทางไปหน้ารายการข้อมูล
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
  String email = '', password = ''; // ตัวแปรเก็บอีเมลและรหัสผ่านที่ผู้ใช้กรอก

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient( // พื้นหลังแบบไล่สี
            colors: [Color(0xFF2C3E50), Color(0xFF00BCD4), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView( // ให้สามารถเลื่อนหน้าจอได้เมื่อคีย์บอร์ดขึ้น
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text( // หัวข้อบนหน้าจอ
                  'โดนGuหลอกja',
                  style: TextStyle(fontSize: 26, color: Colors.white),
                ),
                SizedBox(height: 16),
                CircleAvatar( // โลโก้รูปกลม
                  radius: 80,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/mylogo.png'),
                ),
                SizedBox(height: 32),
                TextField( // ช่องกรอกอีเมล
                  decoration: InputDecoration(
                    labelText: 'อีเมลผู้ใช้งาน',
                    prefixIcon: Icon(Icons.email, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (v) => setState(() => email = v), // เมื่อพิมพ์จะบันทึกลงตัวแปร
                ),
                SizedBox(height: 16),
                TextField( // ช่องกรอกรหัสผ่าน
                  obscureText: true, // ซ่อนข้อความ
                  decoration: InputDecoration(
                    labelText: 'รหัสผ่าน',
                    prefixIcon: Icon(Icons.lock, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (v) => setState(() => password = v),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton( // ปุ่มเข้าสู่ระบบ
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Color(0xFF42A5F5),
                      elevation: 8,
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/list'); // ไปยังหน้ารายการ
                    },
                    child: Text(
                      'เข้าสู่ระบบ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Row( // ลิงก์ลืมรหัสผ่าน และสมัครสมาชิก
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ลืมรหัสผ่าน?',
                      style: TextStyle(
                        color: Color(0xFF2196F3),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    Text(
                      'สมัครสมาชิก',
                      style: TextStyle(
                        color: Color(0xFF2196F3),
                        decoration: TextDecoration.underline,
                      ),
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
  // ตัวแปรเก็บค่าที่เลือกจาก dropdown
  String level = 'ระดับชั้น';
  String year = 'ชั้นปี';
  String room = 'ห้อง';
  String query = ''; // ข้อความค้นหา

  final names = ['สมชาย', 'สมศรี', 'สุรชัย', 'ปริญญา', 'จินตนา']; // รายชื่อสมมติ

  @override
  Widget build(BuildContext context) {
    final filtered = names.where((n) => n.contains(query)).toList(); // กรองรายชื่อจากคำค้น

    return Scaffold(
      appBar: AppBar(
        title: Text('นี่คือหน้ารายการข้อมูล'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // ปุ่มย้อนกลับ
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row( // แถว dropdown ทั้ง 3 ช่อง
              children: [
                Expanded(
                  child: DropdownMenuBox(
                    value: level,
                    options: ['อนุบาล', 'ประถม', 'มัธยม'],
                    onChanged: (v) {
                      setState(() {
                        level = v;
                        year = 'ชั้นปี';
                        room = 'ห้อง';
                      });
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: DropdownMenuBox(
                    value: year,
                    options: level == 'อนุบาล'
                        ? ['อนุบาล1', 'อนุบาล2', 'อนุบาล3']
                        : level == 'ประถม'
                        ? List.generate(6, (i) => 'ป.${i + 1}')
                        : level == 'มัธยม'
                        ? List.generate(6, (i) => 'ม.${i + 1}')
                        : [],
                    onChanged: (v) {
                      setState(() {
                        year = v;
                        room = 'ห้อง';
                      });
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: DropdownMenuBox(
                    value: room,
                    options: ['1/1', '1/2', '1/3', '1/4', '1/5', '1/6'],
                    onChanged: (v) {
                      setState(() {
                        room = v;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField( // ช่องค้นหาชื่อ
              decoration: InputDecoration(
                hintText: 'ค้นหา...',
                prefixIcon: Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Color(0xFF42A5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintStyle: TextStyle(color: Colors.white70),
              ),
              style: TextStyle(color: Colors.white),
              onChanged: (v) => setState(() => query = v), // ค้นหาชื่อเมื่อเปลี่ยนข้อความ
            ),
            SizedBox(height: 16),
            Container( // หัวตาราง
              color: Color(0xFFE0E0E0),
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(flex: 1, child: Text('รหัส')),
                  Expanded(flex: 3, child: Text('ชื่อ')),
                  Icon(Icons.grid_view),
                ],
              ),
            ),
            Divider(),
            Expanded(
              child: ListView.separated( // แสดงรายการที่กรองแล้ว
                itemCount: filtered.length,
                separatorBuilder: (_, __) => Divider(),
                itemBuilder: (context, i) {
                  final name = filtered[i];
                  final id = names.indexOf(name) + 1;
                  return Row(
                    children: [
                      Expanded(flex: 1, child: Text('$id')),
                      Expanded(flex: 3, child: Text(name)),
                      IconButton(
                        icon: Icon(Icons.camera_alt),
                        onPressed: () {}, // ปุ่มกล้อง (ยังไม่มีฟังก์ชัน)
                      ),
                    ],
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

  const DropdownMenuBox({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: options.contains(value) ? value : null, // ตรวจว่าค่าเริ่มต้นอยู่ใน options ไหม
      hint: Text(value),
      items: options
          .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v); // ถ้าเลือกค่าใหม่ไม่เป็น null ให้ส่งกลับ
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xFF42A5F5),
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dropdownColor: Color(0xFF42A5F5),
      icon: Icon(Icons.arrow_drop_down, color: Colors.white),
      style: TextStyle(color: Colors.white),
    );
  }
}
