import std.stdio;
import std.container : SList;

import std.algorithm : canFind;

bool isLeftBracket(char c)
{
  return "([{<".canFind(c);
}

bool isPair(char a, char b)
{
  static char[char] map;
  if (map is null)
  {
    map['('] = ')';
    map['['] = ']';
    map['{'] = '}';
    map['<'] = '>';
  }

  assert(a in map);
  return map[a] == b;
}

long charScore(char c)
{
  static int[char] map;
  if (map is null)
  {
    map[')'] = 3;
    map[']'] = 57;
    map['}'] = 1197;
    map['>'] = 25_137;
  }

  assert(c in map);
  return map[c];
}

void main()
{
  long score;

  foreach (line; stdin.byLine)
  {
    SList!char stack;

    foreach (c; line)
    {
      if (c.isLeftBracket)
        stack.insertFront(c);
      else
      {
        char other = stack.front;
        stack.removeFront;

        if (!isPair(other, c))
        {
          // Syntax error
          score += charScore(c);
          break;
        }
      }
    }
  }

  writeln(score);
}
