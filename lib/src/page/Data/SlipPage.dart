import 'package:appproject/src/page/Data/DetailsSlipPage.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Slippage extends StatefulWidget {
  const Slippage({super.key});

  @override
  State<Slippage> createState() => _SlippageState();
}

class _SlippageState extends State<Slippage> {
  String searchQuery = "";
  List<Map<String, dynamic>> slipData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllSlips();
  }

  /// 📌 ดึงข้อมูลสลิปทั้งหมดจาก API `/getslips`
  Future<void> fetchAllSlips() async {
    String apiUrl = "http://192.168.1.40:3001/getslips";

    print("📡 Fetching all slips from: $apiUrl");

    try {
      final response = await http.get(Uri.parse(apiUrl));

      print("🔍 API Response: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        setState(() {
          slipData = jsonData.map((data) => {
            "id_slip": data["id_slip"],
            "name":
            "${data["first_name"] ?? ""} ${data["last_name"] ?? ""}",
            "date": (data["slip_date"] ?? "-").split("T")[0],
            "time": (data["slip_time"] ?? "-").split(".")[0],
            "status": _getStatusText(data["id_status"]),
          }).toList();
          isLoading = false;
        });

        print("📝 Loaded Data: $slipData");
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      print("🚨 Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  /// 🔍 ค้นหาสลิปตามชื่อจาก API `/searchslips`
  Future<void> searchSlips(String query) async {
    if (query.isEmpty) {
      fetchAllSlips();
      return;
    }

    String apiUrl = "http://192.168.1.40:3001/searchslips?search=$query";

    print("🔍 Searching for: $query");

    try {
      final response = await http.get(Uri.parse(apiUrl));

      print("🔍 API Response: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        setState(() {
          slipData = jsonData.map((data) => {
            "id_slip": data["id_slip"],
            "name":
            "${data["first_name"] ?? ""} ${data["last_name"] ?? ""}",
            "date": (data["slip_date"] ?? "-").split("T")[0],
            "time": (data["slip_time"] ?? "-").split(".")[0],
            "status": _getStatusText(data["id_status"]),
          }).toList();
          isLoading = false;
        });

        print("📝 Search Results: $slipData");
      } else {
        throw Exception("Failed to search data");
      }
    } catch (e) {
      print("🚨 Error searching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getStatusText(String? status) {
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
            // 🔍 ช่องค้นหา
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                    searchSlips(value); // ค้นหาข้อมูล
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

            // 🟢 หัวตาราง
            Container(
              decoration: BoxDecoration(
                color: Colors.green[300],
                borderRadius: BorderRadius.circular(8),
              ),
              padding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: const Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: Text("ชื่อ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white))),
                  Expanded(
                      flex: 2,
                      child: Text("วัน",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white))),
                  Expanded(
                      flex: 2,
                      child: Text("เวลา",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white))),
                  Expanded(
                      flex: 2,
                      child: Text("สถานะ",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white))),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 📜 แสดงข้อมูล
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : slipData.isEmpty
                  ? const Center(
                child: Text("ไม่มีข้อมูล",
                    style: TextStyle(fontSize: 16)),
              )
                  : ListView.builder(
                itemCount: slipData.length,
                itemBuilder: (context, index) {
                  final data = slipData[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 8),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsSlipPage(
                                idSlip: data["id_slip"]),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Expanded(
                              flex: 3,
                              child: Text(data["name"],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14))),
                          Expanded(
                              flex: 2,
                              child: Text(data["date"],
                                  textAlign: TextAlign.center,
                                  style:
                                  const TextStyle(fontSize: 14))),
                          Expanded(
                              flex: 2,
                              child: Text(data["time"],
                                  textAlign: TextAlign.center,
                                  style:
                                  const TextStyle(fontSize: 14))),
                          Expanded(
                            flex: 2,
                            child: Text(
                              data["status"],
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 12,
                                color: data["status"] == "อนุมัติ"
                                    ? Colors.green
                                    : (data["status"] ==
                                    "รอดำเนินการ"
                                    ? Colors.orange
                                    : Colors.red),
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
