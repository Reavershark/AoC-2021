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
    int i;
    T[] arr;

    bool empty()
    {
      return i > (cast(int) arr.length) - size;
    }

    void popFront()
    in (!empty)
    {
      i++;
    }

    T[] front()
    in (!empty)
    {
      return arr[i .. i + size];
    }
  }

  Ret ret;
  ret.arr = arr;
  return ret;
}

void main()
{
  int[] input;
  eachLine((line) { input ~= line.to!int; });

  assert(input.length > 0);

  auto sum3 = input.slidingWindow!3
    .map!sum
    .array;

  int incr;
  foreach (tuple; sum3.slidingWindow!2)
    if (tuple[1] - tuple[0] > 0)
      incr++;
  writeln(incr);
}
