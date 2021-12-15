import std.stdio;

import std.algorithm : min;

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

  void print()
  {
    foreach (y; 0 .. side)
    {
      foreach (x; 0 .. side)
        writef("%3d", this[x, y]);
      writeln;
    }
  }
}

alias Grid = SGrid!int;

Grid expandTo5x5(Grid grid)
{
  Grid exp = Grid(grid.side * 5);

  foreach (y; 0 .. grid.side)
    foreach (x; 0 .. grid.side)
    {
      int val = grid[x, y];
      foreach (y2; 0 .. 5)
        foreach (x2; 0 .. 5)
        {
          int expVal = val + x2 + y2;
          while (expVal > 9)
            expVal -= 9;
          exp[x2 * grid.side + x, y2 * grid.side + y] = expVal;
        }
    }

  return exp;
}

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

Grid fix(Grid cumulative, Grid original)
{
  int side = original.side;

  int fixes;
  do
  {
    fixes = 0;
    foreach (y; 0 .. original.side)
      foreach (x; 0 .. original.side)
      {
        int or = original[x, y];
        int cu = cumulative[x, y];

        if (x > 0)
        {
          int left = cumulative[x - 1, y];
          if (left + or < cu)
          {
            cumulative[x, y] = or + left;
            fixes++;
          }
        }

        if (y > 0)
        {
          int top = cumulative[x, y - 1];
          if (top + or < cu)
          {
            cumulative[x, y] = or + top;
            fixes++;
          }
        }

        if (x < side - 1)
        {
          int right = cumulative[x + 1, y];
          if (right + or < cu)
          {
            cumulative[x, y] = or + right;
            fixes++;
          }
        }

        if (y < side - 1)
        {
          int bottom = cumulative[x, y + 1];
          if (bottom + or < cu)
          {
            cumulative[x, y] = or + bottom;
            fixes++;
          }
        }
      }
    stderr.writeln("Fixes: ", fixes);
  }
  while (fixes > 0);

  return cumulative;
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
  Grid cave = readCave.expandTo5x5;

  Grid cumulative = cave.dup.cumulative.fix(cave);

  // cumulative.print;

  // We never 'visisted' the first spot
  int first = cumulative[0, 0];
  int last = cumulative[cumulative.side - 1, cumulative.side - 1];
  writeln(last - first);
}
