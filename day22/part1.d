import std.stdio;
import std.format : formattedRead;

import std.algorithm : min, max;

struct Reactor
{
  static immutable side = 101;
  static immutable radius = side / 2;
  bool[side][side][side] arr;

  ref bool opIndex(long x, long y, long z)
  {
    return arr[x + radius][y + radius][z + radius];
  }

  long countOnes()
  {
    long count;
    foreach (x; arr)
      foreach (y; x)
        foreach (z; y)
          if (z)
            count++;
    return count;
  }
}

void main()
{
  Reactor r;

  foreach (line; stdin.byLine)
  {
    string action;
    long x1, x2, y1, y2, z1, z2;
    line.formattedRead!"%s x=%d..%d,y=%d..%d,z=%d..%d"(action, x1, x2, y1, y2, z1, z2);

    x1 = max(-r.side, x1);
    y1 = max(-r.side, y1);
    z1 = max(-r.side, z1);
    x2 = min(r.side, x2);
    y2 = min(r.side, y2);
    z2 = min(r.side, z2);

    bool setTo = action == "on";
    foreach (x; x1 .. x2 + 1)
      foreach (y; y1 .. y2 + 1)
        foreach (z; z1 .. z2 + 1)
          r[x, y, z] = setTo;
  }

  writeln(r.countOnes);
}
