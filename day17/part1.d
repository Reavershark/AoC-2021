import std.stdio;

import std.algorithm : map, maxElement;

void main()
{
  long tx1, tx2, ty1, ty2;
  readf("target area: x=%d..%d, y=%d..%d", tx1, tx2, ty1, ty2);

  auto inTargetX = (long x) => tx1 <= x && x <= tx2;
  auto inTargetY = (long y) => ty1 <= y && y <= ty2;

  struct Hit1D
  {
    long startv;
    long hitPos; // x or y
  }

  Hit1D[] xHits, yHits;

  // x-axis (Not needed for part1)
  // Try all velocities that don't immediately overshoot
  foreach (long startv; 1 .. tx2 + 1)
  {
    long x = 0;
    long v = startv;
    while (v > 0)
    {
      x += v;
      v--;
      if (inTargetX(x))
        xHits ~= Hit1D(startv, x);
    }
  }

  long highestY;

  // y-axis
  // I have no idea where to stop
  foreach (long startv; 1 .. 10_000)
  {
    long currHighestY;

    long y = 0;
    long v = startv;
    while (y > ty2)
    {
      y += v;
      v--;

      if (y > currHighestY)
        currHighestY = y;

      if (inTargetY(y))
      {
        yHits ~= Hit1D(startv, y);
        if (currHighestY > highestY)
          highestY = currHighestY;
      }
    }
  }

  writeln(highestY);
}
