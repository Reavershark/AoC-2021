import std.stdio;
import std.conv : to;
import std.string : chomp;

import std.array : split, array;
import std.algorithm : map, minElement, maxElement;

int diff(int a, int b) pure
{
  int d = a - b;
  return d >= 0 ? d : -d;
}

void main()
{
  int[] input = readln.chomp.split(",").map!(to!int).array;
  int width = input.maxElement;

  int[] fuelSpent = new int[](width);

  foreach (x; 0 .. width)
    foreach (i; input)
      fuelSpent[x] += diff(i, x);

  writeln(fuelSpent.minElement);
}
