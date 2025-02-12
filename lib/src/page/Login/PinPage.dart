import 'package:appproject/src/page/Login/ForgotPinPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:appproject/src/page/Home/HomePage.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class PinEntryPage extends StatefulWidget {
  final String idUser;

  PinEntryPage({required this.idUser});

  @override
  _PinEntryPageState createState() => _PinEntryPageState();
}

class _PinEntryPageState extends State<PinEntryPage> {
  String _enteredPin = "";
  String _confirmedPin = "";
  String? _existingPin;
  bool _isConfirming = false;
  bool _pinMismatch = false;
  bool _isLoading = true;
  final int _pinLength = 6;

  @override
  void initState() {
    super.initState();
    _checkExistingPin();
  }

  Future<void> _checkExistingPin() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.40:3001/get_pin/${widget.idUser}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _existingPin = data['pin_user'];
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _existingPin = null;
          _isLoading = false;
        });
      } else {
        throw Exception("โหลดข้อมูลผิดพลาด");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog("ไม่สามารถเชื่อมต่อฐานข้อมูล");
    }
  }

  void _onKeyPress(String value) {
    if (_isLoading) return;

    setState(() {
      if (value == "del") {
        if (_isConfirming && _confirmedPin.isNotEmpty) {
          _confirmedPin = _confirmedPin.substring(0, _confirmedPin.length - 1);
        } else if (!_isConfirming && _enteredPin.isNotEmpty) {
          _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        }
      } else {
        if (_isConfirming && _confirmedPin.length < _pinLength) {
          _confirmedPin += value;
        } else if (!_isConfirming && _enteredPin.length < _pinLength) {
          _enteredPin += value;
        }
      }

      if (_existingPin != null) {
        if (_enteredPin.length == _pinLength) {
          _verifyPin();
        }
      } else {
        if (_enteredPin.length == _pinLength && !_isConfirming) {
          _isConfirming = true;
          _pinMismatch = false;
        } else if (_confirmedPin.length == _pinLength && _isConfirming) {
          if (_enteredPin == _confirmedPin) {
            _savePinToDatabase();
          } else {
            _pinMismatch = true;
            _confirmedPin = "";
            _showErrorDialog("PIN ไม่ตรงกัน! กรุณาลองใหม่");
          }
        }
      }
    });
  }

  Future<void> _verifyPin() async {
    if (_enteredPin == _existingPin) {
      _goToHomePage();
    } else {
      setState(() {
        _enteredPin = "";
        _pinMismatch = true;
      });
      _showErrorDialog("PIN ไม่ถูกต้อง! กรุณาลองอีกครั้ง");
    }
  }

  Future<void> _savePinToDatabase() async {
    setState(() => _isLoading = true);

    final requestBody = jsonEncode({'id_user': widget.idUser, 'pin_user': _enteredPin});

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.40:3001/save_pin'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        _goToHomePage();
      } else {
        _showErrorDialog("เกิดข้อผิดพลาด: ${response.body}");
      }
    } catch (e) {
      _showErrorDialog("ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _goToHomePage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage(idUser: widget.idUser)),
          (Route<dynamic> route) => false,
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("ข้อผิดพลาด"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("ตกลง"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isLoading
                    ? "กำลังโหลดข้อมูล..."
                    : _existingPin != null
                    ? "กรอกรหัส PIN"
                    : (_isConfirming ? "ยืนยันรหัส PIN" : "ตั้งค่ารหัส PIN"),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[700]),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pinLength,
                      (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < (_isConfirming ? _confirmedPin.length : _enteredPin.length)
                          ? Colors.green[700]
                          : Colors.green[200],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (_pinMismatch)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "รหัส PIN ไม่ถูกต้อง! กรุณาลองอีกครั้ง",
                    style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              SizedBox(height: 40),
              _buildNumberPad(),
            ],
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.green)),
            ),
        ],
      ),
    );
  }

  Widget _buildNumberPad() {
    List<List<String>> keys = [
      ["1", "2", "3"],
      ["4", "5", "6"],
      ["7", "8", "9"],
      ["", "0", "del"],
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...keys.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) => key.trim().isEmpty ? _buildEmptySpace() : _buildKey(key)).toList(),
          );
        }).toList(),

        SizedBox(height: 10),
        _buildForgotPasswordButton(),
      ],
    );
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          _showForgotPasswordDialog(context);
        },
        child: Container(
          margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.orange[400],
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(2, 2))
            ],
          ),
          child: Text(
            "ลืมรหัสผ่าน",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
  void _showForgotPasswordDialog(BuildContext context) {
    TextEditingController phoneController = TextEditingController();
    TextEditingController otpController = TextEditingController();
    int countdown = 0;
    Timer? timer;
    bool isFormValid = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void startCountdown() {
              setState(() {
                countdown = 30;
              });
              timer = Timer.periodic(Duration(seconds: 1), (timer) {
                if (countdown > 0) {
                  setState(() {
                    countdown--;
                  });
                } else {
                  timer.cancel();
                }
              });
            }

            void checkFormValid() {
              setState(() {
                isFormValid = phoneController.text.isNotEmpty && otpController.text.isNotEmpty;
              });
            }

            Future<void> verifyPhoneAndOtp() async {
              final phone = phoneController.text.trim();
              final otp = otpController.text.trim();

              if (phone.isEmpty || phone.length != 10) {
                _showErrorDialog("กรุณากรอกเบอร์โทรศัพท์ให้ถูกต้อง");
                return;
              }

              if (otp.isEmpty) {
                _showErrorDialog("กรุณากรอกรหัส OTP");
                return;
              }

              try {
                final response = await http.post(
                  Uri.parse('http://192.168.1.40:3001/check_phone'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({'phone_number': phone, 'otp': otp}),
                );

                if (response.statusCode == 200) {
                  final responseData = jsonDecode(response.body);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ForgotPinPage(idUser: responseData['id_user'])),
                  );
                } else if (response.statusCode == 401) {
                  _showErrorDialog("OTP ไม่ถูกต้อง");
                } else {
                  final responseData = jsonDecode(response.body);
                  _showErrorDialog(responseData['error'] ?? "เกิดข้อผิดพลาด");
                }
              } catch (e) {
                _showErrorDialog("เกิดข้อผิดพลาดในการเชื่อมต่อเซิร์ฟเวอร์");
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "ลืมรหัสผ่าน",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(2, 2))
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.phone_android, color: Colors.blue, size: 24),
                                SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: phoneController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    decoration: InputDecoration(
                                      hintText: "เบอร์โทร",
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: countdown == 0 ? startCountdown : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: countdown == 0 ? Colors.blue : Colors.grey,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                          ),
                          child: Text(
                            countdown == 0 ? "ส่ง OTP" : "$countdown s",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(2, 2))
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lock, color: Colors.red, size: 24),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: otpController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                hintText: "รหัส OTP",
                                border: InputBorder.none,
                              ),
                              onChanged: (value) => checkFormValid(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            timer?.cancel();
                            Navigator.of(context).pop();
                          },
                          child: Text("ยกเลิก", style: TextStyle(color: Colors.grey[800], fontSize: 16)),
                        ),
                        ElevatedButton(
                          onPressed: isFormValid ? verifyPhoneAndOtp : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFormValid ? Colors.green : Colors.grey,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          ),
                          child: Text("ยืนยัน", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildKey(String key) {
    bool isDelete = key == "del";

    return GestureDetector(
      onTap: () => _onKeyPress(key),
      child: Container(
        margin: EdgeInsets.all(10),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDelete ? Colors.red[300] : Colors.green[200],
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(2, 2))
          ],
        ),
        child: Center(
          child: isDelete
              ? Icon(Icons.backspace, color: Colors.white, size: 30)
              : Text(
            key,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green[900]),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySpace() {
    return SizedBox(width: 100, height: 75);
  }

}