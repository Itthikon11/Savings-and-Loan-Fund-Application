import 'package:flutter/material.dart';

class Slippage extends StatefulWidget {
  const Slippage({super.key});

  @override
  State<Slippage> createState() => _LoanDocumentsPageState();
}

class _LoanDocumentsPageState extends State<Slippage> {
  DateTime selectedDate = DateTime.now();

  // Mock Data
  final List<Map<String, dynamic>> mockData = [
    {"name": "อิทธิกร สกุลแก้ว", "time": "09:30น.", "status": "อนุมัติ", "document": "กู้ยืม 1"},
    {"name": "อิทธิกร สกุลแก้ว", "time": "10:00น.", "status": "รอดำเนินการ", "document": "กู้ยืม 2"},
    {"name": "อิทธิกร สกุลแก้ว", "time": "14:30น.", "status": "ไม่อนุมัติ", "document": "กู้ยืม 3"},
    {"name": "ธนวัฒน์ หนองงู", "time": "16:00น.", "status": "อนุมัติ", "document": "กู้ยืม 4"},
    {"name": "อิทธิกร สกุลแก้ว", "time": "10:00น.", "status": "รอดำเนินการ", "document": "กู้ยืม 5"},
    {"name": "อิทธิกร สกุลแก้ว", "time": "14:30น.", "status": "ไม่อนุมัติ", "document": "กู้ยืม 6"},
    {"name": "ธนวัฒน์ หนองงู", "time": "16:00น.", "status": "อนุมัติ", "document": "กู้ยืม 7"},
    {"name": "อิทธิกร สกุลแก้ว", "time": "10:00น.", "status": "รอดำเนินการ", "document": "กู้ยืม 8"},
    {"name": "อิทธิกร สกุลแก้ว", "time": "14:30น.", "status": "ไม่อนุมัติ", "document": "กู้ยืม 9"},
    {"name": "ธนวัฒน์ หนองงู", "time": "16:00น.", "status": "อนุมัติ", "document": "กู้ยืม 10"},
    {"name": "อิทธิกร สกุลแก้ว", "time": "10:00น.", "status": "รอดำเนินการ", "document": "กู้ยืม 11"},
    {"name": "อิทธิกร สกุลแก้ว", "time": "14:30น.", "status": "ไม่อนุมัติ", "document": "กู้ยืม 12"},
    {"name": "ธนวัฒน์ หนองงู", "time": "16:00น.", "status": "อนุมัติ", "document": "กู้ยืม 13"},
  ];

  // ฟังก์ชันเลือกวันที่
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
            // ค้นหา
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "ค้นหา",
                    prefixIcon: Icon(Icons.search, color: Colors.black),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // เลือกวันที่
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("เลือกวันที่", style: TextStyle(fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () => _selectDate(context),
                  icon: const Icon(Icons.calendar_today, color: Colors.white),
                  label: Text(
                    "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // หัวตาราง
            Container(
              decoration: BoxDecoration(
                color: Colors.green[300],
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: const Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      "ชื่อ",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "เวลา",
                      textAlign: TextAlign.left,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "สถานะ",
                      textAlign: TextAlign.left,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                  ),
                  Expanded(
                    flex: 2, // ช่องเอกสารมีพื้นที่ที่เหมาะสม
                    child: Text(
                      "สลิป",
                      textAlign: TextAlign.right, // ชิดขวา
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ข้อมูลตาราง
            Expanded(
              child: ListView.builder(
                itemCount: mockData.length,
                itemBuilder: (context, index) {
                  final data = mockData[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(data["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(data["time"]),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            data["status"],
                            style: TextStyle(
                              color: data["status"] == "อนุมัติ"
                                  ? Colors.green
                                  : (data["status"] == "ไม่อนุมัติ" ? Colors.red : Colors.orange),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: IconButton(
                            alignment: Alignment.centerLeft,
                            icon: const Icon(Icons.search, color: Colors.orange),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("ดูเอกสารกู้ยืม: ${data['document']}"),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
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
