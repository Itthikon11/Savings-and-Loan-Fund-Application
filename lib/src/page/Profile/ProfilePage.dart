import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:appproject/src/page/Home/HomePage.dart';

class Profilepage extends StatefulWidget {
  final String idUser;

  const Profilepage({Key? key, required this.idUser}) : super(key: key);

  @override
  State<Profilepage> createState() => _ProfileState();
}

class _ProfileState extends State<Profilepage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool showPin = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final response = await http.get(
          Uri.parse("http://192.168.1.40:3001/Profile/users/${widget.idUser}")
      );

      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['message'] == 'พบผู้ใช้งาน') {
          setState(() {
            userData = data['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            userData = {"error": "ไม่พบข้อมูล"};
            isLoading = false;
          });
        }
      } else {
        setState(() {
          userData = {"error": "ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์"};
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        userData = {"error": "เกิดข้อผิดพลาด: $e"};
        isLoading = false;
      });
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("โปรไฟล์"),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage(idUser: widget.idUser)),
                  (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData!['error'] != null
          ? Center(child: Text(userData!['error']))
          : Container(
        color: Colors.green,
        child: Column(
          children: [
            Container(
              color: Colors.green,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 60, color: Colors.grey),
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: ListView(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.orange),
                      title: const Text("ชื่อผู้ใช้", style: TextStyle(fontSize: 18)),
                      subtitle: Text(
                        "${userData?['pre_name'] ?? ''} ${userData?['first_name'] ?? 'ไม่มีข้อมูล'} ${userData?['last_name'] ?? 'ไม่มีข้อมูล'}",
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone, color: Colors.green),
                      title: const Text("เบอร์โทร", style: TextStyle(fontSize: 18)),
                      subtitle: Text(userData?['phone_number'] ?? "ไม่มีข้อมูลเบอร์โทร"),
                    ),
                    ListTile(
                      leading: const Icon(Icons.home, color: Colors.blue),
                      title: const Text("ที่อยู่", style: TextStyle(fontSize: 18)),
                      subtitle: Text(userData?['address'] ?? "ไม่มีข้อมูลที่อยู่"),
                    ),
                    ListTile(
                      leading: const Icon(Icons.work, color: Colors.brown),
                      title: const Text("บทบาท", style: TextStyle(fontSize: 18)),
                      subtitle: Text(userData?['role'] ?? "ไม่มีข้อมูลบทบาท"),
                    ),
                    ListTile(
                      leading: const Icon(Icons.lock, color: Colors.purple),
                      title: const Text("รหัส PIN", style: TextStyle(fontSize: 18)),
                      subtitle: Text(
                        showPin
                            ? (userData?['pin_user'] ?? "ไม่มีข้อมูลรหัส PIN")
                            : "****",
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          showPin ? Icons.visibility_off : Icons.visibility, color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            showPin = !showPin;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
