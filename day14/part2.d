import std.stdio;
import std.string : chomp;
import std.conv : to;
import std.format : formattedRead;

import std.range : slide;
import std.algorithm : map, minElement, maxElement;

struct Pair
{
  char a, b;
}

char[Pair] rules;
long[Pair] pairs;
long[char] freq;

void readTemplate()
{
  string input = readln.chomp;

  // Char freq
  foreach (c; input)
    freq[c]++;

  // Pairs
  foreach (t; input.slide(2).map!(to!(char[])))
  {
    Pair p = Pair(t[0], t[1]);
    pairs[p]++;
  }
}

void readRules()
{
  foreach (line; stdin.byLine)
  {
    Pair p;
    char c;
    line.formattedRead("%c%c -> %c", p.a, p.b, c);
    rules[p] = c;
  }
}

void step()
{
  foreach (pair, count; pairs.dup)
  {
    if (pair in rules)
    {
      char insert = rules[pair];

      // Char freq
      freq[insert] += count;

      // Each pair a,b becomes 2 pairs a,c and c,b
      pairs[pair] -= count;
      pairs[Pair(pair.a, insert)] += count;
      pairs[Pair(insert, pair.b)] += count;
    }
  }
}

void main()
{
  readTemplate;
  readln;
  readRules;

  foreach (i; 0 .. 40)
    step;

  writeln(freq.byValue.maxElement - freq.byValue.minElement);
}
