import 'package:flutter/material.dart';

import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';

// ignore: must_be_immutable
class NoInternet extends StatefulWidget {
  // const NoInternet({ Key? key }) : super(key: key);
  dynamic onTap;
  // ignore: use_key_in_widget_constructors
  NoInternet({required this.onTap});

  @override
  State<NoInternet> createState() => _NoInternetState();
}

class _NoInternetState extends State<NoInternet> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Container(
      height: media.height * 1,
      width: media.width * 1,
      color: page,
      padding: EdgeInsets.all(media.width * 0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              SizedBox(
                width: media.width * 0.5,
                child: Image.asset(
                  'assets/images/noInternet.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(
                height: media.width * 0.05,
              ),
              MyText(
                text: (languages.isNotEmpty && choosenLanguage != '')
                    ? languages[choosenLanguage]['text_nointernet']
                    : 'No Internet Connection',
                size: media.width * nineteen,
                fontweight: FontWeight.w600,
              ),
              SizedBox(
                height: media.width * 0.05,
              ),
              MyText(
                textAlign: TextAlign.center,
                text: (languages.isNotEmpty && choosenLanguage != '')
                    ? languages[choosenLanguage]['text_nointernetdesc']
                    : 'Please check your internet connection and try again.',
                size: media.width * fourteen,
                fontweight: FontWeight.w300,
                color: hintColor,
              ),
              SizedBox(
                height: media.width * 0.2,
              ),
              Button(
                  onTap: widget.onTap,
                  text: (languages.isNotEmpty && choosenLanguage != '')
                      ? languages[choosenLanguage]['text_tryagain']
                      : 'Try Again')
            ],
          )
        ],
      ),
    );
  }
}
