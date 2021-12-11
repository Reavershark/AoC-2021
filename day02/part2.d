import std.stdio;
import std.string : chomp;
import std.format : formattedRead;

void eachLine(void delegate(string line) dg)
{
  string line;
  while ((line = readln()) !is null)
    dg(line.chomp);
}

void main()
{
  int h, d, a;
  eachLine((line) {
    string dir;
    int val;
    line.formattedRead("%s %d", dir, val);
    if (dir == "down")
      a += val;
    else if (dir == "up")
      a -= val;
    if (dir == "forward")
    {
      h += val;
      d += a * val;
    }
  });

  writeln(h * d);
}
