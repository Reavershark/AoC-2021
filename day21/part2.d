import std.stdio;

import std.array : array;
import std.parallelism : parallel;

long[10] universeFreq()
{
  static long[10] freq;
  static bool done;

  if (!done)
  {
    synchronized
    {
      foreach (a; [1, 2, 3])
        foreach (b; [1, 2, 3])
          foreach (c; [1, 2, 3])
            freq[a + b + c]++;
      done = true;
    }
  }
  return freq;
}

struct Result
{
  long timesP1Won, timesP2Won;

  Result opBinary(string op)(const Result rhs) const
  {
    static if (op == "+")
      return Result(timesP1Won + rhs.timesP1Won, timesP2Won + rhs.timesP2Won);
  }

  long max()
  {
    return timesP1Won > timesP2Won ? timesP1Won : timesP2Won;
  }
}

/** 
 * Returns: Times each player won
 */
Result turn(long[2] p, long[2] score, long turnI, long diceRoll, long universes)
{
  p[turnI] += diceRoll;
  while (p[turnI] > 10)
    p[turnI] -= 10;

  score[turnI] += p[turnI];
  if (score[turnI] >= 21)
  {
    Result result;
    if (turnI == 0)
      result.timesP1Won = universes;
    else
      result.timesP2Won = universes;
    return result;
  }

  turnI = (turnI + 1) % 2;

  Result result;
  foreach (i, v; universeFreq)
    if (v > 0)
      result = result + turn(p, score, turnI, i, universes * v);
  return result;
}

void main()
{
  // long[2] p = [4, 8]; // Example
  long[2] p = [2, 1]; // Input

  long[2] score;

  Result result;
  foreach (i, v; universeFreq.array.parallel)
    if (v > 0)
      result = result + turn(p, score, 0, i, v);

  writeln(result.max);
}
