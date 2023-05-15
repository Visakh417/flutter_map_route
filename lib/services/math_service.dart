import 'dart:math';
import 'package:latlong2/latlong.dart';

LatLng nearestPointOnLine(LatLng point1, LatLng point2, LatLng givenPoint) {
  // Step 1: calculate slope
  final slope = (point2.latitude - point1.latitude) / (point2.longitude - point1.longitude);

  // Step 2: find equation of line in point-slope form
  final y = slope * (givenPoint.longitude - point1.longitude) + point1.latitude;

  // Step 3: convert to slope-intercept form
  final b = point1.latitude - slope * point1.longitude;

  // Step 4: find equation of perpendicular line
  double perp_slope, x, y_perp;
  if (slope == 0) {
    x = givenPoint.longitude;
    y_perp = point1.latitude;
  } else {
    perp_slope = -1 / slope;
    y_perp = perp_slope * (givenPoint.longitude - givenPoint.longitude) + givenPoint.latitude;
  }

  // Step 5: find intersection point
  x = (y_perp - b) / slope;
  y_perp = slope * x + b;

  // Step 6: check if intersection point is on line segment
  final dist1 = getDistance(point1, givenPoint);
  final dist2 = getDistance(point2, givenPoint);
  final dist12 = getDistance(point1, point2);
  if (x < min(point1.longitude, point2.longitude) ||
      x > max(point1.longitude, point2.longitude) ||
      dist1 > dist12 ||
      dist2 > dist12) {
    return dist1 < dist2 ? point1 : point2;
  } else {
    return LatLng(y_perp, x);
  }
}

double getDistance(LatLng p1, LatLng p2) {
  return const Distance().as(LengthUnit.Meter, p1, p2);
}