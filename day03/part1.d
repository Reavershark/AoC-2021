import std.stdio;
import std.conv : to;

import std.range : retro;
import std.algorithm : map;

void main()
{
  int lines;
  int[] ones;

  foreach (line; stdin.byLine)
  {
    // Get the amount of columns from the first line
    if (ones == null)
      ones = new int[](line.length);

    lines++;

    // Iterate over the bits right to left (retro)
    int n = line.retro.to!int(2);
    int index = 0;
    while (n != 0)
    {
      // Check for 1, update count
      if ((n & 1) != 0)
        ones[index]++;
      index++;
      n >>= 1;
    }
  }

  int gr = 0, er = 0;
  foreach(bit; ones.map!(count => count > lines / 2))
  {
    gr <<= 1;
    er <<= 1;
    bit ? gr++ : er++;
  }

  writeln(gr * er);
}
