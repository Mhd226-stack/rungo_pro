import 'package:flutter/material.dart';
import 'package:flutter_driver/common/responsive.dart';
import 'package:flutter_driver/pages/NavigatorPages/selectlanguage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../login/landingpage.dart';
import '../onTripPage/map_page.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  navigateLogout() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LandingPage()));
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
                                      ['text_settings'],
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

                        //change language
                        MenuSubCatagoryItem(
                          child: NavMenu(
                            onTap: () async {
                              var nav = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SelectLanguage()));
                              if (nav) {
                                setState(() {});
                              }
                            },
                            showIcon: false,
                            text: languages[choosenLanguage]
                                ['text_change_language'],
                            image:
                                'assets/images/menu_item/choose_languages.png',
                          ),
                        ),
                        // delete account
                        MenuSubCatagoryItem(
                          child: userDetails['owner_id'] == null
                              ? NavMenu(
                                  onTap: () {
                                    setState(() {
                                      deleteAccount = true;
                                    });
                                    valueNotifierHome.incrementNotifier();
                                  },
                                  showIcon: false,
                                  text: languages[choosenLanguage]
                                      ['text_delete_account'],
                                  image: 'assets/images/menu_item/delete.png',
                                )
                              : Container(),
                        ),
                      ],
                    ),
                  ),
                  //delete account
                  (deleteAccount == true)
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
                                              color: darkModeBorderColor),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          color: page),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height:
                                                Responsive.height(3, context),
                                          ),
                                          Text(
                                            languages[choosenLanguage]
                                                ['text_delete_confirm'],
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                                fontSize: media.width * sixteen,
                                                color: textColor,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          SizedBox(
                                            height: media.width * 0.05,
                                          ),
                                          Button(
                                              onTap: () async {
                                                setState(() {
                                                  deleteAccount = false;
                                                  // _isLoading = true;
                                                });
                                                var result = await userDelete();
                                                if (result == 'success') {
                                                  setState(() {
                                                    Navigator.pushAndRemoveUntil(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                const LandingPage()),
                                                        (route) => false);
                                                    userDetails.clear();
                                                  });
                                                } else if (result == 'logout') {
                                                  navigateLogout();
                                                } else {
                                                  setState(() {
                                                    // _isLoading = false;
                                                    deleteAccount = true;
                                                  });
                                                }
                                                // setState(() {
                                                //   _isLoading = false;
                                                // });
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
                                              deleteAccount = false;
                                            });
                                          },
                                          child: Icon(
                                            Icons.cancel,
                                            color: white,
                                          )),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ))
                      : Container(),
                ],
              ),
            );
          }),
    );
  }
}
