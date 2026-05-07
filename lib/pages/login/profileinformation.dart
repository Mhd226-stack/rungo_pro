import 'package:flutter/material.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';
import 'carinformation.dart';
import 'login.dart';
import 'namepage.dart';
import 'requiredinformation.dart';

// ignore: must_be_immutable
class ProfileInformation extends StatefulWidget {
  dynamic from;
  ProfileInformation({Key? key, this.from}) : super(key: key);

  @override
  State<ProfileInformation> createState() => _ProfileInformationState();
}

class _ProfileInformationState extends State<ProfileInformation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  TextEditingController firstname = TextEditingController();
  TextEditingController emailText = TextEditingController();
  TextEditingController lastname = TextEditingController();
  TextEditingController mobile = TextEditingController();
  TextEditingController pinText = TextEditingController();
  bool _isLoading = true;
  bool chooseWorkArea = false;
  String _error = '';
  bool getOtp = false;

  @override
  void initState() {
    countryCode();
    // getServiceLoc();
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  countryCode() async {
    if (widget.from == null) {
      firstname.text = name.toString().split(' ')[0];
      lastname.text = name.toString().split(' ')[1];
      mobile.text = phnumber;
      emailText.text = email;
    } else {
      firstname.text = userDetails['name'].toString().split(' ')[0];
      lastname.text = (userDetails['name'].toString().split(' ').length > 1)
          ? userDetails['name'].toString().split(' ')[1]
          : '';
      mobile.text = userDetails['mobile'];
      emailText.text = userDetails['email'];
    }
    _isLoading = false;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              padding: EdgeInsets.only(
                  left: media.width * 0.05, right: media.width * 0.05),
              height: media.height * 1,
              width: media.width * 1,
              color: page,
              child: Column(
                children: [
                  SizedBox(
                    height:
                        media.width * 0.05 + MediaQuery.of(context).padding.top,
                  ),
                  Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: media.width * 0.05),
                        width: media.width * 1,
                        height: media.height * 0.07,
                        alignment: Alignment.center,
                        child: PageTitleTextAdject(
                          isMargin: true,
                          child: MyText(
                              fontweight: FontWeight.w600,
                              text: languages[choosenLanguage]['text_reqinfo'],
                              size: media.width * eighteen),
                        ),
                      ),
                      Positioned(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: IosBackButton()),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // SizedBox(
                          //   width: media.width * 0.9,
                          //   child: MyText(
                          //     text: languages[choosenLanguage]
                          //             ['text_profile_info']
                          //         .toString()
                          //         .toUpperCase(),
                          //     size: media.width * fourteen,
                          //     fontweight: FontWeight.bold,
                          //   ),
                          // ),
                          SizedBox(
                            height: media.width * 0.05,
                          ),
                          SizedBox(
                            width: media.width * 0.9,
                            child: MyText(
                              text: languages[choosenLanguage]['text_name'],
                              size: media.width * twelve,
                              fontweight: FontWeight.w500,
                              color: hintColor,
                            ),
                          ),
                          SizedBox(
                            height: media.width * 0.02,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                    height: media.width * 0.13,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: darkModeSecContainer),
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: MyTextField(
                                      textController: firstname,
                                      fontsize: media.width * sixteen,
                                      hinttext: languages[choosenLanguage]
                                          ['text_first_name'],
                                      inputType: TextInputType.text,
                                      onTap: (val) {
                                        setState(() {});
                                      },
                                      readonly:
                                          (widget.from == null) ? true : false,
                                    )),
                              ),
                              SizedBox(
                                width: media.height * 0.02,
                              ),
                              Expanded(
                                child: Container(
                                    height: media.width * 0.13,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: darkModeSecContainer),
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: MyTextField(
                                      textController: lastname,
                                      fontsize: media.width * sixteen,
                                      hinttext: languages[choosenLanguage]
                                          ['text_last_name'],
                                      inputType: TextInputType.text,
                                      onTap: (val) {
                                        setState(() {});
                                      },
                                      readonly:
                                          (widget.from == null) ? true : false,
                                    )),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: media.height * 0.02,
                          ),
                          SizedBox(
                            width: media.width * 0.9,
                            child: MyText(
                              text: languages[choosenLanguage]['text_mob_num2'],
                              size: media.width * twelve,
                              fontweight: FontWeight.w500,
                              color: hintColor,
                            ),
                          ),
                          SizedBox(
                            height: media.height * 0.01,
                          ),
                          Container(
                            height: media.width * 0.13,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: darkModeSecContainer),
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: MyTextField(
                              textController: mobile,
                              fontsize: media.width * sixteen,
                              readonly: true,
                              hinttext: languages[choosenLanguage]
                                  ['text_enter_phone_number'],
                              // prefixtext: '+962',
                              onTap: (val) {
                                setState(() {});
                              },
                            ),
                          ),
                          SizedBox(
                            height: media.height * 0.02,
                          ),
                          SizedBox(
                            width: media.width * 0.9,
                            child: MyText(
                              text: languages[choosenLanguage]['text_email2'],
                              size: media.width * twelve,
                              fontweight: FontWeight.w500,
                              color: hintColor,
                            ),
                          ),
                          SizedBox(
                            height: media.height * 0.01,
                          ),
                          Container(
                              height: media.width * 0.13,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: darkModeSecContainer),
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: MyTextField(
                                textController: emailText,
                                fontsize: media.width * sixteen,
                                hinttext: languages[choosenLanguage]
                                    ['text_enter_email'],
                                inputType: TextInputType.emailAddress,
                                onTap: (val) {
                                  setState(() {});
                                },
                              )),
                        ],
                      ),
                    ),
                  ),
                  if (_error != '')
                    Container(
                      width: media.width * 0.9,
                      padding: EdgeInsets.only(
                          top: media.width * 0.02, bottom: media.width * 0.02),
                      child: MyText(
                        text: _error,
                        size: media.width * twelve,
                        color: Colors.red,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  Button(
                      onTap: () async {
                        setState(() {
                          _error = '';
                        });
                        String pattern =
                            r"^[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])*$";

                        RegExp regex = RegExp(pattern);
                        if (regex.hasMatch(emailText.text)) {
                          if (widget.from == null) {
                            if (myServiceId != '' && myServiceId != null) {
                              profileCompleted = true;
                              Navigator.pop(context, true);
                            }
                          } else {
                            setState(() {
                              _isLoading = true;
                            });
                            // ignore: prefer_typing_uninitialized_variables
                            var nav;

                            // print('started');
                            nav = await updateProfile(
                              '${firstname.text} ${lastname.text}',
                              emailText.text,
                              // userDetails['mobile']
                            );
                            if (nav != 'success') {
                              _error = nav.toString();
                            } else {
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context, true);
                            }

                            setState(() {
                              _isLoading = false;
                            });
                          }
                        } else {
                          setState(() {
                            _error = languages[choosenLanguage]
                                ['text_email_validation'];
                          });
                        }
                      },
                      text: languages[choosenLanguage]['text_confirm']),
                  ButtonBottomSpace(
                    height: 3,
                  )
                ],
              ),
            ),
            if (_isLoading == true) const Positioned(child: Loading())
          ],
        ),
      ),
    );
  }
}
