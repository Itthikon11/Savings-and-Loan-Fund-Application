import 'package:appproject/src/page/Data/DetailsSlipPage.dart';
import 'package:appproject/src/page/Savings/DetailsSaving.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Slippage extends StatefulWidget {
  const Slippage({super.key});

  @override
  State<Slippage> createState() => _SlippageState();
}

class _SlippageState extends State<Slippage> {
  DateTime selectedDate = DateTime.now();
  String searchQuery = "";
  List<Map<String, dynamic>> slipData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSlipData();
  }

  Future<void> fetchSlipData() async {
    String formattedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
    String apiUrl = "http://192.168.1.40:3001/getslips?date=$formattedDate";
    if (searchQuery.isNotEmpty) {
      apiUrl += "&search=$searchQuery";
    }

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          slipData = jsonData.map((data) => {
            "id_slip": data["id_slip"],
            "name": "${data["first_name"]} ${data["last_name"]}",
            "date": data["slip_date"].split("T")[0],
            "time": data["slip_time"].split(".")[0],
            "status": _getStatusText(data["id_status"]),
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching data: $e");
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case "S001":
        return "อนุมัติ";
      case "S002":
        return "รอดำเนินการ";
      case "S003":
        return "ไม่อนุมัติ";
      default:
        return "ไม่ทราบสถานะ";
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.green,
            colorScheme: const ColorScheme.light(primary: Colors.green),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        fetchSlipData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[300],
        title: const Text("สลิปเงินฝาก"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ช่องค้นหา
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                      fetchSlipData();
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: "ค้นหา",
                    prefixIcon: Icon(Icons.search, color: Colors.black),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // หัวตาราง
            Container(
              decoration: BoxDecoration(
                color: Colors.green[300],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: const Row(
                children: [
                  Expanded(flex: 3, child: Text("ชื่อ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white))),
                  Expanded(flex: 2, child: Text("วัน", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white))),
                  Expanded(flex: 2, child: Text("เวลา", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white))),
                  Expanded(flex: 2, child: Text("สถานะ", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white))),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // แสดงข้อมูลตามช่องที่กำหนด
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: slipData.length,
                itemBuilder: (context, index) {
                  final data = slipData[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: InkWell(
                      onTap: () {
                        // แก้ไขส่วนนี้เพื่อส่ง id_slip ไปยังหน้ารายละเอียด
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsSlipPage(idSlip: data["id_slip"]), // ต้องส่ง id_slip จาก data
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Expanded(flex: 3, child: Text(data["name"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                          Expanded(flex: 2, child: Text(data["date"], textAlign: TextAlign.center, style: const TextStyle(fontSize: 14))),
                          Expanded(flex: 2, child: Text(data["time"], textAlign: TextAlign.center, style: const TextStyle(fontSize: 14))),
                          Expanded(
                            flex: 2,
                            child: Text(
                              data["status"],
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 14,
                                color: data["status"] == "อนุมัติ" ? Colors.green : (data["status"] == "รอดำเนินการ" ? Colors.orange : Colors.red),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
