import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

// --------- MyApp & Routing ---------
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF00BCD4), Colors.white],
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
              Text(
              'โดนGuหลอกja',
              style: TextStyle(fontSize: 26, color: Colors.white),
            ),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Color(0xFF42A5F5),
                  elevation: 8,
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/list');
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
            SizedBox(height: 8,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      // ใส่ฟังก์ชันลืมรหัสผ่านที่นี่
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('ฟังก์ชันลืมรหัสผ่าน')),
                      );
                    },
                    child: Text(
                      'ลืมรหัสผ่าน?',
                      style: TextStyle(
                        color: Color(0xFF2196F3),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // ใส่ฟังก์ชันสมัครสมาชิกที่นี่
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('ฟังก์ชันสมัครสมาชิก')),
                      );
                    },
                    child: Text(
                      'สมัครสมาชิก',
                      style: TextStyle(
                        color: Color(0xFF2196F3),
                        decoration: TextDecoration.underline,
                      ),
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
  String level = 'ระดับชั้น';
  String year = 'ชั้นปี';
  String room = 'ห้อง';
  String query = '';

  final names = [
    'สมชาย ชายจริงๆ',
    'สมศรี อิอิ',
    'สุรชัย เด็ดจริง',
    'ปริญญา ล่าให้พ่อ',
    'จินตนา การสิ'
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = names.where(👎 => n.contains(query)).toList();

    return Scaffold(
    appBar: AppBar(
    title: Text('นี่คือหน้ารายการข้อมูล'),
    leading: IconButton(
    icon: Icon(Icons.arrow_back),
    onPressed: () => Navigator.pop(context),
    ),
    ),
    body: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
    children: [
    Row(
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
    SizedBox(width: 😎,
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
    SizedBox(width: 😎,
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
    TextField(
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
    onChanged: (v) => setState(() => query = v),
    ),
    SizedBox(height: 16),
    Expanded(
    child: SingleChildScrollView(
    scrollDirection: Axis.vertical,
    child: DataTable(
    columns: const [
    DataColumn(label: Text('รหัส')),
    DataColumn(label: Text('ชื่อ')),
    DataColumn(label: Icon(Icons.camera_alt)),
    ],
    rows: filtered.map((name) {
    final id = names.indexOf(name) + 1;
    return DataRow(
    cells: [
    DataCell(Text('$id')),
    DataCell(Text(name)),
    DataCell(
    IconButton(
    icon: Icon(Icons.camera_alt),
    onPressed: () {},
    ),
    ),
    ],
    );
    }).toList(),
    headingRowColor: MaterialStateProperty.all(Color(0xFFE0E0E0)),
    dividerThickness: 1,
    dataRowHeight: 48,
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

  const DropdownMenuBox({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: options.contains(value) ? value : null,
      hint: Text(value),
      items: options
          .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
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