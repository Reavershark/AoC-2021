import std.stdio;
import std.conv : to;

import std.range : retro, walkLength, isInputRange;
import std.algorithm : map;
import std.container.dlist;

int mostCommonBits(R)(R numbers, size_t width, bool inverse = false) if (isInputRange!R)
in (numbers.walkLength > 1)
{
  int[] ones = new int[](width);

  foreach (n; numbers)
  {
    int bitpos = 0;
    while (n != 0)
    {
      // Check for 1, update count
      if ((n & 1) != 0)
        ones[$ - 1 - bitpos]++;
      bitpos++;
      n >>= 1;
    }
  }

  int result = 0;
  foreach (bit; ones.map!(count => count >= numbers.walkLength / 2.0))
  {
    result <<= 1;
    if (bit ^ inverse)
      result++;
  }
  return result;
}

void main()
{
  size_t width;
  int[] numbers;

  foreach (line; stdin.byLine)
  {
    // Get the amount of columns from the first line
    if (width == 0)
      width = line.length;

    numbers ~= line.to!int(2);
  }

  int result = 1;

  foreach (inverse; [false, true])
  {
    auto queue = DList!int(numbers);
    size_t length = numbers.length;
    size_t bitpos = width - 1;

    while (length > 1)
    {
      int bitCriteria = ((mostCommonBits(queue[], width, inverse) >> bitpos) & 1);
      foreach (_; 0 .. length)
      {
        int n = queue.front;
        queue.removeFront;
        if (((n >> bitpos) & 1) == bitCriteria)
          queue.insertBack(n);
      }
      bitpos--;
      length = queue[].walkLength;
    }
    result *= queue.front;
  }

  writeln(result);
}
