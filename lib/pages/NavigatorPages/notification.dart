import 'package:flutter/material.dart';
import 'package:flutter_driver/common/responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';
import '../login/landingpage.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool isLoading = false;
  bool error = false;
  dynamic notificationid;
  @override
  void initState() {
    getdata();
    super.initState();
  }

  getdata() async {
    isLoading = true;
    var val = await getnotificationHistory();
    if (val == 'logout') {
      navigateLogout();
    }
    if (mounted) {
      isLoading = false;
    }
  }

  navigateLogout() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LandingPage()));
  }

  bool showinfo = false;
  int? showinfovalue;

  bool showToastbool = false;

  showToast() async {
    setState(() {
      showToastbool = true;
    });
    Future.delayed(const Duration(seconds: 1), () async {
      setState(() {
        showToastbool = false;
        // Navigator.pop(context, true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
        child: ValueListenableBuilder(
            valueListenable: valueNotifierHome.value,
            builder: (context, value, child) {
              return Directionality(
                textDirection: (languageDirection == 'rtl')
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: Stack(children: [
                  Container(
                    height: media.height * 1,
                    width: media.width * 1,
                    color: page,
                    padding: EdgeInsets.fromLTRB(media.width * 0.05,
                        media.width * 0.05, media.width * 0.05, 0),
                    child: Column(
                      children: [
                        SizedBox(height: MediaQuery.of(context).padding.top),
                        Stack(
                          children: [
                            Container(
                              height: media.height * 0.07,
                              padding:
                                  EdgeInsets.only(bottom: media.width * 0.05),
                              width: media.width * 1,
                              alignment: Alignment.center,
                              child: MyText(
                                text: languages[choosenLanguage]
                                    ['text_notification'],
                                size: media.width * twentythree,
                                fontweight: FontWeight.w700,
                              ),
                            ),
                            Positioned(
                                child: InkWell(
                                    onTap: () async {
                                      Navigator.pop(context);
                                    },
                                    child: IosBackButton()))
                          ],
                        ),
                        Expanded(
                            child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              //wallet history
                              (notificationHistory.isNotEmpty)
                                  ? Column(
                                      children: [
                                        SizedBox(
                                          height: Responsive.height(0, context),
                                        ),
                                        Column(
                                          children: notificationHistory
                                              .asMap()
                                              .map((i, value) {
                                                return MapEntry(
                                                    i,
                                                    InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          showinfovalue = i;
                                                          showinfo = true;
                                                        });
                                                      },
                                                      child: Container(
                                                        margin: EdgeInsets.only(
                                                            top: media.width *
                                                                0.02,
                                                            bottom:
                                                                media.width *
                                                                    0.02),
                                                        width:
                                                            media.width * 0.9,
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                media.width *
                                                                    0.025,
                                                                12,
                                                                0,
                                                                5),
                                                        decoration:
                                                            BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                  color:
                                                                      darkModeBorderColor,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                                color: page),
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Text(
                                                                  notificationHistory[
                                                                              i]
                                                                          [
                                                                          'converted_created_at']
                                                                      .toString(),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontSize: media
                                                                            .width *
                                                                        twelve,
                                                                    color:
                                                                        textColor,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 15,
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Container(
                                                                    height: media
                                                                            .width *
                                                                        0.1067,
                                                                    width: media
                                                                            .width *
                                                                        0.1067,
                                                                    decoration: BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        color: white.withOpacity(
                                                                            0.3)),
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    child: Icon(
                                                                      Icons
                                                                          .notifications,
                                                                      color:
                                                                          white,
                                                                    )),
                                                                SizedBox(
                                                                  width: media
                                                                          .width *
                                                                      0.03,
                                                                ),
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    SizedBox(
                                                                      width: media
                                                                              .width *
                                                                          0.55,
                                                                      child:
                                                                          Text(
                                                                        notificationHistory[i]['title']
                                                                            .toString(),
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: GoogleFonts.inter(
                                                                            fontSize: media.width *
                                                                                sixteen,
                                                                            color:
                                                                                textColor,
                                                                            fontWeight:
                                                                                FontWeight.w500),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height: media
                                                                              .width *
                                                                          0.005,
                                                                    ),
                                                                    SizedBox(
                                                                      width: media
                                                                              .width *
                                                                          0.55,
                                                                      child:
                                                                          Text(
                                                                        notificationHistory[i]['body']
                                                                            .toString(),
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: GoogleFonts
                                                                            .inter(
                                                                          fontSize:
                                                                              media.width * fourteen,
                                                                          color:
                                                                              hintColor,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Expanded(
                                                                    child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Container(
                                                                        alignment:
                                                                            Alignment
                                                                                .centerRight,
                                                                        width: media.width *
                                                                            0.15,
                                                                        child:
                                                                            IconButton(
                                                                          onPressed:
                                                                              () {
                                                                            setState(() {
                                                                              error = true;
                                                                              notificationid = notificationHistory[i]['id'];
                                                                            });
                                                                          },
                                                                          icon:
                                                                              const Icon(Icons.delete_forever),
                                                                        ))
                                                                  ],
                                                                ))
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height:
                                                                  media.width *
                                                                      0.02,
                                                            ),
                                                            if (notificationHistory[
                                                            i]
                                                            ['image'] !=
                                                                null &&
                                                                !notificationHistory[i]['image'].toString().endsWith('/'))
                                                              Builder(builder:
                                                                  (context) {
                                                                print(notificationHistory[
                                                                            i][
                                                                        'title']
                                                                    .toString());
                                                                print(notificationHistory[
                                                                        i]
                                                                    ['image']);
                                                                return Image
                                                                    .network(
                                                                  notificationHistory[
                                                                          i]
                                                                      ['image'],
                                                                  height: media
                                                                          .width *
                                                                      0.1,
                                                                  width: media
                                                                          .width *
                                                                      0.8,
                                                                  fit: BoxFit
                                                                      .contain,
                                                                );
                                                              })
                                                          ],
                                                        ),
                                                      ),
                                                    ));
                                              })
                                              .values
                                              .toList(),
                                        ),
                                        (notificationHistoryPage[
                                                    'pagination'] !=
                                                null)
                                            ? (notificationHistoryPage[
                                                            'pagination']
                                                        ['current_page'] <
                                                    notificationHistoryPage[
                                                            'pagination']
                                                        ['total_pages'])
                                                ? InkWell(
                                                    onTap: () async {
                                                      setState(() {
                                                        isLoading = true;
                                                      });
                                                      var val =
                                                          await getNotificationPages(
                                                              'page=${notificationHistoryPage['pagination']['current_page'] + 1}');
                                                      if (val == 'logout') {
                                                        navigateLogout();
                                                      }
                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.all(
                                                          media.width * 0.025),
                                                      margin: EdgeInsets.only(
                                                          bottom: media.width *
                                                              0.05),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          color: page,
                                                          border: Border.all(
                                                              color:
                                                                  borderLines,
                                                              width: 1.2)),
                                                      child: Text(
                                                        languages[
                                                                choosenLanguage]
                                                            ['text_loadmore'],
                                                        style:
                                                            GoogleFonts.inter(
                                                                fontSize: media
                                                                        .width *
                                                                    sixteen,
                                                                color:
                                                                    textColor),
                                                      ),
                                                    ),
                                                  )
                                                : Container()
                                            : Container()
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: media.width * 0.3,
                                        ),
                                        Container(
                                          alignment: Alignment.center,
                                          height: media.width * 0.5,
                                          width: media.width * 0.5,
                                          decoration: const BoxDecoration(
                                              image: DecorationImage(
                                                  image: AssetImage(
                                                      'assets/images/no_data_found_image.png'),
                                                  fit: BoxFit.contain)),
                                        ),
                                        SizedBox(
                                          height: media.width * 0.07,
                                        ),
                                        SizedBox(
                                          width: media.width * 0.8,
                                          child: MyText(
                                              text: languages[choosenLanguage]
                                                  ['text_noDataFound'],
                                              textAlign: TextAlign.center,
                                              fontweight: FontWeight.w800,
                                              size: media.width * sixteen),
                                        ),
                                      ],
                                    )
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  (showinfo == true)
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
                                  alignment: Alignment.topRight,
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
                                          color: Color.fromARGB(52, 0, 0, 0)),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            child: MyText(
                                              text: notificationHistory[
                                                      showinfovalue!]['title']
                                                  .toString(),
                                              size: media.width * twentythree,
                                            ),
                                          ),
                                          SizedBox(
                                            height: media.width * 0.06,
                                          ),
                                          MyText(
                                            text: notificationHistory[
                                                    showinfovalue!]['body']
                                                .toString(),
                                            size: media.width * seventeen,
                                            color: hintColor,
                                          ),
                                          SizedBox(
                                            height: media.width * 0.05,
                                          ),
                                          if (notificationHistory[
                                                  showinfovalue!]['image'] !=
                                              null)
                                            Image.network(
                                              notificationHistory[
                                                  showinfovalue!]['image'],
                                              height: media.width * 0.4,
                                              width: media.width * 0.4,
                                              fit: BoxFit.contain,
                                            )
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      top: media.width * 0.05,
                                      right: media.width * 0.03,
                                      child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              showinfo = false;
                                              showinfovalue = null;
                                            });
                                          },
                                          child: Icon(Icons.cancel_rounded,
                                              color: textColor)),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ))
                      : Container(),
                  (error == true)
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
                                  padding: EdgeInsets.all(media.width * 0.05),
                                  width: media.width * 0.9,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: page),
                                  child: Column(
                                    children: [
                                      MyText(
                                        text: languages[choosenLanguage]
                                            ['text_delete_notification'],
                                        size: media.width * sixteen,
                                        fontweight: FontWeight.w600,
                                      ),
                                      SizedBox(
                                        height: media.width * 0.05,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Button(
                                              onTap: () async {
                                                setState(() {
                                                  error = false;
                                                  notificationid = null;
                                                });
                                              },
                                              text: languages[choosenLanguage]
                                                  ['text_no']),
                                          SizedBox(
                                            width: media.width * 0.05,
                                          ),
                                          Button(
                                              onTap: () async {
                                                setState(() {
                                                  isLoading = true;
                                                });
                                                var result =
                                                    await deleteNotification(
                                                        notificationid);
                                                if (result == 'success') {
                                                  setState(() {
                                                    getdata();

                                                    error = false;
                                                    isLoading = false;
                                                    showToast();
                                                  });
                                                } else if (result == 'logout') {
                                                  navigateLogout();
                                                } else {
                                                  // setState(() {
                                                  //   logout = true;
                                                  // });
                                                }
                                              },
                                              text: languages[choosenLanguage]
                                                  ['text_yes']),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ))
                      : Container(),
                  (isLoading == true)
                      ? const Positioned(top: 0, child: Loading())
                      : Container(),
                  (showToastbool == true)
                      ? Positioned(
                          bottom: media.height * 0.2,
                          left: media.width * 0.2,
                          right: media.width * 0.2,
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(media.width * 0.025),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.transparent.withOpacity(0.6)),
                            child: MyText(
                              text: languages[choosenLanguage]
                                  ['text_notification_deleted'],
                              size: media.width * twelve,
                              color: topBar,
                            ),
                          ))
                      : Container()
                ]),
              );
            }));
  }
}
