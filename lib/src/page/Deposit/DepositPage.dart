import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

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
  final TextEditingController _idUser = TextEditingController();
  bool _isUserValid = true;
  Color borderColor = Colors.grey;
  File? _selectedSlip;

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

  void _checkUser() async {
    final String idUser = _idUser.text;

    if (idUser.isEmpty) {
      setState(() {
        _isUserValid = false;
        borderColor = Colors.red;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://172.18.138.185:3001/users/$idUser'),
      );

      setState(() {
        if (response.statusCode == 200) {
          _isUserValid = true;
          borderColor = Colors.green;
        } else {
          _isUserValid = false;
          borderColor = Colors.red;
        }
      });
    } catch (e) {
      setState(() {
        _isUserValid = false;
        borderColor = Colors.red;
      });
      print('Error checking user: $e');
    }
  }

  Future<void> saveDeposit(String idUser, List<Map<String, dynamic>> depositData) async {
    final url = Uri.parse('http://172.18.138.185:3001/deposit');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id_user": idUser, "deposit_month": depositData}),
    );

    if (response.statusCode == 201) {
      print("Deposit saved successfully");
    } else {
      print("Failed to save deposit: ${response.body}");
    }
  }

  void onDeposit() {
    if (_idUser.text.isEmpty || controllers.isEmpty) {
      print("กรุณากรอกข้อมูลให้ครบ");
      return;
    }

    List<Map<String, dynamic>> depositData = [];

    for (int i = 0; i < controllers.length; i++) {
      String? selected = selectedMonths[i];
      double amount = double.tryParse(controllers[i].text) ?? 0.0;

      if (selected != null && amount > 0) {
        depositData.add({
          "month": months.indexOf(selected) + 1,
          "amount": amount
        });
      }
    }

    if (depositData.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: Center(
                  child: Text(
                    "ยืนยันการฝากเงิน",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // รหัสสมาชิก
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text("รหัสสมาชิก:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(_idUser.text, style: TextStyle(fontSize: 18, color: Colors.green)),
                          ],
                        ),
                      ),

                      SizedBox(height: 15),

                      // ยอดรวม
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text("ยอดรวม:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("฿${totalAmount.toStringAsFixed(2)}", style: TextStyle(fontSize: 18, color: Colors.green)),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      Text(
                        "สแกน QR Code เพื่อโอนเงิน",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),

                      Image.asset(
                        'assets/imgs/Qrcode.jpg',
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 20),

                      // อัปโหลดสลิป
                      Text(
                        "แนบสลิปโอนเงิน",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      SizedBox(height: 10),

                      // แสดงภาพที่อัปโหลด
                      _selectedSlip != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_selectedSlip!, height: 150, fit: BoxFit.cover),
                      )
                          : Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        child: Center(
                          child: Text("ยังไม่ได้อัปโหลดสลิป", style: TextStyle(color: Colors.grey)),
                        ),
                      ),

                      SizedBox(height: 10),

                      // ปุ่มอัปโหลดสลิป
                      ElevatedButton.icon(
                        onPressed: () async {
                          final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                          if (pickedFile != null) {
                            setState(() {
                              _selectedSlip = File(pickedFile.path);
                            });
                          }
                        },
                        icon: Icon(Icons.upload_file),
                        label: Text("อัปโหลดสลิป"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  // ปุ่มยกเลิก
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close, size: 20.0, color: Colors.white),
                        SizedBox(width: 8.0),
                        Text("ยกเลิก", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      if (_selectedSlip == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("กรุณาอัปโหลดสลิปก่อนยืนยัน"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }
                      Navigator.of(context).pop();
                      saveDeposit(_idUser.text, depositData);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 20.0, color: Colors.white),
                        SizedBox(width: 8.0),
                        Text("ยืนยัน", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    } else {
      print("กรุณากรอกข้อมูลให้ถูกต้อง");
    }
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
              controller: _idUser,
              onChanged: (value) {
                _checkUser();
              },
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: "เลขสมาชิก",
                labelStyle: TextStyle(color: Colors.black),
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
              onPressed: onDeposit,
              child: Text("ฝากเงิน"),
            ),
          ],
        ),
      ),
    );
  }
}
