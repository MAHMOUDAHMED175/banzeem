import 'package:flutter/material.dart';

import 'package:sensors_plus/sensors_plus.dart'; // Make sure to import this

class MetroHomePage extends StatefulWidget {
  const MetroHomePage({super.key});

  @override
  _MetroHomePageState createState() => _MetroHomePageState();
}

class _MetroHomePageState extends State<MetroHomePage> {
  final RouteFormatter routeFormatter = RouteFormatter();

  String startStation = "";
  String endStation = "";
  String routeString = "";
  String initialDirection = "";
  String expectedTime = "";
  String ticketPrice = "";

  List<String> selectedStations = [];
  int numberOfStationsBetween = 0;
  @override
  void initState() {
    super.initState();
    // Subscribe to accelerometer updates
    accelerometerEvents.listen((AccelerometerEvent event) {
      // Check the tilt of the phone
      if (event.x.abs() > 3 || event.y.abs() > 3) {
        resetSelections();
      }
    });
  }

  void resetSelections() {
    setState(() {
      startStation = "";
      endStation = "";
      routeString = "";
      initialDirection = "";
      expectedTime = "";
      ticketPrice = "";
      numberOfStationsBetween = 0;
      selectedStations.clear(); // Clear the selected stations
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cairo Metro Route Finder'),
        backgroundColor: Colors.red[700],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Start Station:'),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return routeFormatter.stationRepository
                      .getLines()
                      .expand((line) => line.stations)
                      .where((station) => station
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase()))
                      .toList();
                },
                onSelected: (String selection) {
                  setState(() {
                    if (selectedStations.isEmpty) {
                      selectedStations.add(selection);
                      startStation = selection;
                    } else if (selectedStations.length == 1) {
                      selectedStations.add(selection);
                      endStation = selection;
                    }

                    if (selectedStations.length == 2) {
                      routeFormatter.getInitialDirection(selectedStations);
                      // routeString =
                      //     routeFormatter.getRouteString(selectedStations);
                      initialDirection =
                          routeFormatter.getInitialDirectionText();
                      expectedTime = getExpectedTime(selectedStations.length);
                      ticketPrice = getTicketPrice(selectedStations.length);
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Select end Station:'),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return routeFormatter.stationRepository
                      .getLines()
                      .expand((line) => line.stations)
                      .where((station) => station
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase()))
                      .toList();
                },
                onSelected: (String selection) {
                  setState(() {
                    if (selectedStations.isEmpty) {
                      selectedStations.add(selection);
                      startStation = selection;
                    } else if (selectedStations.length == 1) {
                      selectedStations.add(selection);
                      endStation = selection;
                    }

                    if (selectedStations.length == 2) {
                      routeFormatter.getInitialDirection(selectedStations);
                      //             final result = routeFormatter.getRouteString(selectedStations);
                      // routeString = result['route'];
                      // numberOfStationsBetween = result['stationCount'];

                      initialDirection =
                          routeFormatter.getInitialDirectionText();
                      expectedTime = getExpectedTime(selectedStations.length);
                      ticketPrice = getTicketPrice(selectedStations.length);
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (selectedStations.length == 2) {
                      final result =
                          routeFormatter.getRouteString(selectedStations);
                      routeString = result['route'];
                      numberOfStationsBetween = result['stationCount'] + 2;

                      initialDirection =
                          routeFormatter.getInitialDirectionText();
                      expectedTime =
                          getExpectedTime(result['stationCount'] + 2);
                      ticketPrice = getTicketPrice(result['stationCount'] + 2);
                    } else {
                      routeString =
                          "Please select both start and end stations.";
                    }
                  });
                  setState(() {});
                  selectedStations.clear();
                },
                child: const Text('New Route'),
              ),
              const SizedBox(height: 16),
              Text(
                "Route Summary:\n\nStart Station = $startStation\n\nEnd Station = $endStation\n\nNumber Of Stations = $numberOfStationsBetween\n\nShortest Route = $routeString\n\nDirection = $initialDirection\n\nExpected Time = $expectedTime\n\nTicket Price = $ticketPrice",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // حساب الوقت المتوقع بناءً على عدد المحطات
  String getExpectedTime(int numberOfStations) {
    int minutesPerStation = 2; // نفترض أن كل محطة تستغرق حوالي دقيقتين
    int totalMinutes = numberOfStations * minutesPerStation;

    // حساب الساعات والدقائق
    int hours = totalMinutes ~/ 60; // قسمة صحيحة للحصول على عدد الساعات
    int minutes = totalMinutes % 60; // باقي القسمة للحصول على عدد الدقائق

    // بناء سلسلة الوقت
    String timeString = "";
    if (hours > 0) {
      timeString += "$hours hours ";
    }
    timeString += "$minutes minutes";

    return timeString;
  }

  // حساب سعر التذكرة بناءً على عدد المحطات
  String getTicketPrice(int numberOfStations) {
    if (numberOfStations <= 7) {
      return "8 EGP";
    } else if (numberOfStations <= 14) {
      return "15 EGP";
    } else {
      return "25 EGP";
    }
  }
}

class StationRepository {
  // قائمة المحطات لكل خط
  List<MetroLine> getLines() {
    return [
      MetroLine("Line 1", [
        "Helwan",
        "Ain Helwan",
        "Helwan University",
        "Wadi Hof",
        "Hadayek Helwan",
        "El-Maasara",
        "Tora El-Asmant",
        "Kolet El-Maadi",
        "Tora El-Balad",
        "Sakanat El-Maadi",
        "Maadi",
        "Hadayek El-Maadi",
        "Dar El-Salam",
        "Zahraa El-Maadi",
        "Mar Girgis",
        "El-Malek El-Saleh",
        "Sayeda Zeinab",
        "Saad Zaghloul",
        "Sadat",
        "Nasser",
        "Orabi",
        "Al-Shohadaa",
        "Ghamra",
        "El-Demerdash",
        "Manshiet El-Sadr",
        "Kobri El-Qobba",
        "Hammamat El-Qobba",
        "Saray El-Qobba",
        "Hadayek El-Zaitoun",
        "Helmeyet El-Zaitoun",
        "El-Matareyya",
        "Ain Shams",
        "Ezbet El-Nakhl",
        "El-Marg",
        "New El-Marg"
      ]),
      // MetroLine("Line 2", [
      //   "Shubra El-Kheima",
      //   "Kolleyet El-Zeraa",
      //   "El-Mazallat",
      //   "El-Khalafawi",
      //   "Saint Teresa",
      //   "Rod El-Farag",
      //   "Massara",
      //   "Al-Shohadaa",
      //   "Attaba",
      //   "Mohamed Naguib",
      //   "Sadat",
      //   "Opera",
      //   "Dokki",
      //   "El Bohoth",
      //   "Cairo University",
      //   "Faisal",
      //   "Giza",
      //   "Omm El-Misryeen",
      //   "Sakiat Mekki",
      //   "El-Mounib"
      // ]),
      // MetroLine("Line 3", [
      //   "Adly Mansour",
      //   "El Haykestep",
      //   "Omar Ibn El Khattab",
      //   "Qobaa",
      //   "Hesham Barakat",
      //   "El Nozha",
      //   "Nadi El Shams",
      //   "Alf Maskan",
      //   "Heliopolis",
      //   "Haroun",
      //   "Al Ahram",
      //   "Koleyet El Banat",
      //   "Stadium",
      //   "El Maarad",
      //   "Abbassia",
      //   "Abdou Pasha",
      //   "El Geish",
      //   "Bab El Shaaria",
      //   "Attaba",
      //   "Nasser",
      //   "Maspero",
      //   "Safaa Hegazy",
      //   "Kit Kat",
      //   "Sudan",
      //   "Imbaba",
      //   "El Bohy",
      //   "Al Qawmia",
      //   "Ring Road",
      //   "Rod al-Farag Axis"
      // ])
    ];
  }
}

class MetroLine {
  final String name;
  final List<String> stations;

  MetroLine(this.name, this.stations);
}

class RouteFormatter {
  final StationRepository stationRepository = StationRepository();
  String? initialDirection;
  String? route;

  // void getInitialDirection(List<String> stations) {
  //   List<String> line1Stations = stationRepository.getLines()[0].stations;
  //   List<String> line2Stations = stationRepository.getLines()[1].stations;
  //   List<String> line3Stations = stationRepository.getLines()[2].stations;

  //   if (line1Stations.contains(stations[0]) &&
  //       line1Stations.contains(stations[1])) {
  //     initialDirection = line1Stations.indexOf(stations[1]) >
  //             line1Stations.indexOf(stations[0])
  //         ? "New El-Marg"
  //         : "Helwan";
  //   } else if (line2Stations.contains(stations[0]) &&
  //       line2Stations.contains(stations[1])) {
  //     initialDirection = line2Stations.indexOf(stations[1]) >
  //             line2Stations.indexOf(stations[0])
  //         ? "El-Mounib"
  //         : "Shubra El-Kheima";
  //   } else if (line3Stations.contains(stations[0]) &&
  //       line3Stations.contains(stations[1])) {
  //     initialDirection = line3Stations.indexOf(stations[1]) >
  //             line3Stations.indexOf(stations[0])
  //         ? "Rod al-Farag Axis"
  //         : "Adly Mansour";
  //   }
  // }
  void getInitialDirection(List<String> stations) {
    List<MetroLine> lines = stationRepository.getLines();

    for (MetroLine line in lines) {
      List<String> lineStations = line.stations;

      if (lineStations.contains(stations[0]) &&
          lineStations.contains(stations[1])) {
        initialDirection = lineStations.indexOf(stations[1]) >
                lineStations.indexOf(stations[0])
            ? getDirectionForLine(line.name, true) // الاتجاه للأمام
            : getDirectionForLine(line.name, false); // الاتجاه للخلف
        return; // نخرج من الدالة بعد العثور على الاتجاه
      }
    }
  }

  String getDirectionForLine(String lineName, bool isForward) {
    switch (lineName) {
      case "Line 1":
        return isForward ? "New El-Marg" : "Helwan";
      default:
        return "Unknown Direction"; // في حالة عدم التعرف على الخط
    }
  }

  Map<String, dynamic> getRouteString(List<String> stations) {
    StringBuffer routeString = StringBuffer();
    int stationCount = 0;

    // Get all metro lines
    List<MetroLine> lines = stationRepository.getLines();

    for (MetroLine line in lines) {
      List<String> lineStations = line.stations;

      // Check if both stations are on the same line
      if (lineStations.contains(stations[0]) &&
          lineStations.contains(stations[1])) {
        int startIndex = lineStations.indexOf(stations[0]);
        int endIndex = lineStations.indexOf(stations[1]);

        // Determine the correct start and end indexes based on the order of stations
        if (startIndex > endIndex) {
          // Swap if the start station is after the end station
          int temp = startIndex;
          startIndex = endIndex;
          endIndex = temp;
        }

        // Count the number of stations between the two stations
        stationCount = (endIndex - startIndex).abs() -
            1; // Exclude the start and end stations

        // Construct the route string
        for (int i = startIndex; i <= endIndex; i++) {
          routeString.write(lineStations[i]);
          if (i < endIndex) {
            routeString.write(" -> ");
          }
        }

        // إذا كانت المحطة الأولى أكبر من المحطة الثانية، اعكس سلسلة المسار
        if (lineStations.indexOf(stations[0]) >
            lineStations.indexOf(stations[1])) {
          String route = routeString.toString();
          // عكس السلسلة
          List<String> routeParts = route.split(" -> ");
          routeParts = routeParts.reversed.toList();
          routeString.clear(); // تنظيف السلسلة الحالية
          routeString.write(routeParts.join(" -> "));
        }

        break; // Exit loop once we find the line containing the stations
      }
    }
    return {
      'route': routeString.toString(),
      'stationCount': stationCount,
    };
  }

  String getInitialDirectionText() {
    return initialDirection ?? "Unknown Direction";
  }
}
