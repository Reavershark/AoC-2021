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

  int lastFoldX, lastFoldY;

  // Folds
  while ((line = readln.chomp) != "")
  {
    char axis;
    int pos;
    line.formattedRead("fold along %c=%d", axis, pos);

    if (axis == 'x')
      lastFoldX = pos;
    if (axis == 'y')
      lastFoldY = pos;

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
  }

  // Draw dots
  foreach (y; 0 .. lastFoldY)
  {
    foreach (x; 0 .. lastFoldX)
    {
      if (Point(x, y) in dots)
        write('#');
      else
        write(' ');
    }
    writeln;
  }
}
