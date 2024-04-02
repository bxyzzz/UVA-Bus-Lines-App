// Used online JSON to Dart Class convertor

class BusLine {
  final int agencyId;
  final List<double> bounds;
  final String color;
  final String description;
  final int id;
  final bool isActive;
  final String longName;
  final String shortName;
  final String textColor;
  final String type;
  final String url;
  bool isFavorite;

  BusLine({
    required this.agencyId,
    required this.bounds,
    required this.color,
    required this.description,
    required this.id,
    required this.isActive,
    required this.longName,
    required this.shortName,
    required this.textColor,
    required this.type,
    required this.url,
    required this.isFavorite
  });

  factory BusLine.fromJson(Map<String, dynamic> json) {
    return BusLine(
      agencyId: json['agency_id'],
      bounds: List<double>.from(json['bounds']),
      color: json['color'],
      description: json['description'],
      id: json['id'],
      isActive: json['is_active'],
      longName: json['long_name'],
      shortName: json['short_name'],
      textColor: json['text_color'],
      type: json['type'],
      url: json['url'],
      isFavorite: false,
    );
  }
} 

class BusRoute {
    int id;
    List<int> stops;

    BusRoute({
        required this.id,
        required this.stops,
    });

  factory BusRoute.fromJson(Map<String, dynamic> json) {
    return BusRoute(
      id: json['id'],
      stops: List<int>.from(json['stops']),
    );
  }

}

class Stop {
    String code;
    String description;
    int id;
    String locationType;
    String name;
    dynamic parentStationId;
    List<double> position;
    String url;

    Stop({
        required this.code,
        required this.description,
        required this.id,
        required this.locationType,
        required this.name,
        required this.parentStationId,
        required this.position,
        required this.url,
    });

    factory Stop.fromJson(Map<String, dynamic> json) {
      return Stop(
        code: json['code'],
        description: json['description'],
        id: json['id'],
        locationType: json['location_type'],
        name: json['name'],
        parentStationId: json['parent_station_id'],
        position: List<double>.from(json['position']),
        url: json['url'],
    );
  }

}

/*

class BusInfo {
    List<BusLine> lines;
    List<Route> routes;
    List<Stop> stops;
    bool success;

    BusInfo({
        required this.lines,
        required this.routes,
        required this.stops,
        required this.success,
    });

}

class BusLine {
    int agencyId;
    List<double> bounds;
    String color;
    String description;
    int id;
    bool isActive;
    String longName;
    String shortName;
    String textColor;
    Type type;
    String url;
    bool isFavorite;

    BusLine({
        required this.agencyId,
        required this.bounds,
        required this.color,
        required this.description,
        required this.id,
        required this.isActive,
        required this.longName,
        required this.shortName,
        required this.textColor,
        required this.type,
        required this.url,
        required this.isFavorite
    });

factory BusLine.fromJson(Map<String, dynamic> json) {
    return BusLine(
      agencyId: json['agency_id'],
      bounds: List<double>.from(json['bounds']),
      color: json['color'],
      description: json['description'],
      id: json['id'],
      isActive: json['is_active'],
      longName: json['long_name'],
      shortName: json['short_name'],
      textColor: json['text_color'],
      type: json['type'],
      url: json['url'],
      isFavorite: false,
    );
  }
}

enum Type {
    BUS
}

class Route {
    int id;
    List<int> stops;

    Route({
        required this.id,
        required this.stops,
    });

}

class Stop {
    String code;
    String description;
    int id;
    LocationType locationType;
    String name;
    dynamic parentStationId;
    List<double> position;
    String url;

    Stop({
        required this.code,
        required this.description,
        required this.id,
        required this.locationType,
        required this.name,
        required this.parentStationId,
        required this.position,
        required this.url,
    });

}

enum LocationType {
    STOP
}
*/