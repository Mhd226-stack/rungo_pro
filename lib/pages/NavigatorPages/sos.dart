import 'package:flutter/material.dart';
import 'package:flutter_driver/common/responsive.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';
import '../login/landingpage.dart';
import 'pickcontacts.dart';

class Sos extends StatefulWidget {
  const Sos({Key? key}) : super(key: key);

  @override
  State<Sos> createState() => _SosState();
}

class _SosState extends State<Sos> {
  bool _isDeleting = false;
  bool _isLoading = false;
  String _deleteId = '';

  navigateLogout() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LandingPage()));
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Material(
        child: ValueListenableBuilder(
            valueListenable: valueNotifierHome.value,
            builder: (context, value, child) {
              return Directionality(
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              height: MediaQuery.of(context).padding.top +
                                  media.width * 0.05),
                          Stack(
                            children: [
                              Container(
                                padding:
                                    EdgeInsets.only(bottom: media.width * 0.05),
                                width: media.width * 1,
                                height: media.height * 0.07,
                                alignment: Alignment.center,
                                child: PageTitleTextAdject(
                                  child: MyText(
                                    text: languages[choosenLanguage]
                                            ['text_add_trust_contact']
                                        .toString(),
                                    size: media.width * twentytwo,
                                    fontweight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Positioned(
                                  child: InkWell(
                                      onTap: () {
                                        Navigator.pop(context, true);
                                      },
                                      child: IosBackButton()))
                            ],
                          ),

                          SizedBox(
                            height: media.width * 0.05,
                          ),
                          MyText(
                            text: languages[choosenLanguage]
                                ['text_trust_contact_3'],
                            size: media.width * sixteen,
                          ),
                          SizedBox(
                            height: media.width * 0.02,
                          ),
                          MyText(
                            text: languages[choosenLanguage]
                                ['text_trust_contact_4'],
                            size: media.width * twelve,
                            textAlign: TextAlign.start,
                          ),
                          SizedBox(
                            height: media.width * 0.07,
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: media.width * 0.025,
                                  ),
                                  (sosData
                                          .where((element) =>
                                              element['user_type'] != 'admin')
                                          .isNotEmpty)
                                      ? Container(
                                          // color: Colors.grey.withOpacity(0.2),
                                          padding: EdgeInsets.all(
                                              media.width * 0.03),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: darkModeBorderColor),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: darkModeSecContainer,
                                          ),
                                          child: Column(
                                            children: sosData
                                                .asMap()
                                                .map((i, value) {
                                                  return MapEntry(
                                                      i,
                                                      (sosData[i]['user_type'] !=
                                                              'admin')
                                                          ? Container(
                                                              padding: EdgeInsets
                                                                  .all(media
                                                                          .width *
                                                                      0.02),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .account_box_sharp,
                                                                    size: media
                                                                            .width *
                                                                        0.06,
                                                                    color:
                                                                        textColor,
                                                                  ),
                                                                  Column(
                                                                    children: [
                                                                      Container(
                                                                        padding:
                                                                            EdgeInsets.only(bottom: media.width * 0.01),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border:
                                                                              Border(
                                                                            bottom:
                                                                                BorderSide(color: darkModeBorderColor.withOpacity(0.4)),
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                SizedBox(
                                                                                  width: media.width * 0.65,
                                                                                  child: MyText(
                                                                                    text: sosData[i]['name'],
                                                                                    size: media.width * fourteen,
                                                                                    fontweight: FontWeight.w400,
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  height: media.width * 0.01,
                                                                                ),
                                                                                MyText(
                                                                                  text: sosData[i]['number'],
                                                                                  size: media.width * ten,
                                                                                  color: hintColor,
                                                                                ),
                                                                                SizedBox(
                                                                                  height: media.width * 0.01,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            InkWell(
                                                                                onTap: () {
                                                                                  setState(() {
                                                                                    _deleteId = sosData[i]['id'];
                                                                                    _isDeleting = true;
                                                                                  });
                                                                                },
                                                                                child: Icon(Icons.delete, color: textColor))
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                            )
                                                          : Container());
                                                })
                                                .values
                                                .toList(),
                                          ),
                                        )
                                      : Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                var nav = await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const PickContact()));
                                                if (nav) {
                                                  setState(() {});
                                                }
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(
                                                    media.width * 0.05),
                                                width: media.width * 0.9,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            darkModeBorderColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color:
                                                        darkModeSecContainer),
                                                child: Column(
                                                  children: [
                                                    Icon(Icons.add_card,
                                                        color: textColor
                                                            .withOpacity(0.5)),
                                                    SizedBox(
                                                      height:
                                                          media.width * 0.02,
                                                    ),
                                                    MyText(
                                                        text: languages[
                                                                choosenLanguage]
                                                            [
                                                            'text_new_connection'],
                                                        color: textColor,
                                                        size: media.width *
                                                            fourteen)
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                ],
                              ),
                            ),
                          ),

                          //add sos button
                          (sosData
                                      .where((element) =>
                                          element['user_type'] != 'admin')
                                      .length <
                                  5)
                              ? Container(
                                  padding: EdgeInsets.only(
                                      top: media.width * 0.05,
                                      bottom: media.width * 0.05),
                                  child: Button(
                                      onTap: () async {
                                        var nav = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const PickContact()));
                                        if (nav) {
                                          setState(() {});
                                        }
                                      },
                                      text: languages[choosenLanguage]
                                          ['text_add_trust_contact']))
                              : Container(),
                          ButtonBottomSpace()
                        ],
                      ),
                    ),

                    //delete sos
                    (_isDeleting == true)
                        ? Positioned(
                            top: 0,
                            child: Container(
                              height: media.height * 1,
                              width: media.width * 1,
                              color: Colors.transparent.withOpacity(0.6),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        padding:
                                            EdgeInsets.all(media.width * 0.05),
                                        width: media.width * 0.9,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: darkModeBorderColor
                                                    .withOpacity(0.3)),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: page),
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height:
                                                  Responsive.height(4, context),
                                            ),
                                            MyText(
                                              text: languages[choosenLanguage]
                                                  ['text_removeSos'],
                                              size: media.width * fifteen,
                                              fontweight: FontWeight.w500,
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(
                                              height: media.width * 0.05,
                                            ),
                                            Button(
                                                onTap: () async {
                                                  setState(() {
                                                    _isLoading = true;
                                                  });

                                                  var val = await deleteSos(
                                                      _deleteId);
                                                  if (val == 'success') {
                                                    setState(() {
                                                      _isDeleting = false;
                                                    });
                                                  } else if (val == 'logout') {
                                                    navigateLogout();
                                                  }
                                                  setState(() {
                                                    _isLoading = false;
                                                  });
                                                },
                                                text: languages[choosenLanguage]
                                                    ['text_confirm'])
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        top: 15,
                                        right: 15,
                                        child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                _isDeleting = false;
                                              });
                                            },
                                            child: Icon(Icons.cancel,
                                                color: textColor)),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          )
                        : Container(),
                    //loader
                    (_isLoading == true)
                        ? const Positioned(top: 0, child: Loading())
                        : Container()
                  ],
                ),
              );
            }),
      ),
    );
  }
}
