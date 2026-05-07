import 'package:flutter/material.dart';
import 'package:flutter_driver/common/responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';
import '../login/login.dart';
import '../noInternet/nointernet.dart';
import 'requiredinformation.dart';

// ignore: must_be_immutable
class CarInformation extends StatefulWidget {
  int? frompage;
  CarInformation({this.frompage, Key? key}) : super(key: key);

  @override
  State<CarInformation> createState() => _CarInformationState();
}

bool isowner = false;
dynamic myVehicalType;
dynamic myVehicleIconFor = '';
List vehicletypelist = [];
dynamic vehicleColor;
dynamic myServiceLocation;
dynamic myServiceId;
String vehicleModelId = '';
dynamic vehicleModelName;
dynamic modelYear;
String vehicleMakeId = '';
dynamic vehicleNumber;
dynamic vehicleMakeName;
String myVehicleId = '';
String mycustommake = '';
String mycustommodel = '';
List choosevehicletypelist = [];

class _CarInformationState extends State<CarInformation> {
  bool loaded = false;
  bool chooseWorkArea = false;
  bool _isLoading = false;
  String _error = '';
  bool chooseVehicleMake = false;
  bool chooseVehicleModel = false;
  bool chooseVehicleType = false;
  String dateError = '';
  bool vehicleAdded = false;
  String uploadError = '';
  bool iscustommake = false;
  TextEditingController modelcontroller = TextEditingController();
  TextEditingController colorcontroller = TextEditingController();
  TextEditingController numbercontroller = TextEditingController();
  TextEditingController referralcontroller = TextEditingController();
  TextEditingController custommakecontroller = TextEditingController();
  TextEditingController custommodelcontroller = TextEditingController();

  bool popAlert = false;

  //navigate
  navigate() {
    Navigator.pop(context, true);
    serviceLocations.clear();
    vehicleMake.clear();
    vehicleModel.clear();
    vehicleType.clear();
  }

  navigateref() {
    Navigator.pop(context, true);
  }

  navigateLogout() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
        (route) => false);
  }

  @override
  void initState() {
    getServiceLoc();
    super.initState();
  }

//get service loc data
  getServiceLoc() async {
    choosevehicletypelist.clear();
    vehicletypelist.clear();
    myServiceId = '';
    myServiceLocation = '';
    vehicleMakeId = '';
    vehicleModelId = '';
    myVehicleId = '';
    // ignore: unused_local_variable, prefer_typing_uninitialized_variables
    var result;
    if (widget.frompage == 2 || isowner == true) {
      myVehicleId = '';

      result = await getvehicleType();
    } else {
      vehicletypelist = [];
      result = await getServiceLocation();
    }

    if (mounted) {
      setState(() {
        loaded = true;
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
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                height: media.height * 1,
                width: media.width * 1,
                color: page,
                child: Column(
                  children: [
                    Container(
                      color: page,
                      padding: EdgeInsets.all(media.width * 0.05),
                      child: Column(
                        children: [
                          SizedBox(height: MediaQuery.of(context).padding.top),
                          Stack(
                            children: [
                              Container(
                                width: media.width * 1,
                                height: Responsive.height(4.5, context),
                                alignment: Alignment.center,
                                child: PageTitleTextAdject(
                                  isMargin: true,
                                  child: Text(
                                    widget.frompage == 2
                                        ? languages[choosenLanguage]
                                            ['text_updateVehicle']
                                        : languages[choosenLanguage]
                                            ['text_car_info'],
                                    style: GoogleFonts.inter(
                                        fontSize: media.width * twentythree,
                                        fontWeight: FontWeight.w700,
                                        color: textColor),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Positioned(
                                  child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          popAlert = true;
                                        });
                                      },
                                      child: IosBackButton()))
                            ],
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                        child: Container(
                      padding: EdgeInsets.fromLTRB(
                          media.width * 0.05,
                          media.width * 0.05,
                          media.width * 0.05,
                          media.width * 0.05),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Visibility(
                              visible: widget.frompage == 1,
                              child: SizedBox(
                                height: media.height * 0.1,
                              ),
                            ),
                            widget.frompage == 1 && isowner == false
                                ? Text(
                                    languages[choosenLanguage]
                                        ['text_service_location'],
                                    style: GoogleFonts.inter(
                                        fontSize: media.width * fourteen,
                                        color: textColor,
                                        fontWeight: FontWeight.w500),
                                  )
                                : Container(),
                            SizedBox(
                              height: media.width * 0.04,
                            ),
                            widget.frompage == 1 && isowner == false
                                ? InkWell(
                                    onTap: () async {
                                      setState(() {
                                        if (chooseWorkArea == true) {
                                          chooseWorkArea = false;
                                        } else {
                                          chooseWorkArea = true;
                                          chooseVehicleMake = false;
                                          chooseVehicleModel = false;
                                          chooseVehicleType = false;
                                        }
                                      });
                                    },
                                    child: Container(
                                      height: media.width * 0.13,
                                      decoration: BoxDecoration(
                                        color: darkModeSecContainer,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                            color: darkModeBorderColor),
                                      ),
                                      padding: EdgeInsets.only(
                                          left: media.width * 0.05,
                                          right: media.width * 0.05),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: media.width * 0.7,
                                            child: Text(
                                              (widget.frompage == 1 &&
                                                      myServiceId == '')
                                                  ? languages[choosenLanguage]
                                                      ['text_service_loc']
                                                  : (myServiceId != null &&
                                                          myServiceId != '')
                                                      ? serviceLocations
                                                              .isNotEmpty
                                                          ? serviceLocations
                                                              .firstWhere(
                                                                  (element) =>
                                                                      element[
                                                                          'id'] ==
                                                                      myServiceId)[
                                                                  'name']
                                                              .toString()
                                                          : ''
                                                      : userDetails[
                                                          'service_location_name'],
                                              style: GoogleFonts.inter(
                                                  fontSize: (myServiceId !=
                                                              null &&
                                                          myServiceId != '')
                                                      ? media.width * sixteen
                                                      : media.width * fourteen,
                                                  // fontWeight: FontWeight.w600,
                                                  color: (myServiceId != null &&
                                                              myServiceId !=
                                                                  '') ||
                                                          widget.frompage == 1
                                                      ? textColor
                                                      : hintColor),
                                            ),
                                          ),
                                          Icon(
                                            Icons.location_on_rounded,
                                            color: buttonColor,
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(),
                            SizedBox(
                              height: media.height * 0.025,
                            ),
                            if (chooseWorkArea == true &&
                                serviceLocations.isNotEmpty)
                              Container(
                                margin:
                                    EdgeInsets.only(bottom: media.width * 0.03),
                                width: media.width * 0.9,
                                // height: media.width * 0.5,
                                padding: EdgeInsets.all(media.width * 0.03),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: underline),
                                ),
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Column(
                                    children: serviceLocations
                                        .asMap()
                                        .map((i, value) {
                                          return MapEntry(
                                              i,
                                              InkWell(
                                                onTap: () async {
                                                  if (serviceLocations[i]
                                                          ['name'] !=
                                                      'Local Testing') {
                                                    setState(() {
                                                      myVehicleId = '';
                                                      vehicleMakeId = '';
                                                      vehicleModelId = '';
                                                      myServiceId =
                                                          serviceLocations[i]
                                                              ['id'];
                                                      chooseWorkArea = false;
                                                      _isLoading = true;
                                                    });
                                                    var result =
                                                        await getvehicleType();
                                                    if (result == 'success') {
                                                      setState(() {
                                                        _isLoading = false;
                                                      });
                                                    } else {
                                                      setState(() {
                                                        _isLoading = false;
                                                      });
                                                    }
                                                    choosevehicletypelist
                                                        .clear();

                                                    setState(() {});
                                                  }
                                                },
                                                child: Container(
                                                  width: media.width * 0.8,
                                                  padding: EdgeInsets.only(
                                                      top: media.width * 0.025,
                                                      bottom:
                                                          media.width * 0.025),
                                                  child: Text(
                                                    serviceLocations[i]
                                                                ['name'] ==
                                                            'Local Testing'
                                                        ? ''
                                                        : serviceLocations[i]
                                                            ['name'],
                                                    style: GoogleFonts.inter(
                                                        fontSize: media.width *
                                                            fourteen,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: textColor),
                                                  ),
                                                ),
                                              ));
                                        })
                                        .values
                                        .toList(),
                                  ),
                                ),
                              ),
                            SizedBox(
                              width: media.width * 0.9,
                              child: MyText(
                                text: languages[choosenLanguage]
                                    ['text_vehicle_type'],
                                size: media.width * fourteen,
                                fontweight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                            SizedBox(
                              height: media.width * 0.03,
                            ),
                            (userDetails['vehicle_type_name'] == null &&
                                    userDetails['role'] != 'owner')
                                ? InkWell(
                                    onTap: () async {
                                      // if (choosevehicletypelist.isEmpty) {
                                      if (chooseVehicleType == true) {
                                        setState(() {
                                          chooseVehicleType = false;
                                        });
                                      } else {
                                        if ((myServiceId != '') ||
                                            (isowner == true)) {
                                          chooseVehicleType = true;
                                        } else {
                                          chooseVehicleType = false;
                                        }
                                        chooseWorkArea = false;
                                        chooseVehicleMake = false;
                                        chooseVehicleModel = false;
                                      }
                                      setState(() {});
                                      // }
                                    },
                                    child: Visibility(
                                      // visible: (chooseVehicleType == true &&
                                      //     vehicleType.isNotEmpty),
                                      child: Container(
                                        height: media.width * 0.13,
                                        width: media.width * 0.9,
                                        alignment: Alignment.centerLeft,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                                color: darkModeBorderColor),
                                            color: ((myServiceId == null ||
                                                        myServiceId == '') &&
                                                    widget.frompage == 1 &&
                                                    isowner == false)
                                                ? darkModeSecContainer
                                                : darkModeSecContainer),
                                        padding: EdgeInsets.only(
                                          right: media.width * 0.03,
                                          left: media.width * 0.03,
                                        ),
                                        child: (myVehicleId == '')
                                            ? Row(
                                                children: [
                                                  MyText(
                                                    text: languages[
                                                                choosenLanguage]
                                                            [
                                                            'text_vehicle_type']
                                                        .toString(),
                                                    size: media.width * twelve,
                                                    color: (chooseWorkArea ==
                                                                true &&
                                                            serviceLocations
                                                                .isNotEmpty)
                                                        ? (isDarkTheme)
                                                            ? hintColor
                                                            : textColor
                                                        : (isDarkTheme)
                                                            ? hintColor
                                                            : hintColor,
                                                  ),
                                                  //   RotatedBox(
                                                  // quarterTurns:
                                                  //     (chooseVehicleType == true &&
                                                  //             vehicleType
                                                  //                 .isNotEmpty)
                                                  //         ? 1
                                                  //         : 4,
                                                  // child: Icon(
                                                  //   Icons
                                                  //       .keyboard_arrow_down_rounded,
                                                  //   size: media.width * 0.06,
                                                  //   color: hintColor,
                                                  // ))
                                                ],
                                              )
                                            : choosevehicletypelist.isNotEmpty
                                                ? SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Row(children: [
                                                      for (int i = 0;
                                                          i <
                                                              choosevehicletypelist
                                                                  .length;
                                                          i++)
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: media
                                                                          .width *
                                                                      0.05),
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 10,
                                                                    right: 10),
                                                            decoration: BoxDecoration(
                                                                color: page,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                            child: Row(
                                                              children: [
                                                                MyText(
                                                                  text: choosevehicletypelist[
                                                                              i]
                                                                          [
                                                                          'name']
                                                                      .toString(),
                                                                  size: media
                                                                          .width *
                                                                      thirteen,
                                                                  fontweight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: (isDarkTheme)
                                                                      ? textColor
                                                                      : textColor,
                                                                ),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Image.network(
                                                                  choosevehicletypelist[
                                                                              i]
                                                                          [
                                                                          'icon']
                                                                      .toString(),
                                                                  fit: BoxFit
                                                                      .contain,
                                                                  width: media
                                                                          .width *
                                                                      0.1,
                                                                  height: media
                                                                          .width *
                                                                      0.09,
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    setState(
                                                                        () {
                                                                      choosevehicletypelist
                                                                          .removeAt(
                                                                              i);
                                                                    });
                                                                    if (choosevehicletypelist
                                                                        .isEmpty) {
                                                                      setState(
                                                                          () {
                                                                        vehicleMake
                                                                            .clear();
                                                                        myVehicleId =
                                                                            '';
                                                                        vehicleModelId =
                                                                            '';
                                                                        vehicleMakeId =
                                                                            '';
                                                                        vehicleModel
                                                                            .clear();
                                                                        iscustommake =
                                                                            false;
                                                                        chooseVehicleMake =
                                                                            false;
                                                                      });
                                                                    }
                                                                    if (choosevehicletypelist
                                                                        .isNotEmpty) {
                                                                      setState(
                                                                          () {
                                                                        _isLoading =
                                                                            true;
                                                                      });
                                                                      await getVehicleMake(
                                                                        myVehicleIconFor:
                                                                            choosevehicletypelist[0]['icon_types_for'].toString(),
                                                                      );
                                                                      setState(
                                                                          () {
                                                                        _isLoading =
                                                                            false;
                                                                      });
                                                                    } else {
                                                                      setState(
                                                                          () {
                                                                        vehicleMake
                                                                            .clear();
                                                                        myVehicleId =
                                                                            '';
                                                                        vehicleModelId =
                                                                            '';
                                                                        vehicleMakeId =
                                                                            '';
                                                                        vehicleModel
                                                                            .clear();
                                                                      });
                                                                    }
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    decoration: BoxDecoration(
                                                                        border: Border.all(
                                                                            color:
                                                                                verifyDeclined),
                                                                        shape: BoxShape
                                                                            .circle),
                                                                    child: Icon(
                                                                      Icons
                                                                          .close,
                                                                      size: media
                                                                              .width *
                                                                          sixteen,
                                                                      color:
                                                                          verifyDeclined,
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                    ]
                                                        // choosevehicletypelist
                                                        //     .asMap()
                                                        //     .map((i, value) {
                                                        //       return MapEntry(
                                                        //         i,
                                                        //         Padding(
                                                        //           padding: EdgeInsets.only(
                                                        //               right: media.width *
                                                        //                   0.05),
                                                        //           child:
                                                        //               Container(
                                                        //             padding: EdgeInsets.only(
                                                        //                 left:
                                                        //                     10,
                                                        //                 right:
                                                        //                     10),
                                                        //             decoration: BoxDecoration(
                                                        //                 color:
                                                        //                     page,
                                                        //                 borderRadius:
                                                        //                     BorderRadius.circular(10)),
                                                        //             child:
                                                        //                 Row(
                                                        //               children: [
                                                        //                 MyText(
                                                        //                   text:
                                                        //                       choosevehicletypelist[i]['name'].toString(),
                                                        //                   size:
                                                        //                       media.width * thirteen,
                                                        //                   fontweight:
                                                        //                       FontWeight.w500,
                                                        //                   color: (isDarkTheme)
                                                        //                       ? textColor
                                                        //                       : textColor,
                                                        //                 ),
                                                        //                 SizedBox(
                                                        //                   width:
                                                        //                       5,
                                                        //                 ),
                                                        //                 Image
                                                        //                     .network(
                                                        //                   vehicleType[i]['icon'].toString(),
                                                        //                   fit:
                                                        //                       BoxFit.contain,
                                                        //                   width:
                                                        //                       media.width * 0.1,
                                                        //                   height:
                                                        //                       media.width * 0.09,
                                                        //                 ),
                                                        //                 SizedBox(
                                                        //                   width:
                                                        //                       10,
                                                        //                 ),
                                                        //                 InkWell(
                                                        //                   onTap:
                                                        //                       () async {
                                                        //                     setState(() {
                                                        //                       choosevehicletypelist.removeAt(i);
                                                        //                     });
                                                        //                     if (choosevehicletypelist.isEmpty) {
                                                        //                       setState(() {
                                                        //                         vehicleMake.clear();
                                                        //                         myVehicleId = '';
                                                        //                         vehicleModelId = '';
                                                        //                         vehicleMakeId = '';
                                                        //                         vehicleModel.clear();
                                                        //                         iscustommake = false;
                                                        //                         chooseVehicleMake = false;
                                                        //                       });
                                                        //                     }
                                                        //                     if (choosevehicletypelist.isNotEmpty) {
                                                        //                       setState(() {
                                                        //                         _isLoading = true;
                                                        //                       });
                                                        //                       await getVehicleMake(
                                                        //                         myVehicleIconFor: choosevehicletypelist[0]['icon_types_for'].toString(),
                                                        //                       );
                                                        //                       setState(() {
                                                        //                         _isLoading = false;
                                                        //                       });
                                                        //                     } else {
                                                        //                       setState(() {
                                                        //                         vehicleMake.clear();
                                                        //                         myVehicleId = '';
                                                        //                         vehicleModelId = '';
                                                        //                         vehicleMakeId = '';
                                                        //                         vehicleModel.clear();
                                                        //                       });
                                                        //                     }
                                                        //                   },
                                                        //                   child:
                                                        //                       Container(
                                                        //                     decoration: BoxDecoration(border: Border.all(color: verifyDeclined), shape: BoxShape.circle),
                                                        //                     child: Icon(
                                                        //                       Icons.close,
                                                        //                       size: media.width * sixteen,
                                                        //                       color: verifyDeclined,
                                                        //                     ),
                                                        //                   ),
                                                        //                 )
                                                        //               ],
                                                        //             ),
                                                        //           ),
                                                        //         ),
                                                        //       );
                                                        //     })
                                                        //     .values
                                                        //     .toList(),
                                                        ),
                                                  )
                                                : MyText(
                                                    text: languages[
                                                                choosenLanguage]
                                                            [
                                                            'text_vehicle_type']
                                                        .toString(),
                                                    size: sixteen,
                                                    color: textColor,
                                                  ),
                                      ),
                                    ),
                                  )
                                : InkWell(
                                    onTap: () async {
                                      if (chooseVehicleType == true) {
                                        setState(() {
                                          chooseVehicleType = false;
                                        });
                                      } else {
                                        if (myServiceId != '' ||
                                            isowner == true) {
                                          chooseVehicleType = true;
                                        } else {
                                          chooseVehicleType = false;
                                        }
                                        chooseWorkArea = false;
                                        chooseVehicleMake = false;
                                        chooseVehicleModel = false;
                                      }
                                      setState(() {});
                                    },
                                    child: Container(
                                      height: media.width * 0.13,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: darkModeBorderColor),
                                          color: ((myServiceId == null ||
                                                      myServiceId == '') &&
                                                  widget.frompage == 1 &&
                                                  isowner == false)
                                              ? hintColor
                                              : darkModeSecContainer),
                                      padding: EdgeInsets.only(
                                          left: media.width * 0.05,
                                          right: media.width * 0.05),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: media.width * 0.7,
                                            child: Text(
                                              (myVehicleId == '')
                                                  ? languages[choosenLanguage]
                                                          ['text_vehicle_type']
                                                      .toString()
                                                  : (myVehicleId != '' &&
                                                          myVehicleId != '')
                                                      ? vehicleType.isNotEmpty
                                                          ? vehicleType
                                                              .firstWhere(
                                                                  (element) =>
                                                                      element[
                                                                          'id'] ==
                                                                      myVehicleId)[
                                                                  'name']
                                                              .toString()
                                                          : ''
                                                      : myVehicalType
                                                          .toString(),
                                              style: GoogleFonts.inter(
                                                  fontSize: (myVehicleId != '')
                                                      ? media.width * sixteen
                                                      : media.width * fourteen,
                                                  // fontWeight: FontWeight.w600,
                                                  color: hintColor

                                                  //  (myVehicleId != null &&
                                                  //             myVehicleId != '' &&
                                                  //             widget.frompage != 1) ||
                                                  //         (widget.frompage == 2 &&
                                                  //             myServiceId != null)
                                                  //     ? textColor
                                                  //     : hintColor
                                                  ),
                                            ),
                                          ),
                                          RotatedBox(
                                              quarterTurns:
                                                  (chooseVehicleType == true &&
                                                          myVehicleId != '')
                                                      ? 1
                                                      : 4,
                                              child: Icon(
                                                Icons.arrow_forward_ios,
                                                size: media.width * 0.05,
                                                color: hintColor,
                                              ))
                                        ],
                                      ),
                                    ),
                                  ),

                            SizedBox(
                              height: media.width * 0.02,
                            ),
                            if (chooseVehicleType == true &&
                                vehicleType.isNotEmpty)
                              Container(
                                width: media.width * 0.9,
                                margin:
                                    EdgeInsets.only(bottom: media.width * 0.03),
                                // height: media.width * 0.5,

                                decoration: BoxDecoration(
                                    color: darkModeSecContainer,
                                    border:
                                        Border.all(color: darkModeBorderColor),
                                    borderRadius: BorderRadius.circular(15)),
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: media.height * 0.02,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: media.width * 0.04),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              languages[choosenLanguage]
                                                  ['text_select_vehicle_type'],
                                              style: GoogleFonts.inter(
                                                  fontSize:
                                                      media.width * twelve,
                                                  color: textColor,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: media.height * 0.012,
                                      ),
                                      Column(
                                        children: vehicleType
                                            .asMap()
                                            .map((i, value) {
                                              return MapEntry(
                                                  i,
                                                  InkWell(
                                                    onTap: () async {
                                                      setState(() {
                                                        vehicleMakeId = '';
                                                        vehicleModelId = '';
                                                        vehicleMakeName = '';
                                                        vehicleModelName = '';
                                                        myVehicleId =
                                                            vehicleType[i]
                                                                ['id'];

                                                        chooseVehicleType =
                                                            false;
                                                        iscustommake = false;
                                                      });
                                                      if (choosevehicletypelist
                                                          .where((element) =>
                                                              element['name'] ==
                                                              vehicleType[i]
                                                                  ['name'])
                                                          .isEmpty) {
                                                        choosevehicletypelist
                                                            .add(
                                                                vehicleType[i]);
                                                      }
                                                      setState(() {
                                                        _isLoading = true;
                                                      });
                                                      await getVehicleMake(
                                                        myVehicleIconFor:
                                                            choosevehicletypelist[
                                                                        0][
                                                                    'icon_types_for']
                                                                .toString(),
                                                      );
                                                      setState(() {
                                                        _isLoading = false;
                                                      });
                                                    },
                                                    child: Container(
                                                        width: media.width *
                                                            0.83,
                                                        margin: EdgeInsets.only(
                                                            bottom: 5),
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: media
                                                                        .width *
                                                                    0.01,
                                                                bottom: media
                                                                        .width *
                                                                    0.01),
                                                        decoration: BoxDecoration(
                                                            color:
                                                                darkModeBackground,
                                                            border: Border.all(
                                                                color:
                                                                    darkModeBorderColor),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        11)),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 15,
                                                                  right: 15),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                vehicleType[i]
                                                                        ['name']
                                                                    .toString()
                                                                    .toUpperCase(),
                                                                style: GoogleFonts.inter(
                                                                    fontSize: media
                                                                            .width *
                                                                        thirteen,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color:
                                                                        textColor),
                                                              ),
                                                              Image.network(
                                                                vehicleType[i]
                                                                        ['icon']
                                                                    .toString(),
                                                                fit: BoxFit
                                                                    .contain,
                                                                width: media
                                                                        .width *
                                                                    0.15,
                                                                height: media
                                                                        .width *
                                                                    0.09,
                                                              ),
                                                            ],
                                                          ),
                                                        )),
                                                  ));
                                            })
                                            .values
                                            .toList(),
                                      ),
                                      SizedBox(
                                        height: media.height * 0.06,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            SizedBox(
                              height: media.width * 0.03,
                            ),
                            Text(
                              languages[choosenLanguage]['text_vehicle_make'],
                              style: GoogleFonts.inter(
                                  fontSize: media.width * fourteen,
                                  color: textColor,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: media.width * 0.03,
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (chooseVehicleMake == true) {
                                    chooseVehicleMake = false;
                                  } else {
                                    if (myVehicleId != '') {
                                      chooseVehicleMake = true;
                                    } else {
                                      chooseVehicleMake = false;
                                    }
                                    chooseWorkArea = false;
                                    chooseVehicleModel = false;
                                    chooseVehicleType = false;
                                  }
                                });
                              },
                              child: (iscustommake == false)
                                  ? Container(
                                      height: media.width * 0.13,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                              color: darkModeBorderColor),
                                          color: myVehicleId == ''
                                              ? darkModeSecContainer
                                              : darkModeSecContainer),
                                      padding: EdgeInsets.only(
                                          left: media.width * 0.05,
                                          right: media.width * 0.05),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: media.width * 0.7,
                                            child: Text(
                                              (vehicleMakeId == '')
                                                  ? languages[choosenLanguage]
                                                      ['text_sel_make']
                                                  : (vehicleMakeId != '')
                                                      ? vehicleMake.isNotEmpty
                                                          ? vehicleMake
                                                              .firstWhere(
                                                                  (element) =>
                                                                      element['id']
                                                                          .toString() ==
                                                                      vehicleMakeId)[
                                                                  'name']
                                                              .toString()
                                                          : ''
                                                      : vehicleMakeName == ''
                                                          ? languages[
                                                                  choosenLanguage]
                                                              [
                                                              'text_vehicle_make']
                                                          : vehicleMakeName,
                                              style: GoogleFonts.inter(
                                                  fontSize: (vehicleMakeId !=
                                                          '')
                                                      ? media.width * twelve
                                                      : media.width * twelve,
                                                  // fontWeight: FontWeight.w600,
                                                  color: (widget.frompage ==
                                                              1 &&
                                                          (vehicleMakeId == ''))
                                                      ? hintColor
                                                      : hintColor),
                                            ),
                                          ),
                                          RotatedBox(
                                              quarterTurns:
                                                  (chooseVehicleType == true &&
                                                          vehicleType
                                                              .isNotEmpty)
                                                      ? 1
                                                      : 4,
                                              child: Icon(
                                                Icons
                                                    .keyboard_arrow_down_rounded,
                                                size: media.width * 0.06,
                                                color: hintColor,
                                              ))
                                        ],
                                      ),
                                    )
                                  : Container(
                                      height: media.width * 0.13,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(color: underline),
                                          color: darkModeSecContainer),
                                      padding: EdgeInsets.only(
                                          left: media.width * 0.05,
                                          right: media.width * 0.05),
                                      child: InputField(
                                        underline: false,
                                        autofocus: true,
                                        text: languages[choosenLanguage]
                                            ['text_sel_make'],
                                        textController: custommakecontroller,
                                        textSize: media.width * twelve,
                                        color: hintColor,
                                        onTap: (val) {
                                          setState(() {
                                            mycustommake = val;
                                          });
                                        },
                                      ),
                                    ),
                            ),
                            SizedBox(
                              height: media.width * 0.02,
                            ),
                            (chooseVehicleMake == true && iscustommake == false)
                                ? Container(
                                    margin: EdgeInsets.only(
                                        bottom: media.width * 0.03),
                                    width: media.width * 0.9,
                                    height: media.width * 0.5,
                                    padding: EdgeInsets.all(media.width * 0.03),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: underline),
                                    ),
                                    child: SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      child: Column(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                iscustommake = true;
                                                custommakecontroller.text = '';
                                                custommodelcontroller.text = '';
                                              });
                                            },
                                            child: Container(
                                              width: media.width * 0.8,
                                              padding: EdgeInsets.only(
                                                  top: media.width * 0.025,
                                                  bottom: media.width * 0.025),
                                              child: Text(
                                                languages[choosenLanguage]
                                                    ['text_custom_make'],
                                                style: GoogleFonts.inter(
                                                    fontSize:
                                                        media.width * fourteen,
                                                    fontWeight: FontWeight.w600,
                                                    color: textColor),
                                              ),
                                            ),
                                          ),
                                          Column(
                                            children: vehicleMake
                                                .asMap()
                                                .map((i, value) {
                                                  return MapEntry(
                                                      i,
                                                      InkWell(
                                                        onTap: () async {
                                                          setState(() {
                                                            vehicleModelId = '';
                                                            vehicleModelName =
                                                                '';
                                                            vehicleMakeId =
                                                                vehicleMake[i]
                                                                        ['id']
                                                                    .toString();
                                                            chooseVehicleMake =
                                                                false;
                                                            _isLoading = true;
                                                          });

                                                          var result =
                                                              await getVehicleModel();
                                                          if (result ==
                                                              'success') {
                                                            setState(() {
                                                              _isLoading =
                                                                  false;
                                                            });
                                                          } else {
                                                            setState(() {
                                                              _isLoading =
                                                                  false;
                                                            });
                                                          }
                                                        },
                                                        child: Container(
                                                          width:
                                                              media.width * 0.8,
                                                          padding: EdgeInsets.only(
                                                              top: media.width *
                                                                  0.025,
                                                              bottom:
                                                                  media.width *
                                                                      0.025),
                                                          child: Text(
                                                            vehicleMake[i]
                                                                    ['name']
                                                                .toString(),
                                                            style: GoogleFonts.inter(
                                                                fontSize: media
                                                                        .width *
                                                                    fourteen,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color:
                                                                    textColor),
                                                          ),
                                                        ),
                                                      ));
                                                })
                                                .values
                                                .toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(),
                            SizedBox(
                              height: media.width * 0.03,
                            ),
                            Text(
                              languages[choosenLanguage]['text_vehicle_model'],
                              style: GoogleFonts.inter(
                                  fontSize: media.width * fourteen,
                                  color: textColor,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: media.width * 0.03,
                            ),
                            (iscustommake)
                                ? Container(
                                    height: media.width * 0.13,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: underline),
                                        color: darkModeSecContainer),
                                    padding: EdgeInsets.only(
                                        left: media.width * 0.05,
                                        right: media.width * 0.05),
                                    child: InputField(
                                      color: hintColor,
                                      textSize: media.width * twelve,
                                      underline: false,
                                      autofocus: true,
                                      text: languages[choosenLanguage]
                                          ['text_sel_model'],
                                      textController: custommodelcontroller,
                                      onTap: (val) {
                                        setState(() {
                                          mycustommodel = val;
                                        });
                                      },
                                    ),
                                  )
                                : InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (chooseVehicleModel == true) {
                                          chooseVehicleModel = false;
                                        } else {
                                          if (vehicleMakeId != '') {
                                            chooseVehicleModel = true;
                                          } else {
                                            chooseVehicleModel = false;
                                          }
                                          chooseVehicleMake = false;
                                          chooseWorkArea = false;
                                          chooseVehicleType = false;
                                        }
                                      });
                                    },
                                    child: Container(
                                      height: media.width * 0.13,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                              color: darkModeBorderColor),
                                          color: vehicleMakeId == ''
                                              ? darkModeSecContainer
                                              : darkModeSecContainer),
                                      padding: EdgeInsets.only(
                                          left: media.width * 0.05,
                                          right: media.width * 0.05),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: media.width * 0.7,
                                            child: Text(
                                              (vehicleModelId == '')
                                                  ? languages[choosenLanguage]
                                                      ['text_sel_model']
                                                  : (vehicleModelId != '' &&
                                                          vehicleModelId !=
                                                              '' &&
                                                          vehicleModel
                                                              .isNotEmpty)
                                                      ? vehicleModel
                                                          .firstWhere(
                                                              (element) =>
                                                                  element['id']
                                                                      .toString() ==
                                                                  vehicleModelId)[
                                                              'name']
                                                          .toString()
                                                      : vehicleModelName == ''
                                                          ? languages[
                                                                  choosenLanguage]
                                                              [
                                                              'text_vehicle_model']
                                                          : vehicleModelName,
                                              style: GoogleFonts.inter(
                                                  fontSize: (vehicleModelId !=
                                                              '' &&
                                                          vehicleModelId != '')
                                                      ? media.width * twelve
                                                      : media.width * twelve,
                                                  // fontWeight: FontWeight.w600,
                                                  color: (widget.frompage ==
                                                              1 &&
                                                          (vehicleModelId ==
                                                                  '' ||
                                                              vehicleModelId ==
                                                                  ''))
                                                      ? hintColor
                                                      : hintColor),
                                            ),
                                          ),
                                          RotatedBox(
                                              quarterTurns:
                                                  (chooseVehicleModel == true &&
                                                          vehicleModel
                                                              .isNotEmpty)
                                                      ? 1
                                                      : 4,
                                              child: Icon(
                                                Icons
                                                    .keyboard_arrow_down_rounded,
                                                size: media.width * 0.06,
                                                color: hintColor,
                                              ))
                                        ],
                                      ),
                                    ),
                                  ),
                            SizedBox(
                              height: media.width * 0.02,
                            ),
                            if (chooseVehicleModel == true &&
                                vehicleModel.isNotEmpty)
                              Container(
                                margin:
                                    EdgeInsets.only(bottom: media.width * 0.03),
                                width: media.width * 0.9,
                                height: media.width * 0.5,
                                padding: EdgeInsets.all(media.width * 0.03),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: underline),
                                ),
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Column(
                                    children: vehicleModel
                                        .asMap()
                                        .map((i, value) {
                                          return MapEntry(
                                              i,
                                              InkWell(
                                                onTap: () async {
                                                  setState(() {
                                                    vehicleModelId =
                                                        vehicleModel[i]['id']
                                                            .toString();
                                                    chooseVehicleModel = false;
                                                    _isLoading = true;
                                                  });

                                                  var result =
                                                      await getVehicleModel();
                                                  if (result == 'success') {
                                                    setState(() {
                                                      _isLoading = false;
                                                    });
                                                  } else {
                                                    setState(() {
                                                      _isLoading = false;
                                                    });
                                                  }
                                                  // setState(() {});
                                                },
                                                child: Container(
                                                  width: media.width * 0.8,
                                                  padding: EdgeInsets.only(
                                                      top: media.width * 0.025,
                                                      bottom:
                                                          media.width * 0.025),
                                                  child: Text(
                                                    vehicleModel[i]['name']
                                                        .toString(),
                                                    style: GoogleFonts.inter(
                                                        fontSize: media.width *
                                                            fourteen,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: textColor),
                                                  ),
                                                ),
                                              ));
                                        })
                                        .values
                                        .toList(),
                                  ),
                                ),
                              ),
                            SizedBox(
                              height: media.height * 0.0125,
                            ),
                            Text(
                              languages[choosenLanguage]
                                  ['text_vehicle_model_year'],
                              style: GoogleFonts.inter(
                                  fontSize: media.width * fourteen,
                                  color: textColor,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: media.width * 0.03,
                            ),
                            Container(
                              height: media.width * 0.13,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border:
                                      Border.all(color: darkModeBorderColor),
                                  color: ((iscustommake)
                                          ? mycustommodel == ''
                                          : vehicleModelId == '')
                                      ? darkModeSecContainer
                                      : darkModeSecContainer),
                              padding: EdgeInsets.only(
                                  left: media.width * 0.05,
                                  right: media.width * 0.05),
                              child: InputField(
                                readonly: ((iscustommake)
                                        ? mycustommodel == ''
                                        : vehicleModelId == '')
                                    ? true
                                    : false,
                                underline: false,
                                text: languages[choosenLanguage]
                                    ['text_enter_vehicle_model_year'],
                                textController: modelcontroller,
                                onTap: (val) {
                                  setState(() {
                                    modelYear = modelcontroller.text;
                                  });
                                  if (modelcontroller.text.length == 4 &&
                                      int.parse(modelYear) <=
                                          int.parse(
                                              DateTime.now().year.toString())) {
                                    setState(() {
                                      dateError = '';
                                    });
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  } else if (modelcontroller.text.length == 4 &&
                                      int.parse(modelYear) >
                                          int.parse(
                                              DateTime.now().year.toString())) {
                                    setState(() {
                                      dateError = 'Please Enter Valid Date';
                                    });
                                  }
                                },
                                color: (dateError == '')
                                    ? (isDarkTheme)
                                        ? hintColor
                                        : hintColor
                                    : Colors.red,
                                textSize: media.width * twelve,
                                inputType: TextInputType.number,
                                maxLength: 4,
                              ),
                            ),
                            (dateError != '')
                                ? Container(
                                    margin: const EdgeInsets.only(top: 20),
                                    child: Text(
                                      dateError,
                                      style: GoogleFonts.inter(
                                          fontSize: media.width * sixteen,
                                          color: Colors.red),
                                    ),
                                  )
                                : Container(),

                            //vehicle number

                            SizedBox(
                              height: media.height * 0.02,
                            ),
                            Text(
                              languages[choosenLanguage]['text_enter_vehicle'],
                              style: GoogleFonts.inter(
                                  fontSize: media.width * fourteen,
                                  color: textColor,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: media.width * 0.03,
                            ),
                            Container(
                              height: media.width * 0.13,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border:
                                      Border.all(color: darkModeBorderColor),
                                  color: ((iscustommake)
                                          ? mycustommodel == ''
                                          : vehicleModelId == '')
                                      ? darkModeSecContainer
                                      : darkModeSecContainer),
                              padding: EdgeInsets.only(
                                  left: media.width * 0.05,
                                  right: media.width * 0.05),
                              child: InputField(
                                readonly: ((iscustommake)
                                        ? mycustommodel == ''
                                        : vehicleModelId == '')
                                    ? true
                                    : false,
                                underline: false,
                                text: languages[choosenLanguage]
                                    ['text_enter_vehicle'],
                                textSize: media.width * twelve,
                                textController: numbercontroller,
                                color: hintColor,
                                onTap: (val) {
                                  setState(() {
                                    vehicleNumber = numbercontroller.text;
                                  });
                                },
                                maxLength: 20,
                              ),
                            ),

                            //vehicle color
                            // SizedBox(
                            //   height: media.height * 0.02,
                            // ),
                            // Text(
                            //   languages[choosenLanguage]['text_vehicle_color'],
                            //   style: GoogleFonts.inter(
                            //       fontSize: media.width * sixteen,
                            //       color: textColor,
                            //       fontWeight: FontWeight.w600),
                            // ),
                            // const SizedBox(
                            //   height: 10,
                            // ),
                            // Container(
                            //   height: media.width * 0.13,
                            //   decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.circular(10),
                            //       border: Border.all(color: underline),
                            //       color: ((iscustommake)
                            //               ? mycustommodel == ''
                            //               : vehicleModelId == '')
                            //           ? hintColor
                            //           : topBar),
                            //   padding: EdgeInsets.only(
                            //       left: media.width * 0.05,
                            //       right: media.width * 0.05),
                            //   child: InputField(
                            //     readonly: ((iscustommake)
                            //             ? mycustommodel == ''
                            //             : vehicleModelId == '')
                            //         ? true
                            //         : false,
                            //     underline: false,
                            //     text: languages[choosenLanguage]
                            //         ['Text_enter_vehicle_color'],
                            //     textController: colorcontroller,
                            //     onTap: (val) {
                            //       setState(() {
                            //         vehicleColor = colorcontroller.text;
                            //       });
                            //     },
                            //   ),
                            // ),
                            // if (widget.frompage == 1 && isowner != true)
                            //   Column(
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: [
                            //       SizedBox(
                            //         height: media.height * 0.02,
                            //       ),
                            //       Text(
                            //         languages[choosenLanguage]
                            //             ['text_referral_optional'],
                            //         style: GoogleFonts.inter(
                            //             fontSize: media.width * sixteen,
                            //             color: textColor,
                            //             fontWeight: FontWeight.w600),
                            //       ),
                            //       const SizedBox(
                            //         height: 10,
                            //       ),
                            //       Container(
                            //         height: media.width * 0.13,
                            //         decoration: BoxDecoration(
                            //             borderRadius: BorderRadius.circular(10),
                            //             border: Border.all(color: underline),
                            //             color: topBar),
                            //         padding: EdgeInsets.only(
                            //             left: media.width * 0.05,
                            //             right: media.width * 0.05),
                            //         child: InputField(
                            //           // color: page,
                            //           underline: false,
                            //           text: languages[choosenLanguage]
                            //               ['text_enter_referral'],
                            //           textController: referralcontroller,
                            //           onTap: (val) {
                            //             setState(() {});
                            //           },
                            //         ),
                            //       ),
                            //     ],
                            //   )
                          ],
                        ),
                      ),
                    )),
                    if (_error != '')
                      Column(
                        children: [
                          SizedBox(
                              width: media.width * 0.9,
                              child: MyText(
                                text: _error,
                                color: Colors.red,
                                size: media.width * fourteen,
                                textAlign: TextAlign.center,
                              )),
                          SizedBox(
                            height: media.width * 0.025,
                          )
                        ],
                      ),
                    if (uploadError != '')
                      Column(
                        children: [
                          SizedBox(
                              width: media.width * 0.9,
                              child: MyText(
                                text: uploadError,
                                color: Colors.red,
                                size: media.width * fourteen,
                                textAlign: TextAlign.center,
                              )),
                          SizedBox(
                            height: media.width * 0.025,
                          )
                        ],
                      ),
                    //navigate to pick service page
                    (numbercontroller.text != '' &&
                                numbercontroller.text.length < 21) &&
                            (myVehicleId != '' ||
                                choosevehicletypelist.isNotEmpty) &&
                            ((iscustommake)
                                ? mycustommake != ''
                                : vehicleMakeId != '') &&
                            ((iscustommake)
                                ? mycustommodel != ''
                                : vehicleModelId != '') &&
                        (modelcontroller.text.length == 4 &&
                            modelYear != null &&
                            (int.tryParse(modelYear.toString()) ?? 9999) <=
                                int.parse(DateTime.now().year.toString()))
                        // &&
                        // (colorcontroller.text.isNotEmpty)
                        ? Container(
                            padding: EdgeInsets.all(media.width * 0.05),
                            child: Button(
                                onTap: () async {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  setState(() {
                                    _error = '';
                                    _isLoading = true;
                                  });
                                  if (widget.frompage == 1 &&
                                      userDetails.isNotEmpty &&
                                      isowner != true) {
                                    if (referralcontroller.text.isNotEmpty) {
                                      var val = await updateReferral(
                                          referralcontroller.text);
                                      if (val == 'true') {
                                        carInformationCompleted = true;
                                        navigateref();
                                      } else {
                                        setState(() {
                                          referralcontroller.clear();
                                          _error = languages[choosenLanguage]
                                              ['text_referral_code'];
                                          _isLoading = false;
                                        });
                                      }
                                    } else {
                                      carInformationCompleted = true;
                                      navigateref();
                                    }
                                  } else if (userDetails.isEmpty) {
                                    vehicletypelist.clear();
                                    for (Map<String, dynamic> json
                                        in choosevehicletypelist) {
                                      // Get the value of the key.
                                      vehicletypelist.add(json['id']);
                                    }

                                    var reg = await registerDriver();

                                    if (reg == 'true') {
                                      if (referralcontroller.text.isNotEmpty) {
                                        var val = await updateReferral(
                                            referralcontroller.text);
                                        if (val == 'true') {
                                          carInformationCompleted = true;
                                          navigateref();
                                        } else {
                                          setState(() {
                                            referralcontroller.clear();
                                            _error = languages[choosenLanguage]
                                                ['text_referral_code'];
                                            _isLoading = false;
                                          });
                                        }
                                      } else {
                                        carInformationCompleted = true;
                                        navigateref();
                                      }
                                    } else {
                                      debugPrint('REG ERROR: ${reg.toString()}');
                                      setState(() {
                                        uploadError = reg == null ? 'Erreur serveur' : reg.toString();
                                      });
                                    }
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  } else if (userDetails['role'] == 'owner') {
                                    vehicletypelist
                                        .add(choosevehicletypelist[0]['id']);
                                    var reg = await addDriver();
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    if (reg == 'true') {
                                      // ignore: use_build_context_synchronously
                                      setState(() {
                                        vehicleAdded = true;
                                      });
                                    } else if (reg == 'logout') {
                                      navigateLogout();
                                    } else {
                                      setState(() {
                                        uploadError = reg.toString();
                                      });
                                    }
                                  } else {
                                    vehicletypelist.clear();
                                    for (Map<String, dynamic> json
                                        in choosevehicletypelist) {
                                      // Get the value of the key.
                                      vehicletypelist.add(json['id']);
                                    }

                                    var update = await updateVehicle();
                                    if (update == 'success') {
                                      navigate();
                                    } else if (update == 'logout') {
                                      navigateLogout();
                                    }
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                },
                                text: widget.frompage == 1 &&
                                        userDetails.isNotEmpty &&
                                        referralcontroller.text.isEmpty &&
                                        isowner != true
                                    ? languages[choosenLanguage]
                                        ['text_skip_referral']
                                    : widget.frompage != 2
                                        ? languages[choosenLanguage]
                                            ['text_confirm']
                                        : languages[choosenLanguage]
                                            ['text_updateVehicle']),
                          )
                        : Container(),
                    ButtonBottomSpace(
                      height: 3,
                    )
                  ],
                ),
              ),
              (popAlert == true)
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
                                  padding: EdgeInsets.all(media.width * 0.05),
                                  width: media.width * 0.9,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: darkModeBorderColor),
                                      borderRadius: BorderRadius.circular(30),
                                      color: page),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: Responsive.height(1, context),
                                      ),
                                      Text(
                                        languages[choosenLanguage]
                                            ['text_sure_to_exit'],
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.inter(
                                            fontSize: media.width * sixteen,
                                            color: textColor,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(
                                        height: media.width * 0.08,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            child: Button(
                                                onTap: () async {
                                                  setState(() {
                                                    Navigator.pop(context);
                                                  });
                                                },
                                                text: languages[choosenLanguage]
                                                    ['text_confirm']),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Button(
                                                color: darkModeSecContainer,
                                                onTap: () async {
                                                  setState(() {
                                                    popAlert = false;
                                                    // _isLoading = true;
                                                  });
                                                },
                                                text: languages[choosenLanguage]
                                                    ['text_cancel']),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ))
                  : Container(),

              if (vehicleAdded == true)
                Positioned(
                    child: Container(
                  height: media.height * 1,
                  width: media.width * 1,
                  color: Colors.transparent.withOpacity(0.6),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: media.width * 0.9,
                          decoration: BoxDecoration(
                              color: page,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: darkModeBorderColor)),
                          padding: EdgeInsets.all(media.width * 0.05),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: media.width * 0.07,
                              ),
                              SizedBox(
                                child: Text(
                                    languages[choosenLanguage]
                                        ['text_vehicle_added'],
                                    style: GoogleFonts.inter(
                                      fontSize: media.width * sixteen,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    )),
                              ),
                              SizedBox(
                                height: media.width * 0.1,
                              ),
                              Button(
                                  width: media.width * 0.9,
                                  height: media.width * 0.1,
                                  onTap: () {
                                    Navigator.pop(context, true);
                                  },
                                  text: languages[choosenLanguage]['text_ok'])
                            ],
                          ),
                        )
                      ]),
                )),
//no internet
              (internet == false)
                  ? Positioned(
                      top: 0,
                      child: NoInternet(
                        onTap: () {
                          setState(() {
                            internetTrue();
                          });
                        },
                      ))
                  : Container(),
              //loader
              (_isLoading == true)
                  ? const Positioned(top: 0, child: Loading())
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
