import std.stdio;
import std.conv : to;

import std.algorithm : canFind;
import std.array : replaceSlice;

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

void main()
{
  Token[] tokens;

  foreach (line; stdin.byLine)
  {
    if (tokens is null)
      tokens = parse(line);
    else
    {
      tokens = Token('[') ~ tokens ~ Token(',') ~ parse(line) ~ Token(']');
      reduce(tokens);
    }
  }
  tokens.toString.writeln;
}
