import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((_) {
    runApp(MaterialApp(
      home: StoredListUI(),
    ));
  });
}

class StoredListUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Avatar Screen'),
      ),
      body: Row(
        children: [
          Expanded(
            child: ListView(
              children: [
                Center(
                  child: Text("Priority/My New Place"),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Listing',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        TextButton(
                          onPressed: () {
                            // Perform action for the first button
                          },
                          child: Text('Bus'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Perform action for the second button
                          },
                          child: Text('Map'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Perform action for the third button
                          },
                          child: Text('Documents'),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage(
                          'assets/images/happy.png'), // Replace with your own avatar image
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        TextButton(
                          onPressed: () {
                            // Perform action for the first button on the right
                          },
                          child: Text('Progress'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Perform action for the second button on the right
                          },
                          child: Text('Viewed'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Perform action for the third button on the right
                          },
                          child: Text('Notes'),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Center(
                  child: Text("Anne Elk"),
                ),
                SizedBox(height: 1),
                Center(
                  child: Text("700 West Georgia"),
                ),
                SizedBox(height: 1),
                Center(
                  child: Text("\$1690 / Month"),
                ),
                SizedBox(height: 8.0),
                Container(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🔷',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 1.0),
                        Text(
                          '🔷 ayla@hushmail.com',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 1.0),
                        Text(
                          '🔷 728-200-0003',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(), // Empty container for the right column
          ),
        ],
      ),
    );
  }
}
