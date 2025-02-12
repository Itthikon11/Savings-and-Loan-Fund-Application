import 'dart:async';
import 'package:appproject/src/page/Login/PinPage.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idUser = TextEditingController();
  final TextEditingController _numberUser = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isButtonDisabled = false;
  bool _isLoginEnabled = false;
  int _countdown = 30;
  Timer? _timer;

  bool _isUserValid = true;

  void _startCountdown() {
    setState(() {
      _isButtonDisabled = true;
      _countdown = 30;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _isButtonDisabled = false;
          timer.cancel();
        }
      });
    });
  }

  void _checkUser() async {
    final String idUser = _idUser.text;

    if (idUser.isEmpty) {
      setState(() {
        _isUserValid = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.40:3001/users/$idUser'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isUserValid = true;
        });
      } else {
        setState(() {
          _isUserValid = false;
        });
      }
    } catch (e) {
      setState(() {
        _isUserValid = false;
      });
      print('Error checking user: $e');
    }
  }


  void _validateForm() {
    setState(() {
      _isLoginEnabled = _idUser.text.isNotEmpty &&
          _numberUser.text.isNotEmpty &&
          _otpController.text.isNotEmpty;
    });
  }

  Future<void> _checkUserAndSavePhone() async {
    final idUser = _idUser.text.trim();
    final phoneNumber = _numberUser.text.trim();
    final otp = _otpController.text.trim();

    if (idUser.isEmpty || phoneNumber.isEmpty || otp.isEmpty) {
      setState(() {
        _isUserValid = false;
      });
      return;
    }

    final phoneRegex = RegExp(r'^0[689]\d{8}$');
    if (!phoneRegex.hasMatch(phoneNumber)) {
      _showErrorDialog('รูปแบบเบอร์โทรศัพท์ไม่ถูกต้อง');
      return;
    }

    try {
      final response = await http
          .post(
        Uri.parse('http://192.168.1.40:3001/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_user': idUser,
          'phone_number': phoneNumber,
          'otp': otp,
        }),
      )
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('คำขอหมดเวลา');
      });

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PinEntryPage(idUser: idUser),
          ),
        );
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        _showErrorDialog(responseData['message'] ?? 'เกิดข้อผิดพลาด');
      }
    } catch (e) {
      _showErrorDialog('เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('เกิดข้อผิดพลาด'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _idUser.dispose();
    _numberUser.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.green[400],
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 350,
                height: 450,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(2, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 40),
                    ..._buildMemberFields(),
                    SizedBox(height: 30),
                    ..._buildNumberFields(),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isLoginEnabled
                          ? () {
                        _checkUserAndSavePhone();
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        _isLoginEnabled ? Colors.blueAccent : Colors.grey,
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding:
                        EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      child: Text(
                        "เข้าสู่ระบบ",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -80,
                left: 100,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 50,
                        spreadRadius: 2,
                        offset: Offset(2, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      "assets/imgs/logo.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMemberFields() {
    return [
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _idUser,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            _validateForm();
            _checkUser();
          },
          decoration: InputDecoration(
            labelText: "รหัสสมาชิก",
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isUserValid ? Colors.green : Colors.red,
              ),
            ),
            prefixIcon: Icon(
              Icons.person,
              color: _isUserValid ? Colors.green : Colors.red,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildNumberFields() {
    return [
      Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _numberUser,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                onChanged: (value) => _validateForm(),
                decoration: InputDecoration(
                  labelText: "เบอร์โทร",
                  labelStyle:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon:
                  Icon(Icons.phone_iphone, color: Colors.blueAccent),
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: _isButtonDisabled
                ? null
                : () {
              _startCountdown();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
              _isButtonDisabled ? Colors.grey : Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
            child: _isButtonDisabled
                ? Text("$_countdown วินาที", style: TextStyle(fontSize: 14))
                : Text("ส่ง OTP",
                style:
                TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      SizedBox(height: 20),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => _validateForm(),
          decoration: InputDecoration(
            labelText: "รหัส OTP",
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(Icons.lock, color: Colors.redAccent),
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          ),
        ),
      ),
    ];
  }
}