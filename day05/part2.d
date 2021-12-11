import std.stdio;
import std.format : formattedRead;

import std.algorithm : filter, count, swap;

struct Point
{
  int x, y;
}

int norm(int n)
{
  return n < 0 ? -1 : 1;
}

void main()
{
  int[Point] map;

  foreach (line; stdin.byLine)
  {
    int x1, y1, x2, y2;
    line.formattedRead("%d,%d -> %d,%d", x1, y1, x2, y2);

    while (x1 != x2 || y1 != y2)
    {
      map[Point(x1, y1)]++;
      if (x1 != x2)
        x1 += norm(x2 - x1);
      if (y1 != y2)
        y1 += norm(y2 - y1);
    }
    // Include end
    map[Point(x2, y2)]++;
  }

  map.byValue.filter!"a > 1".count.writeln;
}
