import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String temp = '0';
  final myController = TextEditingController();

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      final String cityName = myController.text == '' ? "London": myController.text;
      if (kDebugMode) {
        print(cityName);
      }

      const apiKey = "d3421d6595b08f66c9b1091e2d19e645";

      final result = await http.get(
        Uri.parse(
            "http://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$apiKey"),
      );
      final data = json.decode(result.body);
      if (data['cod'] != '200') {
        throw 'An unexpected error';
      }
      return data;
      // setState(() {
      //   temp = data['list'][0]['main']['temp'].toString();
      // });
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentWeather();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
              if (kDebugMode) {
                print("refresh");
              }
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                "Enter a City Name",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: myController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(
                    left: 15,
                    right: 15,
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 53, 48, 48),
                  hintText: "London",
                  hintStyle: const TextStyle(
                    color: Color.fromARGB(171, 255, 255, 255),
                    fontSize: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        
                      });
                    },
                      child: const Icon(
                    Icons.search,
                    size: 25,
                  )),
                ),
              ),
            ),
            FutureBuilder(
              future: getCurrentWeather(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                }
                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }
                // print(snapshot.data);
        
                final data = snapshot.data!;
                final weatherData = data['list'][0];
                final currentTemp = weatherData['main']['temp'];
                final currentSky = weatherData['weather'][0]['main'];
                final currentPressure = weatherData['main']['pressure'];
                final currentWindSpeed = weatherData['wind']['speed'];
                final currentHumidity = weatherData['main']['humidity'];
        
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Main Card
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 10,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "$currentTemp °K",
                                      style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      currentSky == 'Clouds' ||
                                              currentSky == 'Rain'
                                          ? Icons.cloud
                                          : Icons.sunny,
                                      size: 64,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      currentSky,
                                      style: const TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
        
                      const SizedBox(
                        height: 20,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Weather Forecast",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
        
                      const SizedBox(height: 20),
                      // Weather forecast cards
                      // SingleChildScrollView(
                      //   scrollDirection: Axis.horizontal,
                      //   child: Row(
                      //     children: [
                      //       for (int i = 0; i < 5; i++)
                      //         ForecastCards(
                      //           icon: data['list'][i + 1]['weather'][0]['main'] ==
                      //                       'Clouds' ||
                      //                   data['list'][i + 1]['weather'][0]['main'] ==
                      //                       'Rain'
                      //               ? Icons.cloud
                      //               : Icons.sunny,
                      //           time: data['list'][i + 1]['dt'].toString(),
                      //           value: data['list'][i + 1]['main']['temp'].toString(),
                      //         ),
                      //     ],
                      //   ),
                      // ),
        
                      SizedBox(
                        height: 135,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 8,
                          itemBuilder: (context, index) {
                            final time = data['list'][index + 1]['dt_txt'];
                            final currentTime = DateTime.parse(time);
                            return ForecastCards(
                              icon: data['list'][index + 1]['weather'][0]
                                              ['main'] ==
                                          'Clouds' ||
                                      data['list'][index + 1]['weather'][0]
                                              ['main'] ==
                                          'Rain'
                                  ? Icons.cloud
                                  : Icons.sunny,
                              time: DateFormat('j').format(currentTime),
                              value:
                                  '${data['list'][index + 1]['main']['temp'].toString()} °K',
                            );
                          },
                        ),
                      ),
        
                      const SizedBox(
                        height: 20,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Additional Information",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Additional Information Cards
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ExtraInfo(
                            icons: Icons.water_drop,
                            text: "Humidity",
                            value: currentWindSpeed.toString(),
                          ),
                          ExtraInfo(
                            icons: Icons.air,
                            text: "Wind Speed",
                            value: currentHumidity.toString(),
                          ),
                          ExtraInfo(
                            icons: Icons.beach_access,
                            text: "Presssure",
                            value: currentPressure.toString(),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ForecastCards extends StatelessWidget {
  final String time;
  final IconData icon;
  final String value;
  const ForecastCards({
    super.key,
    required this.time,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(right: 20),
      elevation: 10,
      // margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 10,
          bottom: 10,
          left: 30,
          right: 30,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                time,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: Icon(
                icon,
                size: 35,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ExtraInfo extends StatelessWidget {
  final IconData icons;
  final String text;
  final String value;

  const ExtraInfo(
      {super.key,
      required this.icons,
      required this.text,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5, top: 5),
          child: Icon(
            icons,
            size: 45,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 5),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}
