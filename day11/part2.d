import std.stdio;
import std.container : DList;

import std.algorithm : map, filter;

alias Queue = DList;

int[] grid;
int side;

struct Squid
{
  int x, y;

  /// Get energy
  int energy() const @property
  {
    return grid[y * side + x];
  }

  /// Set energy
  void energy(int value) @property
  {
    grid[y * side + x] = value;
  }

  void charge()
  {
    // -1 means can't charge
    if (energy != -1)
      grid[y * side + x]++;
  }

  bool isValid()
  {
    return x >= 0 && x < side && y >= 0 && y < side;
  }

  /// The 3-9 adjecent points
  auto adjecents()
  {
    static Squid[9] adjecents = [
      Squid(-1, -1), Squid(0, -1), Squid(1, -1),
      Squid(-1, 0), Squid(1, 0),
      Squid(-1, 1), Squid(0, 1), Squid(1, 1),
    ];

    return adjecents[]
      .map!((s) { s.x += x; s.y += y; return s; }) // Shift the static 'template' over to this squid
      .filter!(s => s.isValid);
  }
}

void readGrid()
{
  int index;
  foreach (line; stdin.byLine)
  {
    // Get square side from the first line
    if (grid is null)
    {
      side = cast(int) line.length;
      grid = new int[](side * side);
    }

    // Store energy digits in the grid
    foreach (c; line)
    {
      grid[index] = c - '0';
      index++;
    }
  }
}

void main()
{
  readGrid;

  int step;
  while (true)
  {
    step++;

    int flashes;
    Queue!Squid readyToFlash;

    // Charge all squids with 1 energy
    foreach (y; 0 .. side)
      foreach (x; 0 .. side)
      {
        Squid s = Squid(x, y);
        s.charge;
        if (s.energy > 9)
          readyToFlash.insertBack(s);
      }

    // Recursively flash charged squids and charge nearby squids
    while (!readyToFlash.empty)
    {
      Squid s = readyToFlash.front;
      readyToFlash.removeFront;

      if (s.energy > 9)
      {
        flashes++;
        s.energy = -1;

        foreach (a; s.adjecents)
        {
          a.charge;
          if (a.energy > 9)
            readyToFlash.insertBack(a);
        }
      }
    }

    foreach (ref energy; grid)
      if (energy == -1)
        energy = 0;
    
    if (flashes == side*side)
    {
      writeln(step);
      break;
    }
  }
}
