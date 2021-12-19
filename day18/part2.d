import std.stdio;
import std.conv : to;

import std.algorithm : canFind;
import std.array : replaceSlice;

/*
  So...

  part1_uniontree fails on the last example, i have no idea why, spent a while debugging
  But i had another idea: a token stream, this worked perfectly for part 1 and was way easier

  Part 2 is much harder without trees
  But ..., my failed part1_uniontree can calculate the magnitude of a single number perfectly

  So let's combine them!

  Ctrl+F 'import std;' is where all hell breaks loose
*/

enum TokenType : char
{
  BEGIN_PAIR = '[',
  COMMA = ',',
  END_PAIR = ']',
  NUMBER = 0xFF
}

struct Token
{
  TokenType type;
  long _number;

  this(char c)
  {
    type = cast(TokenType) c;
  }

  this(long n)
  {
    type = TokenType.NUMBER;
    _number = n;
  }

  /// Getter
  long number() const @property
  in (type == TokenType.NUMBER)
  {
    return _number;
  }

  /// Setter
  void number(long value) @property
  in (type == TokenType.NUMBER)
  {
    _number = value;
  }
}

Token[] parse(char[] input)
{
  Token[] tokens;

  for (long i; i < input.length; i++)
  {
    char c = input[i];

    auto syntax = "[],";

    if (syntax.canFind(c))
      tokens ~= Token(c);
    else
    {
      // Find number substring
      long start = i;
      i++;
      while (!syntax.canFind(input[i]))
        i++;
      i--;
      long number = input[start .. i + 1].to!long;

      tokens ~= Token(number);
    }
  }

  return tokens;
}

string toString(Token[] arr)
{
  string s;
  foreach (token; arr)
  {
    if (token.type == TokenType.NUMBER)
      s ~= token.number.to!string;
    else
      s ~= cast(char) token.type;
  }
  return s;
}

bool explode(ref Token[] tokens)
{
  long depth;
  for (long i; i < tokens.length; i++)
  {
    Token token = tokens[i];

    if (token.type == TokenType.BEGIN_PAIR)
      depth++;
    else if (token.type == TokenType.END_PAIR)
      depth--;

    if (depth == 5)
    {
      Token[] explodeSlice = tokens[i .. i + 5];

      long left = explodeSlice[1].number;
      long right = explodeSlice[3].number;

      // Shatter to the left
      for (long j = i - 1; j >= 0; j--)
        if (tokens[j].type == TokenType.NUMBER)
        {
          tokens[j].number = tokens[j].number + left;
          break;
        }

      // Shatter to the right
      for (long j = i + 5; j < tokens.length; j++)
        if (tokens[j].type == TokenType.NUMBER)
        {
          tokens[j].number = tokens[j].number + right;
          break;
        }

      tokens = replaceSlice(tokens, explodeSlice, [Token(0L)]);
      return true;
    }
  }
  return false;
}

bool split(ref Token[] tokens)
{
  foreach (i, token; tokens)
    if (token.type == TokenType.NUMBER)
      if (token.number >= 10)
      {
        long left = token.number / 2;
        long right = (token.number + 1) / 2;

        Token[] split = [
          Token('['), Token(left), Token(','), Token(right), Token(']')
        ];

        tokens = replaceSlice(tokens, tokens[i .. i + 1], split);
        return true;
      }
  return false;
}

void reduce(ref Token[] tokens)
{
  while (true)
  {
    if (tokens.explode)
      continue;
    if (tokens.split)
      continue;
    break;
  }
}

// Hacks incoming
import std;

/// Pair from failed attempt
struct Pair
{
  mixin(bitfields!(
      bool, "leftIsPair", 1,
      bool, "rightIsPair", 1,
      uint, "", 6
  ));

  union Child
  {
    long number;
    Pair* pair;
  }

  Child left;
  Child right;

  long magnitude() const
  {
    long m = 0;

    if (leftIsPair)
      m += 3 * left.pair.magnitude;
    else
      m += 3 * left.number;

    if (rightIsPair)
      m += 2 * right.pair.magnitude;
    else
      m += 2 * right.number;

    return m;
  }
}

/// Parser from failed attempt
Pair* parseTree(char[] arr)
{
  Pair* pair = new Pair;

  // arr must be a pair
  assert(arr[0] == '[');
  assert(arr[$ - 1] == ']');

  // Find comma of this pair
  long commaPos;
  long depth;
  foreach (i, c; arr[1 .. $ - 1])
  {
    if (c == '[')
      depth++;
    else if (c == ']')
      depth--;
    else if (c == ',')
      if (depth == 0)
      {
        commaPos = i + 1; // We started at i=1
        break;
      }
  }
  assert(commaPos != 0);

  // Parse each child as pair or number
  char[] leftSlice = arr[1 .. commaPos];
  char[] rightSlice = arr[commaPos + 1 .. $ - 1];

  // Left
  if (leftSlice[0] == '[')
  {
    pair.leftIsPair = true;
    pair.left.pair = parseTree(leftSlice);
  }
  else
    pair.left.number = leftSlice.to!long;

  // Right
  if (rightSlice[0] == '[')
  {
    pair.rightIsPair = true;
    pair.right.pair = parseTree(rightSlice);
  }
  else
    pair.right.number = rightSlice.to!long;

  return pair;
}

void main()
{
  string[] lines = stdin.byLineCopy.array;

  long maxMagnitude;

  foreach (tuple; cartesianProduct(lines, lines))
  {
    Token[] t1 = parse(tuple[0].to!(char[]));
    Token[] t2 = parse(tuple[1].to!(char[]));
    Token[] tokens = Token('[') ~ t1 ~ Token(',') ~ t2 ~ Token(']');
    tokens.reduce;

    Pair* pair = parseTree(tokens.toString.to!(char[]));
    maxMagnitude = max(maxMagnitude, pair.magnitude);
  }

  writeln(maxMagnitude);
}
