import 'package:flutter/material.dart';
import 'package:flutter_driver/common/responsive.dart';
import 'package:flutter_driver/pages/login/landingpage.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';
import '../noInternet/nointernet.dart';
import 'withdraw.dart';

class BankDetails extends StatefulWidget {
  const BankDetails({Key? key}) : super(key: key);

  @override
  State<BankDetails> createState() => _BankDetailsState();
}

class _BankDetailsState extends State<BankDetails> {
//text controller for editing bank details
  TextEditingController holderName = TextEditingController();
  TextEditingController bankName = TextEditingController();
  TextEditingController accountNumber = TextEditingController();
  TextEditingController bankCode = TextEditingController();

  bool _isLoading = true;
  String _showError = '';
  bool _edit = false;

  @override
  void initState() {
    getBankDetails();
    super.initState();
  }

  navigateLogout() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LandingPage()));
  }

  getBankDetails() async {
    var val = await getBankInfo();
    if (val == 'logout') {
      navigateLogout();
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

//showing error
  _errorClear() async {
    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        _showError = '';
      });
    });
  }

  //navigate pop
  pop() {
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
      child: Directionality(
        textDirection: (languageDirection == 'rtl')
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                height: media.height * 1,
                width: media.width * 1,
                color: page,
                padding: EdgeInsets.all(media.width * 0.05),
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top),
                    Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: media.width * 0.05),
                          width: media.width * 1,
                          alignment: Alignment.center,
                          child: PageTitleTextAdject(
                            child: Text(
                              languages[choosenLanguage]['text_bankDetails'],
                              style: GoogleFonts.inter(
                                  fontSize: media.width * twenty,
                                  fontWeight: FontWeight.w600,
                                  color: textColor),
                            ),
                          ),
                        ),
                        Positioned(
                            child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: IosBackButton()))
                      ],
                    ),
                    SizedBox(
                      height: media.width * 0.05,
                    ),
                    Expanded(
                        child: SingleChildScrollView(
                      child: (bankData.isEmpty || _edit == true)
                          ? Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: darkModeSecContainer,
                                      borderRadius: BorderRadius.circular(15)),
                                  child: TextField(
                                    controller: holderName,
                                    decoration: InputDecoration(
                                        hintText: languages[choosenLanguage]
                                            ['text_accoutHolderName'],
                                        hintStyle: TextStyle(
                                            color: (isDarkTheme == true)
                                                ? textColor.withOpacity(0.3)
                                                : null),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.transparent)),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            gapPadding: 1),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.transparent),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            gapPadding: 1),
                                        isDense: true),
                                    style: GoogleFonts.inter(color: textColor),
                                  ),
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: darkModeSecContainer,
                                      borderRadius: BorderRadius.circular(15)),
                                  child: TextField(
                                    controller: accountNumber,
                                    decoration: InputDecoration(
                                        hintText: languages[choosenLanguage]
                                            ['text_accountNumber'],
                                        hintStyle: TextStyle(
                                            color: (isDarkTheme == true)
                                                ? textColor.withOpacity(0.3)
                                                : null),
                                        focusedBorder: OutlineInputBorder(),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            gapPadding: 1),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            gapPadding: 1),
                                        isDense: true),
                                    style: GoogleFonts.inter(color: textColor),
                                  ),
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: darkModeSecContainer,
                                      borderRadius: BorderRadius.circular(15)),
                                  child: TextField(
                                    controller: bankName,
                                    decoration: InputDecoration(
                                        hintText: languages[choosenLanguage]
                                            ['text_bankName'],
                                        hintStyle: TextStyle(
                                            color: (isDarkTheme == true)
                                                ? textColor.withOpacity(0.3)
                                                : null),
                                        focusedBorder: OutlineInputBorder(),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            gapPadding: 1),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            gapPadding: 1),
                                        isDense: true),
                                    style: GoogleFonts.inter(color: textColor),
                                  ),
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: darkModeSecContainer,
                                      borderRadius: BorderRadius.circular(15)),
                                  child: TextField(
                                    controller: bankCode,
                                    decoration: InputDecoration(
                                        hintText: languages[choosenLanguage]
                                            ['text_bankCode'],
                                        hintStyle: TextStyle(
                                            color: (isDarkTheme == true)
                                                ? textColor.withOpacity(0.3)
                                                : null),
                                        focusedBorder: OutlineInputBorder(),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            gapPadding: 1),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            gapPadding: 1),
                                        isDense: true),
                                    style: GoogleFonts.inter(color: textColor),
                                  ),
                                ),
                                SizedBox(
                                  height: media.width * 0.1,
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(media.width * 0.025),
                                  width: media.width * 0.9,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: darkModeSecContainer,
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: Responsive.height(3, context),
                                      ),
                                      Text(
                                        languages[choosenLanguage]
                                            ['text_accoutHolderName'],
                                        style: GoogleFonts.inter(
                                            fontSize: media.width * fifteen,
                                            color: hintColor),
                                      ),
                                      SizedBox(
                                        height: media.width * 0.025,
                                      ),
                                      Text(
                                        bankData['account_name'],
                                        style: GoogleFonts.inter(
                                            fontSize: media.width * sixteen,
                                            fontWeight: FontWeight.w500,
                                            color: textColor),
                                      ),
                                      SizedBox(
                                        height: media.width * 0.05,
                                      ),
                                      Text(
                                        languages[choosenLanguage]
                                            ['text_bankName'],
                                        style: GoogleFonts.inter(
                                            fontSize: media.width * fifteen,
                                            color: hintColor),
                                      ),
                                      SizedBox(
                                        height: media.width * 0.025,
                                      ),
                                      Text(
                                        bankData['bank_name'],
                                        style: GoogleFonts.inter(
                                            fontSize: media.width * sixteen,
                                            fontWeight: FontWeight.w500,
                                            color: textColor),
                                      ),
                                      SizedBox(
                                        height: media.width * 0.05,
                                      ),
                                      Text(
                                        languages[choosenLanguage]
                                            ['text_accountNumber'],
                                        style: GoogleFonts.inter(
                                            fontSize: media.width * fifteen,
                                            color: hintColor),
                                      ),
                                      SizedBox(
                                        height: media.width * 0.025,
                                      ),
                                      Text(
                                        bankData['account_no'],
                                        style: GoogleFonts.inter(
                                            fontSize: media.width * sixteen,
                                            fontWeight: FontWeight.w500,
                                            color: textColor),
                                      ),
                                      SizedBox(
                                        height: media.width * 0.05,
                                      ),
                                      Text(
                                        languages[choosenLanguage]
                                            ['text_bankCode'],
                                        style: GoogleFonts.inter(
                                            fontSize: media.width * fifteen,
                                            color: hintColor),
                                      ),
                                      SizedBox(
                                        height: media.width * 0.025,
                                      ),
                                      Text(
                                        bankData['bank_code'],
                                        style: GoogleFonts.inter(
                                            fontSize: media.width * sixteen,
                                            fontWeight: FontWeight.w500,
                                            color: textColor),
                                      ),
                                      SizedBox(
                                        height: Responsive.height(3, context),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                              ],
                            ),
                    )),
                    (_edit == true || bankData.isEmpty)
                        ? Row(
                            mainAxisAlignment: (bankData.isEmpty)
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.spaceBetween,
                            children: [
                              (bankData.isNotEmpty)
                                  ? Button(
                                      onTap: () {
                                        setState(() {
                                          _edit = false;
                                        });
                                      },
                                      color:
                                          Color(0xffEB001B).withOpacity(0.29),
                                      width: media.width * 0.4,
                                      textcolor: Color(0xffEB001B),
                                      text: languages[choosenLanguage]
                                          ['text_cancel'])
                                  : Container(),
                              Button(
                                  onTap: () async {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    if (holderName.text.isNotEmpty &&
                                        accountNumber.text.isNotEmpty &&
                                        bankCode.text.isNotEmpty &&
                                        bankName.text.isNotEmpty) {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      var val = await addBankData(
                                          holderName.text,
                                          accountNumber.text,
                                          bankCode.text,
                                          bankName.text);
                                      if (val == 'success') {
                                        setState(() {
                                          _edit = false;
                                        });
                                        if (addBank == true) {
                                          pop();
                                        }
                                      } else if (val == 'logout') {
                                        navigateLogout();
                                      } else {
                                        setState(() {
                                          _showError = val.toString();
                                          _errorClear();
                                        });
                                      }
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  },
                                  width: (bankData.isEmpty)
                                      ? media.width * 0.88
                                      : media.width * 0.4,
                                  text: languages[choosenLanguage]
                                      ['text_confirm']),
                            ],
                          )
                        : Button(
                            onTap: () {
                              setState(() {
                                accountNumber.text =
                                    bankData['account_no'].toString();
                                bankName.text = bankData['bank_name'];
                                bankCode.text = bankData['bank_code'];
                                holderName.text = bankData['account_name'];
                                _edit = true;
                              });
                            },
                            text: languages[choosenLanguage]['text_edit']),
                    ButtonBottomSpace()
                  ],
                ),
              ),
              (_showError != '')
                  ? Positioned(
                      top: 0,
                      child: Container(
                        height: media.height * 1,
                        width: media.width * 1,
                        color: Colors.transparent.withOpacity(0.6),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                width: media.width * 0.8,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: page,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          spreadRadius: 2,
                                          blurRadius: 2)
                                    ]),
                                padding: EdgeInsets.all(media.width * 0.05),
                                child: SizedBox(
                                  width: media.width * 0.7,
                                  child: Text(
                                    _showError.toString(),
                                    style: GoogleFonts.inter(
                                        fontSize: media.width * sixteen,
                                        color: textColor),
                                  ),
                                ),
                              )
                            ]),
                      ))
                  : Container(),

              //no internet
              (internet == false)
                  ? Positioned(
                      top: 0,
                      child: NoInternet(onTap: () {
                        setState(() {
                          internetTrue();
                        });
                      }))
                  : Container(),

              //loader
              (_isLoading == true)
                  ? const Positioned(top: 0, child: Loading())
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
