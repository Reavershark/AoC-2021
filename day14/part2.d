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
char firstChar, lastChar;

void readTemplate()
{
  string input = readln.chomp;

  firstChar = input[0];
  lastChar = input[$ - 1];

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
      pairs.remove(pair);
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

  foreach (i; 0 .. 10)
  {
    writeln("Step ", i);
    step;
  }

  long[char] freq;

  foreach (pair, count; pairs)
  {
    freq[pair.a] += count;
    freq[pair.b] += count;
  }

  // We counted each char twice
  // foreach (c, count; freq)
  //   freq[c] = count / 2;

  // Fix the first and last char count
  freq[firstChar] += 1;
  // freq[lastChar] += 1;
  
  writeln(freq);

  writeln(freq.byValue.maxElement - freq.byValue.minElement);
}
