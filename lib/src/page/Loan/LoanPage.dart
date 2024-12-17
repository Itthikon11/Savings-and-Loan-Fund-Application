import 'package:appproject/src/page/Cal/CalDividendPage.dart';
import 'package:appproject/src/page/Data/PercenPage.dart';
import 'package:appproject/src/page/Profile/ProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../routes.dart';

class Loanpage extends StatefulWidget {
  const Loanpage({super.key});

  @override
  State<Loanpage> createState() => _LoanpageState();
}

class _LoanpageState extends State<Loanpage> {
  int _selectedIndex = 2;

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacementNamed(context, AppRoute.home);
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, AppRoute.savings);
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
                else if (value == 2) {}
                else if (value == 3) {}
                else if (value == 4) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Percenpage()),
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
                  child: Text("รายละเอียดเงินกู้"),
                ),
                PopupMenuItem(
                  value: 3,
                  child: Text("ข้อมูลสมาชิก"),
                ),
                PopupMenuItem(
                  value: 4,
                  child: Text("เปอร์เซ็นแบ่งจ่าย"),
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
        children: [
          SizedBox(height: 50.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  "assets/imgs/loanimg.jpg",
                  width: 380,
                ),
              ),
            ],
          ),
          SizedBox(height: 100,),
          Container(
            // padding: EdgeInsets.all(100),
            width: 300,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.green,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ชื่อ',
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.black
                    ),
                  ),
                  Text(
                    'ธนวัฒน์ หนองงู',
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.black
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Container(
            // padding: EdgeInsets.all(100),
            width: 300,
            height: 50,
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.green,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'รหัสสมาชิก',
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.black
                    ),
                  ),
                  Text(
                    '4601',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Container(
            // padding: EdgeInsets.all(100),
            width: 300,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.green,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'บ้านเลขที่',
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.black
                    ),
                  ),
                  Text(
                    '195',
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.black
                    ),
                  ),
                ],
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
}