import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:waitbox_config_generator/data/api_key.dart';
import 'package:waitbox_config_generator/data/attraction.dart';
import 'package:waitbox_config_generator/data/config.dart';
import 'package:waitbox_config_generator/data/park.dart';
import 'package:waitbox_config_generator/managers/themeparks_manager.dart';
import 'package:waitbox_config_generator/ui/widgets/attraction_list_entry.dart';
import 'package:waitbox_config_generator/ui/widgets/generic_list.dart';
import 'package:waitbox_config_generator/ui/widgets/park_list_entry.dart';
import 'package:waitbox_config_generator/ui/widgets/refresh_frequency_dialog.dart';
import 'package:waitbox_config_generator/ui/widgets/space_estimator.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final ThemeparksManager tpManager = ThemeparksManager();
  late Future<List<Park>> parks;
  Future<List<Attraction>>? attractions;

  Park? selectedPark;
  late Configuration configuration;

  late ScrollController leftScrollController, rightScrollController;

  @override
  void initState() {
    leftScrollController = ScrollController();
    rightScrollController = ScrollController();

    parks = tpManager.getParks();
    configuration = Configuration(parks: {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FutureBuilder<List<Park>>(
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Park>> snap) {
                          return GenericList(
                            title: "Supported Parks",
                            controller: leftScrollController,
                            placeholder: (snap.hasData)
                                ? null
                                : const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                            itemCount: (snap.hasData) ? snap.data!.length : 25,
                            itemBuilder: ((c, i) {
                              if (!snap.hasData) return Container();

                              Park park = snap.data![i];
                              int numAttractionsTracked = 0;
                              if (configuration.parks
                                  .containsKey(park.entityID)) {
                                numAttractionsTracked =
                                    configuration.parks[park.entityID]!.length;
                              }

                              return ParkListEntry(
                                parkName: park.name,
                                numAttractionsTracked: numAttractionsTracked,
                                onTap: () => handleParkTapped(park),
                                onDeleteTapped: () =>
                                    handleParkDeleteTapped(park),
                              );
                            }),
                          );
                        },
                        future: parks,
                      ),
                      FutureBuilder<List<Attraction>>(
                          future: attractions,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Attraction>> snap) {
                            return GenericList(
                              title: selectedPark?.name ?? "Attractions",
                              controller: rightScrollController,
                              placeholder: (snap.hasData)
                                  ? null
                                  : const Center(
                                      child: Text(
                                          "Tap on a park to view that park's attractions"),
                                    ),
                              itemCount:
                                  (snap.hasData) ? snap.data!.length : 25,
                              itemBuilder: ((c, i) {
                                Attraction attraction = snap.data![i];

                                bool isTracked = configuration
                                        .parks[selectedPark?.entityID]
                                        ?.contains(attraction.entityID) ??
                                    false;

                                return AttractionListEntry(
                                  attractionName: attraction.name,
                                  attractionType: toBeginningOfSentenceCase(
                                      attraction.entityType.toLowerCase())!,
                                  isTracked: isTracked,
                                  onTap: () => handleAttractionTapped(
                                      selectedPark!.entityID,
                                      attraction.entityID),
                                );
                              }),
                            );
                          }),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                          onPressed: handleRefreshFrequencyDialog,
                          child: const Text("Change Refresh Frequency")),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      ),
                      ElevatedButton(
                          onPressed: handlePasteConfig,
                          child:
                              const Text("Load Configuration From Clipboard")),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      ),
                      ElevatedButton(
                          onPressed: handleCopyConfig,
                          child: const Text("Copy Configuration to Clipboard")),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      ),
                      ElevatedButton(
                          onPressed: handlePastebinSubmit,
                          child: const Text("Upload Configuration to Pastebin"))
                    ],
                  ),
                )
              ],
            ),
            SpaceEstimator(
                numLines: configuration.calculateCurrentRowNumber(),
                maxLines: 35)
          ],
        ),
      ),
    );
  }

  void handleParkTapped(Park tappedPark) {
    attractions = tpManager.getAttractions(tappedPark.entityID);

    // Jump to the top of the attractions list
    if (rightScrollController.hasClients) {
      rightScrollController.jumpTo(0);
    }

    setState(() {
      selectedPark = tappedPark;
    });
  }

  void handleParkDeleteTapped(Park park) async {
    // Confirm that this is what the user wants
    bool? result = await showDialog(
        context: context,
        builder: (b) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0)),
              title: const Text("Delete Park Data"),
              content: Text(
                  "Are you sure you want to remove all tracking data for ${park.name}?"),
              actions: [
                MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  child: const Text("Yes"),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
                MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.of(context).pop(false),
                )
              ],
            ));

    // If the user says no, or cancels, don't do anything
    if ((result ?? false) == false) return;

    // Otherwise, remove any and all attraction data for this park from a new configuration object
    setState(() {
      configuration.parks.remove(park.entityID);
    });
  }

  void handleAttractionTapped(String parkID, String attractionID) {
    // Get the current state of the attraction (is tracked or not)

    // First: is the park tracked?
    bool isParkTracked = configuration.parks.containsKey(parkID);
    if (!isParkTracked) {
      // If the park isn't tracked, our job is easy. Create a new list that
      // contains only this attraction, store it in the configuration, and update
      setState(() {
        configuration.parks[parkID] = [attractionID];
      });
      return;
    }

    // Second: is the attraction tracked?
    bool isAttractionTracked =
        configuration.parks[parkID]!.contains(attractionID);
    if (isAttractionTracked) {
      // If the attraction is already tracked, we want to remove it from the
      // tracked list.

      // We also want to remove that park from the tracked list if that tracked
      // list is now empty.
      setState(() {
        configuration.parks[parkID]!.remove(attractionID);

        if (configuration.parks[parkID]!.isEmpty) {
          configuration.parks.remove(parkID);
        }
      });
    } else {
      // If the attraction isn't tracked, we want to add it to the tracked list
      setState(() {
        configuration.parks[parkID]!.add(attractionID);
      });
    }
  }

  String getResults({bool prettyPrint = false}) {
    // Format the config as a string, and return that
    Map toEncode = configuration.toJSON();
    if (prettyPrint) {
      return (const JsonEncoder.withIndent('    ')).convert(toEncode);
    } else {
      return jsonEncode(toEncode);
    }
  }

  void handlePasteConfig() async {
    // Get the information from the user's clipboard
    String clipboardData = await FlutterClipboard.paste();

    try {
      // Load this information in as a new configuration object
      Map parsedData = jsonDecode(clipboardData);
      Configuration newConfiguration = Configuration.fromJSON(parsedData);
      setState(() {
        configuration = newConfiguration;
      });
    } catch (e) {
      showDialog(
          context: context,
          builder: (b) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                title: const Text("Config Load Error"),
                content: Text("Unable to parse clipboard data:\n$e"),
                actions: [
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0)),
                    child: const Text("Ok"),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ));
    }
  }

  void handleCopyConfig() async {
    // Get the results, and load them into the user's clipboard, notifying them
    String results = getResults();
    await FlutterClipboard.copy(results);

    // Display a dialog to the user, informing them that the copying has been successful
    showDialog(
        context: context,
        builder: (b) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0)),
              title: const Text("Configuration Data Copied"),
              content: const Text(
                  "Your configuration has been copied to your clipboard."),
              actions: [
                MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  child: const Text("Ok"),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ));
  }

  void handlePastebinSubmit() async {
    // Get our API key from our API key file
    const String apiKey = pastebinAPIKey;
    const String pastebinAPIBase = "https://pastebin.com/api/api_post.php";

    String results = getResults(prettyPrint: true);

    Uri url = Uri.parse(pastebinAPIBase);
    http.Response response = await http.post(url, body: {
      "api_dev_key": apiKey,
      "api_option": "paste",
      "api_paste_code": results,
      "api_paste_format": "json",
      "api_paste_private": "1"
    });

    if (response.statusCode != 200) {
      showDialog(
          context: context,
          builder: (b) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                title: const Text("Pastebin Upload Error"),
                content: Text("HTTP Request Error: ${response.statusCode}"),
                actions: [
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0)),
                    child: const Text("Ok"),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ));
      return;
    }

    // Copy the message to the user's clipboard
    await FlutterClipboard.copy(response.body);

    // Display to the user a dialog informing them about the newly-created page
    showDialog(
        context: context,
        builder: (b) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0)),
              title: const Text("Pastebin Upload Success"),
              content: const Text(
                  "Your configuration has been uploaded to pastebin. The URL has been copied to your clipboard, or, you can open the page by clicking the button below."),
              actions: [
                MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  child: const Text("Open Page"),
                  onPressed: () async {
                    await launch(response.body);
                    Navigator.of(context).pop();
                  },
                ),
                MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  child: const Text("Dismiss"),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ));
  }

  void handleRefreshFrequencyDialog() async {
    // Display our dialog to the user
    int? result =
        await showDialog(context: context, builder: (BuildContext context) {
          return RefreshFrequencyDialog(refreshFrequency: configuration.refreshFrequency)
        });
    
    if(result == null) return;

    // Update with our results.
    setState(() {
      // Update our frequency
      configuration = Configuration(refreshFrequency: result, parks: configuration.parks);      
    });
  }
}
