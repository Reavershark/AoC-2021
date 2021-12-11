import std.stdio;
import std.algorithm : all;

void main()
{
  int[] heightmap;
  size_t width;
  size_t height;

  foreach (line; stdin.byLine)
  {
    // Get width from the first line
    if (heightmap is null)
      width = line.length;

    // Enlarge the heightmap for the new line
    height++;
    heightmap.reserve(width);

    // Store digits in the heightmap
    foreach (j, c; line)
      heightmap ~= c - '0';
  }

  alias get = (x, y) => heightmap[y * width + x];

  int riskSum;

  foreach (y; 0 .. height)
    foreach (x; 0 .. width)
    {
      int point = get(x, y);

      // Find the 2 to 4 adjecents
      int[] adjecent;
      adjecent.reserve(4);
      if (x % width > 0)
        adjecent ~= get(x - 1, y);
      if (x % width < width - 1)
        adjecent ~= get(x + 1, y);
      if (y > 0)
        adjecent ~= get(x, y - 1);
      if (y < height - 1)
        adjecent ~= get(x, y + 1);

      // Check if all the adjecent are higher
      if (adjecent.all!(a => a > point))
        riskSum += point + 1;
    }

  writeln(riskSum);
}
