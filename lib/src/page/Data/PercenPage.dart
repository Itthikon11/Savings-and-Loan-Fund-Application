import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../Home/HomePage.dart';
import '../Loan/LoanPage.dart';
import '../Savings/SavingsPage.dart';

class Percenpage extends StatefulWidget {
  const Percenpage({super.key});

  @override
  State<Percenpage> createState() => _PercenpageState();
}

class _PercenpageState extends State<Percenpage> {
  int _selectedIndex = 0;
  List<bool> _isEditing = [false, false, false, false, false, false];
  List<double> _values = [70, 15, 10, 3, 2, 15];

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
            (Route<dynamic> route) => false,
      );
    } else if (index == 1) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Savingspage()),
            (Route<dynamic> route) => false,
      );
    } else if (index == 2) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Loanpage()),
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("เปอร์เซ็นแบ่งจ่าย"),
        backgroundColor: Colors.green[300],
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow("สมาชิก", _values[0], index: 0, isPercentage: true),
            SizedBox(height: 10),
            _buildRow("กรรมการ", _values[1], index: 1, isPercentage: true),
            SizedBox(height: 10),
            _buildRow("สาธารณูปโภค", _values[2], index: 2, isPercentage: true),
            SizedBox(height: 10),
            _buildRow("สมทบทุน", _values[3], index: 3, isPercentage: true),
            SizedBox(height: 10),
            _buildRow("ประกันเสียง", _values[4], index: 4, isPercentage: true),
            SizedBox(height: 30),
            _buildRow("เปอร์เซ็นเงินกู้", _values[5], index: 5, isPercentage: true),
          ],
        ),
      ),
      bottomNavigationBar: _buildMenuBar(),
    );
  }

  Widget _buildRow(String label, double value, {bool isPercentage = false, required int index}) {
    TextEditingController _controller = TextEditingController(text: isPercentage ? "${value.toStringAsFixed(1)}%" : value.toStringAsFixed(1));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: TextField(
            controller: _controller,
            enabled: _isEditing[index],
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              hintText: isPercentage
                  ? "${value.toStringAsFixed(1)}%"
                  : value.toStringAsFixed(1),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            setState(() {
              if (_isEditing[index]) {
                // If editing, save the new value and append %
                double newValue = double.tryParse(_controller.text.replaceAll('%', '')) ?? value;
                _values[index] = newValue;
              }
              _isEditing[index] = !_isEditing[index];
            });
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black, backgroundColor: Colors.yellow,
          ),
          child: Text(_isEditing[index] ? "บันทึก" : "แก้ไข"),
        ),
      ],
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
