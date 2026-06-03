import 'package:flutter/material.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import 'adminchatpage.dart';
import 'faq.dart';

class Support extends StatefulWidget {
  const Support({Key? key}) : super(key: key);

  @override
  State<Support> createState() => _SupportState();
}

class _SupportState extends State<Support> {
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
              child: Stack(
                children: [
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
                              padding:
                                  EdgeInsets.only(bottom: media.width * 0.05),
                              width: media.width * 1,
                              alignment: Alignment.center,
                              height: media.height * 0.07,
                              child: PageTitleTextAdject(
                                child: MyText(
                                  text: languages[choosenLanguage]
                                      ['text_chat_us'],
                                  size: media.width * twentythree,
                                  fontweight: FontWeight.w700,
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
                        // //Admin chat

                        // MenuSubCatagoryItem(
                        //   child: ValueListenableBuilder(
                        //       valueListenable: valueNotifierChat.value,
                        //       builder: (context, value, child) {
                        //         return InkWell(
                        //           onTap: () {},
                        //           child: Stack(
                        //             alignment: Alignment.center,
                        //             children: [
                        //               Container(
                        //                 padding: EdgeInsets.only(
                        //                     top: media.width * 0.025),
                        //                 height: Responsive.height(4.8, context),
                        //                 child: Column(
                        //                   children: [
                        //                     Row(
                        //                       children: [
                        //                         Image.asset(
                        //                           'assets/images/menu_item/chat_with_us.png',
                        //                           fit: BoxFit.contain,
                        //                           width:
                        //                               media.width * twentythree,
                        //                           height:
                        //                               media.width * twentythree,
                        //                           color: hintColor,
                        //                         ),
                        //                         SizedBox(
                        //                           width: media.width * 0.03,
                        //                         ),
                        //                         Row(
                        //                           mainAxisAlignment:
                        //                               MainAxisAlignment
                        //                                   .spaceBetween,
                        //                           children: [
                        //                             SizedBox(
                        //                               width: media.width * 0.6,
                        //                               child: MyText(
                        //                                 text: languages[
                        //                                         choosenLanguage]
                        //                                     ['text_support'],
                        //                                 overflow: TextOverflow
                        //                                     .ellipsis,
                        //                                 size: media.width *
                        //                                     sixteen,
                        //                                 color: hintColor,
                        //                               ),
                        //                             ),
                        //                             Row(
                        //                               children: [
                        //                                 // SizedBox(
                        //                                 //   width: 10,
                        //                                 // ),
                        //                                 // (unSeenChatCount == '0')
                        //                                 //     ? Container()
                        //                                 //     : Container(
                        //                                 //         height: 20,
                        //                                 //         width: 20,
                        //                                 //         alignment: Alignment
                        //                                 //             .center,
                        //                                 //         decoration:
                        //                                 //             BoxDecoration(
                        //                                 //           shape: BoxShape
                        //                                 //               .circle,
                        //                                 //           color:
                        //                                 //               buttonColor,
                        //                                 //         ),
                        //                                 //         child: Text(
                        //                                 //           unSeenChatCount,
                        //                                 //           style: GoogleFonts.inter(
                        //                                 //               fontSize: media
                        //                                 //                       .width *
                        //                                 //                   fourteen,
                        //                                 //               color: (isDarkTheme)
                        //                                 //                   ? Colors
                        //                                 //                       .black
                        //                                 //                   : buttonText),
                        //                                 //         ),
                        //                                 //       ),
                        //                               ],
                        //                             ),
                        //                           ],
                        //                         )
                        //                       ],
                        //                     ),
                        //                   ],
                        //                 ),
                        //               ),
                        //               Positioned(
                        //                 right: media.width * 0,
                        //                 child: Icon(
                        //                   Icons.arrow_forward_ios_rounded,
                        //                   size: media.width * 0.06,
                        //                   color: hintColor,
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         );
                        //       }),
                        // ),

                        //Admin chat
                        MenuSubCatagoryItem(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              NavMenu(
                                widgetColor: white,
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const AdminChatPage()));
                                },
                                text: languages[choosenLanguage]
                                    ['text_support'],
                                image:
                                    'assets/images/menu_item/chat_with_us.png',
                                showIcon: false,
                              ),
                              // Positioned(
                              //   right: 0,
                              //   child: Icon(
                              //     Icons.arrow_forward_ios_rounded,
                              //     size: media.width * 0.05,
                              //     color: white,
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        // //FAQ
                        Visibility(
                          visible: false,
                          child: MenuSubCatagoryItem(
                            child: Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                NavMenu(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const Faq()));
                                  },
                                  text: languages[choosenLanguage]['text_faq'],
                                  image: 'assets/images/menu_item/faq.png',
                                  // icon: Icons.arrow_forward_ios_rounded,
                                  // iconSize: media.width * 0.06,
                                  showIcon: false,
                                ),
                                Positioned(
                                  right: 0,
                                  child: Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: media.width * 0.05,
                                    color: white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        //privacy policy
                        MenuSubCatagoryItem(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              NavMenu(
                                onTap: () {
                                  openBrowser('https://mhd226-stack.github.io/rungo-pro-privacy/');
                                },
                                text: languages[choosenLanguage]
                                    ['text_privacy'],
                                image: 'assets/images/menu_item/privacy_policy.png',
                                showIcon: false,
                              ),
                              // Positioned(
                              //   right: 0,
                              //   child: Icon(
                              //     Icons.arrow_forward_ios_rounded,
                              //     size: media.width * 0.05,
                              //     color: white,
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
