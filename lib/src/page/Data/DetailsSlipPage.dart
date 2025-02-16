import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    fetchSlipDetails();
  }

  Future<void> fetchSlipDetails() async {
    try {
      final response = await http.get(
          Uri.parse('http://192.168.1.40:3001/getslipdetails?id_slip=${widget.idSlip}'));

      if (response.statusCode == 200) {
        setState(() {
          slipData = json.decode(response.body);
          selectedStatus = slipData["id_status"]?.toString();
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

  Future<void> _updateStatus() async {
    if (selectedStatus == null) return;

    try {
      final response = await http.put(
        Uri.parse("http://192.168.1.40:3001/updateSlipStatus/${widget.idSlip}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id_status": selectedStatus}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("อัปเดตสถานะสำเร็จ"),
          backgroundColor: Colors.green,
        ));
        setState(() {
          slipData["id_status"] = selectedStatus;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("เกิดข้อผิดพลาดในการอัปเดตสถานะ"),
          backgroundColor: Colors.redAccent,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("เกิดข้อผิดพลาด: $e"),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  String _getStatusText(String? status) {
    if (status == null) return "ไม่ทราบสถานะ";
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

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
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

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isStatus = false, Color? statusColor, Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor ?? (isStatus ? (statusColor ?? Colors.black) : Colors.black), // ใช้ iconColor ถ้ามี
            size: 28, // ขนาดใหญ่ขึ้นเล็กน้อยเพื่อให้เห็นชัด
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("รายละเอียดสลิปเงินฝาก"),
        backgroundColor: Colors.green[700],
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
                  _buildInfoRow(
                    Icons.person,
                    "ชื่อ",
                    "${slipData["first_name"]} ${slipData["last_name"]}",
                    iconColor: Colors.blue,
                  ),
                  _buildInfoRow(
                    Icons.calendar_today,
                    "วันที่",
                    DateTime.parse(slipData["date"]).toLocal().toString().split('.')[0],
                    iconColor: Colors.purple,
                  ),
                  _buildInfoRow(
                    Icons.confirmation_number,
                    "หมายเลขสลิป",
                    slipData["slip_number"].toString(),
                    iconColor: Colors.green,
                  ),
                  _buildInfoRow(
                    Icons.money,
                    "จำนวนเงิน",
                    "${slipData["amount_slip"].toString()} บาท",
                    iconColor: Colors.orange,
                  ),

                  SizedBox(height: 20),

                  // 🖼 แสดงรูปภาพสลิป
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.transparent,
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.asset(
                                      'assets/imgs/slip.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      elevation: 5,
                                    ),
                                    child: Text(
                                      "ปิด",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/imgs/slip.png',
                        width: 250,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // 📌 สถานะปัจจุบัน
                  _buildInfoRow(
                    Icons.check_circle,
                    "สถานะปัจจุบัน",
                    _getStatusText(slipData["id_status"]?.toString()),
                    iconColor: _getStatusColor(slipData["id_status"]?.toString()),
                    isStatus: true,
                    statusColor: _getStatusColor(slipData["id_status"]?.toString()),
                  ),

                  SizedBox(height: 20),

                  // 📌 เปลี่ยนสถานะ
                  Text("เปลี่ยนสถานะ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    items: [
                      DropdownMenuItem(value: "S001", child: Text("อนุมัติแล้ว")),
                      DropdownMenuItem(value: "S002", child: Text("รอดำเนินการ")),
                      DropdownMenuItem(value: "S003", child: Text("ไม่ผ่านอนุมัติ")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 20),

                  // 📌 ปุ่มอัปเดตสถานะ
                  Center(
                    child: ElevatedButton(
                      onPressed: _updateStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700], // 🟦 สีน้ำเงินเข้ม
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text("อัปเดตสถานะ"),
                    ),
                  ),
                ],
            ),
          ),
        ),
      ),
    );
  }
}
