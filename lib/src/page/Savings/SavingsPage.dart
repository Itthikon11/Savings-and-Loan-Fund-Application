import 'package:appproject/src/page/Cal/CalDividendPage.dart';
import 'package:appproject/src/page/Data/PercenPage.dart';
import 'package:appproject/src/page/Deposit/DepositPage.dart';
import 'package:appproject/src/page/Profile/ProfilePage.dart';
import 'package:appproject/src/page/Savings/DetailsSaving.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Home/HomePage.dart';

class Savingspage extends StatefulWidget {
  final String idUser;

  const Savingspage({super.key, required this.idUser});

  @override
  State<Savingspage> createState() => _SavingspageState();
}

class _SavingspageState extends State<Savingspage> {
  int _selectedIndex = 1;
  double? amountDeposit;
  String? depositDate;
  double? DepositAmount;
  String? idUsers;
  String? NameUser;
  bool _isLoading = false;
  List<Map<String, dynamic>>? depositsList;

  @override
  void initState() {
    super.initState();
    _fetchDepositAmount();
  }

  Future<void> _fetchDepositAmount() async {
    if (widget.idUser.isEmpty) {
      _showErrorDialog("ไม่พบข้อมูลผู้ใช้");
      return;
    }

    setState(() => _isLoading = true);

    final String apiUrl = "http://172.18.138.185:3001/deposit/${widget.idUser}";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      print("API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!data.containsKey("deposits") || (data["deposits"] as List).isEmpty) {
          _showErrorDialog("ไม่พบข้อมูลการฝาก");
          return;
        }
        setState(() {
          depositsList = List<Map<String, dynamic>>.from(data["deposits"].map((deposit) {
            return {
              "id_DepositAm": deposit["id_DepositAm"],
              "amount_Deposit": (deposit["amount_Deposit"] as num).toDouble()
            };
          }));
          amountDeposit = ((data["deposits"][0]["amount_Deposit"] ?? 0) as num).toDouble();
          depositDate = data["date_deposit"] != null
              ? _formatDate(data["date_deposit"])
              : "ไม่พบข้อมูลวันที่";
          idUsers = data["id_user"]?.toString();
          NameUser = "${data["first_name"] ?? ''} ${data["last_name"] ?? ''}".trim();
          DepositAmount = (data["deposit_amount"] ?? 0).toDouble();
        });

      } else {
        _showErrorDialog("เกิดข้อผิดพลาด: ${response.statusCode}");
      }
    } catch (error) {
      _showErrorDialog("ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(String dateStr) {
    try {
      DateTime dateTime = DateTime.parse(dateStr);
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
    } catch (e) {
      return "รูปแบบวันที่ไม่ถูกต้อง";
    }
  }

  void _showErrorDialog(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("ข้อผิดพลาด"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("ตกลง"),
              ),
            ],
          );
        },
      );
    });
  }

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage(idUser: widget.idUser)),
            (Route<dynamic> route) => false,
      );
    } else if (index == 1) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Savingspage(idUser: widget.idUser)),
            (Route<dynamic> route) => false,
      );
    } else if (index == 2) {
      /*Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Loanpage(idUser: widget.idUser)),
            (Route<dynamic> route) => false,
      );*/
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            PopupMenuButton<int>(
              icon: Image.asset("assets/imgs/menu.png", height: 30),
              onSelected: (value) {
                if (value == 1) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Caldividendpage()));
                } else if (value == 4) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Percenpage()));
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 1, child: Text("คำนวณเงินปันผล")),
                PopupMenuItem(value: 2, child: Text("รายละเอียดเงินกู้")),
                PopupMenuItem(value: 3, child: Text("ข้อมูลสมาชิก")),
                PopupMenuItem(value: 4, child: Text("เปอร์เซ็นแบ่งจ่าย")),
              ],
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Profilepage()));
              },
              child: Image.asset("assets/imgs/user.png", height: 30),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 50.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      "assets/imgs/savingimg.jpg",
                      width: 380,
                    ),
                  ),
                  Positioned(
                    top: 110,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                      child: Text(
                        _isLoading
                            ? "กำลังโหลด..."
                            : "ยอดเงินฝาก : ${DepositAmount?.toStringAsFixed(1) ?? '0.0'} บาท",
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                      left: 10,
                      top: 20,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                        child: Text(
                          _isLoading
                              ? "กำลังโหลด..."
                              : "ชื่อ : ${NameUser?? 'ไม่พบข้อมูล'}",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      )
                  ),
                  Positioned(
                    bottom: 20,
                      left: 10,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                        child: Text(
                          _isLoading
                              ? "กำลังโหลด..." :
                              "รหัสสมาชิก : ${idUsers?? 'ไม่มีข้อมูล'}",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                  ),
                  Positioned(
                    bottom: 15,
                      right: 15,
                      child: Container(
                        child: Text(
                          _isLoading
                              ? "กำลังโหลด...":
                              "ล่าสุด : ${depositDate?? 'ไม่มีข้อมูล'}",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      )
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Depositpage()));
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
            child: Text("ฝากเงิน"),
          ),
          SizedBox(height: 10),
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
      Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: depositsList == null || depositsList!.isEmpty
              ? Center(child: Text("ไม่มีข้อมูลการฝาก"))
              : ListView.builder(
            itemCount: depositsList?.length ?? 0,
            itemBuilder: (context, index) {
              final deposit = depositsList![index];
              return _box(
                context,
                deposit["id_DepositAm"],
                (deposit["amount_Deposit"] as num).toDouble(),
              );
            },
          ),
        ),
      ),
        ],
      ),
      bottomNavigationBar: _MuenBar(),
    );
  }

  Widget _MuenBar() {
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

  Widget _box(BuildContext context, String idDeposit, double amountDeposit) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      width: 350,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.green.withOpacity(0.2), blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money, color: Colors.green, size: 24),
              SizedBox(width: 16),
              Text(
                "+ ${amountDeposit.toStringAsFixed(2)} บาท",
                style: TextStyle(fontSize: 18, color: Colors.green.shade700, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Detailssaving(idDepositAm: idDeposit),
                ),
              );
            },
            child: Icon(Icons.arrow_forward_ios, color: Colors.green, size: 24),
          ),
        ],
      ),
    );
  }
}
