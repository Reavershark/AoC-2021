import std.stdio;
import std.conv : to;
import std.string : chomp;

import std.array : split;
import std.algorithm : map, splitter, sum;

void shiftLeft(T)(T[] arr)
in (arr.length >= 2)
{
  T temp = arr[0];
  foreach (i; 1 .. arr.length)
    arr[i - 1] = arr[i];
  arr[$ - 1] = temp;
}

void main()
{
  alias T = long;
  T[9] fish;

  foreach (i; readln.chomp.split(",").map!(to!T))
    fish[i]++;

  foreach (day; 0 .. 80)
  {
    T parents = fish[0];
    fish.shiftLeft;
    fish[6] += parents;
  }

  writeln(fish[].sum);
}
