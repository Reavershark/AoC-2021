import std.stdio;
import std.container : DList;
import std.range : empty;

alias Queue = DList;

void main()
{
  int[] heightmap;
  int width;
  int height;

  foreach (line; stdin.byLine)
  {
    // Get width from the first line
    if (heightmap is null)
      width = cast(int) line.length;

    // Enlarge the heightmap for the new line (the example isn't a square)
    height++;
    heightmap.reserve(width);

    // Store digits in the heightmap
    foreach (j, c; line)
      heightmap ~= c - '0';
  }

  struct Point
  {
    int x, y;

    /// The height of the point
    int value()
    {
      return heightmap[y * width + x];
    }

    /// The 2-4 adjecent points
    Point[] adjecents()
    {
      Point[] adjecent;
      adjecent.reserve(4);
      if (x % width > 0)
        adjecent ~= Point(x - 1, y);
      if (x % width < width - 1)
        adjecent ~= Point(x + 1, y);
      if (y > 0)
        adjecent ~= Point(x, y - 1);
      if (y < height - 1)
        adjecent ~= Point(x, y + 1);
      return adjecent;
    }
  }

  Point[][] basins;
  bool[Point] processed;

  foreach (y; 0 .. height)
    foreach (x; 0 .. width)
    {
      Queue!Point queue;
      Point[] basin;

      // Recursively process each adjecent point until a 9 or the border is hit
      // Skip already processed points
      queue.insertFront(Point(x, y));
      while (!queue.empty)
      {
        Point p = queue.front;
        queue.removeFront;

        if (p.value != 9 && !(p in processed))
        {
          basin ~= p;
          processed[p] = true;
          foreach (adj; p.adjecents)
            queue.insertBack(adj);
        }
      }

      if (!basin.empty)
        basins ~= basin;
    }

  // Multiply the lengths of the 3 largest basins
  import std.algorithm : map, sort, fold;
  import std.range : take, array;

  basins.map!(b => b.length)
    .array
    .sort!"a > b"
    .take(3).fold!"a * b".writeln;
}
