import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';



class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref("App/1");
  double _currentWaterTemperature = 37.0;
  int _currentGeyserStatus = 0;
  int _currentPowerSource = 1;
  String _emoji = "😎"; // Default emoji for normal temperature

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: StreamBuilder<DatabaseEvent>(
              stream: _databaseReference.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  Map<dynamic, dynamic> object = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

                  // Update current values based on the snapshot
                  _currentWaterTemperature = double.parse(object["current_water_temperature"].toString());
                  _currentPowerSource = int.parse(object["power_source"].toString());
                  _currentGeyserStatus = _currentWaterTemperature > 0 ? 1 : 0;

                  // Update emoji based on temperature
                  _emoji = _getTemperatureEmoji(_currentWaterTemperature);
                } else {
                  return const Center(child: Text("No data available"));
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Emoji for temperature display
                    Text(
                      _emoji,
                      style: const TextStyle(fontSize: 100),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Temperature: $_currentWaterTemperature°C",
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 20),

                    // Row for geyser status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          "Geyser Status: ",
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          _currentGeyserStatus == 0 ? "OFF" : "ON",
                          style: TextStyle(
                            fontSize: 18,
                            color: _currentGeyserStatus == 0 ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Power Source: ${_currentPowerSource == 0 ? "GAS" : "ELECTRICITY"}",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }

  // Function to determine emoji based on temperature
  String _getTemperatureEmoji(double temperature) {
    if (temperature >= 40) {
      return "🥵"; // Hot
    } else if (temperature <= 25) {
      return "🥶"; // Cold
    } else {
      return "😎"; // Normal
    }
  }
}
