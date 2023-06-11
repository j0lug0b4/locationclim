import 'package:geolocator/geolocator.dart';
import 'package:locationclim/model/weather_model.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:locationclim/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:convert';

import 'package:locationclim/model/weather_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<Weather>? dataState;
  final LocationService locationService = LocationService();
  @override
  void initState() {
    // TODO: implement initState

    dataState = getWeather();

    latitude = position!.latitude.toString();
    longitude = position!.longitude.toString();

    super.initState();
  }

  String latitude = "6.2387073";
  String longitude = "-75.5862931";
  Future<Weather> getWeatherf(String lat, String lon) async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }

    setState(() {
      latitude = lat;
      longitude = lon;
    });

    String url =
        'http://api.openweathermap.org/data/2.5/weather?lat=${latitude}&lon=${longitude}&APPID=e55b3576f60986730b6077e448b74e10';
    final response = await http.get(Uri.parse(url));
    return Weather.fromJson(json.decode(response.body));
  }

  Position? position;
  Future<Weather> getWeather() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }

    position = await Geolocator.getCurrentPosition();
    setState(() {
      position = position;
      latitude = position!.latitude.toString();
      longitude = position!.longitude.toString();
    });
    String url =
        'http://api.openweathermap.org/data/2.5/weather?lat=${position?.latitude}&lon=${position?.longitude}&APPID=e55b3576f60986730b6077e448b74e10';
    final response = await http.get(Uri.parse(url));
    return Weather.fromJson(json.decode(response.body));
  }

  String _fechaformato(DateTime selectedDate) {
    String formato = DateFormat('dd/MM/yyyy').format(selectedDate);
    return formato;
  }

  void _pickDateDialog(String latitude, String longitude) {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;

        upData(_selectedDate);
        var fecha = DateFormat('yyyy-MM-dd').format(_selectedDate);
        print(fecha);
      });
    });
  }

  void upData(DateTime selectedDate) async {
    var fecha = DateFormat('yyyy-MM-dd').format(selectedDate);
  }

  late DateTime _selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'LocationClim',
          style: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: size.width * 0.080,
          ),
        ),
        backgroundColor: Colors.amber,
        elevation: 0.0,
        centerTitle: true,
      ),
      body: Container(
          child: SingleChildScrollView(
              child: Column(
        children: [
          position!.latitude == null ||
                  position!.longitude == null ||
                  position!.latitude == "" ||
                  position!.longitude == "" ||
                  position == null
              ? Container()
              : Container(
                  height: size.height * 0.5,
                  width: size.width * 0.8,
                  child: OpenStreetMapSearchAndPick(
                    center: LatLong(position!.latitude, position!.longitude),
                    buttonColor: Colors.blue,
                    buttonText: 'Buscar Ubicación',
                    onPicked: (pickedData) {
                      print(pickedData.latLong.latitude);
                      print(pickedData.latLong.longitude);

                      setState(() {
                        dataState = getWeatherf(
                            pickedData.latLong.latitude.toString(),
                            pickedData.latLong.longitude.toString());
                      });
                    },
                    onGetCurrentLocationPressed: locationService.getPosition,
                  ),
                ),
          FutureBuilder<Weather>(
            future: dataState,
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? Container(
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            const SizedBox(height: 20.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.deepOrangeAccent,
                                        //onPrimary: Colors.black,
                                      ),
                                      child: Text(
                                        _fechaformato(_selectedDate),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      onPressed: () {
                                        _pickDateDialog(latitude, longitude);
                                      },
                                    ),
                                  ),
                                ),
                                Container(
                                  color: Colors.amber,
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: 80.0,
                                    child: Text(
                                      "Hoy",
                                      style: GoogleFonts.nunitoSans(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image:
                                        AssetImage('assets/images/header.png'),
                                    alignment: Alignment.centerRight),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(
                                      snapshot.data!.name,
                                      style: GoogleFonts.nunitoSans(
                                        fontSize: size.width * 0.08,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 10.0),
                                    Text(
                                      'Dia ${(snapshot.data!.main.tempMax - 273.15).toInt()}° ↑ • Noche ${(snapshot.data!.main.tempMin - 273.15).toInt()}° ↓',
                                      style: GoogleFonts.nunitoSans(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          '${(snapshot.data!.main.temp - 273.15).toInt()}°',
                                          style: GoogleFonts.nunitoSans(
                                            fontSize: 100.0,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Image.network(
                                              'http://openweathermap.org/img/wn/${snapshot.data!.weather[0].icon}.png',
                                              height: 40,
                                            ),
                                            snapshot.data!.weather[0]
                                                    .description
                                                    .contains(' ')
                                                ? Text(
                                                    '${snapshot.data!.weather[0].description.split(' ')[0][0].toUpperCase()}${snapshot.data!.weather[0].description.split(' ')[0].substring(1)}\n${snapshot.data!.weather[0].description.split(' ')[1][0].toUpperCase()}${snapshot.data!.weather[0].description.split(' ')[1].substring(1)}',
                                                    style:
                                                        GoogleFonts.nunitoSans(
                                                            fontSize: 16.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                    textAlign: TextAlign.center,
                                                  )
                                                : Text(
                                                    snapshot.data!.weather[0]
                                                            .description[0]
                                                            .toUpperCase() +
                                                        snapshot
                                                            .data!
                                                            .weather[0]
                                                            .description
                                                            .substring(1),
                                                    style:
                                                        GoogleFonts.nunitoSans(
                                                            fontSize: 16.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                    textAlign: TextAlign.center,
                                                  ),
                                            const SizedBox(height: 5.0)
                                          ],
                                        )
                                      ],
                                    ),
                                    Text(
                                      '${(snapshot.data!.main.feelsLike - 273.15).toInt()}°',
                                      style: GoogleFonts.nunitoSans(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(40, 20, 40, 5),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Detalles',
                                style: GoogleFonts.nunitoSans(
                                    fontSize: 26.0,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Container(
                                        child: Container(
                                          alignment: Alignment.center,
                                          width: 140.0,
                                          height: 120.0,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: Container(
                                                  height: 5.0,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0),
                                                      color: Colors
                                                          .lightBlueAccent),
                                                ),
                                              ),
                                              const SizedBox(height: 20.0),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Image.asset(
                                                    'assets/images/drop.png',
                                                    width: 20,
                                                  ),
                                                  Text(
                                                    "  Humedad",
                                                    style:
                                                        GoogleFonts.nunitoSans(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 16.0),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6.0),
                                              Text(
                                                "${snapshot.data!.main.humidity}%",
                                                style: GoogleFonts.nunitoSans(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 24.0),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.white,
                                        child: Container(
                                          alignment: Alignment.center,
                                          width: 140.0,
                                          height: 120.0,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: Container(
                                                  height: 5.0,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0),
                                                      color:
                                                          Colors.orangeAccent),
                                                ),
                                              ),
                                              const SizedBox(height: 20.0),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Image.asset(
                                                    'assets/images/sunny.png',
                                                    width: 20,
                                                  ),
                                                  Text(
                                                    "  Visibilidad",
                                                    style:
                                                        GoogleFonts.nunitoSans(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 16.0),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6.0),
                                              Text(
                                                snapshot.data!.visibility
                                                            .toString() ==
                                                        'null'
                                                    ? 'N/A'
                                                    : '${snapshot.data!.visibility} m',
                                                style: GoogleFonts.nunitoSans(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 24.0),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10.0),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Container(
                                        color: Colors.white,
                                        child: Container(
                                          alignment: Alignment.center,
                                          width: 140.0,
                                          height: 120.0,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: Container(
                                                  height: 5.0,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0),
                                                      color:
                                                          Colors.purpleAccent),
                                                ),
                                              ),
                                              const SizedBox(height: 20.0),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Image.asset(
                                                    'assets/images/wind.png',
                                                    width: 20,
                                                  ),
                                                  Text(
                                                    "  Vientos",
                                                    style:
                                                        GoogleFonts.nunitoSans(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 16.0),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6.0),
                                              Text(
                                                "${snapshot.data!.wind.speed.toStringAsFixed(1)} km/h",
                                                style: GoogleFonts.nunitoSans(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 24.0),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        color: Colors.white,
                                        child: Container(
                                          alignment: Alignment.center,
                                          width: 140.0,
                                          height: 120.0,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: Container(
                                                  height: 5.0,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0),
                                                      color: Colors.pinkAccent),
                                                ),
                                              ),
                                              const SizedBox(height: 20.0),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Image.asset(
                                                    'assets/images/brakes.png',
                                                    width: 20,
                                                  ),
                                                  Text(
                                                    "  Presurisación",
                                                    style:
                                                        GoogleFonts.nunitoSans(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 16.0),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6.0),
                                              Text(
                                                "${snapshot.data!.main.pressure} hPa",
                                                style: GoogleFonts.nunitoSans(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 24.0),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(
                          backgroundColor: Colors.black),
                    );
            },
          )
        ],
      ))),
    );
  }
}
