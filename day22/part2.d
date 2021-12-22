import std.stdio;
import std.format : formattedRead;

import std.algorithm : min, max, remove;
import std.typecons : Nullable;
import std.range;

struct Vec2
{
  long x, y;

  Vec2 opUnary(string op)() const
  {
    static if (op == "-")
      return Vec2(-x, -y);
  }

  Vec2 opBinary(string op, R)(const R rhs) const
  {
    static if (is(R == Vec2))
    {
      static if (op == "+")
        return Vec2(x + rhs.x, y + rhs.y);
      else static if (op == "-")
        return this + -rhs;
    }
    else
    {
      static if (op == "+")
        return Vec2(x + rhs, y + rhs);
      else static if (op == "-")
        return Vec2(x - rhs, y - rhs);
    }
  }
}

struct Rect
{
  Vec2 c1, c2;

  this(Vec2 c1, Vec2 c2)
  {
    this.c1 = c1;
    this.c2 = c2;
  }

  this(long x1, long x2, long y1, long y2)
  {
    c1 = Vec2(x1, y1);
    c2 = Vec2(x2, y2);
  }

  Nullable!Rect[4] remove(Rect other)
  {
    Vec2 transform = c1;
    c1 = Vec2(0, 0);
    c2 = c2 - transform;
    other = Rect(other.c1 - transform, other.c2 - transform);

    // Clamp other within this
    other.c1.x = max(c1.x, other.c1.x);
    other.c1.y = max(c1.y, other.c1.y);
    other.c2.x = min(c2.x, other.c2.x);
    other.c2.y = min(c2.y, other.c2.y);

    Nullable!Rect[4] rects;

    // Set rects
    rects[0] = Rect(c1, Vec2(c2.x, other.c1.y - 1));
    rects[1] = Rect(Vec2(c1.x, other.c1.y), Vec2(other.c1.x - 1, other.c2.y));
    rects[2] = Rect(Vec2(other.c2.x + 1, other.c1.y), Vec2(c1.x, other.c2.y));
    rects[3] = Rect(Vec2(c1.x, other.c2.y + 1), c2);

    // Set 0-size and negative value rects to null
    foreach (i, ref rect; rects)
    {
      Rect r = rect.get;
      if (r.c2.x < r.c1.x || r.c2.y < r.c1.y)
        rect.nullify;
      else if (r.c1.x < 0 || r.c1.y < 0 || r.c2.x < 0 || r.c2.y < 01)
        rect.nullify;
      else
      {
        i.writeln;
        rect = Rect(r.c1 + transform, r.c2 + transform);
      }
    }

    return rects;
  }
}

void main()
{
  Rect[] reactor;

  foreach (line; stdin.byLine)
  {
    string action;
    long x1, x2, y1, y2;
    line.writeln;
    line.formattedRead!"%s x=%d..%d,y=%d..%d"(action, x1, x2, y1, y2);

    if (action == "on")
    {
      // Set ones
      Rect[] toAddArr = [Rect(x1, x2, y1, y2)];
      foreach (rect; reactor)
      {
        foreach (i; 0 .. toAddArr.length)
        {
          Rect toAdd = toAddArr.front;
          toAddArr.popFront;

          Nullable!Rect[4] result = toAdd.remove(rect);
          bool match;
          foreach (r; result)
          {
            if (!r.isNull)
            {
              match = true;
              toAddArr ~= r.get;
            }
          }

          if (!match)
            toAddArr ~= toAdd;
        }
      }
      reactor ~= toAddArr;
    }
    else
    {
      // Remove ones
      Rect toRemove = Rect(x1, x2, y1, y2);

      size_t[] removedIndices;
      Rect[] toAdd;
      foreach (i, rect; reactor)
      {
        Nullable!Rect[4] result = rect.remove(toRemove);
        bool match;
        foreach (r; result)
        {
          if (!r.isNull)
          {
            match = true;
            toAdd ~= r.get;
          }
        }

        if (match)
          removedIndices ~= i;
      }

      foreach_reverse (i; removedIndices)
        reactor = reactor.remove(i).array;

      reactor ~= toAdd;
    }

    reactor.writeln;
  }
}
