import 'package:appproject/src/page/Home/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:appproject/src/page/Data_Loan/Data_Loan.dart';

class SavingScreen extends StatefulWidget {
  final String idUser;
  const SavingScreen({Key? key, required this.idUser}) : super(key: key);

  @override
  State<SavingScreen> createState() => _SavingScreenState(); // แก้ไขชื่อให้ตรงกับคลาส
}

class _SavingScreenState extends State<SavingScreen> {
  bool isLoanSelected = false; // กำหนดเริ่มต้นเป็น false เพราะเลือก "เงินออม"

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200], // Light green background
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'ค้นหา',
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Toggle Buttons
            Row(
              children: [
                _buildToggleButton("เงินกู้", isLoanSelected),
                const SizedBox(width: 8),
                _buildToggleButton("เงินออม", !isLoanSelected),
              ],
            ),
            const SizedBox(height: 16),

            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('ชื่อ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('รหัสสมาชิก', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('บ้านเลขที่', style: TextStyle(fontWeight: FontWeight.bold)), // แก้ไขข้อความ
                  Text('เพิ่มเติม', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Data List
            Expanded(
              child: ListView.builder(
                itemCount: 8,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ชื่อ
                        Expanded(
                          flex: 2,
                          child: const Text(
                            'Test',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),

                        // รหัสสมาชิก
                        Expanded(
                          flex: 3,
                          child: const Text(
                            '6517',
                            textAlign: TextAlign.center,
                          ),
                        ),

                        // ดอกเบี้ย
                        Expanded(
                          flex: 2,
                          child: const Text(
                            '124',
                            textAlign: TextAlign.center,
                          ),
                        ),

                        // ไอคอนค้นหา
                        IconButton(
                          icon: const Icon(Icons.search, color: Colors.orange),
                          onPressed: () {
                            // เพิ่ม action เมื่อกดไอคอน
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Footer Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFooterButton('ย้อนกลับ', Colors.red, Icons.arrow_back, () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage(idUser: widget.idUser)),
                        (Route<dynamic> route) => false,
                  );
                }),
                _buildFooterButton('เพิ่มข้อมูล', Colors.green, Icons.add, () {
                  // Add functionality for เพิ่มข้อมูล
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (text == "เงินออม") {
              isLoanSelected = false; // เลือก "เงินออม"
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SavingScreen(idUser: widget.idUser)), // ไปหน้า SavingScreen
              );
            } else {
              isLoanSelected = true; // เลือก "เงินกู้"
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoanScreen(idUser: widget.idUser)), // ไปหน้า LoanScreen
              );
            }
          });
        },
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: text == "เงินออม" ? Colors.green : (isSelected ? Colors.green : Colors.white),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black26),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: text == "เงินออม" ? Colors.white : (isSelected ? Colors.white : Colors.black),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterButton(
      String text, Color color, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color, // สีพื้นหลังของปุ่ม
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // ความโค้งของปุ่ม
        ),
      ),
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
