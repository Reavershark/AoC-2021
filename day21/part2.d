import std;

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

/** 
 * Returns: Times player1 won
 */
long turn(long[2] p, long[2] score, long turnI, long diceRoll, long universes)
{
  p[turnI] += diceRoll;
  while (p[turnI] > 10)
    p[turnI] -= 10;

  score[turnI] += p[turnI];
  if (score[turnI] >= 21)
    return universes;

  turnI = (turnI + 1) % 2;

  long timesP1Won;
  foreach (i, v; universeFreq.parallel)
    if (i > 0)
      timesP1Won += turn(p, score, turnI, i, universes + v);
  return timesP1Won;
}

void main()
{
  long[2] p = [4, 8]; // Example
  // long[2] p = [2, 1]; // Input

  long[2] score;

  long timesP1Won;
  foreach (i, v; universeFreq)
    if (i > 0)
      timesP1Won += turn(p, score, 0, i, v);

  writeln(timesP1Won);
}
