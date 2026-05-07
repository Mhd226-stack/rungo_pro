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

class DriverEarnings extends StatefulWidget {
  const DriverEarnings({Key? key}) : super(key: key);

  @override
  State<DriverEarnings> createState() => _DriverEarningsState();
}

class _DriverEarningsState extends State<DriverEarnings> {
  bool _isLoading = true;
  int _showEarning = 0;
  int _pickDate = 0;
  dynamic fromDate;
  dynamic toDate;
  dynamic _fromDate, _toDate;

  @override
  void initState() {
    getEarnings();
    super.initState();
  }

  navigateLogout() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LandingPage()));
  }

//getting earnings data
  getEarnings() async {
    driverTodayEarnings.clear();
    var val = await driverTodayEarning();
    if (val == 'logout') {
      navigateLogout();
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _datePicker() async {
    DateTime? picker = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: (_pickDate == 2) ? fromDate : DateTime(2020),
        lastDate: DateTime.now());
    if (picker != null) {
      setState(() {
        if (_pickDate == 1) {
          fromDate = picker;
          _fromDate = picker.toString().split(" ")[0];
          toDate = null;
          _toDate = null;
        } else if (_pickDate == 2) {
          toDate = picker;
          _toDate = picker.toString().split(" ")[0];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
      child: Directionality(
        textDirection: (languageDirection == 'rtl')
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(media.width * 0.05,
                  media.width * 0.05, media.width * 0.05, 0),
              height: media.height * 1,
              width: media.width * 1,
              color: page,
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
                          child: MyText(
                            text: languages[choosenLanguage]['text_earnings'],
                            size: media.width * twenty,
                            fontweight: FontWeight.w600,
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
                  Container(
                    height: media.width * 0.12,
                    width: media.width * 0.9,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () async {
                              setState(() {
                                _showEarning = 0;
                                _isLoading = true;
                              });

                              var val = await driverTodayEarning();
                              if (val == 'logout') {
                                navigateLogout();
                              }
                              setState(() {
                                _isLoading = false;
                              });
                            },
                            child: Container(
                                height: media.width * 0.1,
                                width: media.width * 0.28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3000.0),
                                    color: (_showEarning == 0)
                                        ? buttonColor
                                        : darkModeSecContainer),
                                child: MyText(
                                  text: languages[choosenLanguage]
                                      ['text_today'],
                                  size: media.width * fifteen,
                                  fontweight: FontWeight.w600,
                                  color: textColor,
                                )),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () async {
                              setState(() {
                                _showEarning = 1;
                                _isLoading = true;
                              });

                              var val = await driverWeeklyEarning();
                              if (val == 'logout') {
                                navigateLogout();
                              }
                              setState(() {
                                _isLoading = false;
                              });
                            },
                            child: Container(
                                height: media.width * 0.1,
                                width: media.width * 0.28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3000.0),
                                    color: (_showEarning == 1)
                                        ? buttonColor
                                        : darkModeSecContainer),
                                child: MyText(
                                    text: languages[choosenLanguage]
                                        ['text_weekly'],
                                    size: media.width * fifteen,
                                    fontweight: FontWeight.w600,
                                    color: textColor)),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () async {
                              setState(() {
                                driverReportEarnings.clear();
                                _showEarning = 2;
                              });
                            },
                            child: Container(
                                height: media.width * 0.1,
                                width: media.width * 0.27,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3000.0),
                                    color: (_showEarning == 2)
                                        ? buttonColor
                                        : darkModeSecContainer),
                                child: MyText(
                                    text: languages[choosenLanguage]
                                        ['text_report'],
                                    size: media.width * fifteen,
                                    fontweight: FontWeight.w600,
                                    color: textColor)),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: Responsive.width(90, context),
                    height: 1,
                    color: darkModeBorderColor,
                  ),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  Expanded(
                      child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: (driverTodayEarnings.isNotEmpty && _showEarning == 0)
                        ?
                        //current day earnings
                        Column(children: [
                            Container(
                              padding: EdgeInsets.all(media.width * 0.03),
                              decoration: BoxDecoration(
                                  color: buttonColor,
                                  borderRadius: BorderRadius.circular(10)),
                              width: media.width * 0.9,
                              child: Column(
                                children: [
                                  MyText(
                                    text: languages[choosenLanguage]
                                        ['text_todayearn'],
                                    size: media.width * fifteen,
                                    color: textColor,
                                  ),
                                  SizedBox(
                                    height: media.width * 0.025,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      MyText(
                                        text: driverTodayEarnings[
                                            'currency_symbol'],
                                        size: media.width * eighteen,
                                        color: textColor,
                                        fontweight: FontWeight.w500,
                                      ),
                                      MyText(
                                        text: driverTodayEarnings[
                                                'total_earnings']
                                            .toStringAsFixed(2),
                                        size: media.width * eighteen,
                                        color: textColor,
                                        fontweight: FontWeight.w500,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: media.width * 0.02,
                                  ),
                                  MyText(
                                    text: driverTodayEarnings['current_date'],
                                    size: media.width * eleven,
                                    color: hintColor,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: media.width * 0.03,
                            ),
                            Container(
                              padding: EdgeInsets.all(media.width * 0.05),
                              width: media.width * 0.9,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: media.width * 0.225,
                                    height: media.height * 0.1,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: darkModeSecContainer),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: media.width * 0.17,
                                            alignment: Alignment.center,
                                            child: FittedBox(
                                              child: MyText(
                                                text: languages[choosenLanguage]
                                                    ['text_trips'],
                                                size: media.width * fifteen,
                                                color: hintColor,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: media.width * 0.015,
                                          ),
                                          Container(
                                            width: media.width * 0.17,
                                            alignment: Alignment.center,
                                            child: MyText(
                                              text: driverTodayEarnings[
                                                      'total_trips_count']
                                                  .toString(),
                                              size: media.width * sixteen,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: media.width * 0.225,
                                    height: media.height * 0.1,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: darkModeSecContainer),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: media.width * 0.17,
                                          alignment: Alignment.center,
                                          child: FittedBox(
                                            child: MyText(
                                              text: languages[choosenLanguage]
                                                  ['text_enable_wallet'],
                                              size: media.width * sixteen,
                                              color: hintColor,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: media.width * 0.015,
                                        ),
                                        Container(
                                          width: media.width * 0.17,
                                          alignment: Alignment.center,
                                          child: MyText(
                                            text: driverTodayEarnings[
                                                    'total_wallet_trip_count']
                                                .toString(),
                                            size: media.width * sixteen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: media.width * 0.225,
                                    height: media.height * 0.1,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: darkModeSecContainer),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: media.width * 0.17,
                                          alignment: Alignment.center,
                                          child: FittedBox(
                                            child: MyText(
                                              text: languages[choosenLanguage]
                                                  ['text_cash'],
                                              size: media.width * sixteen,
                                              color: hintColor,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: media.width * 0.015,
                                        ),
                                        Container(
                                          width: media.width * 0.17,
                                          alignment: Alignment.center,
                                          child: MyText(
                                            text: driverTodayEarnings[
                                                    'total_cash_trip_count']
                                                .toString(),
                                            size: media.width * sixteen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: media.width * 0.04,
                            ),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    MyText(
                                      text: languages[choosenLanguage]
                                          ['text_tripkm'],
                                      size: media.width * fifteen,
                                    ),
                                    MyText(
                                      text:
                                          driverTodayEarnings['total_trip_kms']
                                              .toString(),
                                      size: media.width * sixteen,
                                    )
                                  ],
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                    top: media.width * 0.03,
                                  ),
                                  height: 1,
                                  color: darkModeBorderColor,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: media.width * 0.05,
                            ),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    MyText(
                                      text: languages[choosenLanguage]
                                          ['text_walletpayment'],
                                      size: media.width * sixteen,
                                    ),
                                    MyText(
                                      text: driverTodayEarnings[
                                                  'total_wallet_trip_amount']
                                              .toStringAsFixed(2) +
                                          ' ' +
                                          driverTodayEarnings[
                                              'currency_symbol'],
                                      size: media.width * sixteen,
                                    )
                                  ],
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                    top: media.width * 0.03,
                                  ),
                                  height: 1,
                                  color: darkModeBorderColor,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: media.width * 0.05,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MyText(
                                  text: languages[choosenLanguage]
                                      ['text_cashpayment'],
                                  size: media.width * sixteen,
                                ),
                                MyText(
                                  text: driverTodayEarnings[
                                              'total_cash_trip_amount']
                                          .toStringAsFixed(2) +
                                      ' ' +
                                      driverTodayEarnings['currency_symbol'],
                                  size: media.width * sixteen,
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: media.width * 0.03,
                                  bottom: media.width * 0.01),
                              height: 1,
                              color: darkModeBorderColor,
                            ),
                            SizedBox(
                              height: media.width * 0.03,
                            ),
                            Container(
                              padding: EdgeInsets.all(media.width * 0.03),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: darkModeSecContainer,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  MyText(
                                    text: languages[choosenLanguage]
                                        ['text_totalearnings'],
                                    size: media.width * fifteen,
                                    color: textColor,
                                  ),
                                  MyText(
                                    text: driverTodayEarnings['total_earnings']
                                            .toStringAsFixed(2) +
                                        ' ' +
                                        driverTodayEarnings['currency_symbol'],
                                    size: media.width * sixteen,
                                    color: textColor,
                                  ),
                                ],
                              ),
                            ),
                          ])
                        :
                        //current week earnings
                        (driverWeeklyEarnings.isNotEmpty && _showEarning == 1)
                            ? Column(children: [
                                MyText(
                                  text: driverWeeklyEarnings['start_of_week'] +
                                      ' - ' +
                                      driverWeeklyEarnings['end_of_week'],
                                  size: media.width * fifteen,
                                  color: hintColor,
                                ),
                                SizedBox(
                                  height: media.width * 0.025,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    MyText(
                                      text: driverWeeklyEarnings[
                                          'currency_symbol'],
                                      size: media.width * eighteen,
                                      fontweight: FontWeight.w500,
                                    ),
                                    MyText(
                                      text:
                                          driverWeeklyEarnings['total_earnings']
                                              .toStringAsFixed(2),
                                      size: media.width * eighteen,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                SizedBox(
                                  height: media.width * 0.5,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: weekDays
                                        .map((i, value) {
                                          List val = [];
                                          weekDays.forEach((i, value) {
                                            val.add(double.parse(
                                                weekDays[i].toString()));
                                          });
                                          val.sort();
                                          return MapEntry(
                                              i,
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  MyText(
                                                    text:
                                                        weekDays[i].toString(),
                                                    size: media.width * twelve,
                                                    color: (isDarkTheme == true)
                                                        ? Colors.white
                                                        : hintColor,
                                                  ),
                                                  SizedBox(
                                                    height: media.width * 0.01,
                                                  ),
                                                  Container(
                                                    width: media.width * 0.07,
                                                    height: (val.last > 0)
                                                        ? (media.width * 0.35) /
                                                            (val.last /
                                                                double.parse(
                                                                    weekDays[i]
                                                                        .toString()))
                                                        : 1,
                                                    color: buttonColor,
                                                  ),
                                                  SizedBox(
                                                    height: media.width * 0.005,
                                                  ),
                                                  MyText(
                                                    text: i,
                                                    size: media.width * twelve,
                                                    color: (isDarkTheme == true)
                                                        ? Colors.white
                                                        : hintColor,
                                                  )
                                                ],
                                              ));
                                        })
                                        .values
                                        .toList(),
                                  ),
                                ),
                                SizedBox(
                                  height: media.width * 0.06,
                                ),
                                Container(
                                  padding: EdgeInsets.all(media.width * 0.05),
                                  width: media.width * 0.9,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: darkModeSecContainer),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: media.width * 0.225,
                                        height: media.height * 0.1,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: page),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: media.width * 0.17,
                                              alignment: Alignment.center,
                                              child: FittedBox(
                                                child: MyText(
                                                  text:
                                                      languages[choosenLanguage]
                                                          ['text_trips'],
                                                  size: media.width * sixteen,
                                                  color: (isDarkTheme == true)
                                                      ? Colors.white
                                                      : hintColor,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: media.width * 0.015,
                                            ),
                                            Container(
                                              width: media.width * 0.17,
                                              alignment: Alignment.center,
                                              child: MyText(
                                                text: driverWeeklyEarnings[
                                                        'total_trips_count']
                                                    .toString(),
                                                size: media.width * sixteen,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: media.width * 0.225,
                                        height: media.height * 0.1,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: page),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: media.width * 0.17,
                                              alignment: Alignment.center,
                                              child: FittedBox(
                                                child: MyText(
                                                  text: languages[
                                                          choosenLanguage]
                                                      ['text_enable_wallet'],
                                                  size: media.width * sixteen,
                                                  color: (isDarkTheme == true)
                                                      ? Colors.white
                                                      : hintColor,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: media.width * 0.015,
                                            ),
                                            Container(
                                              width: media.width * 0.17,
                                              alignment: Alignment.center,
                                              child: MyText(
                                                text: driverWeeklyEarnings[
                                                        'total_wallet_trip_count']
                                                    .toString(),
                                                size: media.width * sixteen,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: media.width * 0.225,
                                        height: media.height * 0.1,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: page),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: media.width * 0.17,
                                              alignment: Alignment.center,
                                              child: FittedBox(
                                                child: MyText(
                                                  text:
                                                      languages[choosenLanguage]
                                                          ['text_cash'],
                                                  size: media.width * sixteen,
                                                  color: (isDarkTheme == true)
                                                      ? Colors.white
                                                      : hintColor,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: media.width * 0.015,
                                            ),
                                            Container(
                                              width: media.width * 0.17,
                                              alignment: Alignment.center,
                                              child: MyText(
                                                text: driverWeeklyEarnings[
                                                        'total_cash_trip_count']
                                                    .toString(),
                                                size: media.width * sixteen,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: media.width * 0.06,
                                ),
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        MyText(
                                          text: languages[choosenLanguage]
                                              ['text_tripkm'],
                                          size: media.width * sixteen,
                                        ),
                                        MyText(
                                          text: driverWeeklyEarnings[
                                                  'total_trip_kms']
                                              .toString(),
                                          size: media.width * sixteen,
                                        )
                                      ],
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: media.width * 0.03,
                                          bottom: media.width * 0.03),
                                      height: 1,
                                      color: darkModeBorderColor,
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        MyText(
                                          text: languages[choosenLanguage]
                                              ['text_walletpayment'],
                                          size: media.width * sixteen,
                                        ),
                                        MyText(
                                          text: driverWeeklyEarnings[
                                                  'currency_symbol'] +
                                              driverWeeklyEarnings[
                                                      'total_wallet_trip_amount']
                                                  .toStringAsFixed(2),
                                          size: media.width * sixteen,
                                        )
                                      ],
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: media.width * 0.03,
                                          bottom: media.width * 0.03),
                                      height: 1,
                                      color: darkModeBorderColor,
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        MyText(
                                          text: languages[choosenLanguage]
                                              ['text_cashpayment'],
                                          size: media.width * sixteen,
                                        ),
                                        MyText(
                                          text: driverWeeklyEarnings[
                                                      'total_cash_trip_amount']
                                                  .toStringAsFixed(2) +
                                              ' ' +
                                              driverWeeklyEarnings[
                                                  'currency_symbol'],
                                          size: media.width * sixteen,
                                        ),
                                      ],
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: media.width * 0.03,
                                          bottom: media.width * 0.01),
                                      height: 1,
                                      color: darkModeBorderColor,
                                    ),
                                    SizedBox(
                                      height: Responsive.height(2, context),
                                    )
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.all(media.width * 0.03),
                                  decoration: BoxDecoration(
                                      color: darkModeSecContainer,
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      MyText(
                                        text: languages[choosenLanguage]
                                            ['text_totalearnings'],
                                        size: media.width * sixteen,
                                        color: textColor,
                                      ),
                                      MyText(
                                        text: driverWeeklyEarnings[
                                                    'total_earnings']
                                                .toStringAsFixed(2) +
                                            ' ' +
                                            driverWeeklyEarnings[
                                                'currency_symbol'],
                                        size: media.width * sixteen,
                                        color: textColor,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                )
                              ])
                            :
                            //earning on specific choosen date
                            (_showEarning == 2)
                                ? Column(
                                    children: [
                                      SizedBox(
                                        height: media.width * 0.03,
                                      ),
                                      Row(
                                        children: [
                                          MyText(
                                            text: languages[choosenLanguage]
                                                ['text_fromDate'],
                                            size: media.width * twelve,
                                            fontweight: FontWeight.w500,
                                            color: hintColor,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: media.width * 0.02,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            _pickDate = 1;
                                          });
                                          _datePicker();
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(
                                              media.width * 0.03),
                                          decoration: BoxDecoration(
                                            color: darkModeSecContainer,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              MyText(
                                                text: _fromDate == null
                                                    ? languages[choosenLanguage]
                                                        ['text_choose_date']
                                                    : _fromDate.toString(),
                                                size: media.width * sixteen,
                                                color: textColor,
                                              ),
                                              Icon(Icons.date_range_outlined,
                                                  color: textColor)
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: media.width * 0.05,
                                      ),
                                      Row(
                                        children: [
                                          MyText(
                                            text: languages[choosenLanguage]
                                                ['text_toDate'],
                                            size: media.width * twelve,
                                            color: hintColor,
                                            fontweight: FontWeight.w500,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: media.width * 0.02,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          if (_fromDate != null) {
                                            setState(() {
                                              _pickDate = 2;
                                            });
                                            _datePicker();
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(
                                              media.width * 0.03),
                                          decoration: BoxDecoration(
                                            color: darkModeSecContainer,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              MyText(
                                                text: _toDate == null
                                                    ? languages[choosenLanguage]
                                                        ['text_choose_date']
                                                    : _toDate.toString(),
                                                size: media.width * sixteen,
                                                color: textColor,
                                              ),
                                              Icon(Icons.date_range_outlined,
                                                  color: textColor)
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: media.width * 0.05,
                                      ),
                                      Button(
                                          onTap: () async {
                                            setState(() {
                                              driverReportEarnings.clear();
                                              _isLoading = true;
                                            });
                                            var val = await driverEarningReport(
                                                _fromDate, _toDate);
                                            if (val == 'logout') {
                                              navigateLogout();
                                            }
                                            setState(() {
                                              _isLoading = false;
                                            });
                                          },
                                          width: media.width * 0.35,
                                          borderRadius: 3000.0,
                                          text: languages[choosenLanguage]
                                              ['text_confirm']),
                                      SizedBox(
                                        height: media.width * 0.05,
                                      ),
                                      (driverReportEarnings.isNotEmpty)
                                          ? Column(
                                              children: [
                                                MyText(
                                                  text: driverReportEarnings[
                                                          'from_date'] +
                                                      ' - ' +
                                                      driverReportEarnings[
                                                          'to_date'],
                                                  size: media.width * fifteen,
                                                  color: hintColor,
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.035,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      driverReportEarnings[
                                                          'currency_symbol'],
                                                      style: GoogleFonts.inter(
                                                          fontSize:
                                                              media.width *
                                                                  eighteen,
                                                          color: textColor),
                                                    ),
                                                    Text(
                                                      driverReportEarnings[
                                                              'total_earnings']
                                                          .toStringAsFixed(2),
                                                      style: GoogleFonts.inter(
                                                          fontSize:
                                                              media.width *
                                                                  eighteen,
                                                          color: textColor),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.03,
                                                ),
                                                Container(
                                                  padding: EdgeInsets.all(
                                                      media.width * 0.05),
                                                  width: media.width * 0.9,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                        width:
                                                            media.width * 0.225,
                                                        height:
                                                            media.height * 0.1,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            color:
                                                                darkModeSecContainer),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Container(
                                                              width:
                                                                  media.width *
                                                                      0.17,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: MyText(
                                                                text: languages[
                                                                        choosenLanguage]
                                                                    [
                                                                    'text_trips'],
                                                                size: media
                                                                        .width *
                                                                    sixteen,
                                                                color:
                                                                    hintColor,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height:
                                                                  media.width *
                                                                      0.015,
                                                            ),
                                                            Container(
                                                              width:
                                                                  media.width *
                                                                      0.17,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: MyText(
                                                                text: driverReportEarnings[
                                                                        'total_trips_count']
                                                                    .toString(),
                                                                size: media
                                                                        .width *
                                                                    sixteen,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        width:
                                                            media.width * 0.225,
                                                        height:
                                                            media.height * 0.1,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            color:
                                                                darkModeSecContainer),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Container(
                                                              width:
                                                                  media.width *
                                                                      0.19,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: MyText(
                                                                text: languages[
                                                                        choosenLanguage]
                                                                    [
                                                                    'text_enable_wallet'],
                                                                size: media
                                                                        .width *
                                                                    sixteen,
                                                                color:
                                                                    hintColor,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height:
                                                                  media.width *
                                                                      0.015,
                                                            ),
                                                            Container(
                                                              width:
                                                                  media.width *
                                                                      0.17,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: MyText(
                                                                text: driverReportEarnings[
                                                                        'total_wallet_trip_count']
                                                                    .toString(),
                                                                size: media
                                                                        .width *
                                                                    sixteen,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        width:
                                                            media.width * 0.225,
                                                        height:
                                                            media.height * 0.1,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            color:
                                                                darkModeSecContainer),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Container(
                                                              width:
                                                                  media.width *
                                                                      0.17,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: MyText(
                                                                text: languages[
                                                                        choosenLanguage]
                                                                    [
                                                                    'text_cash'],
                                                                size: media
                                                                        .width *
                                                                    sixteen,
                                                                color:
                                                                    hintColor,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height:
                                                                  media.width *
                                                                      0.015,
                                                            ),
                                                            Container(
                                                              width:
                                                                  media.width *
                                                                      0.17,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: MyText(
                                                                text: driverReportEarnings[
                                                                        'total_cash_trip_count']
                                                                    .toString(),
                                                                size: media
                                                                        .width *
                                                                    sixteen,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.05,
                                                ),
                                                Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          languages[
                                                                  choosenLanguage]
                                                              ['text_tripkm'],
                                                          style: GoogleFonts.inter(
                                                              fontSize:
                                                                  media.width *
                                                                      sixteen,
                                                              color: textColor),
                                                        ),
                                                        Text(
                                                          driverReportEarnings[
                                                                  'total_trip_kms']
                                                              .toString(),
                                                          style: GoogleFonts.inter(
                                                              fontSize:
                                                                  media.width *
                                                                      sixteen,
                                                              color: textColor),
                                                        )
                                                      ],
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: media.width *
                                                              0.03,
                                                          bottom: media.width *
                                                              0.03),
                                                      height: 1,
                                                      color:
                                                          darkModeBorderColor,
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          languages[
                                                                  choosenLanguage]
                                                              [
                                                              'text_walletpayment'],
                                                          style: GoogleFonts.inter(
                                                              fontSize:
                                                                  media.width *
                                                                      sixteen,
                                                              color: textColor),
                                                        ),
                                                        Text(
                                                          driverReportEarnings[
                                                                      'total_wallet_trip_amount']
                                                                  .toStringAsFixed(
                                                                      2) +
                                                              ' ' +
                                                              driverReportEarnings[
                                                                  'currency_symbol'],
                                                          style: GoogleFonts.inter(
                                                              fontSize:
                                                                  media.width *
                                                                      sixteen,
                                                              color: textColor),
                                                        )
                                                      ],
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: media.width *
                                                              0.03,
                                                          bottom: media.width *
                                                              0.03),
                                                      height: 1,
                                                      color:
                                                          darkModeBorderColor,
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          languages[
                                                                  choosenLanguage]
                                                              [
                                                              'text_cashpayment'],
                                                          style: GoogleFonts.inter(
                                                              fontSize:
                                                                  media.width *
                                                                      sixteen,
                                                              color: textColor),
                                                        ),
                                                        Text(
                                                          driverReportEarnings[
                                                                      'total_cash_trip_amount']
                                                                  .toStringAsFixed(
                                                                      2) +
                                                              ' ' +
                                                              driverReportEarnings[
                                                                  'currency_symbol'],
                                                          style: GoogleFonts.inter(
                                                              fontSize:
                                                                  media.width *
                                                                      sixteen,
                                                              color: textColor),
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: media.width *
                                                              0.03,
                                                          bottom: media.width *
                                                              0.01),
                                                      height: 1,
                                                      color:
                                                          darkModeBorderColor,
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: Responsive.height(
                                                      2, context),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.all(
                                                      media.width * 0.03),
                                                  decoration: BoxDecoration(
                                                    color: darkModeSecContainer,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        languages[
                                                                choosenLanguage]
                                                            [
                                                            'text_totalearnings'],
                                                        style:
                                                            GoogleFonts.inter(
                                                                fontSize: media
                                                                        .width *
                                                                    sixteen,
                                                                color:
                                                                    textColor),
                                                      ),
                                                      Text(
                                                        driverReportEarnings[
                                                                    'total_earnings']
                                                                .toStringAsFixed(
                                                                    2) +
                                                            ' ' +
                                                            driverReportEarnings[
                                                                'currency_symbol'],
                                                        style:
                                                            GoogleFonts.inter(
                                                                fontSize: media
                                                                        .width *
                                                                    sixteen,
                                                                color:
                                                                    textColor),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Container(),
                                      SizedBox(
                                        height: media.width * 0.05,
                                      )
                                    ],
                                  )
                                : Container(),
                  ))
                ],
              ),
            ),

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
                ? const Positioned(child: Loading())
                : Container()
          ],
        ),
      ),
    );
  }
}
