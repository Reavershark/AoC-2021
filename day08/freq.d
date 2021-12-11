import std.stdio;

import std.array : split;
import std.algorithm : map, sum, fold;
import std.range : join;

int[int] digitFreqSums() pure
{
  string[] digits = [
    "abcefg", "cf", "acdeg", "acdfg", "bcdf",
    "abdfg", "abdefg", "acf", "abcdefg", "abcdfg"
  ];

  int[dchar] freq;
  foreach (c; digits.join)
    freq[c]++;

  int[int] sums;
  foreach (i, d; digits)
    sums[d.map!(c => freq[c]).sum] = cast(int) i;

  return sums;
}

void main()
{
  int[int] sums = digitFreqSums;

  int total;
  foreach (line; stdin.byLine)
  {
    auto input = line.split(" ").split("|");
    char[][] patterns = input[0];
    char[][] output = input[1];

    int[dchar] freq;
    foreach (c; patterns.join)
      freq[c]++;

    int[] translated;
    foreach (p; output)
      translated ~= sums[p.map!(c => freq[c]).sum];

    total += translated.fold!"a*10 + b";
  }
  writeln(total);
}
