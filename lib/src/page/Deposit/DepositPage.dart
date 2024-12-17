import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Depositpage extends StatefulWidget {
  const Depositpage({super.key});

  @override
  State<Depositpage> createState() => _DepositpageState();
}

class _DepositpageState extends State<Depositpage> {
  List<String> months = [
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม'
  ];
  String? selectedMonth;
  List<Widget> depositFields = [];
  double totalAmount = 0.0;
  List<TextEditingController> controllers = [];
  List<String?> selectedMonths = [];
  Color borderColor = Colors.grey;

  void _validateInput(String input) {
    setState(() {
      if (RegExp(r'^[0-9]+$').hasMatch(input)) {
        borderColor = Colors.green;
      } else {
        borderColor = Colors.red;
      }
    });
  }

  void addAmount(double amount) {
    setState(() {
      totalAmount = 0.0;
      for (var controller in controllers) {
        double value = double.tryParse(controller.text) ?? 0.0;
        totalAmount += value;
      }
    });
  }

  bool _isNumeric(String value) {
    return double.tryParse(value) != null;
  }

  @override
  void initState() {
    super.initState();
    addField();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ฝากเงิน"),
        backgroundColor: Colors.green,
      ),
      body: Container(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: _validateInput,
              decoration: InputDecoration(
                labelText: "เลขสมาชิก",
                labelStyle: TextStyle(color: Colors.black),
                hintText: 'ใส่ตัวเลขเท่านั้น',
                // border: OutlineInputBorder(
                //   borderRadius: BorderRadius.circular(20),
                // ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: borderColor, width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: borderColor, width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number,
              // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            SizedBox(height: 10),
            Expanded(
                child: ListView(
              children: [
                ...depositFields,
              ],
            )),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: addField,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "+",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: TotalBar(context),
    );
  }

  void addField() {
    if (depositFields.length <= 12) {
      setState(() {
        TextEditingController controller = TextEditingController();
        controllers.add(controller);
        selectedMonths.add(null);

        int fieldIndex = depositFields.length;

        depositFields.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "จำนวนเงิน",
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      double amount = double.tryParse(value) ?? 0.0;
                      addAmount(amount);
                    },
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedMonths[fieldIndex],
                    decoration: InputDecoration(
                      labelText: 'เลือกเดือน',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedMonths[fieldIndex] = newValue;
                      });
                    },
                    items: months
                        .where((month) => !selectedMonths.contains(month) || selectedMonths[fieldIndex] == month)
                        .map<DropdownMenuItem<String>>((String month) {
                      return DropdownMenuItem<String>(
                        value: month,
                        child: Text(month),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      });
    }
  }

  Widget TotalBar(BuildContext context) {
    return Container(
      color: Colors.green,
      height: 90,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("ยอดรวม : ฿${totalAmount.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 20, color: Colors.white)),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "รหัสสมาชิก :",
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "ชื่อสมาชิก :",
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "โปรดตรวจสอบข้อมูลทุกครั้งก่อนโอน",
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.red,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      content: SizedBox(
                        width: 300.0,
                        height: 300.0,
                        child: QrImageView(
                          data: 'https://youtu.be/3R6H9pRbkcw',
                          version: QrVersions.auto,
                          size: 200,
                        ),
                      ),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // จัดปุ่มแยกซ้ายขวา
                          children: [
                            // ปุ่มด้านซ้าย (ส่งสลิป)
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.upload_file, size: 20.0, color: Colors.white),
                                  SizedBox(width: 8.0),
                                  Text(
                                    "ส่งสลิป",
                                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            // ปุ่มด้านขวา (ปิด)
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.close, size: 20.0, color: Colors.white),
                                  SizedBox(width: 8.0),
                                  Text(
                                    "ปิด",
                                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text("ฝากเงิน"),
            ),
          ],
        ),
      ),
    );
  }
}
