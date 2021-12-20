import std.stdio;
import std.string : chomp;

import std.algorithm : min, max, count;

class Tape
{
  static immutable long length = 512;
  bool[] arr;

  this(string str)
  in (str.length == length)
  {
    arr.length = length;
    foreach (i, c; str)
      arr[i] = c == '#';
  }

  bool opIndex(size_t i) const
  in (i < 512)
  {
    return arr[i];
  }
}

struct Point
{
  int x, y;

  // size_t toHash() const @nogc @safe pure nothrow
  // {
  //   return (x << int.sizeof) | y;
  // }

  // bool opEquals(const Point other) const
  // {
  //   return x == other.x && y == other.y;
  // }
}

class Image
{
  bool[Point] map; // true = 1, false = 0, not present = infinity
  bool infinity = false;

  private this()
  {
  }

  /// String ctor
  this(Lines)(Lines lines)
  {
    int y;
    foreach (line; lines)
    {
      int x;
      foreach (c; line)
      {
        map[Point(x, y)] = c == '#';
        x++;
      }
      y++;
    }
  }

  bool opIndex(Point p) const
  {
    if (p in map)
      return map[p];
    else
      return infinity;
  }

  bool opIndexAssign(bool value, Point p)
  {
    map[p] = value;
    return value;
  }

  long countOnes() const
  {
    return map.byValue.count(true);
  }

  Point topLeft() const
  {
    Point result;
    foreach (p; map.byKey)
    {
      result.x = min(result.x, p.x);
      result.y = min(result.y, p.y);
    }
    return result;
  }

  Point bottomRight() const
  {
    Point result;
    foreach (p; map.byKey)
    {
      result.x = max(result.x, p.x);
      result.y = max(result.y, p.y);
    }
    return result;
  }

  void print() const
  {
    Point begin = topLeft;
    Point end = bottomRight;

    foreach (y; begin.y - 3 .. end.y + 4)
    {
      foreach (x; begin.x - 3 .. end.x + 4)
      {
        Point p = Point(x, y);
        write(this[p] ? '#' : '.');
      }
      writeln;
    }
  }

  long tapeIndex(Point p) const
  {
    long result;
    foreach (y; [p.y - 1, p.y, p.y + 1])
      foreach (x; [p.x - 1, p.x, p.x + 1])
      {
        result <<= 1;
        result |= this[Point(x, y)];
      }
    return result;
  }

  Image enhanced(Tape tape) const
  {
    Image result = new Image;

    if (!infinity && tape[0])
      result.infinity = true;

    Point begin = topLeft;
    Point end = bottomRight;

    foreach (y; begin.y - 3 .. end.y + 4)
      foreach (x; begin.x - 3 .. end.x + 4)
      {
        Point p = Point(x, y);
        result[p] = tape[tapeIndex(p)];
      }

    return result;
  }
}

void main()
{
  Tape tape = new Tape(readln.chomp);
  readln;
  Image image = new Image(stdin.byLine);

  long steps = 50;
  foreach (i; 0 .. steps)
  {
    writefln!"Step %d/%d"(i + 1, steps);
    image = image.enhanced(tape);
  }

  image.countOnes.writeln;
}
