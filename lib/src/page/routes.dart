import 'package:flutter/material.dart';

import 'Data/PercenPage.dart';
import 'Data/SlipPage.dart';
import 'Login/LoginPage.dart';
import 'Home/HomePage.dart';
import 'Loan/LoanPage.dart';
import 'Savings/SavingsPage.dart';
import 'Cal/CalDividendPage.dart';
import 'Cal/CalLoanPage.dart';
import 'Profile/ProfilePage.dart';
import 'Deposit/DepositPage.dart';
import 'Data_Loan/Data_Loan.dart';
import 'Data_Savings/Data_Savings.dart';
import 'Login/PinPage.dart';

class AppRoute{
  static const home = 'home';
  static const login = 'login';
  static const loan = 'loan';
  static const savings = 'savings';
  static const CalDividend = 'CalDividend';
  static const CalLoan = 'CalLoan';
  static const Profile = 'Profile';
  static const Deposit = 'Deposit';
  static const Percen = 'Percen';
  static const Status = 'Status';
  static const Data_Loan = 'Data_Loan';
  static const Data_Savings = 'Data_Savings';
  static const PinPage = 'PinPage';


  static get all => <String, WidgetBuilder>{
    login : (context) => const LoginPage(),
    home : (context) => const HomePage(),
    loan : (context) => const Loanpage(),
    savings : (context) => const Savingspage(),
    CalDividend : (context) => const Caldividendpage(),
    CalLoan : (context) => const Calloanpage(),
    Profile : (context) => const Profilepage(),
    Deposit : (context) => const Depositpage(),
    Percen : (context) => const Percenpage(),
    Status : (context) => const Slippage(),
    Data_Loan: (context) => const LoanScreen(),
    Data_Savings: (context) => const SavingScreen(),
    PinPage: (context) => PinEntryPage(),
  };
}