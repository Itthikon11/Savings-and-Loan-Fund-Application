import 'package:appproject/src/page/Login/PinPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPinPage extends StatefulWidget {
  final String idUser;

  ForgotPinPage({required this.idUser});

  @override
  _ForgotPinPageState createState() => _ForgotPinPageState();
}

class _ForgotPinPageState extends State<ForgotPinPage> {
  String _newPin = "";
  String _confirmPin = "";
  bool _isConfirming = false;
  bool _pinMismatch = false;
  final int _pinLength = 6;
  bool _isLoading = false;

  void _onKeyPress(String value) {
    setState(() {
      if (value == "del") {
        if (_isConfirming && _confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        } else if (!_isConfirming && _newPin.isNotEmpty) {
          _newPin = _newPin.substring(0, _newPin.length - 1);
        }
      } else {
        if (_isConfirming && _confirmPin.length < _pinLength) {
          _confirmPin += value;
        } else if (!_isConfirming && _newPin.length < _pinLength) {
          _newPin += value;
        }
      }

      if (_newPin.length == _pinLength && !_isConfirming) {
        _isConfirming = true;
      } else if (_confirmPin.length == _pinLength && _isConfirming) {
        if (_newPin == _confirmPin) {
          _resetPin();
        } else {
          _pinMismatch = true;
          _confirmPin = "";
          _showErrorDialog("รหัส PIN ไม่ตรงกัน! กรุณาลองใหม่");
        }
      }
    });
  }

  Future<void> _resetPin() async {
    setState(() => _isLoading = true);

    final requestBody = jsonEncode({
      'id_user': widget.idUser,
      'pin_user': _newPin,
    });

    try {
      final response = await http.post(
        Uri.parse('http://172.18.138.185:3001/reset_pin'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        _showSuccessDialog("รหัส PIN ถูกเปลี่ยนเรียบร้อย!");
      } else {
        _showErrorDialog("เกิดข้อผิดพลาด: ${response.body}");
      }
    } catch (e) {
      _showErrorDialog("ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์");
    } finally {
      setState(() => _isLoading = false);
    }
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

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("สำเร็จ"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PinEntryPage(idUser: widget.idUser)),
              );
            },
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
                    : (_isConfirming ? "ยืนยันรหัส PIN ใหม่" : "ตั้งค่ารหัส PIN ใหม่"),
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
                      color: index < (_isConfirming ? _confirmPin.length : _newPin.length)
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
                    "รหัส PIN ไม่ตรงกัน! กรุณาลองใหม่",
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
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) => key.trim().isEmpty ? _buildEmptySpace() : _buildKey(key)).toList(),
        );
      }).toList(),
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
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(2, 2))],
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
