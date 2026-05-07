import 'package:flutter/material.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../login/landingpage.dart';

class Languages extends StatefulWidget {
  const Languages({Key? key}) : super(key: key);

  @override
  State<Languages> createState() => _LanguagesState();
}

class _LanguagesState extends State<Languages> {
  @override
  void initState() {
    choosenLanguage = 'en';
    languageDirection = 'fr';
    super.initState();
  }

  navigate() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LandingPage()));
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
      child: Directionality(
        textDirection: (languageDirection == 'fr')
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Container(
          padding: EdgeInsets.fromLTRB(media.width * 0.05, media.width * 0.05,
              media.width * 0.05, media.width * 0.05),
          height: media.height * 1,
          width: media.width * 1,
          color: page,
          child: Column(
            children: [
              Container(
                height: media.width * 0.11 + MediaQuery.of(context).padding.top,
                width: media.width * 1,
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                color: page,
                child: Stack(
                  children: [
                    Container(
                      height: media.width * 0.11,
                      width: media.width * 1,
                      alignment: Alignment.center,
                      child: MyText(
                        text: (choosenLanguage.isEmpty)
                            ? 'Choose Language'
                            : languages[choosenLanguage]
                                ['text_choose_language'],
                        size: media.width * twentythree,
                        color: textColor,
                        fontweight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: media.height * 0.03,
              ),
              SizedBox(
                height: media.height * 0.22,
                child: Image.asset(
                  'assets/images/choose_language.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(
                height: media.height * 0.04,
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: languages
                        .map(
                          (i, value) => MapEntry(
                            i,
                            InkWell(
                              onTap: () {
                                setState(() {
                                  choosenLanguage = i;
                                  if (choosenLanguage == 'ar' ||
                                      choosenLanguage == 'ur' ||
                                      choosenLanguage == 'iw') {
                                    languageDirection = 'rtl';
                                  } else {
                                    languageDirection = 'ltr';
                                  }
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.fromLTRB(
                                    media.width * 0.04,
                                    media.width * 0.04,
                                    media.width * 0.025,
                                    media.width * 0.04),
                                decoration: BoxDecoration(
                                    color: choosenLanguage == i
                                        ? darkModeSecContainer
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    MyText(
                                      text: languagesCode
                                          .firstWhere(
                                              (e) => e['code'] == i)['name']
                                          .toString(),
                                      size: media.width * fourteen,
                                    ),
                                    Container(
                                      height: media.width * 0.05,
                                      width: media.width * 0.05,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: buttonColor, width: 1.2)),
                                      alignment: Alignment.center,
                                      child: (choosenLanguage == i)
                                          ? Container(
                                              height: media.width * 0.03,
                                              width: media.width * 0.03,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: buttonColor),
                                            )
                                          : Container(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                        .values
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              (choosenLanguage != '')
                  ? Button(
                      borderRadius: 3000.0,
                      onTap: () async {
                        await getlangid();
                        //saving language settings in local
                        pref.setString('languageDirection', languageDirection);
                        pref.setString('choosenLanguage', choosenLanguage);
                        navigate();
                      },
                      text: languages[choosenLanguage]['text_confirm'])
                  : Container(),
              ButtonBottomSpace()
            ],
          ),
        ),
      ),
    );
  }
}
