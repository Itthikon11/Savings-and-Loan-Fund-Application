import 'package:appproject/src/page/Login/LoginPage.dart';
import 'package:flutter/material.dart';
import '../routes.dart';

class Profilepage extends StatefulWidget {
  const Profilepage({super.key});

  @override
  State<Profilepage> createState() => _ProfileState();
}

class _ProfileState extends State<Profilepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("โปรไฟล์"),
        backgroundColor: Colors.green,
      ),
      body: Container(
        color: Colors.green,
        child: Column(
          children: [
            Container(
              color: Colors.green,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 60, color: Colors.black),
                  ),
                ],
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
                      leading: const Icon(Icons.lock, color: Colors.purple),
                      title: const Text("รหัสผ่าน", style: TextStyle(fontSize: 18)),
                      subtitle: const Text("3389"),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.orange),
                      title: const Text("ข้อมูลผู้ใช้", style: TextStyle(fontSize: 18)),
                      subtitle: const Text("อิทธิกร สกุลแก้ว"),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone, color: Colors.green),
                      title: const Text("เบอร์โทร", style: TextStyle(fontSize: 18)),
                      subtitle: const Text("0639344990"),
                      onTap: () {},
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(240.0, 390.0, 16.0, 16.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(context: context,
                            builder: (context){
                              return AlertDialog(
                                title: Text("ออกจากระบบ"),
                                content: Text("ออกจากระบบระบบหรือไม่"),
                                actions: [
                                  TextButton(onPressed: (){
                                    Navigator.of(context).pop();
                                  }, style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ), child: Text("ยกเลิก")),
                                  ElevatedButton(onPressed: (){
                                    Navigator.of(context).pop();
                                    // Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()),);
                                  },style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white
                                  ), child: Text("ยืนยัน"))
                                ]
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text("ออกจากระบบ", style: TextStyle(color: Colors.red)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        ),
                      ),
                    )
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
