import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Detailssaving extends StatefulWidget {
  final String idDepositAm;

  const Detailssaving({Key? key, required this.idDepositAm}) : super(key: key);

  @override
  _DetailssavingState createState() => _DetailssavingState();
}

class _DetailssavingState extends State<Detailssaving> {
  List<Map<String, dynamic>> savingsData = [];
  bool isLoading = true;
  String? errorMessage;
  bool _isDisposed = false;

  // รายชื่อเดือน 1-12 (ภาษาไทย)
  final List<String> monthNames = [
    "มกราคม", "กุมภาพันธ์", "มีนาคม", "เมษายน", "พฤษภาคม", "มิถุนายน",
    "กรกฎาคม", "สิงหาคม", "กันยายน", "ตุลาคม", "พฤศจิกายน", "ธันวาคม"
  ];

  @override
  void initState() {
    super.initState();
    print("📌 Received idDepositAm: ${widget.idDepositAm}");
    fetchSavingsData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> fetchSavingsData() async {
    final String apiUrl = "http://192.168.1.40:3001/deposit/DepositMonth";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"idDepositAm": widget.idDepositAm}),
      );

      print("📝 API Response Code: ${response.statusCode}");
      print("📜 API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final dynamic jsonResponse = jsonDecode(response.body);

        if (jsonResponse is Map && jsonResponse.containsKey("Deposit_month")) {
          final List<dynamic> data = jsonResponse["Deposit_month"];

          Map<int, int> depositMap = {};
          for (var item in data) {
            depositMap[item["month"]] = item["amount"];
          }

          List<Map<String, dynamic>> allMonthsData = List.generate(12, (index) {
            int monthNumber = index + 1;
            return {
              "month": monthNames[index],
              "amount": depositMap.containsKey(monthNumber) ? depositMap[monthNumber] : 0
            };
          });

          if (mounted) {
            setState(() {
              savingsData = allMonthsData;
              isLoading = false;
            });
          }
        } else {
          throw Exception("API Response ไม่มี key 'Deposit_month'");
        }
      } else {
        if (mounted) {
          setState(() {
            errorMessage = "เกิดข้อผิดพลาดในการโหลดข้อมูล (${response.statusCode})";
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "ไม่สามารถเชื่อมต่อ API ได้: $e";
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("รายละเอียดเงินฝาก"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(child: Text(errorMessage!, style: TextStyle(color: Colors.red, fontSize: 16)))
            : Column(
          children: [
            Text(
              "ยอดเงินฝากแต่ละเดือน",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: savingsData.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    elevation: 3,
                    child: ListTile(
                      leading: Icon(Icons.calendar_today, color: Colors.green),
                      title: Text(
                        "${savingsData[index]["month"]}",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        "${savingsData[index]["amount"]} บาท",
                        style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
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
