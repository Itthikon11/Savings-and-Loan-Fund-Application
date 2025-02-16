import 'package:appproject/src/page/Data/LoanDocumentsPage.dart';
import 'package:appproject/src/page/Data/SlipPage.dart';
import 'package:appproject/src/page/Data_Loan/Data_Loan.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:appproject/src/page/Savings/SavingsPage.dart';
import 'package:appproject/src/page/Home/HomePage.dart';
import 'package:appproject/src/page/Cal/CalDividendPage.dart';
import 'package:appproject/src/page/Data/PercenPage.dart';
import 'package:appproject/src/page/Profile/ProfilePage.dart';
import 'package:appproject/src/page/Loan/LoanRequestPage.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class Loanpage extends StatefulWidget {
  final String idUser;

  const Loanpage({Key? key, required this.idUser}) : super(key: key);

  @override
  State<Loanpage> createState() => _LoanPageState();
}

class _LoanPageState extends State<Loanpage> {
  int _selectedIndex = 2;
  String name = "กำลังโหลด...";
  String memberId = "กำลังโหลด...";
  String address = "กำลังโหลด...";
  String loanAmount = "กำลังโหลด...";
  List<Map<String, dynamic>> loanRequests = [];

  @override
  void initState() {
    super.initState();
    fetchLoanData();
  }

  Future<void> fetchLoanData() async {
    String userId = widget.idUser.trim();

    if (userId.isEmpty) {
      setState(() {
        name = "Error: ID ไม่ถูกต้อง";
        memberId = "-";
        address = "-";
        loanAmount = "-";
        loanRequests = [];
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse("http://192.168.1.40:3001/loanRequests/$userId"));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          setState(() {
            name = "${data[0]['first_name']} ${data[0]['last_name']}";
            memberId = data[0]['id_user'];
            address = data[0]['address'];

            // ✅ ใช้ `double.tryParse()` และ `.toStringAsFixed(2)`
            loanAmount = data
                .fold<double>(0.0, (sum, item) => sum + (double.tryParse(item['loan_amount'].toString()) ?? 0.0))
                .toStringAsFixed(2);

            loanRequests = List<Map<String, dynamic>>.from(data.map((item) => Map<String, dynamic>.from(item)));
          });
        } else {
          setState(() {
            name = "ไม่พบข้อมูล";
            memberId = "-";
            address = "-";
            loanAmount = "-";
            loanRequests = [];
          });
        }
      } else {
        setState(() {
          name = "ไม่พบข้อมูล";
          memberId = "-";
          address = "-";
          loanAmount = "-";
          loanRequests = [];
        });
      }
    } catch (e) {
      setState(() {
        name = "Error: ${e.toString()}";
        memberId = "-";
        address = "-";
        loanAmount = "-";
        loanRequests = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            PopupMenuButton<int>(
              icon: Image.asset(
                "assets/imgs/menu.png",
                height: 30,
              ),
              onSelected: (value) {
                if (value == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Caldividendpage()),
                  );
                }
                else if (value == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoanDocumentsPage()),
                  );
                }
                else if (value == 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoanScreen(idUser: widget.idUser)),
                  );
                }
                else if (value == 4) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Percenpage()),
                  );
                }
                else if (value == 5) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Slippage()),
                  );
                }
              },
              itemBuilder: (context)=>[
                PopupMenuItem(
                  value: 1,
                  child: Text("คำนวณเงินปันผล"),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Text("เอกสารเงินกู้"),
                ),
                PopupMenuItem(
                  value: 3,
                  child: Text("ข้อมูลสมาชิก"),
                ),
                PopupMenuItem(
                  value: 4,
                  child: Text("เปอร์เซ็นแบ่งจ่าย"),
                ),
                PopupMenuItem(
                  value: 5,
                  child: Text("สลิปเงินฝาก"),
                ),
              ],
            ),
            SizedBox(width: 290),
            GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profilepage(idUser: widget.idUser)),
                );
              },
              child: Image.asset(
                "assets/imgs/user.png",
                height: 30,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset("assets/imgs/loanimg.jpg", width: 380),
                ),
                Positioned(
                  top: 20,
                  left: 10,
                  child: Text(
                    "ชื่อ : $name",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 10,
                  child: Text(
                    "รหัสสมาชิก : $memberId",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 10,
                  child: Text(
                    "ที่อยู่ : $address",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                Positioned(
                  child: Text(
                    "$loanAmount บาท",
                    style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoanRequestPage(idUser: widget.idUser)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[300],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 5,
                shadowColor: Colors.green.withOpacity(0.5),
              ),
              child: Text("กู้ยืมเงิน"),
            ),
            SizedBox(height: 10,),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.attach_money, color: Colors.green, size: 24),
                    SizedBox(width: 5),
                    Text("อนุมัติแล้ว", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),

                    SizedBox(width: 20),

                    Icon(Icons.attach_money, color: Colors.yellow, size: 24),
                    SizedBox(width: 5),
                    Text("รอดำเนินการ", style: TextStyle(color: Colors.yellow[700], fontWeight: FontWeight.bold)),

                    SizedBox(width: 20),

                    Icon(Icons.attach_money, color: Colors.red, size: 24),
                    SizedBox(width: 5),
                    Text("ไม่ผ่านอนุมัติ", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Column(
              children: [
                loanRequests.isEmpty
                    ? Center(child: Text("ไม่มีข้อมูลการกู้ยืม"))
                    : Column(
                  children: loanRequests.map((loanRequest) {
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(Icons.attach_money, color: Colors.green, size: 24),
                            SizedBox(width: 16),
                            Text(
                              "+ ${(double.tryParse(loanRequest['loan_amount'].toString()) ?? 0.0).toStringAsFixed(2)} บาท",
                              style: TextStyle(fontSize: 18, color: Colors.green.shade700, fontWeight: FontWeight.bold),
                            ),
                          ]),
                          SizedBox(height: 8),
                          Row(children: [
                            Icon(Icons.document_scanner, color: Colors.blue, size: 24),
                            SizedBox(width: 16),
                            Text("รหัสคำขอกู้เงิน: ${loanRequest['id_loanReq']}", style: TextStyle(fontSize: 16)),
                          ]),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: _buildMenuBar(),
    );
  }

  Widget _buildMenuBar() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: GNav(
          activeColor: Colors.white,
          tabBackgroundColor: Colors.green.shade300,
          gap: 10,
          padding: EdgeInsets.all(15),
          selectedIndex: _selectedIndex,
          onTabChange: _onTabChange,
          tabs: const [
            GButton(icon: Icons.home, text: 'หน้าหลัก'),
            GButton(icon: Icons.savings, text: 'เงินฝาก'),
            GButton(icon: Icons.account_balance, text: 'เงินกู้'),
          ],
        ),
      ),
    );
  }

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(idUser: widget.idUser)),
        (Route<dynamic> route) => false,
      );
    } else if (index == 1) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => Savingspage(idUser: widget.idUser)),
        (Route<dynamic> route) => false,
      );
    } else if (index == 2) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => Loanpage(idUser: widget.idUser)),
        (Route<dynamic> route) => false,
      );
    }
  }
}
