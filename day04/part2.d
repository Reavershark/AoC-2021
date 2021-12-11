import std.stdio;
import std.conv : to;
import std.string : chomp;

import std.array : array, split;
import std.range : stride;
import std.algorithm : map, filter, all;

struct Board
{
  int[25] numbers;
  bool[25] marked;

  this(int[] numbers)
  {
    this.numbers = numbers;
  }

  void mark(int toMark)
  {
    foreach (i, n; numbers)
      if (n == toMark)
        marked[i] = true;
  }

  bool bingo()
  {
    // Rows
    foreach (x; 0 .. 5)
      if (marked[x * 5 .. x * 5 + 5].all)
        return true;
    // Columns
    foreach (y; 0 .. 5)
      if (marked[y .. $].stride(5).all)
        return true;
    return false;
  }

  int unmarkedSum()
  {
    int sum;
    foreach (i; 0 .. 25)
      if (!marked[i])
        sum += numbers[i];
    return sum;
  }
}

void main()
{
  int[] drawnNumbers = readln.chomp.split(',').map!(to!int).array;

  Board[] boards;
  int[] currBoardNumbers;
  foreach (line; stdin.byLine)
  {
    auto numbers = line.split(" ").filter!(s => s != "")
      .map!(to!int)
      .array;
    currBoardNumbers ~= numbers;
    if (currBoardNumbers.length == 25)
    {
      boards ~= Board(currBoardNumbers);
      currBoardNumbers = [];
    }
  }

  bool[] wonBoards = new bool[](boards.length);

  foreach (drawn; drawnNumbers)
  {
    foreach (boardIndex, ref board; boards)
    {
      // Skip already won boards
      if (wonBoards[boardIndex])
        continue;

      board.mark(drawn);

      if (board.bingo)
      {
        wonBoards[boardIndex] = true;
        if (wonBoards.all)
        {
          // Last board to win
          writeln(drawn * boards[boardIndex].unmarkedSum);
          return;
        }
      }
    }
  }
}
