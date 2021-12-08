import std.stdio;

import std.array : split, array;
import std.algorithm : map, filter, all, canFind, countUntil, isPermutation, fold;
import std.range : empty;

struct SevenSegment
{
  static immutable recognizable = [1, 4, 7, 8];
  static immutable recognizableLengths = [2, 4, 3, 7];

  char[][10] patterns;
  char[][] remainingPatterns;

  void putPattern(char[] s)
  {
    // Find the 4 easy ones
    int i = cast(int) recognizableLengths.countUntil(s.length);
    if (i >= 0)
    {
      int d = recognizable[i];
      patterns[d] = s;
    }
    else
      remainingPatterns ~= s;
  }

  void solve()
  {
    // 3 = pattern with len 5, containing all digits from 1
    foreach (i, p; remainingPatterns)
      if (p.length == 5 && patterns[1].all!(c => p.canFind(c)))
      {
        patterns[3] = p;
        remainingPatterns[i] = [];
        break;
      }

    // 9 = pattern with len 6, containing all digits from 4
    foreach (i, p; remainingPatterns)
      if (p.length == 6 && patterns[4].all!(c => p.canFind(c)))
      {
        patterns[9] = p;
        remainingPatterns[i] = [];
        break;
      }

    // 0 = pattern with len 6, containing all digits from 1
    foreach (i, p; remainingPatterns)
      if (p.length == 6 && patterns[1].all!(c => p.canFind(c)))
      {
        patterns[0] = p;
        remainingPatterns[i] = [];
        break;
      }

    // 6 = remaining pattern with len 6
    foreach (i, p; remainingPatterns)
      if (p.length == 6)
      {
        patterns[6] = p;
        remainingPatterns[i] = [];
        break;
      }

    // 2 = remaining pattern, differing 2 digits from 6
    foreach (i, p; remainingPatterns)
      if (!p.empty)
      {
        int diff;
        foreach (c; patterns[6])
          if (!p.canFind(c))
            diff++;
        if (diff == 2)
        {
          patterns[2] = p;
          remainingPatterns[i] = [];
          break;
        }
      }

    // 5 = remaining pattern
    foreach (i, p; remainingPatterns)
      if (!p.empty)
      {
        patterns[5] = p;
        remainingPatterns[i] = [];
        break;
      }
  }

  int translate(char[] p)
  {
    foreach (i, digit; patterns)
      if (digit.isPermutation(p))
        return cast(int) i;
    assert(0);
  }
}

void main()
{
  int sum;

  foreach (line; stdin.byLine)
  {
    SevenSegment segment;

    auto input = line.split(" ").split("|");
    char[][] patterns = input[0];
    char[][] output = input[1];

    foreach (p; patterns)
      segment.putPattern(p);

    segment.solve;

    auto digits = output.map!(p => segment.translate(p)).array;
    sum += digits.fold!"a*10 + b";
  }

  writeln(sum);
}
