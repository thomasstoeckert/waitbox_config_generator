import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:waitbox_config_generator/data/attraction.dart';
import 'package:waitbox_config_generator/data/park.dart';

class ThemeparksManager {
  /* -- Singleton Construction -- */
  static final ThemeparksManager _themeparksManager =
      ThemeparksManager._internal();

  factory ThemeparksManager() {
    return _themeparksManager;
  }

  ThemeparksManager._internal();

  /* -- Environment-ish variables -- */
  static const _urlDestinations = "https://api.themeparks.wiki/v1/destinations";
  static const _urlChildrenBase = "https://api.themeparks.wiki/v1/entity/";
  static const _urlChildrenSlug = "/children";

  /* -- ThemeparksManager Functions -- */
  // We cache results during the life of the program for speedier use
  Map<String, Park> parks = {};

  Future<List<Park>> getParks() async {
    // Check to see if we have parks in our parks list
    // If so, return that
    if (parks.isNotEmpty) return List.from(parks.values);

    // Otherwise, we must get this information from the server

    Uri url = Uri.parse(_urlDestinations);
    http.Response response = await http.get(url);

    if (kDebugMode) {
      print("Destinations Request Outcome: ");
      print("\tResponse Status: ${response.statusCode}");
      print("\tResponse Size: ${response.body.length}");
    }

    if (response.statusCode != 200) {
      // Something went wrong. Raise an exception
      throw Exception(
          "Web Request Failed: Code ${response.statusCode}, ${response.body}");
    }

    // Get the body of our response as a string, parse it as a JSON object
    Map parsedResponse = jsonDecode(response.body);

    // The result should contain a list of destinations. We need to extract
    // the parks from this list.
    List<dynamic> destinations = parsedResponse["destinations"];
    for (var destination in destinations) {
      // Get the parks for this destination
      List<dynamic> destinationParks = destination["parks"];
      // Parse the park
      for (var parkMap in destinationParks) {
        Park parsedPark = Park.fromJSON(parkMap);
        parks[parsedPark.entityID] = parsedPark;
      }
    }

    return List.from(parks.values);
  }

  Future<List<Attraction>> getAttractions(String parkID) async {
    // Check to see if that park (if we have it) already has attraction data.
    // If so, return that
    if (parks[parkID]?.attractions.isNotEmpty ?? false) {
      return parks[parkID]!.attractions;
    }

    // Otherwise, we must get this information from the server

    Uri url = Uri.parse(_urlChildrenBase + parkID + _urlChildrenSlug);
    http.Response response = await http.get(url);

    if (kDebugMode) {
      print("Children Request Outcome: ");
      print("\tResponse Status: ${response.statusCode}");
      print("\tResponse Size: ${response.body.length}");
    }

    if (response.statusCode != 200) {
      // Something went wrong. Raise an exception
      throw Exception(
          "Web Request Failed: Code ${response.statusCode}, ${response.body}");
    }

    // Get the body of our response as a string, parse it as a JSON object
    Map parsedResponse = jsonDecode(response.body);

    // Create a new park based off of this information
    Park populatedPark = Park.fromJSON(parsedResponse);
    parks[populatedPark.entityID] = populatedPark;

    return populatedPark.attractions;
  }
}
