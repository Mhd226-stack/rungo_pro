import 'dart:math';
import 'dart:ui' as ui;
import 'dart:io' show Platform;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_driver/common/responsive.dart';
import 'package:flutter_driver/pages/login/landingpage.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:switcher_button/switcher_button.dart';
import 'package:vector_math/vector_math.dart' as vector;
import '../../functions/functions.dart';
import '../../functions/geohash.dart';
import '../../functions/notifications.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../NavigatorPages/notification.dart';
import '../chatPage/chat_page.dart';
import '../in_app_calling/call_screen.dart';
import '../in_app_calling/incomming_call_screen.dart';
import '../loadingPage/loading.dart';
import '../loadingPage/loadingpage.dart';
import '../navDrawer/nav_drawer.dart';
import '../noInternet/nointernet.dart';
import '../vehicleInformations/docs_onprocess.dart';
import 'droplocation.dart';
import 'invoice.dart';

class Maps extends StatefulWidget {
  const Maps({Key? key}) : super(key: key);

  @override
  State<Maps> createState() => _MapsState();
}

bool showLogoutNotifier = false;
const callingStatus = 'calling_status';
const callingStatusIncomming = 'incomming';
const shouldShowIncommingCall = 'should_show_incomming_call';
const callingStatusDeclined = 'declined';
const callingStatusAccepted = 'accepted';
const readyForCall = 'ready';
final FlutterRingtonePlayer ringtonePlayer = FlutterRingtonePlayer();

dynamic _center = const LatLng(41.4219057, -102.0840772);
dynamic center;
LatLng? destinationLocation;
bool locationAllowed = false;

List<Marker> myMarkers = [];
List<Marker> destinationMarkerList = [];
Set<Circle> circles = {};
bool polylineGot = false;

dynamic _timer;
String cancelReasonText = '';
bool notifyCompleted = false;
bool logout = false;
bool deleteAccount = false;
bool getStartOtp = false;
String driverOtp = '';
bool serviceEnabled = false;
bool show = true;

int filtericon = 0;
dynamic isAvailable;
List vechiletypeslist = [];
Map rideRequest = {};

class _MapsState extends State<Maps>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  List driverData = [];

  bool sosLoaded = false;
  bool cancelRequest = false;
  bool _pickAnimateDone = false;

  late geolocator.LocationPermission permission;
  Location location = Location();
  String state = '';
  dynamic _controller;
  Animation<double>? _animation;
  dynamic animationController;
  String _cancellingError = '';
  double mapPadding = 0.0;
  var iconDropKeys = {};
  String _cancelReason = '';
  bool _locationDenied = false;
  int gettingPerm = 0;
  bool _errorOtp = false;
  dynamic loc;
  String _otp1 = '';
  String _otp2 = '';
  String _otp3 = '';
  String _otp4 = '';
  bool showSos = false;
  bool _showWaitingInfo = false;
  bool _isLoading = false;
  bool _reqCancelled = false;
  bool navigated = false;
  dynamic pinLocationIcon;
  dynamic pinLocationIcon2;
  dynamic pinLocationIcon3;
  dynamic userLocationIcon;
  bool makeOnline = false;
  bool contactus = false;
  GlobalKey iconKey = GlobalKey();
  GlobalKey iconDropKey = GlobalKey();
  List gesture = [];
  dynamic start;
  dynamic onrideicon;
  dynamic offlineicon;
  dynamic onlineicon;
  dynamic onridebikeicon;
  dynamic offlinebikeicon;
  dynamic onlinebikeicon;

  bool currentpage = true;
  bool _tripOpenMap = false;
  bool _isDarkTheme = false;

  bool maptype = false;

  final _mapMarkerSC = StreamController<List<Marker>>();
  StreamSink<List<Marker>> get _mapMarkerSink => _mapMarkerSC.sink;
  Stream<List<Marker>> get mapMarkerStream => _mapMarkerSC.stream;
  TextEditingController bidText = TextEditingController();
  final _advanceSwitchController = ValueNotifier<bool>(false);

  @override
  void initState() {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref();
    // updateDriverFcm();
    // checkFcmTokenChange();
    Future.delayed(Duration(seconds: 3)).then((value) {
      FirebaseMessaging.instance.getToken().then((token) {
        if (token != null) {
          dbRef
              .child('drivers/driver_${userDetails['id']}')
              .update({'fcm_token': token}).then(
                  (value) => debugPrint('Current token: $token'));
        }
      });
    });
    Timer.periodic((Duration(seconds: 10)), (timer) {
      dbRef
          .child('drivers/driver_${userDetails['id']}')
          .get()
          .then((snapshot) async {
        if (snapshot.exists) {
          var snapShotValue = snapshot.value;
          String dbToken = (snapShotValue as Map)['fcm_token'];
          debugPrint('Database token: $dbToken');
          String? currentToken = await FirebaseMessaging.instance.getToken();
          if (currentToken != null && dbToken != currentToken) {
            // showLogoutNotifier = true;
            await userLogout();
            navigateLogout();
            // print('''$result Loged out''');
          } else {
            debugPrint('Logged in');
          }
        }
      });
    });

    WidgetsBinding.instance.addObserver(this);
    myMarkers = [];
    show = true;
    navigated = false;
    filtericon = 0;
    polylineGot = false;
    _isDarkTheme = isDarkTheme;

    currentpage = true;
    getLocs();
    getadminCurrentMessages();
    getonlineoffline();
    FirebaseDatabase.instance
        .ref('requests/${driverReq['id']}')
        .onValue
        .listen((event) async {
      rideRequest = event.snapshot.value as Map;
      String currentCallingStatus = rideRequest[callingStatus] ?? '';
      bool shouldShowIncommingCallScreen = rideRequest[shouldShowIncommingCall] == true;
      bool? isDriverCalling = rideRequest['driver'];
      if (isDriverCalling == false &&
          currentCallingStatus == callingStatusIncomming &&
          shouldShowIncommingCallScreen) {
        ringtonePlayer.play(android: AndroidSounds.ringtone, volume: 1.0);
        await Navigator.of(context).push(CupertinoPageRoute(
          builder: (context) {
            return IncommingCallScreen();
          },
        ));
      }
    });
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;
      _controller?.setMapStyle(mapStyle);
    });

    if (driverReq.isNotEmpty) {
      _pickAnimateDone = true;
      Future.delayed(const Duration(milliseconds: 100), () {
        addPickDropMarker();
      });
    }
  }

  getonlineoffline() async {
    if (userDetails['role'] == 'driver' &&
        userDetails['owner_id'] != null &&
        userDetails['vehicle_type_id'] == null &&
        userDetails['active'] == true) {
      var val = await driverStatus();
      if (val == 'logout') {
        navigateLogout();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_controller != null) {
        _controller!.setMapStyle(mapStyle);
        valueNotifierHome.incrementNotifier();
      }

      isBackground = false;
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      isBackground = true;
    }
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
    }
    _controller?.dispose();
    _controller = null;
    animationController?.dispose();

    super.dispose();
  }

  navigateLogout() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LandingPage()));
  }

  reqCancel() {
    _reqCancelled = true;

    Future.delayed(const Duration(seconds: 2), () {
      _reqCancelled = false;
      userReject = false;
    });
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  capturePng(GlobalKey iconKeys) async {
    dynamic bitmap;

    try {
      RenderRepaintBoundary boundary =
      iconKeys.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData!.buffer.asUint8List();
      bitmap = BitmapDescriptor.fromBytes(pngBytes);
      // return pngBytes;
      return bitmap;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  addMarkers() {
    Future.delayed(const Duration(milliseconds: 200), () {
      addPickDropMarker();
    });
  }

  addDropMarker() async {
    if (tripStops.isNotEmpty) {
      for (var i = 0; i < tripStops.length; i++) {
        var testIcon = await capturePng(iconDropKeys[i]);
        // ignore: unnecessary_null_comparison
        if (testIcon != null) {
          myMarkers.add(Marker(
              markerId: MarkerId((i + 3).toString()),
              icon: testIcon,
              position:
              LatLng(tripStops[i]['latitude'], tripStops[i]['longitude'])));
        }
      }
      setState(() {});
    } else {
      var testIcon = await capturePng(iconDropKey);
      if (testIcon != null) {
        setState(() {
          myMarkers.add(Marker(
              markerId: const MarkerId('3'),
              icon: testIcon,
              position: LatLng(driverReq['drop_lat'], driverReq['drop_lng'])));
        });
      }
    }
    LatLngBounds bound;

    if (driverReq['pick_lat'] > driverReq['drop_lat'] &&
        driverReq['pick_lng'] > driverReq['drop_lng']) {
      bound = LatLngBounds(
          southwest: LatLng(driverReq['drop_lat'], driverReq['drop_lng']),
          northeast: LatLng(driverReq['pick_lat'], driverReq['pick_lng']));
    } else if (driverReq['pick_lng'] > driverReq['drop_lng']) {
      bound = LatLngBounds(
          southwest: LatLng(driverReq['pick_lat'], driverReq['drop_lng']),
          northeast: LatLng(driverReq['drop_lat'], driverReq['pick_lng']));
    } else if (driverReq['pick_lat'] > driverReq['drop_lat']) {
      bound = LatLngBounds(
          southwest: LatLng(driverReq['drop_lat'], driverReq['pick_lng']),
          northeast: LatLng(driverReq['pick_lat'], driverReq['drop_lng']));
    } else {
      bound = LatLngBounds(
          southwest: LatLng(driverReq['pick_lat'], driverReq['pick_lng']),
          northeast: LatLng(driverReq['drop_lat'], driverReq['drop_lng']));
    }
    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bound, 50);
    _controller?.animateCamera(cameraUpdate);
  }

  addMarker() async {
    polyline.clear();
    if (driverReq.isNotEmpty) {
      var testIcon = await capturePng(iconKey);
      if (testIcon != null) {
        setState(() {
          myMarkers.add(Marker(
              markerId: const MarkerId('2'),
              icon: testIcon,
              position: LatLng(driverReq['pick_lat'], driverReq['pick_lng'])));
        });
      }
    }
  }

  addPickDropMarker() async {
    addMarker();
    if (driverReq['drop_address'] != null) {
      await getPolylines();
      addDropMarker();
      _controller?.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(driverReq['pick_lat'], driverReq['pick_lng']), 11.0));
    }
  }

//getting permission and current location
  getLocs() async {
    permission = await geolocator.GeolocatorPlatform.instance.checkPermission();
    serviceEnabled =
    await geolocator.GeolocatorPlatform.instance.isLocationServiceEnabled();

    if (permission == geolocator.LocationPermission.denied ||
        permission == geolocator.LocationPermission.deniedForever ||
        serviceEnabled == false) {
      gettingPerm++;

      if (gettingPerm > 1) {
        locationAllowed = false;
        if (userDetails['active'] == true) {
          var val = await driverStatus();
          if (val == 'logout') {
            navigateLogout();
          }
        }
        state = '3';
      } else {
        state = '2';
      }
      setState(() {
        _isLoading = false;
      });
    } else if (permission == geolocator.LocationPermission.whileInUse ||
        permission == geolocator.LocationPermission.always) {
      if (serviceEnabled == true) {
        final Uint8List markerIcon;
        final Uint8List markerIcon2;
        final Uint8List onrideicon1;
        final Uint8List offlineicon1;
        final Uint8List onlineicon1;
        final Uint8List onlinebikeicon1;
        final Uint8List offlinebikeicon1;
        final Uint8List onridebikeicon1;
        markerIcon = await getBytesFromAsset('assets/images/top-taxi.png', 60);
        markerIcon2 = await getBytesFromAsset('assets/images/bike.png', 40);

        if (userDetails['role'] == 'owner') {
          onlinebikeicon1 =
          await getBytesFromAsset('assets/images/bike_online.png', 40);
          onridebikeicon1 =
          await getBytesFromAsset('assets/images/bike_onride.png', 40);
          offlinebikeicon1 =
          await getBytesFromAsset('assets/images/bike.png', 40);
          onrideicon1 =
          await getBytesFromAsset('assets/images/onboardicon.png', 40);
          offlineicon1 =
          await getBytesFromAsset('assets/images/offlineicon.png', 40);
          onlineicon1 =
          await getBytesFromAsset('assets/images/onlineicon.png', 40);

          onrideicon = BitmapDescriptor.fromBytes(onrideicon1);
          offlineicon = BitmapDescriptor.fromBytes(offlineicon1);
          onlineicon = BitmapDescriptor.fromBytes(onlineicon1);

          onridebikeicon = BitmapDescriptor.fromBytes(onridebikeicon1);
          offlinebikeicon = BitmapDescriptor.fromBytes(offlinebikeicon1);
          onlinebikeicon = BitmapDescriptor.fromBytes(onlinebikeicon1);
        }

        if (center == null) {
          var locs = await geolocator.Geolocator.getLastKnownPosition();
          if (locs != null) {
            center = LatLng(locs.latitude, locs.longitude);
            heading = locs.heading;
          } else {
            loc = await geolocator.Geolocator.getCurrentPosition(
                desiredAccuracy: geolocator.LocationAccuracy.best);
            center = LatLng(double.parse(loc.latitude.toString()),
                double.parse(loc.longitude.toString()));
            heading = loc.heading;
          }

          _controller?.animateCamera(CameraUpdate.newLatLngZoom(center, 14.0));
        }
        if (mounted) {
          setState(() {
            pinLocationIcon = BitmapDescriptor.fromBytes(markerIcon);
            pinLocationIcon2 = BitmapDescriptor.fromBytes(markerIcon2);

            if (myMarkers.isEmpty && userDetails['role'] != 'owner') {
              myMarkers = [
                Marker(
                    markerId: const MarkerId('1'),
                    rotation: heading,
                    position: center,
                    icon: (userDetails['vehicle_type_icon_for'] == 'motor_bike')
                        ? pinLocationIcon2
                        : (userDetails['vehicle_type_icon_for'] == 'taxi')
                        ? pinLocationIcon
                        : pinLocationIcon3,
                    anchor: const Offset(0.5, 0.5))
              ];
            }
          });
        }
      }

      if (makeOnline == true && userDetails['active'] == false) {
        var val = await driverStatus();
        if (val == 'logout') {
          navigateLogout();
        }
      }
      makeOnline = false;
      if (mounted) {
        setState(() {
          locationAllowed = true;
          state = '3';
          _isLoading = false;
        });
      }
    }
  }

  getLocationService() async {
    // await location.requestService();
    await geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.best);
    getLocs();
  }

  getLocationPermission() async {
    if (permission == geolocator.LocationPermission.denied ||
        permission == geolocator.LocationPermission.deniedForever) {
      if (permission != geolocator.LocationPermission.deniedForever) {
        if (platform == TargetPlatform.android) {
          await perm.Permission.location.request();
          await perm.Permission.locationAlways.request();
        } else {
          await [perm.Permission.location].request();
        }
        if (serviceEnabled == false) {
          // await location.requestService();
          await geolocator.Geolocator.getCurrentPosition(
              desiredAccuracy: geolocator.LocationAccuracy.best);
        }
      }
    } else if (serviceEnabled == false) {
      // await location.requestService();
      await geolocator.Geolocator.getCurrentPosition(
          desiredAccuracy: geolocator.LocationAccuracy.best);
    }
    setState(() {
      _isLoading = true;
    });
    getLocs();
  }

  int _bottom = 0;
  String _permission = '';

  GeoHasher geo = GeoHasher();

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        if (logout == false && deleteAccount == false) {
          if (platform == TargetPlatform.android) {
            platforms.invokeMethod('pipmode');
          }
        }
        return false;
      },
      child: Material(
        child: ValueListenableBuilder(
            valueListenable: valueNotifierHome.value,
            builder: (context, value, child) {
              if (_isDarkTheme != isDarkTheme && _controller != null) {
                _controller!.setMapStyle(mapStyle);
                _isDarkTheme = isDarkTheme;
              }
              if (navigated == false) {
                if (isGeneral == true) {
                  isGeneral = false;
                  if (lastNotification != latestNotification) {
                    lastNotification = latestNotification;
                    pref.setString('lastNotification', latestNotification);
                    latestNotification = '';
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NotificationPage()));
                    });
                  }
                }
                if ((driverReq.isNotEmpty && _pickAnimateDone == false) &&
                    _controller != null) {
                  _pickAnimateDone = true;
                  if (mounted) {
                    addMarkers();
                  }
                }
                if (myMarkers
                    .where((element) => element.markerId == const MarkerId('1'))
                    .isNotEmpty) {
                  if (userDetails['vehicle_type_icon_for'] != 'motor_bike' &&
                      myMarkers
                          .firstWhere((element) =>
                      element.markerId == const MarkerId('1'))
                          .icon ==
                          pinLocationIcon2) {
                    myMarkers.removeWhere(
                            (element) => element.markerId == const MarkerId('1'));
                  } else if (userDetails['vehicle_type_icon_for'] != 'taxi' &&
                      myMarkers
                          .firstWhere((element) =>
                      element.markerId == const MarkerId('1'))
                          .icon ==
                          pinLocationIcon) {
                    myMarkers.removeWhere(
                            (element) => element.markerId == const MarkerId('1'));
                  }
                }
                if (myMarkers
                    .where((element) =>
                element.markerId == const MarkerId('1'))
                    .isNotEmpty &&
                    pinLocationIcon != null &&
                    _controller != null &&
                    center != null) {
                  var dist = calculateDistance(
                      myMarkers
                          .firstWhere((element) =>
                      element.markerId == const MarkerId('1'))
                          .position
                          .latitude,
                      myMarkers
                          .firstWhere((element) =>
                      element.markerId == const MarkerId('1'))
                          .position
                          .longitude,
                      center.latitude,
                      center.longitude);
                  if (dist > 10 &&
                      animationController == null &&
                      _controller != null) {
                    animationController = AnimationController(
                      duration: const Duration(
                          milliseconds: 1500), //Animation duration of marker

                      vsync: this, //From the widget
                    );
                    animateCar(
                        myMarkers
                            .firstWhere((element) =>
                        element.markerId == const MarkerId('1'))
                            .position
                            .latitude,
                        myMarkers
                            .firstWhere((element) =>
                        element.markerId == const MarkerId('1'))
                            .position
                            .longitude,
                        center.latitude,
                        center.longitude,
                        _mapMarkerSink,
                        this,
                        _controller,
                        '1',
                        (userDetails.isNotEmpty &&
                            userDetails['vehicle_type_icon_for'] ==
                                'motor_bike')
                            ? pinLocationIcon2
                            : (userDetails.isNotEmpty &&
                            userDetails['vehicle_type_icon_for'] ==
                                'taxi')
                            ? pinLocationIcon
                            : pinLocationIcon3,
                        '',
                        '');
                  }
                } else if (myMarkers
                    .where((element) =>
                element.markerId == const MarkerId('1'))
                    .isEmpty &&
                    pinLocationIcon != null &&
                    center != null &&
                    userDetails['role'] != 'owner') {
                  myMarkers.add(Marker(
                      markerId: const MarkerId('1'),
                      rotation: heading,
                      position: center,
                      icon: (userDetails.isNotEmpty &&
                          userDetails['vehicle_type_icon_for'] ==
                              'motor_bike')
                          ? pinLocationIcon2
                          : (userDetails.isNotEmpty &&
                          userDetails['vehicle_type_icon_for'] ==
                              'taxi')
                          ? pinLocationIcon
                          : pinLocationIcon3,
                      anchor: const Offset(0.5, 0.5)));
                }
                if (driverReq.isNotEmpty) {
                  if (_controller != null) {
                    mapPadding = media.width * 1;
                  }
                  if (driverReq['is_completed'] == 1 &&
                      driverReq['requestBill'] != null &&
                      currentpage == true) {
                    navigated = true;
                    currentpage = false;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Invoice()),
                              (route) => false);
                    });
                    _pickAnimateDone = false;
                    myMarkers.removeWhere(
                            (element) => element.markerId != const MarkerId('1'));
                    polyline.clear();
                    polylineGot = false;
                  }
                } else if (driverReq.isEmpty) {
                  mapPadding = 0;
                  if (myMarkers
                      .where((element) =>
                  element.markerId != const MarkerId('1'))
                      .isNotEmpty &&
                      userDetails['role'] != 'owner') {
                    myMarkers.removeWhere(
                            (element) => element.markerId != const MarkerId('1'));
                    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                      setState(() {
                        polyline.clear();
                      });
                    });

                    if (userReject == true) {
                      reqCancel();
                    }
                    _pickAnimateDone = false;
                  }
                }
              }

              if (userDetails['approve'] == false && driverReq.isEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DocsProcess()),
                          (route) => false);
                });
              }
              return Directionality(
                textDirection: (languageDirection == 'rtl')
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: Scaffold(
                  drawer: const NavDrawer(),
                  body: StreamBuilder(
                      stream: userDetails['role'] == 'owner'
                          ? FirebaseDatabase.instance
                          .ref('drivers')
                          .orderByChild('ownerid')
                          .equalTo(userDetails['id'].toString())
                          .onValue
                          : null,
                      builder: (context, AsyncSnapshot<DatabaseEvent> event) {
                        if (event.hasData) {
                          driverData.clear();
                          for (var element in event.data!.snapshot.children) {
                            driverData.add(element.value);
                          }
                          // myMarkers.removeWhere((element) =>
                          //     element.markerId.toString().contains('car'));
                          for (var element in driverData) {
                            if (element['l'] != null &&
                                element['is_deleted'] != 1) {
                              if (userDetails['role'] == 'owner') {
                                if (userDetails['role'] == 'owner' &&
                                    offlineicon != null &&
                                    onlineicon != null &&
                                    onrideicon != null &&
                                    offlinebikeicon != null &&
                                    onlinebikeicon != null &&
                                    onridebikeicon != null &&
                                    filtericon == 0) {
                                  if (myMarkers
                                      .where((e) => e.markerId
                                      .toString()
                                      .contains('car${element['id']}'))
                                      .isEmpty) {
                                    myMarkers.add(Marker(
                                      markerId: MarkerId('car${element['id']}'),
                                      rotation: double.parse(
                                          element['bearing'].toString()),
                                      position: LatLng(
                                          element['l'][0], element['l'][1]),
                                      infoWindow: InfoWindow(
                                          title: element['vehicle_number'],
                                          snippet: element['name']),
                                      anchor: const Offset(0.5, 0.5),
                                      icon: (element['is_active'] == 0)
                                          ? (element['vehicle_type_icon'] ==
                                          'motor_bike')
                                          ? offlinebikeicon
                                          : offlineicon
                                          : (element['is_available'] == true &&
                                          element['is_active'] == 1)
                                          ? (element['vehicle_type_icon'] ==
                                          'motor_bike')
                                          ? onlinebikeicon
                                          : onlineicon
                                          : (element['vehicle_type_icon'] ==
                                          'motor_bike')
                                          ? onridebikeicon
                                          : onrideicon,
                                    ));
                                  } else if ((element['is_active'] != 0 &&
                                      myMarkers
                                          .lastWhere((e) => e.markerId
                                          .toString()
                                          .contains(
                                          'car${element['id']}'))
                                          .icon ==
                                          offlineicon) ||
                                      (element['is_active'] != 0 &&
                                          myMarkers
                                              .lastWhere((e) => e.markerId
                                              .toString()
                                              .contains(
                                              'car${element['id']}'))
                                              .icon ==
                                              offlinebikeicon)) {
                                    myMarkers.removeWhere((e) => e.markerId
                                        .toString()
                                        .contains('car${element['id']}'));
                                    myMarkers.add(Marker(
                                      markerId: MarkerId('car${element['id']}'),
                                      rotation: double.parse(
                                          element['bearing'].toString()),
                                      position: LatLng(
                                          element['l'][0], element['l'][1]),
                                      infoWindow: InfoWindow(
                                          title: element['vehicle_number'],
                                          snippet: element['name']),
                                      anchor: const Offset(0.5, 0.5),
                                      icon: (element['is_active'] == 0)
                                          ? (element['vehicle_type_icon'] ==
                                          'motor_bike')
                                          ? offlinebikeicon
                                          : offlineicon
                                          : (element['is_available'] == true &&
                                          element['is_active'] == 1)
                                          ? (element['vehicle_type_icon'] ==
                                          'motor_bike')
                                          ? onlinebikeicon
                                          : onlineicon
                                          : (element['vehicle_type_icon'] ==
                                          'motor_bike')
                                          ? onridebikeicon
                                          : onrideicon,
                                    ));
                                  } else if ((element['is_available'] != true &&
                                      myMarkers
                                          .lastWhere((e) => e.markerId
                                          .toString()
                                          .contains(
                                          'car${element['id']}'))
                                          .icon ==
                                          onlineicon) ||
                                      (element['is_available'] != true &&
                                          myMarkers
                                              .lastWhere((e) => e.markerId
                                              .toString()
                                              .contains(
                                              'car${element['id']}'))
                                              .icon ==
                                              onlinebikeicon)) {
                                    myMarkers.removeWhere((e) => e.markerId
                                        .toString()
                                        .contains('car${element['id']}'));
                                    myMarkers.add(Marker(
                                      markerId: MarkerId('car${element['id']}'),
                                      rotation: double.parse(
                                          element['bearing'].toString()),
                                      position: LatLng(
                                          element['l'][0], element['l'][1]),
                                      infoWindow: InfoWindow(
                                          title: element['vehicle_number'],
                                          snippet: element['name']),
                                      anchor: const Offset(0.5, 0.5),
                                      icon: (element['is_active'] == 0)
                                          ? (element['vehicle_type_icon'] ==
                                          'motor_bike')
                                          ? offlinebikeicon
                                          : offlineicon
                                          : (element['is_available'] == true &&
                                          element['is_active'] == 1)
                                          ? (element['vehicle_type_icon'] ==
                                          'motor_bike')
                                          ? onlinebikeicon
                                          : onlineicon
                                          : (element['vehicle_type_icon'] ==
                                          'motor_bike')
                                          ? onridebikeicon
                                          : onrideicon,
                                    ));
                                  } else if ((element['is_active'] != 1 &&
                                      myMarkers
                                          .lastWhere((e) => e.markerId
                                          .toString()
                                          .contains(
                                          'car${element['id']}'))
                                          .icon ==
                                          onlineicon) ||
                                      (element['is_active'] != 1 &&
                                          myMarkers
                                              .lastWhere((e) => e.markerId
                                              .toString()
                                              .contains(
                                              'car${element['id']}'))
                                              .icon ==
                                              onlinebikeicon)) {
                                    myMarkers.removeWhere((e) => e.markerId
                                        .toString()
                                        .contains('car${element['id']}'));
                                    myMarkers.add(Marker(
                                      markerId: MarkerId('car${element['id']}'),
                                      rotation: double.parse(
                                          element['bearing'].toString()),
                                      position: LatLng(
                                          element['l'][0], element['l'][1]),
                                      infoWindow: InfoWindow(
                                          title: element['vehicle_number'],
                                          snippet: element['name']),
                                      anchor: const Offset(0.5, 0.5),
                                      icon: (element['is_active'] == 0)
                                          ? (element['vehicle_type_icon'] ==
                                          'motor_bike')
                                          ? offlinebikeicon
                                          : offlineicon
                                          : (element['is_available'] == true &&
                                          element['is_active'] == 1)
                                          ? (element['vehicle_type_icon'] ==
                                          'motor_bike')
                                          ? onlinebikeicon
                                          : onlineicon
                                          : (element['vehicle_type_icon'] ==
                                          'motor_bike')
                                          ? onridebikeicon
                                          : onrideicon,
                                    ));
                                  } else if ((element['is_available'] == true &&
                                      myMarkers
                                          .lastWhere((e) => e.markerId
                                          .toString()
                                          .contains(
                                          'car${element['id']}'))
                                          .icon ==
                                          onrideicon) ||
                                      (element['is_available'] == true &&
                                          myMarkers
                                              .lastWhere((e) => e.markerId
                                              .toString()
                                              .contains(
                                              'car${element['id']}'))
                                              .icon ==
                                              onridebikeicon)) {
                                    myMarkers.removeWhere((e) => e.markerId
                                        .toString()
                                        .contains('car${element['id']}'));
                                    myMarkers.add(Marker(
                                        markerId:
                                        MarkerId('car${element['id']}'),
                                        rotation: double.parse(
                                            element['bearing'].toString()),
                                        position: LatLng(
                                            element['l'][0], element['l'][1]),
                                        infoWindow: InfoWindow(
                                            title: element['vehicle_number'],
                                            snippet: element['name']),
                                        anchor: const Offset(0.5, 0.5),
                                        icon: (element['is_active'] == 0)
                                            ? (element['vehicle_type_icon'] ==
                                            'motor_bike')
                                            ? offlinebikeicon
                                            : offlineicon
                                            : (element['is_available'] ==
                                            true &&
                                            element['is_active'] == 1)
                                            ? (element['vehicle_type_icon'] ==
                                            'motor_bike')
                                            ? onlinebikeicon
                                            : onlineicon
                                            : (element['vehicle_type_icon'] ==
                                            'motor_bike')
                                            ? onridebikeicon
                                            : onrideicon));
                                  } else if (_controller != null) {
                                    if (myMarkers
                                        .lastWhere((e) => e.markerId
                                        .toString()
                                        .contains(
                                        'car${element['id']}'))
                                        .position
                                        .latitude !=
                                        element['l'][0] ||
                                        myMarkers
                                            .lastWhere((e) => e.markerId
                                            .toString()
                                            .contains(
                                            'car${element['id']}'))
                                            .position
                                            .longitude !=
                                            element['l'][1]) {
                                      var dist = calculateDistance(
                                          myMarkers
                                              .lastWhere((e) => e.markerId
                                              .toString()
                                              .contains(
                                              'car${element['id']}'))
                                              .position
                                              .latitude,
                                          myMarkers
                                              .lastWhere((e) => e.markerId
                                              .toString()
                                              .contains(
                                              'car${element['id']}'))
                                              .position
                                              .longitude,
                                          element['l'][0],
                                          element['l'][1]);
                                      if (dist > 10 && _controller != null) {
                                        animationController =
                                            AnimationController(
                                              duration: const Duration(
                                                  milliseconds:
                                                  1500), //Animation duration of marker

                                              vsync: this, //From the widget
                                            );

                                        animateCar(
                                            myMarkers
                                                .lastWhere((e) => e.markerId
                                                .toString()
                                                .contains(
                                                'car${element['id']}'))
                                                .position
                                                .latitude,
                                            myMarkers
                                                .lastWhere((e) => e.markerId
                                                .toString()
                                                .contains(
                                                'car${element['id']}'))
                                                .position
                                                .longitude,
                                            element['l'][0],
                                            element['l'][1],
                                            _mapMarkerSink,
                                            this,
                                            _controller,
                                            'car${element['id']}',
                                            (element['is_active'] == 0)
                                                ? (element['vehicle_type_icon'] ==
                                                'motor_bike')
                                                ? offlinebikeicon
                                                : offlineicon
                                                : (element['is_available'] ==
                                                true &&
                                                element['is_active'] ==
                                                    1)
                                                ? (element['vehicle_type_icon'] ==
                                                'motor_bike')
                                                ? onlinebikeicon
                                                : onlineicon
                                                : (element['vehicle_type_icon'] ==
                                                'motor_bike')
                                                ? onridebikeicon
                                                : onrideicon,
                                            element['vehicle_number'],
                                            element['name']);
                                      }
                                    }
                                  }
                                } else if (filtericon == 1 &&
                                    userDetails['role'] == 'owner' &&
                                    onlineicon != null) {
                                  if (element['l'] != null) {
                                    if (element['is_active'] == 0 &&
                                        offlineicon != null) {
                                      if (myMarkers
                                          .where((e) => e.markerId
                                          .toString()
                                          .contains('car${element['id']}'))
                                          .isEmpty) {
                                        myMarkers.add(Marker(
                                          markerId: MarkerId(
                                              'carid${element['id']}idoffline'),
                                          rotation: double.parse(
                                              element['bearing'].toString()),
                                          position: LatLng(
                                              element['l'][0], element['l'][1]),
                                          anchor: const Offset(0.5, 0.5),
                                          icon: (element['vehicle_type_icon'] ==
                                              'motor_bike')
                                              ? offlinebikeicon
                                              : offlineicon,
                                        ));
                                      } else if (_controller != null) {
                                        if (myMarkers
                                            .lastWhere((e) => e.markerId
                                            .toString()
                                            .contains(
                                            'car${element['id']}'))
                                            .position
                                            .latitude !=
                                            element['l'][0] ||
                                            myMarkers
                                                .lastWhere((e) => e.markerId
                                                .toString()
                                                .contains(
                                                'car${element['id']}'))
                                                .position
                                                .longitude !=
                                                element['l'][1]) {
                                          var dist = calculateDistance(
                                              myMarkers
                                                  .lastWhere((e) => e.markerId
                                                  .toString()
                                                  .contains(
                                                  'car${element['id']}'))
                                                  .position
                                                  .latitude,
                                              myMarkers
                                                  .lastWhere((e) => e.markerId
                                                  .toString()
                                                  .contains(
                                                  'car${element['id']}'))
                                                  .position
                                                  .longitude,
                                              element['l'][0],
                                              element['l'][1]);
                                          if (dist > 10 &&
                                              _controller != null) {
                                            animationController =
                                                AnimationController(
                                                  duration: const Duration(
                                                      milliseconds:
                                                      1500), //Animation duration of marker

                                                  vsync: this, //From the widget
                                                );

                                            animateCar(
                                                myMarkers
                                                    .lastWhere((e) => e.markerId
                                                    .toString()
                                                    .contains(
                                                    'car${element['id']}'))
                                                    .position
                                                    .latitude,
                                                myMarkers
                                                    .lastWhere((e) => e.markerId
                                                    .toString()
                                                    .contains(
                                                    'car${element['id']}'))
                                                    .position
                                                    .longitude,
                                                element['l'][0],
                                                element['l'][1],
                                                _mapMarkerSink,
                                                this,
                                                _controller,
                                                'car${element['id']}',
                                                (element['vehicle_type_icon'] ==
                                                    'motor_bike')
                                                    ? offlinebikeicon
                                                    : offlineicon,
                                                element['vehicle_number'],
                                                element['name']);
                                          }
                                        }
                                      }
                                    } else {
                                      if (myMarkers
                                          .where((e) => e.markerId
                                          .toString()
                                          .contains('car${element['id']}'))
                                          .isNotEmpty) {
                                        myMarkers.removeWhere((e) => e.markerId
                                            .toString()
                                            .contains('car${element['id']}'));
                                      }
                                    }
                                  }
                                } else if (filtericon == 2 &&
                                    userDetails['role'] == 'owner' &&
                                    onlineicon != null) {
                                  if (element['is_available'] == false &&
                                      element['is_active'] == 1) {
                                    if (myMarkers
                                        .where((e) => e.markerId
                                        .toString()
                                        .contains('car${element['id']}'))
                                        .isEmpty) {
                                      myMarkers.add(Marker(
                                        markerId:
                                        MarkerId('car${element['id']}'),
                                        rotation: double.parse(
                                            element['bearing'].toString()),
                                        position: LatLng(
                                            element['l'][0], element['l'][1]),
                                        anchor: const Offset(0.5, 0.5),
                                        icon: (element['vehicle_type_icon'] ==
                                            'motor_bike')
                                            ? onridebikeicon
                                            : onrideicon,
                                      ));
                                    } else if (_controller != null) {
                                      if (myMarkers
                                          .lastWhere((e) => e.markerId
                                          .toString()
                                          .contains(
                                          'car${element['id']}'))
                                          .position
                                          .latitude !=
                                          element['l'][0] ||
                                          myMarkers
                                              .lastWhere((e) => e.markerId
                                              .toString()
                                              .contains(
                                              'car${element['id']}'))
                                              .position
                                              .longitude !=
                                              element['l'][1]) {
                                        var dist = calculateDistance(
                                            myMarkers
                                                .lastWhere((e) => e.markerId
                                                .toString()
                                                .contains(
                                                'car${element['id']}'))
                                                .position
                                                .latitude,
                                            myMarkers
                                                .lastWhere((e) => e.markerId
                                                .toString()
                                                .contains(
                                                'car${element['id']}'))
                                                .position
                                                .longitude,
                                            element['l'][0],
                                            element['l'][1]);
                                        if (dist > 10 && _controller != null) {
                                          animationController =
                                              AnimationController(
                                                duration: const Duration(
                                                    milliseconds:
                                                    1500), //Animation duration of marker

                                                vsync: this, //From the widget
                                              );

                                          animateCar(
                                              myMarkers
                                                  .lastWhere((e) => e.markerId
                                                  .toString()
                                                  .contains(
                                                  'car${element['id']}'))
                                                  .position
                                                  .latitude,
                                              myMarkers
                                                  .lastWhere((e) => e.markerId
                                                  .toString()
                                                  .contains(
                                                  'car${element['id']}'))
                                                  .position
                                                  .longitude,
                                              element['l'][0],
                                              element['l'][1],
                                              _mapMarkerSink,
                                              this,
                                              _controller,
                                              'car${element['id']}',
                                              (element['vehicle_type_icon'] ==
                                                  'motor_bike')
                                                  ? onridebikeicon
                                                  : onrideicon,
                                              element['vehicle_number'],
                                              element['name']);
                                        }
                                      }
                                    }
                                  } else {
                                    if (myMarkers
                                        .where((e) => e.markerId
                                        .toString()
                                        .contains('car${element['id']}'))
                                        .isNotEmpty) {
                                      myMarkers.removeWhere((e) => e.markerId
                                          .toString()
                                          .contains('car${element['id']}'));
                                    }
                                  }
                                } else if (filtericon == 3 &&
                                    userDetails['role'] == 'owner' &&
                                    onlineicon != null) {
                                  if (element['is_available'] == true &&
                                      element['is_active'] == 1) {
                                    if (myMarkers
                                        .where((e) => e.markerId
                                        .toString()
                                        .contains('car${element['id']}'))
                                        .isEmpty) {
                                      myMarkers.add(Marker(
                                        markerId:
                                        MarkerId('car${element['id']}'),
                                        rotation: double.parse(
                                            element['bearing'].toString()),
                                        position: LatLng(
                                            element['l'][0], element['l'][1]),
                                        anchor: const Offset(0.5, 0.5),
                                        icon: (element['vehicle_type_icon'] ==
                                            'motor_bike')
                                            ? onlinebikeicon
                                            : onlineicon,
                                      ));
                                    } else if (_controller != null) {
                                      if (myMarkers
                                          .lastWhere((e) => e.markerId
                                          .toString()
                                          .contains(
                                          'car${element['id']}'))
                                          .position
                                          .latitude !=
                                          element['l'][0] ||
                                          myMarkers
                                              .lastWhere((e) => e.markerId
                                              .toString()
                                              .contains(
                                              'car${element['id']}'))
                                              .position
                                              .longitude !=
                                              element['l'][1]) {
                                        var dist = calculateDistance(
                                            myMarkers
                                                .lastWhere((e) => e.markerId
                                                .toString()
                                                .contains(
                                                'car${element['id']}'))
                                                .position
                                                .latitude,
                                            myMarkers
                                                .lastWhere((e) => e.markerId
                                                .toString()
                                                .contains(
                                                'car${element['id']}'))
                                                .position
                                                .longitude,
                                            element['l'][0],
                                            element['l'][1]);
                                        if (dist > 10 && _controller != null) {
                                          animationController =
                                              AnimationController(
                                                duration: const Duration(
                                                    milliseconds:
                                                    1500), //Animation duration of marker

                                                vsync: this, //From the widget
                                              );

                                          animateCar(
                                              myMarkers
                                                  .lastWhere((e) => e.markerId
                                                  .toString()
                                                  .contains(
                                                  'car${element['id']}'))
                                                  .position
                                                  .latitude,
                                              myMarkers
                                                  .lastWhere((e) => e.markerId
                                                  .toString()
                                                  .contains(
                                                  'car${element['id']}'))
                                                  .position
                                                  .longitude,
                                              element['l'][0],
                                              element['l'][1],
                                              _mapMarkerSink,
                                              this,
                                              _controller,
                                              'car${element['id']}',
                                              (element['vehicle_type_icon'] ==
                                                  'motor_bike')
                                                  ? onlinebikeicon
                                                  : onlineicon,
                                              element['vehicle_number'],
                                              element['name']);
                                        }
                                      }
                                    }
                                  }
                                } else {
                                  if (myMarkers
                                      .where((e) => e.markerId
                                      .toString()
                                      .contains('car${element['id']}'))
                                      .isNotEmpty) {
                                    myMarkers.removeWhere((e) => e.markerId
                                        .toString()
                                        .contains('car${element['id']}'));
                                  }
                                }
                              }
                            } else {
                              if (myMarkers
                                  .where((e) => e.markerId
                                  .toString()
                                  .contains('car${element['id']}'))
                                  .isNotEmpty) {
                                myMarkers.removeWhere((e) => e.markerId
                                    .toString()
                                    .contains('car${element['id']}'));
                              }
                            }
                          }
                        }
                        return SingleChildScrollView(
                          child: Stack(
                            children: [
                              Container(
                                color: page,
                                height: media.height * 1,
                                width: media.width * 1,
                                child: Column(
                                    mainAxisAlignment:
                                    (state == '1' || state == '2')
                                        ? MainAxisAlignment.center
                                        : MainAxisAlignment.start,
                                    children: [
                                      (state == '1')
                                          ? Container(
                                        padding: EdgeInsets.all(
                                            media.width * 0.05),
                                        width: media.width * 0.6,
                                        height: media.width * 0.3,
                                        decoration: BoxDecoration(
                                            color: page,
                                            boxShadow: [
                                              BoxShadow(
                                                  blurRadius: 5,
                                                  color: Colors.black
                                                      .withValues(alpha: 0.2),
                                                  spreadRadius: 2)
                                            ],
                                            borderRadius:
                                            BorderRadius.circular(
                                                10)),
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              languages[choosenLanguage][
                                              'text_enable_location'],
                                              style: GoogleFonts.inter(
                                                  fontSize: media.width *
                                                      sixteen,
                                                  color: textColor,
                                                  fontWeight:
                                                  FontWeight.bold),
                                            ),
                                            Container(
                                              alignment:
                                              Alignment.centerRight,
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    state = '';
                                                  });
                                                  getLocs();
                                                },
                                                child: Text(
                                                  languages[
                                                  choosenLanguage]
                                                  ['text_ok'],
                                                  style: GoogleFonts.inter(
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      fontSize:
                                                      media.width *
                                                          twenty,
                                                      color: buttonColor),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                          : (state == '2')
                                          ? Stack(
                                        alignment:
                                        Alignment.topCenter,
                                        children: [
                                          Container(
                                            height: media.height * 1,
                                            width: media.width * 1,
                                            alignment:
                                            Alignment.topCenter,
                                            child: Align(
                                              alignment:
                                              Alignment.topCenter,
                                              child: SizedBox(
                                                height:
                                                Responsive.height(
                                                    80, context),
                                                width:
                                                media.width * 1,
                                                child:
                                                SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      SizedBox(
                                                        height: media
                                                            .height *
                                                            0.1,
                                                      ),
                                                      Image(
                                                          fit: BoxFit
                                                              .cover,
                                                          width: Responsive
                                                              .width(
                                                              90,
                                                              context),
                                                          image: AssetImage(
                                                              'assets/images/allow_location_image.png')),
                                                      SizedBox(
                                                        height: Responsive
                                                            .height(5,
                                                            context),
                                                      ),
                                                      Text(
                                                        languages[
                                                        choosenLanguage]
                                                        [
                                                        'text_trustedtaxi'],
                                                        style: GoogleFonts.inter(
                                                            fontSize:
                                                            media.width *
                                                                twentytwo,
                                                            color:
                                                            textColor,
                                                            fontWeight:
                                                            FontWeight
                                                                .w600),
                                                      ),
                                                      SizedBox(
                                                        height: Responsive
                                                            .height(
                                                            1.8,
                                                            context),
                                                      ),
                                                      Text(
                                                        languages[
                                                        choosenLanguage]
                                                        [
                                                        'text_allowpermission1'],
                                                        style:
                                                        GoogleFonts
                                                            .inter(
                                                          fontSize: media
                                                              .width *
                                                              fifteen,
                                                          color:
                                                          textColor,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: Responsive
                                                            .height(5,
                                                            context),
                                                      ),
                                                      Container(
                                                        padding: EdgeInsets.fromLTRB(
                                                            media.width *
                                                                0.05,
                                                            0,
                                                            media.width *
                                                                0.05,
                                                            0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                          children: [
                                                            SizedBox(
                                                                width: media.width *
                                                                    0.075,
                                                                child:
                                                                Icon(
                                                                  Icons.location_on_rounded,
                                                                  color:
                                                                  buttonColor,
                                                                )),
                                                            SizedBox(
                                                              width: media.width *
                                                                  0.025,
                                                            ),
                                                            SizedBox(
                                                              width: media.width *
                                                                  0.8,
                                                              child:
                                                              Text(
                                                                languages[choosenLanguage]
                                                                [
                                                                'text_loc_permission'],
                                                                style: GoogleFonts.inter(
                                                                    fontSize: media.width * fourteen,
                                                                    color: textColor,
                                                                    fontWeight: FontWeight.w500),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: media
                                                            .width *
                                                            0.02,
                                                      ),
                                                      Container(
                                                        padding: EdgeInsets.fromLTRB(
                                                            media.width *
                                                                0.05,
                                                            0,
                                                            media.width *
                                                                0.05,
                                                            0),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                          children: [
                                                            SizedBox(
                                                                width: media.width *
                                                                    0.075,
                                                                child:
                                                                Icon(
                                                                  Icons.location_on_rounded,
                                                                  color:
                                                                  buttonColor,
                                                                )),
                                                            SizedBox(
                                                              width: media.width *
                                                                  0.025,
                                                            ),
                                                            SizedBox(
                                                              width: media.width *
                                                                  0.8,
                                                              child:
                                                              Text(
                                                                languages[choosenLanguage]
                                                                [
                                                                'text_background_permission'],
                                                                style: GoogleFonts.inter(
                                                                    fontSize: media.width * fourteen,
                                                                    color: textColor,
                                                                    fontWeight: FontWeight.w500),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: Responsive
                                                            .height(7,
                                                            context),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: Responsive.height(
                                                3, context),
                                            child: Container(
                                                padding:
                                                EdgeInsets.all(
                                                    media.width *
                                                        0.05),
                                                child: Button(
                                                    width: Responsive
                                                        .width(90,
                                                        context),
                                                    onTap: () async {
                                                      getLocationPermission();
                                                    },
                                                    text: languages[
                                                    choosenLanguage]
                                                    [
                                                    'text_continue'])),
                                          )
                                        ],
                                      )
                                          : (state == '3')
                                          ? Stack(
                                        alignment:
                                        Alignment.center,
                                        children: [
                                          SizedBox(
                                              height:
                                              media.height *
                                                  1,
                                              width:
                                              media.width * 1,
                                              //google maps
                                              child: StreamBuilder<
                                                  List<
                                                      Marker>>(
                                                  stream:
                                                  mapMarkerStream,
                                                  builder: (context,
                                                      snapshot) {
                                                    return GoogleMap(
                                                      padding: EdgeInsets.only(
                                                          bottom:
                                                          media.width *
                                                              1,
                                                          top: media.height *
                                                              0.1 +
                                                              MediaQuery.of(context).padding.top),
                                                      onMapCreated:
                                                      _onMapCreated,
                                                      initialCameraPosition:
                                                      CameraPosition(
                                                        target: (center ==
                                                            null)
                                                            ? _center
                                                            : center,
                                                        zoom:
                                                        18.0,
                                                      ),
                                                      // markers: {
                                                      //   ...Set<Marker>.from(
                                                      //       myMarkers),
                                                      //   ...Set<Marker>.from(
                                                      //       destinationMarkerList)
                                                      // },
                                                      markers: Set<
                                                          Marker>.from(
                                                          myMarkers),

                                                      // polylines: {
                                                      //   ...polyline,
                                                      //   ...sourceToDestPolylines
                                                      // },
                                                      polylines:
                                                      polyline,
                                                      minMaxZoomPreference:
                                                      const MinMaxZoomPreference(
                                                          0.0,
                                                          20.0),
                                                      myLocationButtonEnabled:
                                                      false,
                                                      compassEnabled:
                                                      false,
                                                      buildingsEnabled:
                                                      false,
                                                      zoomControlsEnabled:
                                                      false,
                                                    );
                                                  })),

                                          //driver status
                                          (userDetails['role'] ==
                                              'owner' ||
                                              // driverReq
                                              //     .isNotEmpty ||
                                              // duration != 0 ||
                                              userDetails[
                                              'low_balance'] ==
                                                  true ||
                                              userDetails[
                                              'car_make_name'] ==
                                                  null)
                                              ? Container()
                                              : Positioned(
                                              top: MediaQuery.of(
                                                  context)
                                                  .padding
                                                  .top +
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                      0.05,
                                              child: InkWell(
                                                // onTap:
                                                //     () async {
                                                //   if (((userDetails['vehicle_type_id'] !=
                                                //               null) ||
                                                //           (userDetails['vehicle_types'] !=
                                                //               [])) &&
                                                //       driverReq
                                                //           .isEmpty &&
                                                //       userDetails['role'] ==
                                                //           'driver') {
                                                //     if (locationAllowed ==
                                                //             true &&
                                                //         serviceEnabled ==
                                                //             true) {
                                                //       setState(
                                                //           () {
                                                //         _isLoading =
                                                //             true;
                                                //       });

                                                //       var val =
                                                //           await driverStatus();
                                                //       if (val ==
                                                //           'logout') {
                                                //         navigateLogout();
                                                //       }
                                                //       setState(
                                                //           () {
                                                //         _isLoading =
                                                //             false;
                                                //       });
                                                //     } else if (locationAllowed ==
                                                //             true &&
                                                //         serviceEnabled ==
                                                //             false) {
                                                //       await geolocator.Geolocator.getCurrentPosition(
                                                //           desiredAccuracy:
                                                //               geolocator.LocationAccuracy.best);
                                                //       if (await geolocator
                                                //           .GeolocatorPlatform
                                                //           .instance
                                                //           .isLocationServiceEnabled()) {
                                                //         serviceEnabled =
                                                //             true;
                                                //         setState(
                                                //             () {
                                                //           _isLoading =
                                                //               true;
                                                //         });

                                                //         var val =
                                                //             await driverStatus();
                                                //         if (val ==
                                                //             'logout') {
                                                //           navigateLogout();
                                                //         }
                                                //         setState(
                                                //             () {
                                                //           _isLoading =
                                                //               false;
                                                //         });
                                                //       }
                                                //     } else {
                                                //       if (serviceEnabled ==
                                                //           true) {
                                                //         setState(
                                                //             () {
                                                //           makeOnline =
                                                //               true;
                                                //           _locationDenied =
                                                //               true;
                                                //         });
                                                //       } else {
                                                //         await geolocator.Geolocator.getCurrentPosition(
                                                //             desiredAccuracy: geolocator.LocationAccuracy.best);

                                                //         setState(
                                                //             () {
                                                //           _isLoading =
                                                //               true;
                                                //         });
                                                //         await getLocs();
                                                //         if (serviceEnabled ==
                                                //             true) {
                                                //           setState(() {
                                                //             makeOnline = true;
                                                //             _locationDenied = true;
                                                //           });
                                                //         }
                                                //       }
                                                //     }
                                                //   }
                                                // },
                                                child: Stack(
                                                  alignment:
                                                  Alignment
                                                      .center,
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.only(
                                                          left: media.width *
                                                              0.01,
                                                          right:
                                                          media.width * 0.01),
                                                      height: media.width *
                                                          0.12,
                                                      width: media.width *
                                                          0.9,
                                                      decoration:
                                                      BoxDecoration(
                                                        borderRadius:
                                                        BorderRadius.circular(media.width),
                                                        color:
                                                        page,
                                                        // (userDetails['active'] ==
                                                        //         false)
                                                        //     ? page
                                                        //     : (driverReq['accepted_at'] != null && driverReq['is_driver_arrived'] == 0)
                                                        //         ? const Color(0XFF127CE6).withValues(alpha: 0.6)
                                                        //         : (driverReq['is_driver_arrived'] == 1 && driverReq['is_trip_start'] == 0)
                                                        //             ? const Color(0XFFFEECD2)
                                                        //             : (driverReq['is_trip_start'] == 1)
                                                        //                 ? const Color(0XFFF9D9D9)
                                                        //                 : buttonColor,
                                                      ),
                                                      child:
                                                      // (userDetails['active'] ==
                                                      //         false)
                                                      // ? Row(
                                                      //     mainAxisAlignment:
                                                      //         MainAxisAlignment.spaceBetween,
                                                      //     children: [
                                                      //       Container(
                                                      //         padding: EdgeInsets.all(media.width * 0.01),
                                                      //         height: media.width * 0.07,
                                                      //         width: media.width * 0.07,
                                                      //         decoration: BoxDecoration(shape: BoxShape.circle, color: onlineOfflineText),
                                                      //         child: Image.asset(
                                                      //           'assets/images/offline.png',
                                                      //           color: page,
                                                      //         ),
                                                      //       ),
                                                      //       MyText(
                                                      //         text: languages[choosenLanguage]['text_offline'],
                                                      //         size: media.width * twelve,
                                                      //         fontweight: FontWeight.w500,
                                                      //         color: white,
                                                      //       ),
                                                      //       Container(),
                                                      //     ],
                                                      //   )
                                                      // :
                                                      Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                        children: [
                                                          // (driverReq['is_driver_arrived'] == 1 && waitingTime != null)
                                                          //     ?

                                                          Visibility(
                                                            visible: (driverReq['is_driver_arrived'] == 1 && driverReq['is_trip_start'] == 0 && waitingTime != null),
                                                            child: (waitingTime != null && waitingTime / 60 >= 1)
                                                                ? (driverReq['is_driver_arrived'] == 1 && waitingTime != null)
                                                                ? (waitingTime / 60 >= 1)
                                                                ? MyText(
                                                              text: '${languages[choosenLanguage]['text_waiting_time']}: ${(waitingTime / 60).toInt()} mins',
                                                              size: media.width * fourteen,
                                                              color: textColor,
                                                            )
                                                                : Container()
                                                                : Container()
                                                                : Container(),
                                                          ),
                                                          // : Container(),
                                                          Visibility(
                                                            visible: !(driverReq['is_driver_arrived'] == 1 && driverReq['is_trip_start'] == 0),
                                                            child: MyText(
                                                              textAlign: TextAlign.center,
                                                              text: (userDetails['active'] == false)
                                                                  ? languages[choosenLanguage]['text_offline']
                                                                  : (driverReq['accepted_at'] != null && driverReq['arrived_at'] == null)
                                                                  ? languages[choosenLanguage]['text_in_the_way']
                                                                  : (driverReq['is_driver_arrived'] == 1 && driverReq['is_trip_start'] == 0)
                                                                  ? languages[choosenLanguage]['text_arrived']
                                                                  : (driverReq['is_trip_start'] == 1)
                                                                  ? languages[choosenLanguage]['text_onride']
                                                                  : languages[choosenLanguage]['text_online'],
                                                              size: media.width * fourteen,
                                                              fontweight: FontWeight.w500,
                                                              color: (userDetails['active'] == false)
                                                                  ? Color(0xffEB001B)
                                                                  : (driverReq['accepted_at'] != null && driverReq['arrived_at'] == null)
                                                                  ? textColor
                                                                  : (driverReq['is_driver_arrived'] == 1 && driverReq['is_trip_start'] == 0)
                                                                  ? textColor
                                                                  : (driverReq['is_trip_start'] == 1)
                                                                  ? textColor
                                                                  : buttonColor,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Visibility(
                                                    //   visible:
                                                    //       false,
                                                    //   child:
                                                    //       Positioned(
                                                    //     right:
                                                    //         media.width * thirteen,
                                                    //     child:
                                                    //         Visibility(
                                                    //       visible:
                                                    //           !(driverReq.isNotEmpty || duration != 0),
                                                    //       child:
                                                    //           AdvancedSwitch(
                                                    //         initialValue: userDetails['active'],
                                                    //         onChanged: (value) async {},
                                                    //         borderRadius: BorderRadius.circular(40),
                                                    //         width: media.width * 0.13,
                                                    //         height: media.width * 0.07,
                                                    //         activeColor: buttonColor,
                                                    //         inactiveColor: Color(0xff929292),
                                                    //         controller: _advanceSwitchController,
                                                    //       ),
                                                    //     ),
                                                    //   ),
                                                    // ),
                                                    Positioned(
                                                      right: media.width *
                                                          thirteen,
                                                      child:
                                                      Visibility(
                                                        visible:
                                                        !(driverReq.isNotEmpty || duration != 0),
                                                        child:
                                                        SwitcherButton(
                                                          onColor:
                                                          Color(0xff08BA61),
                                                          offColor: userDetails['active']
                                                              ? ui.Color.fromARGB(255, 255, 255, 255)
                                                              : Color(0xff929292),
                                                          value:
                                                          userDetails['active'],
                                                          onChange:
                                                              (bool? value) async {
                                                            if (((userDetails['vehicle_type_id'] != null) || (userDetails['vehicle_types'] != [])) && driverReq.isEmpty && userDetails['role'] == 'driver') {
                                                              if (locationAllowed == true && serviceEnabled == true) {
                                                                setState(() {
                                                                  // _isLoading = true;
                                                                });

                                                                var val = await driverStatus();
                                                                if (val == 'logout') {
                                                                  navigateLogout();
                                                                }
                                                                setState(() {
                                                                  _isLoading = false;
                                                                });
                                                              } else if (locationAllowed == true && serviceEnabled == false) {
                                                                await geolocator.Geolocator.getCurrentPosition(desiredAccuracy: geolocator.LocationAccuracy.best);
                                                                if (await geolocator.GeolocatorPlatform.instance.isLocationServiceEnabled()) {
                                                                  serviceEnabled = true;
                                                                  setState(() {
                                                                    _isLoading = true;
                                                                  });

                                                                  var val = await driverStatus();
                                                                  if (val == 'logout') {
                                                                    navigateLogout();
                                                                  }
                                                                  setState(() {
                                                                    _isLoading = false;
                                                                  });
                                                                }
                                                              } else {
                                                                if (serviceEnabled == true) {
                                                                  setState(() {
                                                                    makeOnline = true;
                                                                    _locationDenied = true;
                                                                  });
                                                                } else {
                                                                  await geolocator.Geolocator.getCurrentPosition(desiredAccuracy: geolocator.LocationAccuracy.best);

                                                                  setState(() {
                                                                    _isLoading = true;
                                                                  });
                                                                  await getLocs();
                                                                  if (serviceEnabled == true) {
                                                                    setState(() {
                                                                      makeOnline = true;
                                                                      _locationDenied = true;
                                                                    });
                                                                  }
                                                                }
                                                              }
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    // (driverReq.isNotEmpty) ||
                                                    //         duration != 0
                                                    //     ? Container()
                                                    // :
                                                    Positioned(
                                                        left: media.width *
                                                            fifteen,
                                                        child:
                                                        SizedBox(
                                                          width:
                                                          media.width * 0.9,
                                                          child:
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              StatefulBuilder(builder: (context, setState) {
                                                                return InkWell(
                                                                  onTap: () {
                                                                    Scaffold.of(context).openDrawer();
                                                                  },
                                                                  child: Icon(Icons.menu, size: media.width * thirty, color: buttonColor),
                                                                  // child: Container(
                                                                  //     height: media.width * 0.1,
                                                                  //     width: media.width * 0.1,
                                                                  //     decoration: BoxDecoration(boxShadow: [
                                                                  //       (_bottom == 0) ? BoxShadow(blurRadius: (_bottom == 0) ? 2 : 0, color: (_bottom == 0) ? Colors.black.withValues(alpha: 0.2) : Colors.transparent, spreadRadius: (_bottom == 0) ? 2 : 0) : const BoxShadow(),
                                                                  //     ], color: buttonColor, shape: BoxShape.circle),
                                                                  //     alignment: Alignment.center,
                                                                  //     child: Icon(Icons.menu, size: media.width * 0.065, color: textColor)),
                                                                );
                                                              }),
                                                            ],
                                                          ),
                                                        )),
                                                  ],
                                                ),
                                              )),

                                          //menu bar
                                          // (driverReq.isNotEmpty) ||
                                          //         duration != 0
                                          //     ? Container()
                                          //     : Positioned(
                                          //         top: MediaQuery.of(
                                          //                     context)
                                          //                 .padding
                                          //                 .top +
                                          //             12.5,
                                          //         child: SizedBox(
                                          //           width: media
                                          //                   .width *
                                          //               0.9,
                                          //           child: Row(
                                          //             mainAxisAlignment:
                                          //                 MainAxisAlignment
                                          //                     .start,
                                          //             children: [
                                          //               StatefulBuilder(builder:
                                          //                   (context,
                                          //                       setState) {
                                          //                 return InkWell(
                                          //                   onTap:
                                          //                       () {
                                          //                     Scaffold.of(context).openDrawer();
                                          //                   },
                                          //                   child: Container(
                                          //                       height: media.width * 0.1,
                                          //                       width: media.width * 0.1,
                                          //                       decoration: BoxDecoration(boxShadow: [
                                          //                         (_bottom == 0) ? BoxShadow(blurRadius: (_bottom == 0) ? 2 : 0, color: (_bottom == 0) ? Colors.black.withValues(alpha: 0.2) : Colors.transparent, spreadRadius: (_bottom == 0) ? 2 : 0) : const BoxShadow(),
                                          //                       ], color: buttonColor, shape: BoxShape.circle),
                                          //                       alignment: Alignment.center,
                                          //                       child: Icon(Icons.menu, size: media.width * 0.065, color: textColor)),
                                          //                 );
                                          //               }),
                                          //             ],
                                          //           ),
                                          //         )),
                                          //online or offline button
                                          (userDetails['role'] ==
                                              'owner')
                                              ? (languageDirection ==
                                              'rtl')
                                              ? Positioned(
                                            top: MediaQuery.of(context)
                                                .padding
                                                .top +
                                                12.5,
                                            left: 10,
                                            child:
                                            AnimatedContainer(
                                              curve: Curves
                                                  .fastLinearToSlowEaseIn,
                                              duration: const Duration(
                                                  milliseconds:
                                                  0),
                                              height: media
                                                  .width *
                                                  0.13,
                                              width: (show == true)
                                                  ? media.width *
                                                  0.13
                                                  : media.width *
                                                  0.7,
                                              decoration:
                                              BoxDecoration(
                                                borderRadius: show ==
                                                    true
                                                    ? BorderRadius.circular(
                                                    100.0)
                                                    : const BorderRadius.only(
                                                    topLeft: Radius.circular(100),
                                                    bottomLeft: Radius.circular(100),
                                                    topRight: Radius.circular(20),
                                                    bottomRight: Radius.circular(20)),
                                                color: Colors
                                                    .white,
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: ui.Color.fromARGB(
                                                        255,
                                                        8,
                                                        38,
                                                        172),
                                                    offset:
                                                    Offset(0.0, 1.0), //(x,y)
                                                    blurRadius:
                                                    10.0,
                                                  ),
                                                ],
                                              ),
                                              child:
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                children: [
                                                  show == false
                                                      ? SizedBox(
                                                    width: media.width * 0.57,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        OwnerCarImagecontainer(
                                                          color: Colors.green,
                                                          imgurl: 'assets/images/available.png',
                                                          text: languages[choosenLanguage]['text_available'],
                                                          ontap: () {
                                                            setState(() {
                                                              filtericon = 3;
                                                              myMarkers.clear();
                                                            });
                                                          },
                                                        ),
                                                        OwnerCarImagecontainer(
                                                          color: Colors.red,
                                                          imgurl: 'assets/images/onboard.png',
                                                          text: languages[choosenLanguage]['text_onboard'],
                                                          ontap: () {
                                                            setState(() {
                                                              filtericon = 2;
                                                              myMarkers.clear();
                                                            });
                                                          },
                                                        ),
                                                        OwnerCarImagecontainer(
                                                          color: Colors.grey,
                                                          imgurl: 'assets/images/offlinecar.png',
                                                          text: languages[choosenLanguage]['text_offline'],
                                                          ontap: () {
                                                            setState(() {
                                                              filtericon = 1;
                                                              myMarkers.clear();
                                                              polyline.clear();
                                                            });
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                      : Container(),
                                                  InkWell(
                                                    onTap:
                                                        () {
                                                      setState(() {
                                                        filtericon = 0;
                                                        myMarkers.clear();
                                                        if (show == false) {
                                                          show = true;
                                                        } else {
                                                          show = false;
                                                        }
                                                      });
                                                    },
                                                    child:
                                                    Container(
                                                      width: media.width * 0.13,
                                                      decoration: BoxDecoration(image: const DecorationImage(image: AssetImage('assets/images/bluecar.png'), fit: BoxFit.contain), borderRadius: BorderRadius.circular(100.0)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                              : Positioned(
                                            top: MediaQuery.of(context)
                                                .padding
                                                .top +
                                                12.5,
                                            right: 10,
                                            child:
                                            AnimatedContainer(
                                              curve: Curves
                                                  .fastLinearToSlowEaseIn,
                                              duration: const Duration(
                                                  milliseconds:
                                                  0),
                                              height: media
                                                  .width *
                                                  0.13,
                                              width: (show == true)
                                                  ? media.width *
                                                  0.13
                                                  : media.width *
                                                  0.7,
                                              decoration:
                                              BoxDecoration(
                                                borderRadius: show ==
                                                    true
                                                    ? BorderRadius.circular(
                                                    100.0)
                                                    : const BorderRadius.only(
                                                    topLeft: Radius.circular(20),
                                                    bottomLeft: Radius.circular(20),
                                                    topRight: Radius.circular(100),
                                                    bottomRight: Radius.circular(100)),
                                                color: Colors
                                                    .white,
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: ui.Color.fromARGB(
                                                        255,
                                                        8,
                                                        38,
                                                        172),
                                                    offset:
                                                    Offset(0.0, 1.0), //(x,y)
                                                    blurRadius:
                                                    10.0,
                                                  ),
                                                ],
                                              ),
                                              child:
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                children: [
                                                  show == false
                                                      ? SizedBox(
                                                    width: media.width * 0.57,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        OwnerCarImagecontainer(
                                                          color: Colors.green,
                                                          imgurl: 'assets/images/available.png',
                                                          text: languages[choosenLanguage]['text_available'],
                                                          ontap: () {
                                                            setState(() {
                                                              filtericon = 3;
                                                              myMarkers.clear();
                                                            });
                                                          },
                                                        ),
                                                        OwnerCarImagecontainer(
                                                          color: Colors.red,
                                                          imgurl: 'assets/images/onboard.png',
                                                          text: languages[choosenLanguage]['text_onboard'],
                                                          ontap: () {
                                                            setState(() {
                                                              filtericon = 2;
                                                              myMarkers.clear();
                                                            });
                                                          },
                                                        ),
                                                        OwnerCarImagecontainer(
                                                          color: Colors.grey,
                                                          imgurl: 'assets/images/offlinecar.png',
                                                          text: 'Offline',
                                                          ontap: () {
                                                            setState(() {
                                                              filtericon = 1;
                                                              myMarkers.clear();
                                                            });
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                      : Container(),
                                                  InkWell(
                                                    onTap:
                                                        () {
                                                      setState(() {
                                                        filtericon = 0;
                                                        myMarkers.clear();
                                                        if (show == false) {
                                                          show = true;
                                                        } else {
                                                          show = false;
                                                        }
                                                      });
                                                    },
                                                    child:
                                                    Container(
                                                      width: media.width * 0.13,
                                                      decoration: BoxDecoration(image: const DecorationImage(image: AssetImage('assets/images/bluecar.png'), fit: BoxFit.contain), borderRadius: BorderRadius.circular(100.0)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                              : Container(),

                                          //request popup accept or reject
                                          Positioned(
                                              bottom: 0,
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .end,
                                                children: [
                                                  (driverReq.isNotEmpty &&
                                                      driverReq['is_trip_start'] ==
                                                          1)
                                                      ? InkWell(
                                                      onTap:
                                                          () async {
                                                        setState(
                                                                () {
                                                              showSos =
                                                              true;
                                                            });
                                                      },
                                                      child:
                                                      Container(
                                                        height:
                                                        media.width * 0.1,
                                                        width:
                                                        media.width * 0.1,
                                                        decoration: BoxDecoration(
                                                            color: buttonColor,
                                                            shape: BoxShape.circle),
                                                        alignment:
                                                        Alignment.center,
                                                        child:
                                                        Text(
                                                          'SOS',
                                                          style:
                                                          GoogleFonts.inter(fontSize: media.width * fourteen, color: white),
                                                        ),
                                                      ))
                                                      : Container(),
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                  // (driverReq.isNotEmpty &&
                                                  //         driverReq['accepted_at'] !=
                                                  //             null &&
                                                  //         driverReq['drop_address'] !=
                                                  //             null)
                                                  //     ? Row(
                                                  //         children: [
                                                  //           (maptype == true)
                                                  //               ? Container(
                                                  //                   padding: EdgeInsets.all(media.width * 0.02),
                                                  //                   decoration: BoxDecoration(boxShadow: [], borderRadius: BorderRadius.circular(media.width * 0.02)),
                                                  //                   child: Row(
                                                  //                     children: [
                                                  //                       InkWell(
                                                  //                         onTap: () {
                                                  //                           if (driverReq['is_trip_start'] == 0) {
                                                  //                             launchGoogleMapToPickup(driverReq['pick_lat'], driverReq['pick_lng']);
                                                  //                           }
                                                  //                           if (tripStops.isEmpty && driverReq['is_trip_start'] != 0) {
                                                  //                             launchGoogleMapFromPickupToDropoff(driverReq['pick_lat'], driverReq['pick_lng'], driverReq['drop_lat'], driverReq['drop_lng']);
                                                  //                           }
                                                  //                         },
                                                  //                         child: Container(
                                                  //                           width: media.width * 00.09,
                                                  //                           height: media.width * 0.09,
                                                  //                           padding: EdgeInsets.all(7),
                                                  //                           decoration: BoxDecoration(
                                                  //                             color: white,
                                                  //                             shape: BoxShape.circle,
                                                  //                           ),
                                                  //                           child: Image(image: AssetImage('assets/images/googlemaps.png')),
                                                  //                         ),
                                                  //                       ),
                                                  //                       SizedBox(
                                                  //                         width: media.width * 0.02,
                                                  //                       ),
                                                  //                       InkWell(
                                                  //                         onTap: () {
                                                  //                           if (driverReq['is_trip_start'] == 0) {
                                                  //                             launchWazeMapToPickup(driverReq['pick_lat'], driverReq['pick_lng']);
                                                  //                           }
                                                  //                           if (tripStops.isEmpty && driverReq['is_trip_start'] != 0) {
                                                  //                             launchWazeMapFromPickupToDropoff(driverReq['pick_lat'], driverReq['pick_lng'], driverReq['drop_lat'], driverReq['drop_lng']);
                                                  //                           }
                                                  //                         },
                                                  //                         child: Container(
                                                  //                           clipBehavior: Clip.antiAlias,
                                                  //                           width: media.width * 00.09,
                                                  //                           height: media.width * 0.09,
                                                  //                           decoration: BoxDecoration(
                                                  //                             color: white,
                                                  //                             shape: BoxShape.circle,
                                                  //                           ),
                                                  //                           child: Image(image: AssetImage('assets/images/waze.png')),
                                                  //                         ),
                                                  //                       ),
                                                  //                     ],
                                                  //                   ),
                                                  //                 )
                                                  //               : Container(),
                                                  //           SizedBox(
                                                  //             width:
                                                  //                 media.width * 0.01,
                                                  //           ),
                                                  //           InkWell(
                                                  //             onTap:
                                                  //                 () async {
                                                  //               if (userDetails['enable_vase_map'] == '1') {
                                                  //                 if (maptype == false) {
                                                  //                   if (driverReq['is_trip_start'] == 0) {
                                                  //                     setState(() {
                                                  //                       maptype = true;
                                                  //                     });
                                                  //                   } else if (tripStops.isNotEmpty) {
                                                  //                     setState(() {
                                                  //                       _tripOpenMap = true;
                                                  //                     });
                                                  //                   } else {
                                                  //                     setState(() {
                                                  //                       maptype = true;
                                                  //                     });
                                                  //                   }
                                                  //                 } else {
                                                  //                   setState(() {
                                                  //                     maptype = false;
                                                  //                   });
                                                  //                 }
                                                  //               } else {
                                                  //                 if (driverReq['is_trip_start'] == 0) {
                                                  //                   launchGoogleMapToPickup(driverReq['pick_lat'], driverReq['pick_lng']);
                                                  //                 }
                                                  //                 if (tripStops.isEmpty && driverReq['is_trip_start'] != 0) {
                                                  //                   launchGoogleMapFromPickupToDropoff(driverReq['pick_lat'], driverReq['pick_lng'], driverReq['drop_lat'], driverReq['drop_lng']);
                                                  //                 }
                                                  //               }
                                                  //             },
                                                  //             child: Container(
                                                  //                 height: media.width * 0.1,
                                                  //                 width: media.width * 0.1,
                                                  //                 decoration: BoxDecoration(boxShadow: [], color: white, shape: BoxShape.circle),
                                                  //                 alignment: Alignment.center,
                                                  //                 child: Image.asset(
                                                  //                   'assets/images/locationFind.png',
                                                  //                   width: media.width * 0.05,
                                                  //                 )),
                                                  //           ),
                                                  //         ],
                                                  //       )
                                                  //     : Container(),
                                                  const SizedBox(
                                                      height: 20),

                                                  //animate to current location button
                                                  SizedBox(
                                                    width: media
                                                        .width *
                                                        0.9,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .end,
                                                      children: [
                                                        InkWell(
                                                          onTap:
                                                              () async {
                                                            if (locationAllowed ==
                                                                true) {
                                                              _controller?.animateCamera(CameraUpdate.newLatLngZoom(center,
                                                                  18.0));
                                                            } else {
                                                              if (serviceEnabled ==
                                                                  true) {
                                                                setState(() {
                                                                  _locationDenied = true;
                                                                });
                                                              } else {
                                                                await geolocator.Geolocator.getCurrentPosition(desiredAccuracy: geolocator.LocationAccuracy.best);

                                                                setState(() {
                                                                  _isLoading = true;
                                                                });
                                                                await getLocs();
                                                                if (serviceEnabled == true) {
                                                                  setState(() {
                                                                    _locationDenied = true;
                                                                  });
                                                                }
                                                              }
                                                            }
                                                          },
                                                          child:
                                                          Container(
                                                            height:
                                                            media.width * 0.1,
                                                            width:
                                                            media.width * 0.1,
                                                            decoration: BoxDecoration(
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    blurRadius: 2,
                                                                    color: Colors.black26,
                                                                  )
                                                                ],
                                                                color: white,
                                                                shape: BoxShape.circle),
                                                            alignment:
                                                            Alignment.center,
                                                            child: Icon(
                                                                Icons.near_me_outlined,
                                                                color: black,
                                                                size: media.width * 0.06),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height: media
                                                          .width *
                                                          0.40),
                                                  (driverReq
                                                      .isNotEmpty)
                                                      ? (duration != 0 &&
                                                      driverReq['accepted_at'] ==
                                                          null &&
                                                      userReject ==
                                                          false)
                                                      ? Column(
                                                    children: [
                                                      (driverReq['is_later'] == 1 && driverReq['is_rental'] != true)
                                                          ? Container(
                                                        alignment: Alignment.center,
                                                        margin: EdgeInsets.only(bottom: media.width * 0.025),
                                                        padding: EdgeInsets.all(media.width * 0.025),
                                                        decoration: BoxDecoration(color: buttonColor, borderRadius: BorderRadius.circular(6)),
                                                        width: media.width * 1,
                                                        child: MyText(
                                                          text: languages[choosenLanguage]['text_rideLaterTime'] + " " + driverReq['cv_trip_start_time'],
                                                          size: media.width * sixteen,
                                                          color: topBar,
                                                        ),
                                                      )
                                                          : (driverReq['is_rental'] == true && driverReq['is_later'] != 1)
                                                          ? Container(
                                                        alignment: Alignment.center,
                                                        margin: EdgeInsets.only(bottom: media.width * 0.025),
                                                        padding: EdgeInsets.all(media.width * 0.025),
                                                        decoration: BoxDecoration(color: buttonColor, borderRadius: BorderRadius.circular(6)),
                                                        width: media.width * 1,
                                                        child: MyText(
                                                          text: languages[choosenLanguage]['text_rental_ride'] + ' - ' + driverReq['rental_package_name'],
                                                          size: media.width * sixteen,
                                                          color: Colors.black,
                                                        ),
                                                      )
                                                          : (driverReq['is_rental'] == true && driverReq['is_later'] == 1)
                                                          ? Container(
                                                        alignment: Alignment.center,
                                                        margin: EdgeInsets.only(bottom: media.width * 0.025),
                                                        padding: EdgeInsets.all(media.width * 0.025),
                                                        decoration: BoxDecoration(color: buttonColor, borderRadius: BorderRadius.circular(6)),
                                                        width: media.width * 1,
                                                        child: Column(
                                                          children: [
                                                            MyText(
                                                              text: languages[choosenLanguage]['text_rideLaterTime'] + " " + driverReq['cv_trip_start_time'],
                                                              size: media.width * sixteen,
                                                              color: Colors.black,
                                                            ),
                                                            SizedBox(height: media.width * 0.02),
                                                            MyText(
                                                              text: languages[choosenLanguage]['text_rental_ride'] + ' - ' + driverReq['rental_package_name'],
                                                              size: media.width * sixteen,
                                                              color: Colors.black,
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                          : Container(),
                                                      // FutureBuilder<Map>(
                                                      //     future: fetchDestinationLocation(),
                                                      //     builder: (context, snapshot) {
                                                      //       if (snapshot.hasData) {
                                                      //         if (snapshot.data != null) {
                                                      //           Map destinationLocationMap = snapshot.data!['destination_location'];
                                                      //           destinationLocation = LatLng(destinationLocationMap['lat'], destinationLocationMap['lng']);
                                                      //           // if (destinationLocation != null) {
                                                      //           //   destinationMarkerList = [];
                                                      //           //   destinationMarkerList.add(Marker(markerId: const MarkerId('destination_location'), position: destinationLocation!));
                                                      //           //   drawPolylineBetweenPoints(LatLng(driverReq['pick_lat'], driverReq['pick_lng']), destinationLocation!);
                                                      //           //   // adjustZoomAndAnimateCamera(LatLng(driverReq['pick_lat'], driverReq['pick_lng']), destinationLocation!, _controller);
                                                      //           // }
                                                      //         }
                                                      //       }
                                                      // return
                                                      Container(
                                                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                          // margin: EdgeInsets.only(bottom: media.width * 0.0375),
                                                          width: media.width,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                                                            color: page,
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Stack(
                                                                clipBehavior: Clip.none,
                                                                alignment: Alignment.topCenter,
                                                                children: [
                                                                  Container(
                                                                    padding: EdgeInsets.fromLTRB(
                                                                      media.width * 0.05,
                                                                      media.width * 0.02,
                                                                      media.width * 0.05,
                                                                      media.width * 0.05,
                                                                    ),
                                                                    child: Column(
                                                                      children: [
                                                                        SizedBox(
                                                                          height: Responsive.height(4, context),
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                          children: [
                                                                            Container(
                                                                              height: media.width * 0.15,
                                                                              width: media.width * 0.15,
                                                                              decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: NetworkImage(driverReq['userDetail']['data']['profile_picture']), fit: BoxFit.cover)),
                                                                            ),
                                                                            SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                MyText(
                                                                                  text: driverReq['userDetail']['data']['name'],
                                                                                  size: media.width * sixteen,
                                                                                  fontweight: FontWeight.w600,
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 5,
                                                                                ),
                                                                                Row(
                                                                                  children: [
                                                                                    Icon(
                                                                                      Icons.star,
                                                                                      color: Color(0xffF79E1B),
                                                                                      size: media.width * thirteen,
                                                                                    ),
                                                                                    SizedBox(
                                                                                      width: 5,
                                                                                    ),
                                                                                    MyText(
                                                                                      text: driverReq['userDetail']['data']['rating'].toString(),
                                                                                      size: media.width * twelve,
                                                                                    ),
                                                                                    SizedBox(
                                                                                      width: media.width * 0.12,
                                                                                    ),
                                                                                    (driverReq['drop_address'] == null && driverReq['is_rental'] == false)
                                                                                        ? Container()
                                                                                        : Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Row(
                                                                                          children: [
                                                                                            //payment image
                                                                                            (driverReq['payment_opt'].toString() == '1')
                                                                                                ? Image.asset(
                                                                                              'assets/images/cash_image.png',
                                                                                              fit: BoxFit.contain,
                                                                                              width: media.width * twenty,
                                                                                              height: media.width * seventeen,
                                                                                            )
                                                                                                : (driverReq['payment_opt'].toString() == '2')
                                                                                                ? Image.asset(
                                                                                              'assets/images/wallet.png',
                                                                                              fit: BoxFit.contain,
                                                                                              width: media.width * twenty,
                                                                                              height: media.width * seventeen,
                                                                                            )
                                                                                                : (driverReq['payment_opt'].toString() == '0')
                                                                                                ? Image.asset(
                                                                                              'assets/images/card.png',
                                                                                              fit: BoxFit.contain,
                                                                                              width: media.width * twenty,
                                                                                              height: media.width * seventeen,
                                                                                            )
                                                                                                : Container(),
                                                                                            SizedBox(
                                                                                              width: 5,
                                                                                            ),

                                                                                            MyText(
                                                                                              text: driverReq['payment_type_string'].toString(),
                                                                                              size: media.width * sixteen,
                                                                                            ),
                                                                                            SizedBox(
                                                                                              width: 5,
                                                                                            ),

                                                                                            (driverReq['show_request_eta_amount'] == true && driverReq['request_eta_amount'] != null)
                                                                                                ? Row(
                                                                                              children: [
                                                                                                MyText(
                                                                                                  text: driverReq['request_eta_amount'].toStringAsFixed(0),
                                                                                                  size: media.width * fourteen,
                                                                                                  fontweight: FontWeight.w700,
                                                                                                ),
                                                                                                SizedBox(
                                                                                                  width: 5,
                                                                                                ),
                                                                                                MyText(
                                                                                                  text: userDetails['currency_symbol'],
                                                                                                  size: media.width * fourteen,
                                                                                                )
                                                                                              ],
                                                                                            )
                                                                                                : Container()
                                                                                          ],
                                                                                        )
                                                                                      ],
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        SizedBox(
                                                                          height: media.width * 0.05,
                                                                        ),
                                                                        SizedBox(
                                                                          height: media.width * 0.05,
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                          children: [
                                                                            Container(
                                                                              height: media.width * 0.05,
                                                                              width: media.width * 0.05,
                                                                              alignment: Alignment.center,
                                                                              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: buttonColor)),
                                                                              child: Container(
                                                                                height: media.width * 0.025,
                                                                                width: media.width * 0.025,
                                                                                decoration: BoxDecoration(shape: BoxShape.circle, color: buttonColor),
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              width: media.width * 0.02,
                                                                            ),
                                                                            Expanded(
                                                                              child: MyText(
                                                                                text: driverReq['pick_address'],
                                                                                size: media.width * twelve,
                                                                                // overflow: TextOverflow.ellipsis,
                                                                                // maxLines: 1,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        SizedBox(
                                                                          height: media.width * 0.03,
                                                                        ),
                                                                        (driverReq['is_rental'] != true && driverReq['drop_address'] != null)
                                                                            ? Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                Icon(
                                                                                  Icons.location_on_outlined,
                                                                                  color: textColor,
                                                                                  size: media.width * eighteen,
                                                                                ),
                                                                                SizedBox(
                                                                                  width: media.width * 0.02,
                                                                                ),
                                                                                Expanded(
                                                                                  child: MyText(
                                                                                    text: driverReq['drop_address'],
                                                                                    // maxLines: 1,
                                                                                    size: media.width * twelve,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        )
                                                                            : Container(),
                                                                        SizedBox(
                                                                          height: media.width * 0.06,
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Button(
                                                                                color: const Color(0xFFFF0000).withValues(alpha: 0.2),
                                                                                width: media.width * 0.38,
                                                                                borderRadius: 30000.0,
                                                                                textcolor: const Color(0XFFFF0000),
                                                                                onTap: () async {
                                                                                  setState(() {
                                                                                    _isLoading = true;
                                                                                  });
                                                                                  //reject request
                                                                                  await requestReject();
                                                                                  setState(() {
                                                                                    _isLoading = false;
                                                                                  });
                                                                                  await Future.delayed(Duration(milliseconds: 500));
                                                                                  navigate(context);
                                                                                },
                                                                                text: languages[choosenLanguage]['text_decline']),
                                                                            Button(
                                                                              onTap: () async {
                                                                                setState(() {
                                                                                  _isLoading = true;
                                                                                });
                                                                                await Future.delayed(Duration(seconds: 2));
                                                                                if (duration != 0) {
                                                                                  await requestAccept();
                                                                                  setState(() {
                                                                                    _isLoading = false;
                                                                                  });
                                                                                }
                                                                                setState(() {
                                                                                  _isLoading = false;
                                                                                });
                                                                              },
                                                                              borderRadius: 30000.0,
                                                                              text: languages[choosenLanguage]['text_accept'],
                                                                              width: media.width * 0.38,
                                                                            )
                                                                          ],
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  // Positioned(
                                                                  //   child: (duration != 0)
                                                                  //       ? AnimatedContainer(
                                                                  //           duration: const Duration(milliseconds: 100),
                                                                  //           height: 10,
                                                                  //           width: (media.width * 0.9 / double.parse(userDetails['trip_accept_reject_duration_for_driver'].toString())) * (double.parse(userDetails['trip_accept_reject_duration_for_driver'].toString()) - duration),
                                                                  //           decoration: BoxDecoration(
                                                                  //               color: buttonColor,
                                                                  //               borderRadius: (languageDirection == 'ltr')
                                                                  //                   ? BorderRadius.only(
                                                                  //                       topLeft: const Radius.circular(100),
                                                                  //                       topRight: (duration <= 2.0) ? const Radius.circular(100) : const Radius.circular(0),
                                                                  //                     )
                                                                  //                   : BorderRadius.only(
                                                                  //                       topRight: const Radius.circular(100),
                                                                  //                       topLeft: (duration <= 2.0) ? const Radius.circular(100) : const Radius.circular(0),
                                                                  //                     )),
                                                                  //         )
                                                                  //       : Builder(builder: (context) {
                                                                  //           return SizedBox();
                                                                  //         }),
                                                                  // ),
                                                                  Positioned(
                                                                    top: -Responsive.height(3, context),
                                                                    child: (duration != 0)
                                                                        ? Container(
                                                                        clipBehavior: Clip.antiAlias,
                                                                        height: media.width * 0.12,
                                                                        width: media.width * 0.37,
                                                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(media.width), color: darkModeSecContainer),
                                                                        alignment: Alignment.centerLeft,
                                                                        child: SizedBox(
                                                                          height: media.width * 0.12,
                                                                          width: (media.width * 0.37),
                                                                          child: Stack(
                                                                            alignment: Alignment.centerLeft,
                                                                            children: [
                                                                              AnimatedContainer(
                                                                                duration: const Duration(milliseconds: 100),
                                                                                height: media.width * 0.12,
                                                                                width: (media.width * 0.37 * (duration / double.parse(userDetails['trip_accept_reject_duration_for_driver']))),
                                                                                decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(media.width), bottomLeft: Radius.circular(media.width)), color: buttonColor),
                                                                              ),
                                                                              Container(
                                                                                  alignment: Alignment.center,
                                                                                  height: media.width * 0.12,
                                                                                  width: (media.width * 0.37),
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      Icon(
                                                                                        Icons.access_time_filled,
                                                                                        color: white,
                                                                                        size: 20,
                                                                                      ),
                                                                                      SizedBox(
                                                                                        width: 6,
                                                                                      ),
                                                                                      Text(
                                                                                        '${Duration(seconds: duration.toInt()).toString().substring(3, 7)} ${languages[choosenLanguage]['text_sec']}',
                                                                                        style: GoogleFonts.inter(fontSize: 17, color: white),
                                                                                      ),
                                                                                    ],
                                                                                  ))
                                                                            ],
                                                                          ),
                                                                        ))
                                                                        : SizedBox(),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ))
                                                      // ;
                                                      // }),
                                                    ],
                                                  )
                                                      : (driverReq['accepted_at'] !=
                                                      null)
                                                      ? Builder(builder:
                                                      (context) {
                                                    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
                                                      await Future.delayed(Duration(milliseconds: 500));
                                                      setState(() {
                                                        polyline.clear();
                                                      });
                                                    });
                                                    return SizedBox(
                                                      width: media.width * 0.9,
                                                      height: media.width * 0.7,
                                                    );
                                                  })
                                                      : Builder(builder:
                                                      (context) {
                                                    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
                                                      await Future.delayed(Duration(milliseconds: 500));
                                                      setState(() {
                                                        polyline.clear();
                                                      });
                                                    });
                                                    return SizedBox(width: media.width * 0.9);
                                                  })
                                                      : Builder(
                                                      builder:
                                                          (context) {
                                                        SchedulerBinding
                                                            .instance
                                                            .addPostFrameCallback((timeStamp) async {
                                                          await Future.delayed(
                                                              Duration(milliseconds: 500));
                                                          setState(
                                                                  () {
                                                                polyline.clear();
                                                              });
                                                        });

                                                        return SizedBox();
                                                      })
                                                  // :Builder(
                                                  //     builder:
                                                  //         (context) {
                                                  //     SchedulerBinding
                                                  //         .instance
                                                  //         .addPostFrameCallback((timeStamp) async {
                                                  //       await Future.delayed(
                                                  //           Duration(milliseconds: 500));
                                                  //       setState(
                                                  //           () {
                                                  //         sourceToDestPolylines =
                                                  //             {};
                                                  //         polyline =
                                                  //             {};
                                                  //         destinationLocation =
                                                  //             null;
                                                  //         destinationMarkerList =
                                                  //             [];
                                                  //       });
                                                  //     });

                                                  //     return Container();
                                                  //   }),
                                                ],
                                              )),

                                          //on ride bottom sheet
                                          (driverReq['accepted_at'] !=
                                              null)
                                              ? Positioned(
                                              bottom: 0,
                                              child:
                                              GestureDetector(
                                                onVerticalDragStart:
                                                    (v) {
                                                  start = v
                                                      .globalPosition
                                                      .dy;
                                                  gesture
                                                      .clear();
                                                },
                                                onVerticalDragUpdate:
                                                    (v) {
                                                  gesture.add(v
                                                      .globalPosition
                                                      .dy);
                                                },
                                                onVerticalDragEnd:
                                                    (v) {
                                                  if (gesture
                                                      .isNotEmpty &&
                                                      start >
                                                          gesture[gesture.length -
                                                              1] &&
                                                      _bottom ==
                                                          0) {
                                                    setState(
                                                            () {
                                                          _bottom =
                                                          1;
                                                        });
                                                  } else if (gesture
                                                      .isNotEmpty &&
                                                      start <
                                                          gesture[gesture.length -
                                                              1] &&
                                                      _bottom ==
                                                          1) {
                                                    setState(
                                                            () {
                                                          _bottom =
                                                          0;
                                                        });
                                                  }
                                                },
                                                child: Stack(
                                                  clipBehavior:
                                                  Clip.none,
                                                  alignment:
                                                  Alignment
                                                      .topCenter,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        SizedBox(
                                                          height:
                                                          media.width * 0.1,
                                                        ),
                                                        AnimatedContainer(
                                                          duration:
                                                          const Duration(milliseconds: 200),
                                                          // margin: EdgeInsets.all(
                                                          //     media.width *
                                                          //         0.03),
                                                          padding: EdgeInsets.fromLTRB(
                                                              media.width * 0.05,
                                                              Responsive.height(1, context),
                                                              media.width * 0.05,
                                                              media.width * 0.05),
                                                          width:
                                                          media.width,

                                                          decoration:
                                                          BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)), color: page),
                                                          child:
                                                          Column(
                                                            children: [
                                                              Container(
                                                                width: Responsive.width(25, context),
                                                                height: 5,
                                                                decoration: BoxDecoration(color: white.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(3000)),
                                                              ),
                                                              SizedBox(
                                                                height: media.width * 0.05,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      // Image.asset(
                                                                      //     (driverReq['is_driver_arrived'] == 0)
                                                                      //         ? 'assets/images/offline.png'
                                                                      //         : (driverReq['is_trip_start'] == 1)
                                                                      //             ? 'assets/images/ontheway_icon.png'
                                                                      //             : 'assets/images/startonthe.png',
                                                                      //     width: media.width * 0.07,
                                                                      //     color: textColor),
                                                                      GestureDetector(
                                                                          onTap: () {
                                                                            //                                                                                     print(bearerToken[0].token);
                                                                            // print(bearerToken[0].token.toString().substring(200));
                                                                            debugPrint('driverReq id: ${driverReq['id']}');
                                                                          },
                                                                          child: Image.asset('assets/images/offline.png', width: media.width * 0.065, color: textColor)),
                                                                      SizedBox(
                                                                        width: media.width * 0.02,
                                                                      ),
                                                                      MyText(
                                                                        text: (driverReq['is_driver_arrived'] == 0)
                                                                            ? languages[choosenLanguage]['text_in_the_way']
                                                                            : (driverReq['is_trip_start'] == 1)
                                                                            ? languages[choosenLanguage]['text_onride']
                                                                            : languages[choosenLanguage]['text_waiting_rider'],
                                                                        size: media.width * sixteen,
                                                                        fontweight: FontWeight.w500,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: Responsive.height(3, context),
                                                                  ),
                                                                  // (driverReq['is_driver_arrived'] == 1 && waitingTime != null)
                                                                  //     ? (waitingTime / 60 >= 1)
                                                                  //         ? Container(
                                                                  //             padding: EdgeInsets.all(media.width * 0.01),
                                                                  //             decoration: BoxDecoration(color: darkModeSecContainer, borderRadius: BorderRadius.circular(media.width * 0.02), border: Border.all(color: darkModeBorderColor)),
                                                                  //             child: (driverReq['accepted_at'] == null && driverReq['show_request_eta_amount'] == true && driverReq['request_eta_amount'] != null)
                                                                  //                 ? MyText(
                                                                  //                     text: userDetails['currency_symbol'] + (driverReq['is_bid_ride'] == 1) ? driverReq['accepted_ride_fare'].toString() : driverReq['request_eta_amount'].toString(),
                                                                  //                     size: media.width * fourteen,
                                                                  //                     color: textColor,
                                                                  //                   )
                                                                  //                 : (driverReq['is_driver_arrived'] == 1 && waitingTime != null)
                                                                  //                     ? (waitingTime / 60 >= 1)
                                                                  //                         ? MyText(
                                                                  //                             text: '${(waitingTime / 60).toInt()} mins',
                                                                  //                             size: media.width * fourteen,
                                                                  //                             color: textColor,
                                                                  //                           )
                                                                  //                         : Container()
                                                                  //                     : Container(),
                                                                  //           )
                                                                  //         : Container()
                                                                  //     : Container(),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: media.width * 0.025,
                                                              ),
                                                              (driverReq['is_trip_start'] == 1 && _bottom == 0 && driverReq['drop_address'] != null)
                                                                  ? Row(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                children: [
                                                                  Container(
                                                                    height: media.width * 0.06,
                                                                    width: media.width * 0.06,
                                                                    alignment: Alignment.center,
                                                                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red.withValues(alpha: 0.1)),
                                                                    child: Icon(
                                                                      Icons.location_on_outlined,
                                                                      color: const Color(0xFFFF0000),
                                                                      size: media.width * eighteen,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: media.width * 0.05,
                                                                  ),
                                                                  Expanded(
                                                                    child: MyText(
                                                                      text: driverReq['drop_address'],
                                                                      // maxLines: 1,
                                                                      size: media.width * twelve,
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                                  : Row(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                children: [
                                                                  Container(
                                                                    height: media.width * 0.05,
                                                                    width: media.width * 0.05,
                                                                    alignment: Alignment.center,
                                                                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: buttonColor)),
                                                                    child: Container(
                                                                      height: media.width * 0.025,
                                                                      width: media.width * 0.025,
                                                                      decoration: BoxDecoration(shape: BoxShape.circle, color: buttonColor),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: media.width * 0.02,
                                                                  ),
                                                                  Expanded(
                                                                    child: MyText(
                                                                      text: driverReq['pick_address'],
                                                                      size: media.width * twelve,
                                                                      // maxLines: 1,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              // SizedBox(
                                                              //   height: media.width * 0.03,
                                                              // ),
                                                              (driverReq['drop_address'] != null && _bottom == 1)
                                                                  ? Column(
                                                                children: [
                                                                  (tripStops.isNotEmpty)
                                                                      ? Column(
                                                                    children: tripStops
                                                                        .asMap()
                                                                        .map((i, value) {
                                                                      return MapEntry(
                                                                          i,
                                                                          (i < tripStops.length - 1)
                                                                              ? Container(
                                                                            padding: EdgeInsets.only(top: media.width * 0.02),
                                                                            child: Column(
                                                                              children: [
                                                                                Row(
                                                                                  children: [
                                                                                    SizedBox(
                                                                                      width: media.width * 0.8,
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                        children: [
                                                                                          Container(
                                                                                            height: media.width * 0.06,
                                                                                            width: media.width * 0.06,
                                                                                            alignment: Alignment.center,
                                                                                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red.withValues(alpha: 0.1)),
                                                                                            child: MyText(
                                                                                              text: (i + 1).toString(),
                                                                                              // maxLines: 1,
                                                                                              color: const Color(0xFFFF0000),
                                                                                              fontweight: FontWeight.w600,
                                                                                              size: media.width * twelve,
                                                                                            ),
                                                                                          ),
                                                                                          SizedBox(
                                                                                            width: media.width * 0.05,
                                                                                          ),
                                                                                          Expanded(
                                                                                            child: MyText(
                                                                                              text: tripStops[i]['address'],
                                                                                              // maxLines: 1,
                                                                                              size: media.width * twelve,
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          )
                                                                              : Container());
                                                                    })
                                                                        .values
                                                                        .toList(),
                                                                  )
                                                                      : Container(),
                                                                  SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                    children: [
                                                                      Icon(
                                                                        Icons.location_on_outlined,
                                                                        color: white,
                                                                        size: media.width * eighteen,
                                                                      ),
                                                                      SizedBox(
                                                                        width: media.width * 0.02,
                                                                      ),
                                                                      Expanded(
                                                                        child: MyText(
                                                                          text: driverReq['drop_address'],
                                                                          size: media.width * twelve,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              )
                                                                  : Container(),
                                                              SizedBox(
                                                                height: media.width * 0.03,
                                                              ),

                                                              Column(children: [
                                                                Container(
                                                                  decoration: BoxDecoration(
                                                                    color: page,
                                                                  ),
                                                                  child: (driverReq['is_trip_start'] == 1)
                                                                      ? Row(
                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                    children: [
                                                                      Container(
                                                                        height: media.width * 0.15,
                                                                        width: media.width * 0.15,
                                                                        decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: NetworkImage(driverReq['userDetail']['data']['profile_picture']), fit: BoxFit.cover)),
                                                                      ),
                                                                      SizedBox(
                                                                        width: 10,
                                                                      ),
                                                                      Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          MyText(
                                                                            text: driverReq['userDetail']['data']['name'],
                                                                            size: media.width * sixteen,
                                                                            fontweight: FontWeight.w600,
                                                                          ),
                                                                          SizedBox(
                                                                            height: 5,
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              Icon(
                                                                                Icons.star,
                                                                                color: Color(0xffF79E1B),
                                                                                size: media.width * thirteen,
                                                                              ),
                                                                              SizedBox(
                                                                                width: 5,
                                                                              ),
                                                                              MyText(
                                                                                text: driverReq['userDetail']['data']['rating'].toString(),
                                                                                size: media.width * twelve,
                                                                              ),
                                                                              SizedBox(
                                                                                width: media.width * 0.15,
                                                                              ),
                                                                              (driverReq['drop_address'] == null && driverReq['is_rental'] == false)
                                                                                  ? Container()
                                                                                  : Row(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Row(
                                                                                    children: [
                                                                                      //payment image
                                                                                      (driverReq['payment_opt'].toString() == '1')
                                                                                          ? Image.asset(
                                                                                        'assets/images/cash_image.png',
                                                                                        fit: BoxFit.contain,
                                                                                        width: media.width * twenty,
                                                                                        height: media.width * seventeen,
                                                                                      )
                                                                                          : (driverReq['payment_opt'].toString() == '2')
                                                                                          ? Image.asset(
                                                                                        'assets/images/wallet.png',
                                                                                        fit: BoxFit.contain,
                                                                                        width: media.width * twenty,
                                                                                        height: media.width * seventeen,
                                                                                      )
                                                                                          : (driverReq['payment_opt'].toString() == '0')
                                                                                          ? Image.asset(
                                                                                        'assets/images/card.png',
                                                                                        fit: BoxFit.contain,
                                                                                        width: media.width * twenty,
                                                                                        height: media.width * seventeen,
                                                                                      )
                                                                                          : Container(),
                                                                                      SizedBox(
                                                                                        width: 5,
                                                                                      ),

                                                                                      MyText(
                                                                                        text: driverReq['payment_type_string'].toString(),
                                                                                        size: media.width * sixteen,
                                                                                      ),
                                                                                      SizedBox(
                                                                                        width: 5,
                                                                                      ),

                                                                                      (driverReq['show_request_eta_amount'] == true && driverReq['request_eta_amount'] != null)
                                                                                          ? Row(
                                                                                        children: [
                                                                                          MyText(
                                                                                            text: driverReq['request_eta_amount'].toStringAsFixed(0),
                                                                                            size: media.width * fourteen,
                                                                                            fontweight: FontWeight.w700,
                                                                                          ),
                                                                                          SizedBox(
                                                                                            width: 5,
                                                                                          ),
                                                                                          MyText(
                                                                                            text: userDetails['currency_symbol'],
                                                                                            size: media.width * fourteen,
                                                                                          )
                                                                                        ],
                                                                                      )
                                                                                          : Container()
                                                                                    ],
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  )
                                                                      : Row(
                                                                    children: [
                                                                      Container(
                                                                        height: media.width * 0.15,
                                                                        width: media.width * 0.15,
                                                                        decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: NetworkImage(driverReq['userDetail']['data']['profile_picture']), fit: BoxFit.cover)),
                                                                      ),
                                                                      SizedBox(width: media.width * 0.03),
                                                                      (driverReq['is_trip_start'] == 1)
                                                                          ? Row(
                                                                        children: [
                                                                          SizedBox(
                                                                            width: media.width * 0.3,
                                                                            child: MyText(
                                                                              text: driverReq['userDetail']['data']['name'],
                                                                              size: media.width * eighteen,
                                                                              color: textColor,
                                                                              maxLines: 1,
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width: media.width * 0.09,
                                                                          ),
                                                                          Row(
                                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                                            children: [
                                                                              SizedBox(
                                                                                width: media.width * 0.06,
                                                                                child: (driverReq['payment_opt'].toString() == '1')
                                                                                    ? Image.asset(
                                                                                  'assets/images/cash.png',
                                                                                  fit: BoxFit.contain,
                                                                                )
                                                                                    : (driverReq['payment_opt'].toString() == '2')
                                                                                    ? Image.asset(
                                                                                  'assets/images/wallet.png',
                                                                                  fit: BoxFit.contain,
                                                                                )
                                                                                    : (driverReq['payment_opt'].toString() == '0')
                                                                                    ? Image.asset(
                                                                                  'assets/images/card.png',
                                                                                  fit: BoxFit.contain,
                                                                                )
                                                                                    : Container(),
                                                                              ),
                                                                              SizedBox(
                                                                                width: media.width * 0.03,
                                                                              ),
                                                                              MyText(text: driverReq['payment_type_string'].toString(), size: media.width * sixteen, color: textColor),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      )
                                                                          : SizedBox(
                                                                        width: media.width * 0.3,
                                                                        child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                SizedBox(
                                                                                  child: MyText(
                                                                                    text: getFirstName(driverReq['userDetail']['data']['name']),
                                                                                    size: media.width * sixteen,
                                                                                    color: textColor,
                                                                                    fontweight: FontWeight.w500,
                                                                                    maxLines: 1,
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  width: 10,
                                                                                ),
                                                                                Row(
                                                                                  children: [
                                                                                    Icon(
                                                                                      Icons.star,
                                                                                      color: Color(0xffF79E1B),
                                                                                      size: 11,
                                                                                    ),
                                                                                    Text(
                                                                                      driverReq['userDetail']['data']['rating'].toString(),
                                                                                      style: GoogleFonts.inter(fontSize: media.width * eleven, color: textColor),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Row(
                                                                              children: [
                                                                                // SizedBox(
                                                                                //   width: media.width * 0.06,
                                                                                //   child: (driverReq['payment_opt'].toString() == '1')
                                                                                //       ? Image.asset(
                                                                                //           'assets/images/cash.png',
                                                                                //           fit: BoxFit.contain,
                                                                                //         )
                                                                                //       : (driverReq['payment_opt'].toString() == '2')
                                                                                //           ? Image.asset(
                                                                                //               'assets/images/wallet.png',
                                                                                //               fit: BoxFit.contain,
                                                                                //             )
                                                                                //           : (driverReq['payment_opt'].toString() == '0')
                                                                                //               ? Image.asset(
                                                                                //                   'assets/images/card.png',
                                                                                //                   fit: BoxFit.contain,
                                                                                //                 )
                                                                                //               : Container(),
                                                                                // ),

                                                                                MyText(
                                                                                  text: driverReq['payment_type_string'].toString(),
                                                                                  size: media.width * twelve,
                                                                                  color: textColor,
                                                                                  fontweight: FontWeight.w500,
                                                                                ),
                                                                                SizedBox(
                                                                                  width: 5,
                                                                                ),
                                                                                (driverReq['show_request_eta_amount'] == true && driverReq['request_eta_amount'] != null)
                                                                                    ? Row(
                                                                                  children: [
                                                                                    MyText(
                                                                                      text: driverReq['request_eta_amount'].toStringAsFixed(0),
                                                                                      size: media.width * twelve,
                                                                                      color: textColor,
                                                                                      fontweight: FontWeight.w500,
                                                                                    ),
                                                                                    SizedBox(
                                                                                      width: 5,
                                                                                    ),
                                                                                    MyText(
                                                                                      text: userDetails['currency_symbol'],
                                                                                      size: media.width * twelve,
                                                                                      color: textColor,
                                                                                      fontweight: FontWeight.w500,
                                                                                    )
                                                                                  ],
                                                                                )
                                                                                    : Container()
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      (driverReq['is_trip_start'] == 1)
                                                                          ? Container()
                                                                          : Expanded(
                                                                        child: Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                          children: [
                                                                            SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            InkWell(
                                                                              onTap: () async {
                                                                                // makingPhoneCall(driverReq['userDetail']['data']['mobile']);
                                                                                if (driverReq['id'] != null) {
                                                                                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                                                    FirebaseDatabase.instance.ref('requests/${driverReq['id']}').update({callingStatus: readyForCall});
                                                                                    return const CallScreen();
                                                                                  }));
                                                                                }
                                                                              },
                                                                              child: Container(
                                                                                alignment: Alignment.center,
                                                                                child: Image.asset('assets/images/callride.png', width: media.width * 0.065, color: white),
                                                                              ),
                                                                            ),
                                                                            (driverReq['if_dispatch'] == true)
                                                                                ? Container()
                                                                                : InkWell(
                                                                              onTap: () {
                                                                                Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatPage()));
                                                                              },
                                                                              child: Column(
                                                                                children: [
                                                                                  Row(
                                                                                    children: [
                                                                                      Stack(
                                                                                        alignment: Alignment.center,
                                                                                        children: [
                                                                                          // Container(
                                                                                          //   alignment: Alignment.center,
                                                                                          //   height: media.width * 0.096,
                                                                                          //   width: media.width * 0.096,
                                                                                          //   decoration: BoxDecoration(border: Border.all(color: const Color(0XFFf3f3f3), width: 1.5)),
                                                                                          //   child: Image.asset(
                                                                                          //     'assets/images/ridemessage.png',
                                                                                          //     width: media.width * 0.05,
                                                                                          //   ),
                                                                                          // ),
                                                                                          Icon(
                                                                                            Icons.chat_bubble,
                                                                                            color: white,
                                                                                          ),
                                                                                          (chatList.where((element) => element['from_type'] == 1 && element['seen'] == 0).isNotEmpty)
                                                                                              ? MyText(
                                                                                            text: chatList.where((element) => element['from_type'] == 1 && element['seen'] == 0).length.toString(),
                                                                                            size: media.width * twelve,
                                                                                            color: page,
                                                                                          )
                                                                                              : Container()
                                                                                        ],
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: media.width * 0.03,
                                                                ),
                                                                (driverReq['is_trip_start'] == 1)
                                                                    ? Container()
                                                                    : Container(
                                                                  width: Responsive.width(40, context),
                                                                  padding: EdgeInsets.all(Responsive.width(2, context)),
                                                                  decoration: BoxDecoration(color: darkModeSecContainer, border: Border.all(color: darkModeBorderColor), borderRadius: BorderRadius.circular(3000.0)),
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: [
                                                                      InkWell(
                                                                        onTap: () async {
                                                                          setState(() {
                                                                            _isLoading = true;
                                                                          });
                                                                          var val = await cancelReason((driverReq['is_driver_arrived'] == 0) ? 'before' : 'after');
                                                                          if (val == true) {
                                                                            setState(() {
                                                                              cancelRequest = true;
                                                                              _cancelReason = '';
                                                                              _cancellingError = '';
                                                                            });
                                                                          }
                                                                          setState(() {
                                                                            _isLoading = false;
                                                                          });
                                                                        },
                                                                        child: Row(
                                                                          mainAxisSize: MainAxisSize.min,
                                                                          children: [
                                                                            Image.asset(
                                                                              'assets/images/cancelride.png',
                                                                              height: media.width * 0.064,
                                                                              width: media.width * 0.064,
                                                                              fit: BoxFit.contain,
                                                                              color: verifyDeclined,
                                                                            ),
                                                                            Flexible(
                                                                              child: MyText(
                                                                                text: languages[choosenLanguage]['text_cancel_booking'],
                                                                                size: media.width * twelve,
                                                                                color: verifyDeclined,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                maxLines: 1,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ]),
                                                              SizedBox(
                                                                height: media.width * 0.04,
                                                              ),
                                                              Button(
                                                                  borderRadius: 3000.0,
                                                                  onTap: () async {
                                                                    maptype = false;
                                                                    setState(() {
                                                                      _isLoading = true;
                                                                    });
                                                                    if ((driverReq['is_driver_arrived'] == 0)) {
                                                                      var val = await driverArrived();
                                                                      if (val == 'logout') {
                                                                        navigateLogout();
                                                                      }
                                                                    } else if (driverReq['is_driver_arrived'] == 1 && driverReq['is_trip_start'] == 0) {
                                                                      if (driverReq['show_otp_feature'] == true) {
                                                                        setState(() {
                                                                          getStartOtp = true;
                                                                        });
                                                                      } else {
                                                                        var val = await tripStartDispatcher();
                                                                        if (val == 'logout') {
                                                                          navigateLogout();
                                                                        }
                                                                      }
                                                                    } else {
                                                                      driverOtp = '';
                                                                      var val = await endTrip();
                                                                      if (val == 'logout') {
                                                                        navigateLogout();
                                                                      }
                                                                    }

                                                                    _isLoading = false;
                                                                  },
                                                                  text: (driverReq['is_driver_arrived'] == 0)
                                                                      ? languages[choosenLanguage]['text_arrived']
                                                                      : (driverReq['is_driver_arrived'] == 1 && driverReq['is_trip_start'] == 0)
                                                                      ? languages[choosenLanguage]['text_startride']
                                                                      : languages[choosenLanguage]['text_endtrip'])
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Positioned(
                                                        top: media.width *
                                                            0.03,
                                                        child:
                                                        Container(
                                                          width:
                                                          Responsive.width(43, context),
                                                          height:
                                                          Responsive.height(6.5, context),
                                                          decoration:
                                                          BoxDecoration(color: buttonColor, borderRadius: BorderRadius.circular(3000.0)),
                                                          child:
                                                          InkWell(
                                                            onTap: () async {
                                                              if (userDetails['enable_vase_map'] == '1') {
                                                                if (maptype == false) {
                                                                  if (driverReq['is_trip_start'] == 0) {
                                                                    setState(() {
                                                                      maptype = true;
                                                                    });
                                                                  } else if (tripStops.isNotEmpty) {
                                                                    setState(() {
                                                                      _tripOpenMap = true;
                                                                    });
                                                                  } else {
                                                                    setState(() {
                                                                      maptype = true;
                                                                    });
                                                                  }
                                                                } else {
                                                                  setState(() {
                                                                    maptype = false;
                                                                  });
                                                                }
                                                              } else {
                                                                if (driverReq['is_trip_start'] == 0) {
                                                                  launchGoogleMapToPickup(driverReq['pick_lat'], driverReq['pick_lng']);
                                                                }
                                                                if (tripStops.isEmpty && driverReq['is_trip_start'] != 0) {
                                                                  launchGoogleMapFromPickupToDropoff(driverReq['pick_lat'], driverReq['pick_lng'], driverReq['drop_lat'], driverReq['drop_lng']);
                                                                }
                                                              }
                                                            },
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Container(
                                                                    height: media.width * 0.07,
                                                                    width: media.width * 0.07,
                                                                    decoration: BoxDecoration(color: white, shape: BoxShape.circle),
                                                                    alignment: Alignment.center,
                                                                    child: Image.asset(
                                                                      'assets/images/locationFind.png',
                                                                      color: buttonColor,
                                                                      width: media.width * 0.035,
                                                                    )),
                                                                SizedBox(
                                                                  width: Responsive.width(4, context),
                                                                ),
                                                                MyText(
                                                                  text: languages[choosenLanguage]['text_navigate'],
                                                                  size: media.width * sixteen,
                                                                  fontweight: FontWeight.w500,
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        )),
                                                  ],
                                                ),
                                              ))
                                              : Container(),
                                          maptype
                                              ? Positioned(
                                            bottom: 0,
                                            child:
                                            Container(
                                              padding: EdgeInsets.fromLTRB(
                                                  media.width *
                                                      0.1,
                                                  media.width *
                                                      0.07,
                                                  media.width *
                                                      0.1,
                                                  0),
                                              width: media
                                                  .width,
                                              height: media
                                                  .height *
                                                  0.53,
                                              decoration: BoxDecoration(
                                                  color:
                                                  page,
                                                  borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(30))),
                                              child: Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .start,
                                                children: [
                                                  Container(
                                                      height: media.width *
                                                          0.07,
                                                      width: media.width *
                                                          0.07,
                                                      decoration: BoxDecoration(
                                                          color:
                                                          white,
                                                          shape: BoxShape
                                                              .circle),
                                                      alignment: Alignment
                                                          .center,
                                                      child:
                                                      Image.asset(
                                                        'assets/images/locationFind.png',
                                                        color:
                                                        black,
                                                        width:
                                                        media.width * 0.035,
                                                      )),
                                                  SizedBox(
                                                    height: Responsive.height(
                                                        2.2,
                                                        context),
                                                  ),
                                                  MyText(
                                                      text: languages[choosenLanguage]
                                                      [
                                                      'text_navigate'],
                                                      size: media.width *
                                                          twentysix,
                                                      fontweight:
                                                      FontWeight.w500),
                                                  SizedBox(
                                                    height: Responsive.height(
                                                        2.2,
                                                        context),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: MyText(
                                                            text: languages[choosenLanguage]['text_navigate_description'],
                                                            size: media.width * fourteen,
                                                            fontweight: FontWeight.w400),
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: Responsive.height(
                                                        4.5,
                                                        context),
                                                  ),
                                                  GestureDetector(
                                                    onTap:
                                                        () {
                                                      if (driverReq['is_trip_start'] ==
                                                          0) {
                                                        launchGoogleMapToPickup(driverReq['pick_lat'],
                                                            driverReq['pick_lng']);
                                                      }
                                                      if (tripStops.isEmpty &&
                                                          driverReq['is_trip_start'] != 0) {
                                                        launchGoogleMapFromPickupToDropoff(
                                                            driverReq['pick_lat'],
                                                            driverReq['pick_lng'],
                                                            driverReq['drop_lat'],
                                                            driverReq['drop_lng']);
                                                      }
                                                    },
                                                    child:
                                                    Stack(
                                                      alignment:
                                                      Alignment.centerRight,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            Container(
                                                              width: media.width * 0.12,
                                                              height: media.width * 0.12,
                                                              decoration: BoxDecoration(shape: BoxShape.circle, color: darkModeSecContainer),
                                                              child: Center(
                                                                child: Image.asset(
                                                                  'assets/images/googlemaps.png',
                                                                  width: media.width * 0.045,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: media.width * 0.08,
                                                            ),
                                                            MyText(text: languages[choosenLanguage]['text_googlemaps'], size: media.width * eighteen, fontweight: FontWeight.w500),
                                                          ],
                                                        ),
                                                        Icon(
                                                          Icons.arrow_forward_ios_rounded,
                                                          color: white,
                                                          size: media.width * 0.05,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: Responsive.height(
                                                        2.5,
                                                        context),
                                                  ),
                                                  GestureDetector(
                                                    onTap:
                                                        () {
                                                      if (driverReq['is_trip_start'] ==
                                                          0) {
                                                        launchWazeMapToPickup(driverReq['pick_lat'],
                                                            driverReq['pick_lng']);
                                                      }
                                                      if (tripStops.isEmpty &&
                                                          driverReq['is_trip_start'] != 0) {
                                                        launchWazeMapFromPickupToDropoff(
                                                            driverReq['pick_lat'],
                                                            driverReq['pick_lng'],
                                                            driverReq['drop_lat'],
                                                            driverReq['drop_lng']);
                                                      }
                                                    },
                                                    child:
                                                    Stack(
                                                      alignment:
                                                      Alignment.centerRight,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            Container(
                                                              width: media.width * 0.12,
                                                              height: media.width * 0.12,
                                                              decoration: BoxDecoration(shape: BoxShape.circle, color: darkModeSecContainer),
                                                              child: Center(
                                                                child: Image.asset(
                                                                  'assets/images/waze.png',
                                                                  width: media.width * 0.045,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: media.width * 0.08,
                                                            ),
                                                            MyText(text: languages[choosenLanguage]['text_wazelemaps'], size: media.width * eighteen, fontweight: FontWeight.w500),
                                                          ],
                                                        ),
                                                        Icon(
                                                          Icons.arrow_forward_ios_rounded,
                                                          color: white,
                                                          size: media.width * 0.05,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: Responsive.height(
                                                        6,
                                                        context),
                                                  ),
                                                  Button(
                                                      borderRadius:
                                                      3000.0,
                                                      fontweight: FontWeight
                                                          .w500,
                                                      fontSize: media.width *
                                                          sixteen,
                                                      onTap:
                                                          () {
                                                        setState(() {
                                                          maptype = false;
                                                        });
                                                      },
                                                      text: languages[choosenLanguage]
                                                      [
                                                      'text_cancel']),
                                                  ButtonBottomSpace()
                                                ],
                                              ),
                                            ),
                                          )
                                              : SizedBox(),

                                          (driverReq.isEmpty &&
                                              userDetails[
                                              'role'] !=
                                                  'owner' &&
                                              userDetails[
                                              'active'] ==
                                                  true &&
                                              (userDetails['show_instant_ride'] ==
                                                  true ||
                                                  userDetails[
                                                  'show_instant_ride_feature_on_mobile_app'] ==
                                                      '1'))
                                              ? Positioned(
                                              bottom: media
                                                  .width *
                                                  0.05,
                                              left: media
                                                  .width *
                                                  0.05,
                                              right: media
                                                  .width *
                                                  0.05,
                                              child: Row(
                                                children: [
                                                  Button(
                                                      color:
                                                      theme,
                                                      onTap:
                                                          () async {
                                                        addressList
                                                            .clear();
                                                        var val = await geoCoding(
                                                            center.latitude,
                                                            center.longitude);
                                                        setState(
                                                                () {
                                                              if (addressList.where((element) => element.id == 'pickup').isNotEmpty) {
                                                                var add = addressList.firstWhere((element) => element.id == 'pickup');
                                                                add.address = val;
                                                                add.latlng = LatLng(center.latitude, center.longitude);
                                                              } else {
                                                                addressList.add(AddressList(id: 'pickup', address: val, latlng: LatLng(center.latitude, center.longitude)));
                                                              }
                                                            });
                                                        if (addressList
                                                            .isNotEmpty) {
                                                          // ignore: use_build_context_synchronously
                                                          Navigator.push(context,
                                                              MaterialPageRoute(builder: (context) => const DropLocation()));
                                                        }
                                                      },
                                                      text: languages[choosenLanguage]
                                                      [
                                                      'text_instant_ride'])
                                                ],
                                              ))
                                              : Container(),

                                          //user cancelled request popup
                                          (_reqCancelled == true)
                                              ? Positioned(
                                              bottom: media
                                                  .height *
                                                  0.5,
                                              child:
                                              Container(
                                                padding: EdgeInsets
                                                    .all(media
                                                    .width *
                                                    0.05),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.circular(10),
                                                    color: page,
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color: Colors.black.withValues(alpha:
                                                          0.2),
                                                          blurRadius:
                                                          2,
                                                          spreadRadius:
                                                          2)
                                                    ]),
                                                child: Text(languages[
                                                choosenLanguage]
                                                [
                                                'text_user_cancelled_request']),
                                              ))
                                              : Container(),
                                        ],
                                      )
                                          : Container(),
                                    ]),
                              ),
                              (_locationDenied == true)
                                  ? Positioned(
                                  child: Container(
                                    height: media.height * 1,
                                    width: media.width * 1,
                                    color:
                                    Colors.transparent.withValues(alpha: 0.6),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(
                                              left: media.width * 0.05,
                                              right: media.width * 0.03,
                                              bottom: media.width * 0.05),
                                          width: media.width * 0.9,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(12),
                                              color: page,
                                              boxShadow: [
                                                BoxShadow(
                                                    blurRadius: 2.0,
                                                    spreadRadius: 2.0,
                                                    color: Colors.black
                                                        .withValues(alpha: 0.2))
                                              ]),
                                          child: Column(
                                            children: [
                                              Align(
                                                alignment: Alignment.topRight,
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      _locationDenied = false;
                                                    });
                                                  },
                                                  child: Container(
                                                    height: media.width * 0.1,
                                                    width: media.width * 0.1,
                                                    decoration: BoxDecoration(
                                                        shape:
                                                        BoxShape.circle,
                                                        color: page),
                                                    child: Icon(
                                                      Icons.cancel,
                                                      color: white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              SizedBox(
                                                  width: media.width * 0.8,
                                                  child: MyText(
                                                    text: languages[
                                                    choosenLanguage][
                                                    'text_open_loc_settings'],
                                                    size:
                                                    media.width * sixteen,
                                                    fontweight:
                                                    FontWeight.w600,
                                                  )),
                                              SizedBox(
                                                  height: media.width * 0.05),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: ElevatedButton(
                                                        style: ButtonStyle(
                                                          backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(
                                                              buttonColor),
                                                          shape: MaterialStateProperty
                                                              .all<
                                                              RoundedRectangleBorder>(
                                                            RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  2000.0),
                                                            ),
                                                          ),
                                                          minimumSize: MaterialStateProperty
                                                              .all<Size>(Size(
                                                              media.width *
                                                                  0.3,
                                                              media.width *
                                                                  0.12)),
                                                        ),
                                                        onPressed: () async {
                                                          await perm
                                                              .openAppSettings();
                                                        },
                                                        child: MyText(
                                                          text: languages[
                                                          choosenLanguage]
                                                          [
                                                          'text_open_settings'],
                                                          size: media.width *
                                                              sixteen,
                                                          fontweight:
                                                          FontWeight.w600,
                                                        )),
                                                  ),
                                                  SizedBox(
                                                    width: 15,
                                                  ),
                                                  Expanded(
                                                    child: ElevatedButton(
                                                        style: ButtonStyle(
                                                          backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(
                                                              Color(
                                                                  0xff191B1A)),
                                                          shape: MaterialStateProperty
                                                              .all<
                                                              RoundedRectangleBorder>(
                                                            RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  3000.0),
                                                            ),
                                                          ),
                                                          minimumSize: MaterialStateProperty
                                                              .all<Size>(Size(
                                                              media.width *
                                                                  0.3,
                                                              media.width *
                                                                  0.12)),
                                                        ),
                                                        onPressed: () async {
                                                          setState(() {
                                                            _locationDenied =
                                                            false;
                                                            _isLoading = true;
                                                          });
                                                        },
                                                        child: MyText(
                                                          text: languages[
                                                          choosenLanguage]
                                                          ['text_done'],
                                                          color: Colors.white,
                                                          size: media.width *
                                                              sixteen,
                                                          fontweight:
                                                          FontWeight.w600,
                                                        )),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ))
                                  : Container(),

                              // (_locationDenied == true)
                              //     ? Visibility(
                              //         visible: false,
                              //         child: Positioned(
                              //             child: Container(
                              //           height: media.height * 1,
                              //           width: media.width * 1,
                              //           color:
                              //               Colors.transparent.withValues(alpha: 0.6),
                              //           child: Column(
                              //             mainAxisAlignment:
                              //                 MainAxisAlignment.center,
                              //             children: [
                              //               SizedBox(
                              //                 width: media.width * 0.9,
                              //                 child: Row(
                              //                   mainAxisAlignment:
                              //                       MainAxisAlignment.end,
                              //                   children: [
                              //                     InkWell(
                              //                       onTap: () {
                              //                         setState(() {
                              //                           _locationDenied = false;
                              //                         });
                              //                       },
                              //                       child: Container(
                              //                         height:
                              //                             media.height * 0.05,
                              //                         width:
                              //                             media.height * 0.05,
                              //                         decoration: BoxDecoration(
                              //                           color: page,
                              //                           shape: BoxShape.circle,
                              //                         ),
                              //                         child: Icon(Icons.cancel,
                              //                             color: buttonColor),
                              //                       ),
                              //                     ),
                              //                   ],
                              //                 ),
                              //               ),
                              //               SizedBox(
                              //                   height: media.width * 0.025),
                              //               Container(
                              //                 padding: EdgeInsets.all(
                              //                     media.width * 0.05),
                              //                 width: media.width * 0.9,
                              //                 decoration: BoxDecoration(
                              //                     borderRadius:
                              //                         BorderRadius.circular(12),
                              //                     color: page,
                              //                     boxShadow: [
                              //                       BoxShadow(
                              //                           blurRadius: 2.0,
                              //                           spreadRadius: 2.0,
                              //                           color: Colors.black
                              //                               .withValues(alpha: 0.2))
                              //                     ]),
                              //                 child: Column(
                              //                   children: [
                              //                     SizedBox(
                              //                         width: media.width * 0.8,
                              //                         child: Text(
                              //                           languages[
                              //                                   choosenLanguage]
                              //                               [
                              //                               'text_open_loc_settings'],
                              //                           style:
                              //                               GoogleFonts.inter(
                              //                                   fontSize: media
                              //                                           .width *
                              //                                       sixteen,
                              //                                   color:
                              //                                       textColor,
                              //                                   fontWeight:
                              //                                       FontWeight
                              //                                           .w600),
                              //                         )),
                              //                     SizedBox(
                              //                         height:
                              //                             media.width * 0.05),
                              //                     Row(
                              //                       mainAxisAlignment:
                              //                           MainAxisAlignment
                              //                               .spaceBetween,
                              //                       children: [
                              //                         InkWell(
                              //                             onTap: () async {
                              //                               await perm
                              //                                   .openAppSettings();
                              //                             },
                              //                             child: Text(
                              //                               languages[
                              //                                       choosenLanguage]
                              //                                   [
                              //                                   'text_open_settings'],
                              //                               style: GoogleFonts.inter(
                              //                                   fontSize: media
                              //                                           .width *
                              //                                       sixteen,
                              //                                   color:
                              //                                       buttonColor,
                              //                                   fontWeight:
                              //                                       FontWeight
                              //                                           .w600),
                              //                             )),
                              //                         InkWell(
                              //                             onTap: () async {
                              //                               setState(() {
                              //                                 _locationDenied =
                              //                                     false;
                              //                                 _isLoading = true;
                              //                               });

                              //                               getLocs();
                              //                             },
                              //                             child: Text(
                              //                               languages[
                              //                                       choosenLanguage]
                              //                                   ['text_done'],
                              //                               style: GoogleFonts.inter(
                              //                                   fontSize: media
                              //                                           .width *
                              //                                       sixteen,
                              //                                   color:
                              //                                       buttonColor,
                              //                                   fontWeight:
                              //                                       FontWeight
                              //                                           .w600),
                              //                             ))
                              //                       ],
                              //                     )
                              //                   ],
                              //                 ),
                              //               )
                              //             ],
                              //           ),
                              //         )),
                              //       )
                              //     : Container(),

                              // Auto logout notifier
                              // (_showLogoutNotifier == true)
                              //     ? Positioned(
                              //         child: Container(
                              //         height: media.height * 1,
                              //         width: media.width * 1,
                              //         color:
                              //             Colors.transparent.withValues(alpha: 0.6),
                              //         child: Column(
                              //           mainAxisAlignment:
                              //               MainAxisAlignment.center,
                              //           children: [
                              //             Container(
                              //               padding: EdgeInsets.all(
                              //                   media.width * 0.05),
                              //               width: media.width * 0.9,
                              //               decoration: BoxDecoration(
                              //                 border: Border.all(
                              //                     color: darkModeBorderColor),
                              //                 borderRadius:
                              //                     BorderRadius.circular(30),
                              //                 color: page,
                              //               ),
                              //               child: Column(
                              //                 children: [
                              //                   SizedBox(
                              //                     height: Responsive.height(
                              //                         2, context),
                              //                   ),
                              //                   SizedBox(
                              //                       width: media.width * 0.8,
                              //                       child: Text(
                              //                         languages[choosenLanguage]
                              //                             [
                              //                             'text_logout_notifier'],
                              //                         style: GoogleFonts.inter(
                              //                             fontSize:
                              //                                 media.width *
                              //                                     sixteen,
                              //                             color: textColor,
                              //                             fontWeight:
                              //                                 FontWeight.w600),
                              //                       )),
                              //                   SizedBox(
                              //                       height: media.width * 0.1),
                              //                   Button(
                              //                       width: media.width,
                              //                       onTap: () async {
                              //                         // await userLogout();
                              //                         // navigateLogout();
                              //                       },
                              //                       text: languages[
                              //                               choosenLanguage]
                              //                           ['text_ok'])
                              //                 ],
                              //               ),
                              //             )
                              //           ],
                              //         ),
                              //       ))
                              //     : Container(),
                              //enter otp
                              (getStartOtp == true && driverReq.isNotEmpty)
                                  ? Positioned(
                                top: 0,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      getStartOtp = false;
                                    });
                                  },
                                  child: Container(
                                    height: media.height * 1,
                                    width: media.width * 1,
                                    color: Colors.transparent
                                        .withValues(alpha: 0.5),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(
                                              media.width * 0.05),
                                          width: media.width * 0.8,
                                          height: media.width * 0.7,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  30),
                                              border: Border.all(
                                                  color:
                                                  darkModeBorderColor),
                                              color: page,
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.2),
                                                    spreadRadius: 2,
                                                    blurRadius: 2)
                                              ]),
                                          child: Column(
                                            children: [
                                              Text(
                                                languages[choosenLanguage]
                                                ['text_driver_otp'],
                                                style: GoogleFonts.inter(
                                                    fontSize:
                                                    media.width *
                                                        eighteen,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: textColor),
                                              ),
                                              SizedBox(
                                                  height:
                                                  media.width * 0.05),
                                              Text(
                                                languages[choosenLanguage]
                                                [
                                                'text_enterdriverotp'],
                                                style: GoogleFonts.inter(
                                                  fontSize: media.width *
                                                      twelve,
                                                  color: textColor
                                                      .withValues(alpha: 0.7),
                                                ),
                                                textAlign:
                                                TextAlign.center,
                                              ),
                                              SizedBox(
                                                height:
                                                media.width * 0.05,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceAround,
                                                children: [
                                                  Container(
                                                    alignment:
                                                    Alignment.center,
                                                    width: media.width *
                                                        0.12,
                                                    decoration: BoxDecoration(
                                                        color:
                                                        darkModeSecContainer,
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                            10)),
                                                    child: TextFormField(
                                                      onChanged: (val) {
                                                        if (val.length ==
                                                            1) {
                                                          setState(() {
                                                            _otp1 = val;
                                                            driverOtp =
                                                                _otp1 +
                                                                    _otp2 +
                                                                    _otp3 +
                                                                    _otp4;
                                                            FocusScope.of(
                                                                context)
                                                                .nextFocus();
                                                          });
                                                        }
                                                      },
                                                      keyboardType:
                                                      TextInputType
                                                          .number,
                                                      maxLength: 1,
                                                      textAlign: TextAlign
                                                          .center,
                                                      style: GoogleFonts.inter(
                                                          fontSize: media
                                                              .width *
                                                              sixteen,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          color:
                                                          textColor),
                                                      decoration: const InputDecoration(
                                                          counterText: '',
                                                          border: UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .black,
                                                                  width:
                                                                  1.5,
                                                                  style: BorderStyle
                                                                      .solid))),
                                                    ),
                                                  ),
                                                  Container(
                                                    alignment:
                                                    Alignment.center,
                                                    width: media.width *
                                                        0.12,
                                                    decoration: BoxDecoration(
                                                        color:
                                                        darkModeSecContainer,
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                            10)),
                                                    child: TextFormField(
                                                      onChanged: (val) {
                                                        if (val.length ==
                                                            1) {
                                                          setState(() {
                                                            _otp2 = val;
                                                            driverOtp =
                                                                _otp1 +
                                                                    _otp2 +
                                                                    _otp3 +
                                                                    _otp4;
                                                            FocusScope.of(
                                                                context)
                                                                .nextFocus();
                                                          });
                                                        } else {
                                                          setState(() {
                                                            FocusScope.of(
                                                                context)
                                                                .previousFocus();
                                                          });
                                                        }
                                                      },
                                                      style: GoogleFonts.inter(
                                                          fontSize: media
                                                              .width *
                                                              sixteen,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          color:
                                                          textColor),
                                                      keyboardType:
                                                      TextInputType
                                                          .number,
                                                      maxLength: 1,
                                                      textAlign: TextAlign
                                                          .center,
                                                      decoration: const InputDecoration(
                                                          counterText: '',
                                                          border: UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .black,
                                                                  width:
                                                                  1.5,
                                                                  style: BorderStyle
                                                                      .solid))),
                                                    ),
                                                  ),
                                                  Container(
                                                    alignment:
                                                    Alignment.center,
                                                    width: media.width *
                                                        0.12,
                                                    decoration: BoxDecoration(
                                                        color:
                                                        darkModeSecContainer,
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                            10)),
                                                    child: TextFormField(
                                                      onChanged: (val) {
                                                        if (val.length ==
                                                            1) {
                                                          setState(() {
                                                            _otp3 = val;
                                                            driverOtp =
                                                                _otp1 +
                                                                    _otp2 +
                                                                    _otp3 +
                                                                    _otp4;
                                                            FocusScope.of(
                                                                context)
                                                                .nextFocus();
                                                          });
                                                        } else {
                                                          setState(() {
                                                            FocusScope.of(
                                                                context)
                                                                .previousFocus();
                                                          });
                                                        }
                                                      },
                                                      style: GoogleFonts.inter(
                                                          fontSize: media
                                                              .width *
                                                              sixteen,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          color:
                                                          textColor),
                                                      keyboardType:
                                                      TextInputType
                                                          .number,
                                                      maxLength: 1,
                                                      textAlign: TextAlign
                                                          .center,
                                                      decoration: const InputDecoration(
                                                          counterText: '',
                                                          border: UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .black,
                                                                  width:
                                                                  1.5,
                                                                  style: BorderStyle
                                                                      .solid))),
                                                    ),
                                                  ),
                                                  Container(
                                                    alignment:
                                                    Alignment.center,
                                                    width: media.width *
                                                        0.12,
                                                    decoration: BoxDecoration(
                                                        color:
                                                        darkModeSecContainer,
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                            10)),
                                                    child: TextFormField(
                                                      onChanged: (val) {
                                                        if (val.length ==
                                                            1) {
                                                          setState(() {
                                                            _otp4 = val;
                                                            driverOtp =
                                                                _otp1 +
                                                                    _otp2 +
                                                                    _otp3 +
                                                                    _otp4;
                                                            FocusScope.of(
                                                                context)
                                                                .nextFocus();
                                                          });
                                                        } else {
                                                          setState(() {
                                                            FocusScope.of(
                                                                context)
                                                                .previousFocus();
                                                          });
                                                        }
                                                      },
                                                      style: GoogleFonts.inter(
                                                          fontSize: media
                                                              .width *
                                                              sixteen,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          color:
                                                          textColor),
                                                      keyboardType:
                                                      TextInputType
                                                          .number,
                                                      maxLength: 1,
                                                      textAlign: TextAlign
                                                          .center,
                                                      decoration: const InputDecoration(
                                                          counterText: '',
                                                          border: UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .black,
                                                                  width:
                                                                  1.5,
                                                                  style: BorderStyle
                                                                      .solid))),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height:
                                                media.width * 0.04,
                                              ),
                                              (_errorOtp == true)
                                                  ? Text(
                                                languages[
                                                choosenLanguage]
                                                [
                                                'text_error_trip_otp'],
                                                style: GoogleFonts.inter(
                                                    color:
                                                    Colors.red,
                                                    fontSize: media
                                                        .width *
                                                        twelve),
                                              )
                                                  : Container(),
                                              SizedBox(
                                                  height:
                                                  media.width * 0.02),
                                              Button(
                                                onTap: () async {
                                                  if (driverOtp.length !=
                                                      4) {
                                                    setState(() {});
                                                  } else {
                                                    setState(() {
                                                      _errorOtp = false;
                                                      _isLoading = true;
                                                    });
                                                    var val =
                                                    await tripStart();
                                                    if (val == 'logout') {
                                                      navigateLogout();
                                                    } else if (val !=
                                                        'success') {
                                                      setState(() {
                                                        _errorOtp = true;
                                                        _isLoading =
                                                        false;
                                                      });
                                                    } else {
                                                      setState(() {
                                                        _isLoading =
                                                        false;
                                                        getStartOtp =
                                                        false;
                                                      });
                                                    }
                                                  }
                                                },
                                                text: languages[
                                                choosenLanguage]
                                                ['text_confirm'],
                                                color: (driverOtp
                                                    .length !=
                                                    4)
                                                    ? darkModeSecContainer
                                                    : buttonColor,
                                                borcolor: (driverOtp
                                                    .length !=
                                                    4)
                                                    ? darkModeBorderColor
                                                    : buttonColor,
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                                  : (getStartOtp == true &&
                                  driverReq.isNotEmpty)
                                  ? Positioned(
                                top: 0,
                                child: Container(
                                  height: media.height * 1,
                                  width: media.width * 1,
                                  padding: EdgeInsets.fromLTRB(
                                      media.width * 0.1,
                                      MediaQuery.of(context)
                                          .padding
                                          .top +
                                          media.width * 0.05,
                                      media.width * 0.1,
                                      media.width * 0.05),
                                  color: page,
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: media.width * 0.8,
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.end,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  getStartOtp = false;
                                                });
                                              },
                                              child: Container(
                                                height: media.height *
                                                    0.05,
                                                width: media.height *
                                                    0.05,
                                                decoration:
                                                BoxDecoration(
                                                  color: page,
                                                  shape:
                                                  BoxShape.circle,
                                                ),
                                                child: Icon(
                                                    Icons.cancel,
                                                    color:
                                                    buttonColor),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                          height:
                                          media.width * 0.025),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              (driverReq['show_otp_feature'] ==
                                                  true)
                                                  ? Column(children: [
                                                Text(
                                                  languages[
                                                  choosenLanguage]
                                                  [
                                                  'text_driver_otp'],
                                                  style: GoogleFonts.inter(
                                                      fontSize:
                                                      media.width *
                                                          eighteen,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      color:
                                                      textColor),
                                                ),
                                                SizedBox(
                                                    height: media
                                                        .width *
                                                        0.05),
                                                Text(
                                                  languages[
                                                  choosenLanguage]
                                                  [
                                                  'text_enterdriverotp'],
                                                  style:
                                                  GoogleFonts
                                                      .inter(
                                                    fontSize: media
                                                        .width *
                                                        twelve,
                                                    color: textColor
                                                        .withValues(alpha:
                                                    0.7),
                                                  ),
                                                  textAlign:
                                                  TextAlign
                                                      .center,
                                                ),
                                                SizedBox(
                                                  height: media
                                                      .width *
                                                      0.05,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceAround,
                                                  children: [
                                                    Container(
                                                      alignment:
                                                      Alignment
                                                          .center,
                                                      width: media
                                                          .width *
                                                          0.12,
                                                      color:
                                                      page,
                                                      child:
                                                      TextFormField(
                                                        onChanged:
                                                            (val) {
                                                          if (val.length ==
                                                              1) {
                                                            setState(() {
                                                              _otp1 = val;
                                                              driverOtp = _otp1 + _otp2 + _otp3 + _otp4;
                                                              FocusScope.of(context).nextFocus();
                                                            });
                                                          }
                                                        },
                                                        style: GoogleFonts.inter(
                                                            color:
                                                            textColor,
                                                            fontSize:
                                                            media.width * sixteen),
                                                        keyboardType:
                                                        TextInputType.number,
                                                        maxLength:
                                                        1,
                                                        textAlign:
                                                        TextAlign.center,
                                                        decoration: InputDecoration(
                                                            counterText:
                                                            '',
                                                            border:
                                                            UnderlineInputBorder(borderSide: BorderSide(color: textColor, width: 1.5, style: BorderStyle.solid))),
                                                      ),
                                                    ),
                                                    Container(
                                                      alignment:
                                                      Alignment
                                                          .center,
                                                      width: media
                                                          .width *
                                                          0.12,
                                                      color:
                                                      page,
                                                      child:
                                                      TextFormField(
                                                        onChanged:
                                                            (val) {
                                                          if (val.length ==
                                                              1) {
                                                            setState(() {
                                                              _otp2 = val;
                                                              driverOtp = _otp1 + _otp2 + _otp3 + _otp4;
                                                              FocusScope.of(context).nextFocus();
                                                            });
                                                          } else {
                                                            setState(() {
                                                              _otp2 = val;
                                                              driverOtp = _otp1 + _otp2 + _otp3 + _otp4;
                                                              FocusScope.of(context).previousFocus();
                                                            });
                                                          }
                                                        },
                                                        style: GoogleFonts.inter(
                                                            color:
                                                            textColor,
                                                            fontSize:
                                                            media.width * sixteen),
                                                        keyboardType:
                                                        TextInputType.number,
                                                        maxLength:
                                                        1,
                                                        textAlign:
                                                        TextAlign.center,
                                                        decoration: InputDecoration(
                                                            counterText:
                                                            '',
                                                            border:
                                                            UnderlineInputBorder(borderSide: BorderSide(color: textColor, width: 1.5, style: BorderStyle.solid))),
                                                      ),
                                                    ),
                                                    Container(
                                                      alignment:
                                                      Alignment
                                                          .center,
                                                      width: media
                                                          .width *
                                                          0.12,
                                                      color:
                                                      page,
                                                      child:
                                                      TextFormField(
                                                        onChanged:
                                                            (val) {
                                                          if (val.length ==
                                                              1) {
                                                            setState(() {
                                                              _otp3 = val;
                                                              driverOtp = _otp1 + _otp2 + _otp3 + _otp4;
                                                              FocusScope.of(context).nextFocus();
                                                            });
                                                          } else {
                                                            setState(() {
                                                              _otp3 = val;
                                                              driverOtp = _otp1 + _otp2 + _otp3 + _otp4;
                                                              FocusScope.of(context).previousFocus();
                                                            });
                                                          }
                                                        },
                                                        style: GoogleFonts.inter(
                                                            color:
                                                            textColor,
                                                            fontSize:
                                                            media.width * sixteen),
                                                        keyboardType:
                                                        TextInputType.number,
                                                        maxLength:
                                                        1,
                                                        textAlign:
                                                        TextAlign.center,
                                                        decoration: InputDecoration(
                                                            counterText:
                                                            '',
                                                            border:
                                                            UnderlineInputBorder(borderSide: BorderSide(color: textColor, width: 1.5, style: BorderStyle.solid))),
                                                      ),
                                                    ),
                                                    Container(
                                                      alignment:
                                                      Alignment
                                                          .center,
                                                      width: media
                                                          .width *
                                                          0.12,
                                                      color:
                                                      page,
                                                      child:
                                                      TextFormField(
                                                        onChanged:
                                                            (val) {
                                                          if (val.length ==
                                                              1) {
                                                            setState(() {
                                                              _otp4 = val;
                                                              driverOtp = _otp1 + _otp2 + _otp3 + _otp4;
                                                              FocusScope.of(context).nextFocus();
                                                            });
                                                          } else {
                                                            setState(() {
                                                              _otp4 = val;
                                                              driverOtp = _otp1 + _otp2 + _otp3 + _otp4;
                                                              FocusScope.of(context).previousFocus();
                                                            });
                                                          }
                                                        },
                                                        style: GoogleFonts.inter(
                                                            color:
                                                            textColor,
                                                            fontSize:
                                                            media.width * sixteen),
                                                        keyboardType:
                                                        TextInputType.number,
                                                        maxLength:
                                                        1,
                                                        textAlign:
                                                        TextAlign.center,
                                                        decoration: InputDecoration(
                                                            counterText:
                                                            '',
                                                            border:
                                                            UnderlineInputBorder(borderSide: BorderSide(color: textColor, width: 1.5, style: BorderStyle.solid))),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: media
                                                      .width *
                                                      0.04,
                                                ),
                                                (_errorOtp ==
                                                    true)
                                                    ? Text(
                                                  languages[choosenLanguage]
                                                  [
                                                  'text_error_trip_otp'],
                                                  style: GoogleFonts.inter(
                                                      color:
                                                      Colors.red,
                                                      fontSize: media.width * twelve),
                                                )
                                                    : Container(),
                                                SizedBox(
                                                    height: media
                                                        .width *
                                                        0.02),
                                              ])
                                                  : Container(),
                                              SizedBox(
                                                width:
                                                media.width * 0.8,
                                                child: Text(
                                                  languages[
                                                  choosenLanguage]
                                                  [
                                                  'text_shipment_title'],
                                                  style: GoogleFonts
                                                      .inter(
                                                    fontSize:
                                                    media.width *
                                                        eighteen,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                    color: textColor,
                                                  ),
                                                  textAlign: TextAlign
                                                      .center,
                                                ),
                                              ),
                                              SizedBox(
                                                  height:
                                                  media.width *
                                                      0.02),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          height: media.width * 0.02),
                                      Button(
                                        onTap: () async {
                                          if (driverOtp.length != 4) {
                                            setState(() {});
                                          } else {
                                            setState(() {
                                              _errorOtp = false;
                                              _isLoading = true;
                                            });
                                            var val =
                                            await tripStart();
                                            if (val == 'logout') {
                                              navigateLogout();
                                            } else if (val !=
                                                'success') {
                                              setState(() {
                                                _errorOtp = true;
                                                _isLoading = false;
                                              });
                                            } else {
                                              setState(() {
                                                _isLoading = false;
                                                getStartOtp = false;
                                              });
                                            }
                                          }
                                        },
                                        text:
                                        languages[choosenLanguage]
                                        ['text_confirm'],
                                        color: (driverOtp.length != 4)
                                            ? Colors.grey
                                            : buttonColor,
                                        borcolor:
                                        (driverOtp.length != 4)
                                            ? Colors.grey
                                            : buttonColor,
                                      )
                                    ],
                                  ),
                                ),
                              )
                                  : Container(),

                              //permission denied popup
                              (_permission != '')
                                  ? Positioned(
                                  child: Container(
                                    height: media.height * 1,
                                    width: media.width * 1,
                                    color:
                                    Colors.transparent.withValues(alpha: 0.6),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: media.width * 0.9,
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.end,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _permission = '';
                                                  });
                                                },
                                                child: Container(
                                                  height: media.width * 0.1,
                                                  width: media.width * 0.1,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: page),
                                                  child: Icon(
                                                      Icons.cancel_outlined,
                                                      color: textColor),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: media.width * 0.05,
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(
                                              media.width * 0.05),
                                          width: media.width * 0.9,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(12),
                                              color: page,
                                              boxShadow: [
                                                BoxShadow(
                                                    blurRadius: 2.0,
                                                    spreadRadius: 2.0,
                                                    color: Colors.black
                                                        .withValues(alpha: 0.2))
                                              ]),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                  width: media.width * 0.8,
                                                  child: Text(
                                                    languages[choosenLanguage]
                                                    [
                                                    'text_open_camera_setting'],
                                                    style: GoogleFonts.inter(
                                                        fontSize:
                                                        media.width *
                                                            sixteen,
                                                        color: textColor,
                                                        fontWeight:
                                                        FontWeight.w600),
                                                  )),
                                              SizedBox(
                                                  height: media.width * 0.05),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  InkWell(
                                                      onTap: () async {
                                                        await perm
                                                            .openAppSettings();
                                                      },
                                                      child: Text(
                                                        languages[
                                                        choosenLanguage]
                                                        [
                                                        'text_open_settings'],
                                                        style: GoogleFonts.inter(
                                                            fontSize:
                                                            media.width *
                                                                sixteen,
                                                            color:
                                                            buttonColor,
                                                            fontWeight:
                                                            FontWeight
                                                                .w600),
                                                      )),
                                                  InkWell(
                                                      onTap: () async {
                                                        // pickImageFromCamera();
                                                        setState(() {
                                                          _permission = '';
                                                        });
                                                      },
                                                      child: Text(
                                                        languages[
                                                        choosenLanguage]
                                                        ['text_done'],
                                                        style: GoogleFonts.inter(
                                                            fontSize:
                                                            media.width *
                                                                sixteen,
                                                            color:
                                                            buttonColor,
                                                            fontWeight:
                                                            FontWeight
                                                                .w600),
                                                      ))
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ))
                                  : Container(),

                              //popup for cancel request
                              (cancelRequest == true && driverReq.isNotEmpty)
                                  ? Positioned(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        cancelRequest = false;
                                      });
                                    },
                                    child: Container(
                                      height: media.height * 1,
                                      width: media.width * 1,
                                      color:
                                      Colors.transparent.withValues(alpha: 0.6),
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(
                                                media.width * 0.05),
                                            width: media.width * 0.9,
                                            decoration: BoxDecoration(
                                                color: page,
                                                border: Border.all(
                                                    color:
                                                    darkModeBorderColor),
                                                borderRadius:
                                                BorderRadius.circular(
                                                    30)),
                                            child: Column(children: [
                                              SizedBox(
                                                height: Responsive.height(
                                                    2.5, context),
                                              ),
                                              MyText(
                                                text:
                                                languages[choosenLanguage]
                                                ['text_cancel_ride2'],
                                                size:
                                                media.width * twentythree,
                                                fontweight: FontWeight.w600,
                                              ),
                                              SizedBox(
                                                height: Responsive.height(
                                                    1.5, context),
                                              ),
                                              Column(
                                                children: cancelReasonsList
                                                    .asMap()
                                                    .map((i, value) {
                                                  return MapEntry(
                                                      i,
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            _cancelReason =
                                                            cancelReasonsList[
                                                            i]
                                                            [
                                                            'reason'];
                                                          });
                                                        },
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .all(media
                                                              .width *
                                                              0.01),
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                height: media
                                                                    .height *
                                                                    0.05,
                                                                width: media
                                                                    .width *
                                                                    0.05,
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border: Border.all(
                                                                        color: buttonColor,
                                                                        width: 1.2)),
                                                                alignment:
                                                                Alignment
                                                                    .center,
                                                                child: (_cancelReason ==
                                                                    cancelReasonsList[i]['reason'])
                                                                    ? Container(
                                                                  height: media.width * 0.03,
                                                                  width: media.width * 0.03,
                                                                  decoration: BoxDecoration(
                                                                    shape: BoxShape.circle,
                                                                    color: buttonColor,
                                                                  ),
                                                                )
                                                                    : Container(),
                                                              ),
                                                              SizedBox(
                                                                width: media
                                                                    .width *
                                                                    0.05,
                                                              ),
                                                              SizedBox(
                                                                width: media
                                                                    .width *
                                                                    0.65,
                                                                child:
                                                                MyText(
                                                                  text: cancelReasonsList[i]
                                                                  [
                                                                  'reason'],
                                                                  size: media.width *
                                                                      thirteen,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ));
                                                })
                                                    .values
                                                    .toList(),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _cancelReason = 'others';
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(
                                                      media.width * 0.01),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        height: media.height *
                                                            0.05,
                                                        width: media.width *
                                                            0.05,
                                                        decoration: BoxDecoration(
                                                            shape: BoxShape
                                                                .circle,
                                                            border: Border.all(
                                                                color:
                                                                buttonColor,
                                                                width: 1.2)),
                                                        alignment:
                                                        Alignment.center,
                                                        child:
                                                        (_cancelReason ==
                                                            'others')
                                                            ? Container(
                                                          height: media
                                                              .width *
                                                              0.03,
                                                          width: media
                                                              .width *
                                                              0.03,
                                                          decoration:
                                                          BoxDecoration(
                                                            shape: BoxShape
                                                                .circle,
                                                            color:
                                                            buttonColor,
                                                          ),
                                                        )
                                                            : Container(),
                                                      ),
                                                      SizedBox(
                                                        width: media.width *
                                                            0.05,
                                                      ),
                                                      MyText(
                                                        text: languages[
                                                        choosenLanguage]
                                                        ['text_others'],
                                                        size: media.width *
                                                            thirteen,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              (_cancelReason == 'others')
                                                  ? Container(
                                                margin:
                                                EdgeInsets.fromLTRB(
                                                    0,
                                                    media.width *
                                                        0.025,
                                                    0,
                                                    media.width *
                                                        0.025),
                                                padding: EdgeInsets.all(
                                                    media.width * 0.02),
                                                width:
                                                media.width * 0.9,
                                                decoration: BoxDecoration(
                                                    color:
                                                    darkModeSecContainer,
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                        10)),
                                                child: TextField(
                                                  style:
                                                  GoogleFonts.inter(
                                                      color:
                                                      textColor),
                                                  decoration: InputDecoration(
                                                      border:
                                                      InputBorder
                                                          .none,
                                                      hintText: languages[
                                                      choosenLanguage]
                                                      [
                                                      'text_cancelRideReason'],
                                                      hintStyle: GoogleFonts.inter(
                                                          color: textColor
                                                              .withValues(alpha:
                                                          0.4),
                                                          fontSize: media
                                                              .width *
                                                              twelve)),
                                                  maxLines: 4,
                                                  minLines: 2,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      cancelReasonText =
                                                          val;
                                                    });
                                                  },
                                                ),
                                              )
                                                  : Container(),
                                              (_cancellingError !=
                                                  '')
                                                  ? Container(
                                                  padding: EdgeInsets
                                                      .only(
                                                      top: media
                                                          .width *
                                                          0.02,
                                                      bottom: media
                                                          .width *
                                                          0.02),
                                                  width: media
                                                      .width *
                                                      0.9,
                                                  child: Text(
                                                      _cancellingError,
                                                      style: GoogleFonts.inter(
                                                          fontSize: media
                                                              .width *
                                                              twelve,
                                                          color: Colors
                                                              .red)))
                                                  : Container(),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Button(
                                                        color:
                                                        Color(0xffFB5B5B),
                                                        textcolor: textColor,
                                                        borderRadius: 30000.0,
                                                        width: media.width *
                                                            0.35,
                                                        onTap: () async {
                                                          setState(() {
                                                            _isLoading = true;
                                                          });
                                                          if (_cancelReason !=
                                                              '') {
                                                            if (_cancelReason ==
                                                                'others') {
                                                              if (cancelReasonText !=
                                                                  '' &&
                                                                  cancelReasonText
                                                                      .isNotEmpty) {
                                                                _cancellingError =
                                                                '';
                                                                var val =
                                                                await cancelRequestDriver(
                                                                    cancelReasonText);
                                                                if (val ==
                                                                    'logout') {
                                                                  navigateLogout();
                                                                }
                                                                setState(() {
                                                                  cancelRequest =
                                                                  false;
                                                                });
                                                                if (val) {
                                                                  await Future.delayed(Duration(
                                                                      milliseconds:
                                                                      500));
                                                                  navigate(
                                                                      context);
                                                                }
                                                              } else {
                                                                setState(() {
                                                                  _cancellingError =
                                                                  languages[choosenLanguage]
                                                                  [
                                                                  'text_add_cancel_reason'];
                                                                });
                                                              }
                                                            } else {
                                                              var val =
                                                              await cancelRequestDriver(
                                                                  _cancelReason);
                                                              if (val ==
                                                                  'logout') {
                                                                navigateLogout();
                                                              }
                                                              setState(() {
                                                                cancelRequest =
                                                                false;
                                                              });
                                                              if (val) {
                                                                await Future.delayed(
                                                                    Duration(
                                                                        milliseconds:
                                                                        500));
                                                                navigate(
                                                                    context);
                                                              }
                                                            }
                                                          }
                                                          setState(() {
                                                            _isLoading =
                                                            false;
                                                          });
                                                        },
                                                        text: languages[
                                                        choosenLanguage]
                                                        [
                                                        'text_cancel_ride']),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: Button(
                                                        borderRadius: 3000.0,
                                                        width: media.width *
                                                            0.35,
                                                        onTap: () {
                                                          setState(() {
                                                            cancelRequest =
                                                            false;
                                                          });
                                                        },
                                                        text: languages[
                                                        choosenLanguage]
                                                        [
                                                        'text_continue_ride']),
                                                  )
                                                ],
                                              )
                                            ]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ))
                                  : Container(),

                              (userDetails['low_balance'] == true)
                                  ? Positioned(
                                bottom: media.width * 0.05,
                                left: media.width * 0.05,
                                right: media.width * 0.05,
                                child: MyText(
                                  textAlign: TextAlign.center,
                                  text: userDetails['owner_id'] != null
                                      ? languages[choosenLanguage]
                                  ['text_fleet_diver_low_bal']
                                      : languages[choosenLanguage]
                                  ['text_low_balance'],
                                  size: media.width * sixteen,
                                  color: verifyDeclined,
                                  fontweight: FontWeight.w600,
                                ),
                              )
                                  : Container(),
                              //loader
                              (state == '')
                                  ? const Positioned(top: 0, child: Loading())
                                  : Container(),

                              //logout popup
                              (logout == true)
                                  ? Positioned(
                                  top: 0,
                                  child: Container(
                                    height: media.height * 1,
                                    width: media.width * 1,
                                    color:
                                    Colors.transparent.withValues(alpha: 0.6),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(
                                                  media.width * 0.05),
                                              width: media.width * 0.9,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color:
                                                      darkModeBorderColor),
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      30),
                                                  color: page),
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                      height:
                                                      Responsive.height(
                                                          3, context)),
                                                  Text(
                                                    languages[
                                                    choosenLanguage]
                                                    [
                                                    'text_confirmlogout'],
                                                    textAlign:
                                                    TextAlign.center,
                                                    style:
                                                    GoogleFonts.inter(
                                                        fontSize: media
                                                            .width *
                                                            sixteen,
                                                        color:
                                                        textColor,
                                                        fontWeight:
                                                        FontWeight
                                                            .w600),
                                                  ),
                                                  SizedBox(
                                                    height:
                                                    media.width * 0.05,
                                                  ),
                                                  Button(
                                                      onTap: () async {
                                                        setState(() {
                                                          _isLoading = true;
                                                          logout = false;
                                                        });
                                                        var result =
                                                        await userLogout();
                                                        if (result ==
                                                            'success') {
                                                          await sharefPref!
                                                              .setString(
                                                              currentRegScreen,
                                                              isLoginScreen);
                                                          setState(() {
                                                            Navigator.pushAndRemoveUntil(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) {
                                                                      return const LandingPage();
                                                                    }),
                                                                    (route) =>
                                                                false);
                                                            userDetails
                                                                .clear();
                                                          });
                                                        } else if (result ==
                                                            'logout') {
                                                          navigateLogout();
                                                        } else {
                                                          setState(() {
                                                            logout = true;
                                                          });
                                                        }
                                                      },
                                                      text: languages[
                                                      choosenLanguage]
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
                                                      logout = false;
                                                    });
                                                  },
                                                  child: Icon(Icons.cancel,
                                                      color: white)),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ))
                                  : Container(),

                              //waiting time popup
                              (_showWaitingInfo == true)
                                  ? Positioned(
                                  top: 0,
                                  child: Container(
                                    height: media.height * 1,
                                    width: media.width * 1,
                                    color:
                                    Colors.transparent.withValues(alpha: 0.6),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: media.width * 0.9,
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                  height:
                                                  media.height * 0.1,
                                                  width: media.width * 0.1,
                                                  decoration: BoxDecoration(
                                                      shape:
                                                      BoxShape.circle,
                                                      color: page),
                                                  child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          _showWaitingInfo =
                                                          false;
                                                        });
                                                      },
                                                      child: const Icon(Icons
                                                          .cancel_outlined))),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(
                                              media.width * 0.05),
                                          width: media.width * 0.9,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(12),
                                              color: page),
                                          child: Column(
                                            children: [
                                              Text(
                                                languages[choosenLanguage]
                                                ['text_waiting_time_1'],
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.inter(
                                                    fontSize: media.width *
                                                        sixteen,
                                                    color: textColor,
                                                    fontWeight:
                                                    FontWeight.w600),
                                              ),
                                              SizedBox(
                                                height: media.width * 0.05,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Text(
                                                      languages[
                                                      choosenLanguage]
                                                      [
                                                      'text_waiting_time_2'],
                                                      style: GoogleFonts.inter(
                                                          fontSize:
                                                          media.width *
                                                              fourteen,
                                                          color:
                                                          textColor)),
                                                  Text(
                                                      '${driverReq['free_waiting_time_in_mins_before_trip_start']} mins',
                                                      style: GoogleFonts.inter(
                                                          fontSize:
                                                          media.width *
                                                              fourteen,
                                                          color: textColor,
                                                          fontWeight:
                                                          FontWeight
                                                              .w600)),
                                                ],
                                              ),
                                              SizedBox(
                                                height: media.width * 0.05,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Text(
                                                      languages[
                                                      choosenLanguage]
                                                      [
                                                      'text_waiting_time_3'],
                                                      style: GoogleFonts.inter(
                                                          fontSize:
                                                          media.width *
                                                              fourteen,
                                                          color:
                                                          textColor)),
                                                  Text(
                                                      '${driverReq['free_waiting_time_in_mins_after_trip_start']} mins',
                                                      style: GoogleFonts.inter(
                                                          fontSize:
                                                          media.width *
                                                              fourteen,
                                                          color: textColor,
                                                          fontWeight:
                                                          FontWeight
                                                              .w600)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ))
                                  : Container(),

                              //no internet
                              (internet == false)
                                  ? Positioned(
                                  top: 0,
                                  child: NoInternet(
                                    onTap: () {
                                      setState(() {
                                        internetTrue();
                                        getUserDetails();
                                      });
                                    },
                                  ))
                                  : Container(),

                              //sos popup
                              (showSos == true)
                                  ? Positioned(
                                  top: 0,
                                  child: Container(
                                    height: media.height * 1,
                                    width: media.width * 1,
                                    color:
                                    Colors.transparent.withValues(alpha: 0.6),
                                    child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Stack(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(
                                                    media.width * 0.05),
                                                height: media.height * 0.5,
                                                width: media.width * 0.7,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(30),
                                                    border: Border.all(
                                                        color:
                                                        darkModeBorderColor
                                                            .withValues(alpha:
                                                        0.3)),
                                                    color: page),
                                                child:
                                                SingleChildScrollView(
                                                    physics:
                                                    const BouncingScrollPhysics(),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        SizedBox(
                                                          height: Responsive
                                                              .height(2,
                                                              context),
                                                        ),
                                                        InkWell(
                                                          onTap:
                                                              () async {
                                                            setState(
                                                                    () {
                                                                  notifyCompleted =
                                                                  false;
                                                                });
                                                            var val =
                                                            await notifyAdmin();
                                                            if (val ==
                                                                true) {
                                                              setState(
                                                                      () {
                                                                    notifyCompleted =
                                                                    true;
                                                                  });
                                                            }
                                                          },
                                                          child:
                                                          Container(
                                                            padding: EdgeInsets.all(
                                                                media.width *
                                                                    0.03),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                              children: [
                                                                Column(
                                                                  crossAxisAlignment:
                                                                  CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text(
                                                                      languages[choosenLanguage]['text_notifyadmin'],
                                                                      style: GoogleFonts.inter(fontSize: media.width * seventeen, color: textColor, fontWeight: FontWeight.w500),
                                                                    ),
                                                                    (notifyCompleted == true)
                                                                        ? Container(
                                                                      padding: EdgeInsets.only(top: media.width * 0.01),
                                                                      child: Text(
                                                                        languages[choosenLanguage]['text_notifysuccess'],
                                                                        style: GoogleFonts.inter(
                                                                          fontSize: media.width * twelve,
                                                                          color: const Color(0xff319900),
                                                                        ),
                                                                      ),
                                                                    )
                                                                        : Container()
                                                                  ],
                                                                ),
                                                                Icon(
                                                                    Icons
                                                                        .notifications_none,
                                                                    color:
                                                                    white)
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        (sosData.isNotEmpty)
                                                            ? Column(
                                                          children: sosData
                                                              .asMap()
                                                              .map((i, value) {
                                                            return MapEntry(
                                                                i,
                                                                InkWell(
                                                                  onTap: () {
                                                                    makingPhoneCall(sosData[i]['number'].toString().replaceAll(' ', ''));
                                                                  },
                                                                  child: Container(
                                                                    padding: EdgeInsets.all(media.width * 0.03),
                                                                    child: Row(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            SizedBox(
                                                                              width: media.width * 0.4,
                                                                              child: Text(
                                                                                sosData[i]['name'],
                                                                                style: GoogleFonts.inter(fontSize: media.width * seventeen, color: textColor, fontWeight: FontWeight.w500),
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              height: media.width * 0.01,
                                                                            ),
                                                                            Text(
                                                                              sosData[i]['number'],
                                                                              style: GoogleFonts.inter(
                                                                                fontSize: media.width * thirteen,
                                                                                color: textColor.withValues(alpha: 0.53),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                        Icon(
                                                                          Icons.call,
                                                                          color: white,
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ));
                                                          })
                                                              .values
                                                              .toList(),
                                                        )
                                                            : Container(
                                                          width: media.width *
                                                              0.7,
                                                          alignment:
                                                          Alignment.center,
                                                          child:
                                                          Text(
                                                            languages[choosenLanguage]
                                                            [
                                                            'text_noDataFound'],
                                                            style: GoogleFonts.inter(
                                                                fontSize: media.width * eighteen,
                                                                fontWeight: FontWeight.w600,
                                                                color: textColor),
                                                          ),
                                                        )
                                                      ],
                                                    )),
                                              ),
                                              Positioned(
                                                top: 15,
                                                right: 15,
                                                child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        notifyCompleted =
                                                        false;
                                                        showSos = false;
                                                      });
                                                    },
                                                    child: Icon(
                                                      Icons.cancel,
                                                      color: white,
                                                    )),
                                              ),
                                            ],
                                          )
                                        ]),
                                  ))
                                  : Container(),

                              //choose option for seeing location on map while having multiple stops
                              (_tripOpenMap == true)
                                  ? Positioned(
                                  top: 0,
                                  child: Container(
                                    height: media.height * 1,
                                    width: media.width * 1,
                                    color:
                                    Colors.transparent.withValues(alpha: 0.6),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: media.width * 0.9,
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.end,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _tripOpenMap = false;
                                                  });
                                                },
                                                child: Container(
                                                  height: media.width * 0.1,
                                                  width: media.width * 0.1,
                                                  decoration: BoxDecoration(
                                                      shape:
                                                      BoxShape.circle,
                                                      color: page),
                                                  child: Icon(
                                                    Icons.cancel_outlined,
                                                    color: textColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: media.width * 0.05,
                                        ),
                                        Container(
                                            width: media.width * 0.9,
                                            padding: EdgeInsets.fromLTRB(
                                                media.width * 0.02,
                                                media.width * 0.05,
                                                media.width * 0.02,
                                                media.width * 0.05),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    12),
                                                color: page),
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  width: media.width * 0.8,
                                                  child: Text(
                                                    languages[
                                                    choosenLanguage]
                                                    [
                                                    'text_choose_address_nav'],
                                                    style:
                                                    GoogleFonts.roboto(
                                                        fontSize: media
                                                            .width *
                                                            sixteen,
                                                        color:
                                                        textColor,
                                                        fontWeight:
                                                        FontWeight
                                                            .w600),
                                                    maxLines: 1,
                                                    overflow: TextOverflow
                                                        .ellipsis,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height:
                                                  media.width * 0.03,
                                                ),
                                                SizedBox(
                                                  height:
                                                  media.height * 0.2,
                                                  child:
                                                  SingleChildScrollView(
                                                    physics:
                                                    const BouncingScrollPhysics(),
                                                    child: Column(
                                                      children: tripStops
                                                          .asMap()
                                                          .map((i, value) {
                                                        return MapEntry(
                                                            i,
                                                            Container(
                                                              // width: media.width*0.5,
                                                              padding: EdgeInsets.all(
                                                                  media.width *
                                                                      0.025),
                                                              child:
                                                              Row(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                    Text(
                                                                      tripStops[i]['address'],
                                                                      style: GoogleFonts.roboto(fontSize: media.width * fourteen, color: textColor, fontWeight: FontWeight.w600),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width:
                                                                    media.width * 0.01,
                                                                  ),
                                                                  InkWell(
                                                                    onTap:
                                                                        () {
                                                                      launchGoogleMapToPickup(tripStops[i]['latitude'], tripStops[i]['longitude']);
                                                                    },
                                                                    child:
                                                                    SizedBox(
                                                                      width: media.width * 00.08,
                                                                      child: Image.asset('assets/images/googlemaps.png', width: media.width * 0.05, fit: BoxFit.contain),
                                                                    ),
                                                                  ),
                                                                  (userDetails['enable_vase_map'] == '1')
                                                                      ? SizedBox(
                                                                    width: media.width * 0.02,
                                                                  )
                                                                      : Container(),
                                                                  (userDetails['enable_vase_map'] == '1')
                                                                      ? InkWell(
                                                                    onTap: () {
                                                                      // openWazeMap(tripStops[i]['latitude'], tripStops[i]['longitude']);
                                                                      launchWazeMapToPickup(tripStops[i]['latitude'], tripStops[i]['longitude']);
                                                                    },
                                                                    child: SizedBox(
                                                                      width: media.width * 00.1,
                                                                      child: Image.asset('assets/images/waze.png', width: media.width * 0.05, fit: BoxFit.contain),
                                                                    ),
                                                                  )
                                                                      : Container(),
                                                                ],
                                                              ),
                                                            ));
                                                      })
                                                          .values
                                                          .toList(),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ))
                                      ],
                                    ),
                                  ))
                                  : Container(),

                              //loader
                              (_isLoading == true)
                                  ? const Positioned(top: 0, child: Loading())
                                  : Container(),
                              //pickup marker
                              Visibility(
                                // visible: false,
                                child: Positioned(
                                  top: media.height * 1.5,
                                  left: 100,
                                  child: RepaintBoundary(
                                      key: iconKey,
                                      child: Column(
                                        children: [
                                          Container(
                                            // decoration: BoxDecoration(
                                            //     gradient: LinearGradient(
                                            //         colors: [
                                            //           (isDarkTheme == true)
                                            //               ? const Color(
                                            //                   0xff000000)
                                            //               : const Color(
                                            //                   0xffFFFFFF),
                                            //           (isDarkTheme == true)
                                            //               ? const Color(
                                            //                   0xff808080)
                                            //               : const Color(
                                            //                   0xffEFEFEF),
                                            //         ],
                                            //         begin: Alignment.topCenter,
                                            //         end:
                                            //             Alignment.bottomCenter),
                                            //     borderRadius:
                                            //         BorderRadius.circular(5)),
                                            width: media.width * 0.7,
                                            padding: const EdgeInsets.all(5),
                                            child: (driverReq.isNotEmpty &&
                                                driverReq['pick_address'] !=
                                                    null)
                                                ? Text(
                                              '',
                                              // maxLines: 1,
                                              overflow: TextOverflow.fade,
                                              softWrap: false,
                                              style: GoogleFonts.inter(
                                                  color: textColor,
                                                  fontSize: media.width *
                                                      twelve),
                                            )
                                                : Container(),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                    image: AssetImage(
                                                        'assets/images/pick_icon.png'),
                                                    fit: BoxFit.contain)),
                                            height: media.width * 0.07,
                                            width: media.width * 0.08,
                                          )
                                        ],
                                      )),
                                ),
                              ),

                              //drop marker
                              Positioned(
                                  top: media.height * 2.5,
                                  left: 100,
                                  child: Column(
                                    children: [
                                      (tripStops.isNotEmpty)
                                          ? Column(
                                        children: tripStops
                                            .asMap()
                                            .map((i, value) {
                                          iconDropKeys[i] =
                                              GlobalKey();
                                          return MapEntry(
                                            i,
                                            RepaintBoundary(
                                                key: iconDropKeys[i],
                                                child: Column(
                                                  children: [
                                                    (i <=
                                                        tripStops
                                                            .length -
                                                            2)
                                                        ? Column(
                                                      children: [
                                                        Container(
                                                          padding:
                                                          const EdgeInsets.only(bottom: 5),
                                                          child:
                                                          Text(
                                                            (i + 1).toString(),
                                                            style: GoogleFonts.inter(
                                                                fontSize: media.width * sixteen,
                                                                fontWeight: FontWeight.w600,
                                                                color: Colors.red),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height:
                                                          10,
                                                        ),
                                                      ],
                                                    )
                                                        : (i ==
                                                        tripStops.length -
                                                            1)
                                                        ? Column(
                                                      children: [
                                                        Container(
                                                          decoration: BoxDecoration(
                                                              gradient: LinearGradient(colors: [
                                                                (isDarkTheme == true) ? const Color(0xff000000) : const Color(0xffFFFFFF),
                                                                (isDarkTheme == true) ? const Color(0xff808080) : const Color(0xffEFEFEF),
                                                              ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                                                              borderRadius: BorderRadius.circular(5)),
                                                          width: media.width * 0.7,
                                                          padding: const EdgeInsets.all(5),
                                                          child: (driverReq.isNotEmpty && driverReq['drop_address'] != null)
                                                              ? Text(
                                                            driverReq['drop_address'],
                                                            // maxLines: 1,
                                                            overflow: TextOverflow.fade,
                                                            softWrap: false,
                                                            style: GoogleFonts.inter(
                                                              fontSize: media.width * twelve,
                                                              color: textColor,
                                                            ),
                                                          )
                                                              : Container(),
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Container(
                                                          decoration: const BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: AssetImage('assets/images/drop_icon.png'), fit: BoxFit.contain)),
                                                          height: media.width * 0.07,
                                                          width: media.width * 0.08,
                                                        )
                                                      ],
                                                    )
                                                        : Container(),
                                                  ],
                                                )),
                                          );
                                        })
                                            .values
                                            .toList(),
                                      )
                                          : Container(),
                                    ],
                                  )),

                              //drop marker
                              Visibility(
                                // visible: false,
                                child: Positioned(
                                  top: media.height * 2.5,
                                  left: 100,
                                  child: Column(
                                    children: [
                                      RepaintBoundary(
                                          key: iconDropKey,
                                          child: Column(
                                            children: [
                                              Container(
                                                // decoration: BoxDecoration(
                                                //     gradient: LinearGradient(
                                                //         colors: [
                                                //           (isDarkTheme == true)
                                                //               ? const Color(
                                                //                   0xff000000)
                                                //               : const Color(
                                                //                   0xffFFFFFF),
                                                //           (isDarkTheme == true)
                                                //               ? const Color(
                                                //                   0xff808080)
                                                //               : const Color(
                                                //                   0xffEFEFEF),
                                                //         ],
                                                //         begin:
                                                //             Alignment.topCenter,
                                                //         end: Alignment
                                                //             .bottomCenter),
                                                //     borderRadius:
                                                //         BorderRadius.circular(
                                                //             5)),
                                                width: media.width * 0.7,
                                                padding:
                                                const EdgeInsets.all(5),
                                                child: (driverReq.isNotEmpty &&
                                                    driverReq[
                                                    'drop_address'] !=
                                                        null)
                                                    ? Text(
                                                  '',
                                                  // maxLines: 1,
                                                  overflow:
                                                  TextOverflow.fade,
                                                  softWrap: false,
                                                  style:
                                                  GoogleFonts.inter(
                                                      color:
                                                      textColor,
                                                      fontSize: media
                                                          .width *
                                                          twelve),
                                                )
                                                    : Container(),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                        image: AssetImage(
                                                            'assets/images/drop_icon.png'),
                                                        fit: BoxFit.contain)),
                                                height: media.width * 0.07,
                                                width: media.width * 0.08,
                                              )
                                            ],
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                ),
              );
            }),
      ),
    );
  }

  double getBearing(LatLng begin, LatLng end) {
    double lat = (begin.latitude - end.latitude).abs();

    double lng = (begin.longitude - end.longitude).abs();

    if (begin.latitude < end.latitude && begin.longitude < end.longitude) {
      return vector.degrees(atan(lng / lat));
    } else if (begin.latitude >= end.latitude &&
        begin.longitude < end.longitude) {
      return (90 - vector.degrees(atan(lng / lat))) + 90;
    } else if (begin.latitude >= end.latitude &&
        begin.longitude >= end.longitude) {
      return vector.degrees(atan(lng / lat)) + 180;
    } else if (begin.latitude < end.latitude &&
        begin.longitude >= end.longitude) {
      return (90 - vector.degrees(atan(lng / lat))) + 270;
    }

    return -1;
  }

  animateCar(
      double fromLat, //Starting latitude

      double fromLong, //Starting longitude

      double toLat, //Ending latitude

      double toLong, //Ending longitude

      StreamSink<List<Marker>> mapMarkerSink, //Stream G of map to update the UI

      TickerProvider
      provider, //Ticker provider of the widget. This is used for animation

      GoogleMapController controller, //Google map controller of our widget

      markerid,
      icon,
      name,
      number) async {
    final double bearing =
    getBearing(LatLng(fromLat, fromLong), LatLng(toLat, toLong));

    dynamic carMarker;
    if (name == '' && number == '') {
      carMarker = Marker(
          markerId: MarkerId(markerid),
          position: LatLng(fromLat, fromLong),
          icon: icon,
          anchor: const Offset(0.5, 0.5),
          flat: true,
          draggable: false);
    } else {
      carMarker = Marker(
          markerId: MarkerId(markerid),
          position: LatLng(fromLat, fromLong),
          icon: icon,
          anchor: const Offset(0.5, 0.5),
          infoWindow: InfoWindow(title: number, snippet: name),
          flat: true,
          draggable: false);
    }

    myMarkers.add(carMarker);

    mapMarkerSink.add(Set<Marker>.from(myMarkers).toList());

    Tween<double> tween = Tween(begin: 0, end: 1);

    _animation = tween.animate(animationController)
      ..addListener(() async {
        myMarkers
            .removeWhere((element) => element.markerId == MarkerId(markerid));

        final v = _animation!.value;

        double lng = v * toLong + (1 - v) * fromLong;

        double lat = v * toLat + (1 - v) * fromLat;

        LatLng newPos = LatLng(lat, lng);

        //New marker location

        if (name == '' && number == '') {
          carMarker = Marker(
              markerId: MarkerId(markerid),
              position: newPos,
              icon: icon,
              anchor: const Offset(0.5, 0.5),
              flat: true,
              rotation: bearing,
              draggable: false);
        } else {
          carMarker = Marker(
              markerId: MarkerId(markerid),
              position: newPos,
              icon: icon,
              infoWindow: InfoWindow(title: number, snippet: name),
              anchor: const Offset(0.5, 0.5),
              flat: true,
              rotation: bearing,
              draggable: false);
        }

        //Adding new marker to our list and updating the google map UI.

        myMarkers.add(carMarker);

        mapMarkerSink.add(Set<Marker>.from(myMarkers).toList());
      });

    //Starting the animation

    animationController.forward();

    if (driverReq.isEmpty || driverReq['is_trip_start'] == 1) {
      controller.getVisibleRegion().then((value) {
        if (value.contains(myMarkers
            .firstWhere((element) => element.markerId == MarkerId(markerid))
            .position)) {
        } else {
          controller.animateCamera(CameraUpdate.newLatLng(center));
        }
      });
    }
    animationController = null;
  }
}

class OwnerCarImagecontainer extends StatelessWidget {
  final String imgurl;
  final String text;
  final Color color;
  final void Function()? ontap;
  const OwnerCarImagecontainer(
      {Key? key,
        required this.imgurl,
        required this.text,
        required this.ontap,
        required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return InkWell(
      onTap: ontap,
      child: Container(
        padding: EdgeInsets.all(
          media.width * 0.01,
        ),
        width: media.width * 0.15,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: AssetImage(imgurl), fit: BoxFit.contain)),
              height: media.width * 0.07,
              width: media.width * 0.15,
            ),
            Container(
              height: media.width * 0.03,
              width: media.width * 0.13,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: color,
              ),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            )
          ],
        ),
      ),
    );
  }
}