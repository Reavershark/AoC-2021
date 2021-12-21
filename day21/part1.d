import std;

void main()
{
  // long[2] p = [4, 8]; // Example
  long[2] p = [2, 1]; // Input

  auto dice = iota(1, 101).repeat.joiner;

  long rolls;

  long turn;
  long[2] score;
  while (true)
  {
    p[turn] += dice.take(3).sum;
    dice = dice.drop(3);
    rolls += 3;
    while (p[turn] > 10)
      p[turn] -= 10;

    score[turn] += p[turn];
    if (score[turn] >= 1000)
      break;

    turn = (turn + 1) % 2;
  }

  writeln(rolls * score[(turn + 1) % 2]);
}
