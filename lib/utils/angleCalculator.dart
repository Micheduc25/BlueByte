import 'package:flutter/material.dart';
import 'dart:math';

double angleBetween(Offset p1, Offset p2, Offset p3) {
  final p1p2 = Offset(p2.dx - p1.dx, p2.dy - p1.dy);

  final p2p3 = Offset(p3.dx - p2.dx, p3.dy - p2.dy);

  final dotProd = p1p2.dx * p2p3.dx + p1p2.dy * p2p3.dy;

  final magp1p2 = sqrt(pow(p1p2.dx, 2) + pow(p1p2.dy, 2));
  final magp2p3 = sqrt(pow(p2p3.dx, 2) + pow(p2p3.dy, 2));
  double angle;
  if (p1p2.dy >= p2p3.dy)
    angle = acos(dotProd / (magp1p2 * magp2p3));
  else
    angle = -acos(dotProd / (magp1p2 * magp2p3));

  return angle;
}

double angleBetweenLineAndXaxis(Offset p1, Offset p2) {
  final gradient = (p2.dy - p1.dy) / (p2.dx - p1.dx);

  final angle = atan(gradient);

  return angle;
}

double gradientOfLine(Offset p1, Offset p2) {
  return (p2.dy - p1.dy) / (p2.dx - p1.dx);
}

double vectorLength(Offset p) {
  return sqrt(pow(p.dx, 2) + pow(p.dy, 2));
}

Offset midPoint(Offset p1, Offset p2) {
  return Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
}

double angleBetweenTwoLines(Offset p1, Offset p2, Offset p3, Offset p4) {
  final g1 = gradientOfLine(p1, p2);
  final g2 = gradientOfLine(p3, p4);
  final val = -(g2 - g1) / (1 + (g2 * g1));
  final angle = atan(val.abs());
  return angle;
}

double lineLength(Offset p1, Offset p2) {
  return sqrt(pow(p2.dx - p1.dx, 2) + pow(p2.dy - p1.dy, 2));
}
