import 'package:appproject/src/page/Home/HomePage.dart';
import 'package:flutter/material.dart';

class PinEntryPage extends StatefulWidget {
  @override
  _PinEntryPageState createState() => _PinEntryPageState();
}

class _PinEntryPageState extends State<PinEntryPage> {
  String _enteredPin = "";
  String _confirmedPin = "";
  bool _isConfirming = false;
  bool _pinMismatch = false;
  final int _pinLength = 6;

  void _onKeyPress(String value) {
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

      if (_enteredPin.length == _pinLength && !_isConfirming) {
        _isConfirming = true;
        _pinMismatch = false;
      } else if (_confirmedPin.length == _pinLength && _isConfirming) {
        if (_enteredPin == _confirmedPin) {
          print("PIN ยืนยันสำเร็จ: $_enteredPin");
          _goToHomePage();
        } else {
          print("PIN ไม่ตรงกัน! ให้ใส่ใหม่");
          _pinMismatch = true;
          _confirmedPin = "";
        }
      }
    });
  }

  void _goToHomePage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isConfirming ? "ยืนยันรหัส PIN" : "ตั้งค่ารหัส PIN",
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
                "รหัส PIN ไม่ตรงกัน! กรุณาลองอีกครั้ง",
                style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

          SizedBox(height: 40),

          // ปุ่มยืนยัน PIN (เมื่อกรอกครบ 6 หลัก)
          if (_isConfirming && _confirmedPin.length == _pinLength)
            ElevatedButton(
              onPressed: _enteredPin == _confirmedPin ? _goToHomePage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text("ยืนยัน"),
            ),

          SizedBox(height: 20),

          // Number Pad
          _buildNumberPad(),
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
      children: keys
          .map((row) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: row.map((key) {
          return key.isNotEmpty
              ? _buildKey(key)
              : SizedBox(width: 75);
        }).toList(),
      ))
          .toList(),
    );
  }

  Widget _buildKey(String key) {
    return GestureDetector(
      onTap: () => _onKeyPress(key),
      child: Container(
        margin: EdgeInsets.all(10),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: key == "del" ? Colors.red[200] : Colors.green[100],
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(2, 2)),
          ],
        ),
        child: Center(
          child: key == "del"
              ? Icon(Icons.backspace, color: Colors.red[900], size: 24)
              : Text(
            key,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[800]),
          ),
        ),
      ),
    );
  }
}
