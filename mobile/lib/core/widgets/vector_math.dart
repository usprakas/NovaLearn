const double pi = 3.141592653589793;

/// Small, dependency-free sin/cos approximations shared by every hand-drawn vector painter in
/// this app (shapes, clock faces, ...) — avoids pulling in `dart:math` just for a couple of trig
/// calls per painter.
double taylorCos(double radians) {
  double x = radians;
  while (x > pi) {
    x -= 2 * pi;
  }
  while (x < -pi) {
    x += 2 * pi;
  }
  final double x2 = x * x;
  return 1 - x2 / 2 + (x2 * x2) / 24 - (x2 * x2 * x2) / 720;
}

double taylorSin(double radians) => taylorCos(radians - pi / 2);
