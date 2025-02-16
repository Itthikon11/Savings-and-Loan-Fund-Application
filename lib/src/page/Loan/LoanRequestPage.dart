import 'package:flutter/material.dart';

class LoanRequestPage extends StatefulWidget {
  final String idUser;

  const LoanRequestPage({Key? key, required this.idUser}) : super(key: key);

  @override
  State<LoanRequestPage> createState() => _LoanRequestPageState();
}

class _LoanRequestPageState extends State<LoanRequestPage> {
  bool _isLoanRequested = false;
  TextEditingController _loanReasonController = TextEditingController();

  // ✅ ฟังก์ชันกดปุ่มขอกู้เงิน
  void _submitLoanRequest() {
    if (_loanReasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("กรุณากรอกเหตุผลในการกู้เงิน"),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    setState(() {
      _isLoanRequested = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("คำขอกู้เงินของคุณถูกส่งแล้ว"),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ขอกู้เงิน"),
        backgroundColor: Colors.green[600],
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade200, Colors.grey.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {}, // ยังไม่ต้องใส่ URL
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[500],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: Icon(Icons.download, size: 24),
                      label: Text("ดาวน์โหลดเอกสาร", style: TextStyle(fontSize: 16)),
                    ),

                    SizedBox(height: 20),

                    // ✅ ช่องให้พิมพ์เหตุผลการกู้เงิน
                    TextField(
                      controller: _loanReasonController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "กรุณากรอกเหตุผลในการกู้เงิน",
                        labelStyle: TextStyle(color: Colors.black54),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),

                    SizedBox(height: 20),

                    // ✅ แจ้งเตือนถ้ามีคำขอกู้เงินอยู่
                    if (_isLoanRequested)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "คุณมีคำขอกู้ที่ยังรอการอนุมัติอยู่",
                          style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),

                    // ✅ ปุ่มขอกู้เงิน
                    ElevatedButton(
                      onPressed: _isLoanRequested ? null : _submitLoanRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLoanRequested ? Colors.grey : Colors.green[500],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 5,
                      ),
                      child: Text("ขอกู้เงิน"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
