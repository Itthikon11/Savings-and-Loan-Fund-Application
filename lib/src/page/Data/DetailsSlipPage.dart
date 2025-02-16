import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:ui';

class DetailsSlipPage extends StatefulWidget {
  final String idSlip;

  const DetailsSlipPage({super.key, required this.idSlip});

  @override
  State<DetailsSlipPage> createState() => _DetailsSlipPageState();
}

class _DetailsSlipPageState extends State<DetailsSlipPage> {
  bool isLoading = true;
  bool hasError = false;
  Map<String, dynamic> slipData = {};

  @override
  void initState() {
    super.initState();
    fetchSlipDetails();
  }

  Future<void> fetchSlipDetails() async {
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.1.40:3001/getslipdetails?id_slip=${widget.idSlip}'));
      if (response.statusCode == 200) {
        setState(() {
          slipData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print("Error fetching slip details: $e");
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case "S001":
        return "อนุมัติแล้ว";
      case "S002":
        return "รอดำเนินการ";
      case "S003":
        return "ไม่ผ่านอนุมัติ";
      default:
        return "ไม่ทราบสถานะ";
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "S001":
        return Colors.green;
      case "S002":
        return Colors.orange;
      case "S003":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getIconColor(IconData icon) {
    if (icon == Icons.person) return Colors.blue;
    if (icon == Icons.calendar_today) return Colors.purple;
    if (icon == Icons.confirmation_number) return Colors.teal;
    if (icon == Icons.money) return Colors.amber;
    if (icon == Icons.check_circle) return Colors.green;
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("รายละเอียดสลิปเงินฝาก"),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : hasError
            ? const Center(
            child: Text("ไม่สามารถดึงข้อมูลได้ กรุณาลองใหม่",
                style: TextStyle(color: Colors.red, fontSize: 16)))
            : slipData.isEmpty
            ? const Center(
            child: Text("ไม่พบข้อมูล",
                style: TextStyle(fontSize: 16)))
            : Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.person, "ชื่อ", "${slipData["first_name"]} ${slipData["last_name"]}"),
                  _buildInfoRow(Icons.calendar_today, "วันที่", DateTime.parse(slipData["date"]).toLocal().toString().split('.')[0]),
                  _buildInfoRow(Icons.confirmation_number, "หมายเลขสลิป", slipData["slip_number"].toString()),
                  _buildInfoRow(Icons.money, "จำนวนเงิน", "${slipData["amount_slip"].toString()} บาท"),

                  Center(
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.transparent, // พื้นหลังโปร่งใส
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15), // ทำให้ภาพโค้งมน
                                    child: Image.asset(
                                      'assets/imgs/slip.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  SizedBox(height: 15),

                                  // ปุ่มปิดที่ตกแต่งใหม่
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent, // สีแดงเข้ม
                                      foregroundColor: Colors.white, // สีตัวอักษร
                                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10), // ขอบมน
                                      ),
                                      elevation: 5, // เพิ่มเงาให้ปุ่มดูเด่น
                                    ),
                                    child: Text(
                                      "ปิด",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2, // เพิ่มระยะห่างตัวอักษร
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: Offset(0, 4),
                            ),
                          ],
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.all(5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/imgs/slip.png',
                            width: 400,
                            height: 400,
                            fit: BoxFit.cover, // ทำให้รูปพอดีกับกรอบ
                          ),
                        ),
                      ),
                    ),
                  ),

                  _buildInfoRow(Icons.check_circle, "สถานะ", _getStatusText(slipData["id_status"].toString()),
                      isStatus: true, statusColor: _getStatusColor(slipData["id_status"].toString())),
                ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isStatus = false, Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: isStatus ? (statusColor ?? Colors.black) : _getIconColor(icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "$label: $value",
              style: TextStyle(
                fontSize: 16,
                fontWeight: isStatus ? FontWeight.bold : FontWeight.normal,
                color: isStatus ? statusColor ?? Colors.black : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
