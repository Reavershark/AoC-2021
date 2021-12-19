import std.stdio;
import std.format : formattedRead;

import std.algorithm : max, swap, map, sum, any;
import std.math : abs;
import std.traits : EnumMembers;
import std.typecons : Nullable;

struct Position
{
  long x, y, z;

  Position oriented(int orientation)
  in (0 <= orientation && orientation <= 23)
  {
    Position p = this;

    for (long i = 1; i < orientation + 1; i++)
    {
      swap(p.y, p.z);
      p.y = -p.y;

      if (i == 12)
      {
        swap(p.x, p.z);
        p.z = -p.z;
      }

      if (i != 12 && i % 4 == 0)
      {
        swap(p.x, p.y);
        p.y = -p.y;
      }
    }

    return p;
  }

  Position opUnary(string op)() const if (op == "-")
  {
    return Position(-x, -y, -z);
  }

  Position opBinary(string op)(const Position rhs) const if (op == "+" || op == "-")
  {
    static if (op == "+")
      return Position(x + rhs.x, y + rhs.y, z + rhs.z);
    else static if (op == "-")
      return this + -rhs;
  }
}

Scanner[] parse(T)(T lines)
{
  Scanner[] scanners;

  Scanner curr;
  foreach (line; lines)
  {
    if (line == "")
      scanners ~= curr;
    else if (line[0 .. 3] == "---")
      curr = new Scanner;
    else
    {
      Position p;
      line.formattedRead!"%d,%d,%d"(p.x, p.y, p.z);
      curr.addBeacon(p);
    }
  }

  // No newline at end of file
  if (scanners[$ - 1] != curr)
    scanners ~= curr;

  return scanners;
}

class Scanner
{
  Nullable!Position position;

  Position[] beacons;

  void addBeacon(Position pos)
  {
    beacons ~= pos;
  }
}

void main()
{
  Scanner[] scanners = stdin.byLine.parse;

  scanners[0].position = Position(0, 0, 0);

  while (scanners.any!(s => s.position.isNull))
  {
    writeln;
    ulong[] nulls;
    foreach(i, s; scanners)
      if (s.position.isNull)
        nulls ~= i;
    writeln(nulls);

    outer: foreach (s1i, s1; scanners)
      foreach (s2i, s2; scanners)
      {
        if (s1 == s2 || s1.position.isNull || !s2.position.isNull)
          continue;

        foreach (orientation; 0 .. 24)
        {
          long[Position] diffFreq;
          foreach (b1; s1.beacons)
            foreach (b2; s2.beacons.map!(b => b.oriented(orientation)))
              diffFreq[b1 - b2]++;

          Position offset;
          bool found;
          foreach (diff, freq; diffFreq)
            if (freq >= 12)
            {
              offset = diff;
              found = true;
              break;
            }

          if (found)
          {
            s2.position = offset;
            writefln!"%d -> %d %s"(s1i, s2i, s2.position.get);
            foreach (ref b; s2.beacons)
              b = b.oriented(orientation) + offset;
            break outer;
          }
        }
      }
  }
  writeln("Done mapping");

  Position[Position] beacons;
  foreach (s; scanners)
    foreach (b; s.beacons)
      beacons[b] = b;
  writeln(beacons.length);
}
