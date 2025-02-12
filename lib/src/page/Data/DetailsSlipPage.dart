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

  @override
  void initState() {
    super.initState();
    fetchSlipDetails();
  }

  Future<void> fetchSlipDetails() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.40:3001/getslipdetails?id_slip=${widget.idSlip}'));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("รายละเอียดสลิปเงินฝาก"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : hasError
            ? const Center(child: Text("ไม่สามารถดึงข้อมูลได้ กรุณาลองใหม่", style: TextStyle(color: Colors.red)))
            : slipData.isEmpty
            ? const Center(child: Text("ไม่พบข้อมูล"))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // ข้อมูลอื่นๆ ที่คุณต้องการแสดง
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.green[300]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "ชื่อ: ${slipData["first_name"]} ${slipData["last_name"]}",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.green[300]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "วันที่: ${slipData["date"]}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.confirmation_number, color: Colors.green[300]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "หมายเลขสลิป: ${slipData["slip_number"]}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.money, color: Colors.green[300]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "จำนวนเงิน: ${slipData["amount_slip"]} บาท",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[300]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "สถานะ: ${_getStatusText(slipData["id_status"])}",
                            style: const TextStyle(fontSize: 16, color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
