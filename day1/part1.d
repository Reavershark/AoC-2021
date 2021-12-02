import std.stdio;
import std.conv : to;
import std.string : chomp;

void eachLine(void delegate(string line) dg)
{
  string line;
  while ((line = readln()) !is null)
    dg(line.chomp);
}

void main()
{
  int[] input;
  eachLine((line) { input ~= line.to!int; });

  assert(input.length > 0);

  int result;
  foreach (i; 1 .. input.length)
  {
    auto last = input[i - 1];
    auto curr = input[i];
    if (last < curr)
      result++;
  }

  writeln(result);
}
