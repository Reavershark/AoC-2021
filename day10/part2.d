import std.stdio;
import std.container : SList;

import std.algorithm : canFind, sort;

bool isLeftBracket(char c)
{
  return "([{<".canFind(c);
}

char rightBracketOf(char left)
{
  static char[char] map;
  if (map is null)
  {
    map['('] = ')';
    map['['] = ']';
    map['{'] = '}';
    map['<'] = '>';
  }

  assert(left in map);
  return map[left];
}

int charScore(char right)
{
  static int[char] map;
  if (map is null)
  {
    map[')'] = 1;
    map[']'] = 2;
    map['}'] = 3;
    map['>'] = 4;
  }

  assert(right in map);
  return map[right];
}

void main()
{
  long[] scores;

  outer: foreach (line; stdin.byLine)
  {
    SList!char stack;

    // Verify syntax
    foreach (c; line)
    {
      if (c.isLeftBracket)
        stack.insertFront(c);
      else
      {
        char left = stack.front;
        stack.removeFront;

        if (rightBracketOf(left) != c)
        {
          // Syntax error, skip line
          continue outer;
        }
      }
    }

    // Autocomplete
    long score;
    while (!stack.empty)
    {
      char left = stack.front;
      stack.removeFront;
      char right = rightBracketOf(left);

      score *= 5;
      score += charScore(right);
    }
    scores ~= score;
  }

  scores.sort;
  scores[$ / 2].writeln;
}
