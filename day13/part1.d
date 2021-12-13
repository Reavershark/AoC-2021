import std.stdio;
import std.string : chomp;
import std.format : formattedRead;

struct Point
{
  int x, y;
}

void main()
{
  Point[Point] dots;

  string line;
  // Dots
  while ((line = readln.chomp) != "")
  {
    Point dot;
    line.formattedRead("%d,%d", dot.x, dot.y);
    dots[dot] = dot;
  }

  // Folds
  while ((line = readln.chomp) != "")
  {
    char axis;
    int pos;
    line.formattedRead("fold along %c=%d", axis, pos);

    foreach (dot; dots.byValue)
    {
      if (axis == 'x' && dot.x > pos)
      {
        dots.remove(dot);
        dot.x = pos - (dot.x - pos);
        dots[dot] = dot;
      }
      else if (axis == 'y' && dot.y > pos)
      {
        dots.remove(dot);
        dot.y = pos - (dot.y - pos);
        dots[dot] = dot;
      }
    }
    writeln(dots.length);
  }
}
