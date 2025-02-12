import 'package:appproject/src/page/Cal/CalDividendPage.dart';
import 'package:appproject/src/page/Data/PercenPage.dart';
import 'package:appproject/src/page/Data/SlipPage.dart';
import 'package:appproject/src/page/Data/LoanDocumentsPage.dart';
import 'package:appproject/src/page/Profile/ProfilePage.dart';
import 'package:appproject/src/page/Data_Loan/Data_Loan.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../Savings/SavingsPage.dart';
import '../routes.dart';

class HomePage extends StatefulWidget {
  final String idUser;

  const HomePage({super.key, required this.idUser});

  @override
  State<HomePage> createState() => _HomepageState();
}


class _HomepageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(idUser: widget.idUser),
        ),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Savingspage(idUser: widget.idUser),
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, AppRoute.loan);
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
                    MaterialPageRoute(builder: (context) => LoanScreen()),
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
                  MaterialPageRoute(builder: (context) => Profilepage()),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text("หน้าหลัก"),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(right: 30.0, left: 30, top: 10),
              children: [
                _box(),
                _box(),
                _box(),
                _box(),
                _box(),
              ],
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
            GButton(
              icon: Icons.home,
              text: 'หน้าหลัก',
            ),
            GButton(
              icon: Icons.savings,
              text: 'เงินฝาก',
            ),
            GButton(
              icon: Icons.account_balance,
              text: 'เงินกู้',
            ),
          ],
        ),
      ),
    );
  }

  Widget _box() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.0),
      padding: EdgeInsets.all(10.0),
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.green,
        border: Border.all(
          color: Colors.black,
          width: 1.0,
        ),
      ),
    );
  }
}
