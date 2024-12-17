import 'package:appproject/src/page/routes.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _idUser = TextEditingController();
  final _idCard = TextEditingController();
  String? _idUserError;
  String? _idCardError;

  bool _isFormValid(){
    return _idUser.text.isNotEmpty &&
        _idCard.text.isNotEmpty &&
        _idUserError == null &&
        _idCardError == null;
  }

  bool _isNumeric(String value) {
    return double.tryParse(value) != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Colors.green[400],
        child: Container(
            padding: const EdgeInsets.all(42),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/imgs/logo.png",width: 250,),
                SizedBox(height: 20,),
                ..._BuildTextFields(),
                SizedBox(height: 32,),
                ..._BuildButton(),
              ],
            )
        ),
      ),
    );
  }

  void _loginClick() {
    print("ID User => ${_idUser.text} ID Card => ${_idCard.text}");
    Navigator.pushReplacementNamed(context, AppRoute.home);
  }

  List<Widget> _BuildTextFields() {
    return [
    TextField(
      controller: _idUser,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: "รหัสสมาชิก",
        labelStyle: TextStyle(
            color: Colors.white
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
            color: Colors.white,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
            color: Colors.blue,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
            color: Colors.red,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
            color: Colors.red,
          ),
        ),
        errorText: _idUserError,
      ),
      onChanged: (value) {
        setState(() {
          _idUserError = _isNumeric(value) ? null : "กรุณาใส่ตัวเลขเท่านั้น";
        });
      },
    ),
      SizedBox(height: 20),
      TextField(
        controller: _idCard,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: "รหัส 4 ตัวท้ายบัตรประชาชน",
          labelStyle: TextStyle(
            color: Colors.white
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(
              color: Colors.white,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(
              color: Colors.blue,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(
              color: Colors.red,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: Colors.red,
            ),
          ),
          errorText: _idCardError,
        ),
        onChanged: (value) {
          setState(() {
            if (!_isNumeric(value)) {
              _idCardError = "กรุณาใส่ตัวเลขเท่านั้น";
            } else if (value.length != 4) {
              _idCardError = "กรุณาใส่ 4 ตัว";
            } else {
              _idCardError = null;
            }
          });
        },
      ),
    ];
  }

  _BuildButton() {
    return[
      ElevatedButton(onPressed: _isFormValid() ? _loginClick : null, child: Text("Login")),
    ];
  }
}