class BusLines {
    List<Line> lines;
    List<Route> routes;
    List<Stop> stops;
    bool success;

    BusLines({
        required this.lines,
        required this.routes,
        required this.stops,
        required this.success,
    });

}

class Line {
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

    Line({
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
    });

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
