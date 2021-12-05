import std.stdio;
import std.format : formattedRead;

import std.algorithm : filter, count, swap;

struct Point
{
  int x, y;
}

void main()
{
  int[Point] map;

  foreach (line; stdin.byLine)
  {
    int x1, y1, x2, y2;
    line.formattedRead("%d,%d -> %d,%d", x1, y1, x2, y2);

    // Skip diagonals
    if (x1 != x2 && y1 != y2)
      continue;

    // Reverse points if needed
    if (x2 < x1 || y2 < y1)
    {
      swap(x1, x2);
      swap(y1, y2);
    }

    // Start to end - 1
    while (x1 < x2 || y1 < y2)
    {
      map[Point(x1, y1)]++;
      if (x1 < x2)
        x1++;
      if (y1 < y2)
        y1++;
    }
    // Include end
    map[Point(x2, y2)]++;
  }

  map.byValue.filter!"a > 1".count.writeln;

}
