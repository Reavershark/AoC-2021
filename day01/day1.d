import std.stdio;
import std.conv : to;
import std.string : chomp;

import std.range;
import std.algorithm;

void eachLine(void delegate(string line) dg)
{
  string line;
  while ((line = readln()) !is null)
    dg(line.chomp);
}

auto slidingWindow(int size, T)(T[] arr)
{
  struct Ret
  {
    T[] arr;
    int i;

    bool empty() => i > arr.length - size;
    T[] front() => arr[i .. i + size];
    void popFront() { i++; }
  }
  return Ret(arr);
}

size_t countIncrements(R)(R r)
{
  return r.filter!(t => t[1] - t[0] > 0).walkLength;
}

void main()
{
  int[] input;
  eachLine((line) { input ~= line.to!int; });

  input.slidingWindow!2.countIncrements
    .writeln;

  input.slidingWindow!3.map!sum
    .array.slidingWindow!2.countIncrements
    .writeln;
}
