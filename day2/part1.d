import std.stdio;
import std.conv : to;
import std.string : chomp;
import std.format : formattedRead;

import std.range;
import std.algorithm;

void eachLine(void delegate(string line) dg)
{
  string line;
  while ((line = readln()) !is null)
    dg(line.chomp);
}

void main()
{
  int h, d;
  eachLine((line) {
    string dir;
    int val;
    line.formattedRead("%s %d", dir, val);
    if (dir == "forward") h += val;
    else if (dir == "down") d += val;
    else if (dir == "up") d -= val;
  });

  writeln(h * d);
}
