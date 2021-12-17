import std.stdio;

enum LargeNumber1 = 10_000;
enum LargeNumber2 = 100;

void main()
{
  long tx1, tx2, ty1, ty2;
  readf("target area: x=%d..%d, y=%d..%d", tx1, tx2, ty1, ty2);

  auto inTargetX = (long x) => tx1 <= x && x <= tx2;
  auto inTargetY = (long y) => ty1 <= y && y <= ty2;

  // Note:
  //  x(v) and y(x) sequences are completely independent
  //   => Find all valid x and y velocities seperately

  struct Hit1D
  {
    long startv;
    long step;
    bool stalled;
  }

  Hit1D[] xHits, yHits;

  // x-axis
  // Try all velocities that don't immediately overshoot
  foreach (long startv; 1 .. tx2 + 1)
  {
    long x = 0;
    long v = startv;
    long step;
    while (v > 0)
    {
      x += v;
      v--;
      step++;
      if (inTargetX(x))
        xHits ~= Hit1D(startv, step, v == 0);
    }
  }

  // y-axis
  // I have no idea what the bound should be
  foreach (long startv; -LargeNumber1 .. LargeNumber1)
  {
    long y = 0;
    long v = startv;
    long step;
    while (y >= ty2 * LargeNumber2)
    {
      y += v;
      v--;
      step++;
      if (inTargetY(y))
        yHits ~= Hit1D(startv, step, false);
    }
  }

  struct Vec2
  {
    long x, y;
  }

  Vec2[Vec2] velocities;

  foreach (xHit; xHits)
    foreach (yHit; yHits)
      if (xHit.step == yHit.step || (xHit.step < yHit.step && xHit.stalled))
      {
        auto v = Vec2(xHit.startv, yHit.startv);
        velocities[v] = v;
      }

  writeln(velocities.length);
}
