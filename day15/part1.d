import std.stdio;
import std.string : chomp;
import std.format : formattedRead;

import std.algorithm : min, sort;

/// Square grid of T's
struct SGrid(T)
{
  T[] arr;
  int side;

  this(int side)
  {
    this.side = side;
    arr = new T[](side * side);
  }

  ref T opIndex(int x, int y)
  {
    return arr[y * side + x];
  }

  SGrid!T dup()
  {
    SGrid grid = this;
    grid.arr = arr.dup;
    return grid;
  }
}

alias Grid = SGrid!int;

Grid cumulative(Grid grid)
{
  foreach (y; 0 .. grid.side)
    foreach (x; 0 .. grid.side)
    {
      int cu = grid[x, y];
      if (x > 0 || y > 0)
      {
        int left = int.max;
        int top = int.max;
        if (x > 0)
          left = grid[x - 1, y];
        if (y > 0)
          top = grid[x, y - 1];
        cu += min(left, top);
      }
      grid[x, y] = cu;
    }
  return grid;
}

Grid readCave()
{
  Grid grid;

  int x, y;
  foreach (line; stdin.byLine)
  {
    // Side is only known by reading the first line
    if (grid.arr is null)
      grid = Grid(cast(int) line.length);

    x = 0;
    foreach (c; line)
    {
      grid[x, y] = c - '0';
      x++;
    }

    y++;
  }

  return grid;
}

void main()
{
  Grid cave = readCave;

  Grid cumulative = cave.dup.cumulative;

  // We never 'visisted' the first spot
  int first = cumulative[0, 0];
  int last = cumulative[cumulative.side - 1, cumulative.side - 1];
  writeln(last - first);
}
