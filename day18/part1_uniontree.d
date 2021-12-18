import std.stdio;
import std.conv : to;
import std.format : format;

import std.bitmanip : bitfields;

struct Pair
{
  // mixin(bitfields!(
  //     bool, "leftIsPair", 1,
  //     bool, "rightIsPair", 1,
  //     uint, "", 6
  // ));

  bool leftIsPair = false;
  bool rightIsPair = false;

  union Child
  {
    long number;
    Pair* pair;
  }

  Child left;
  Child right;

  /// Visit root, then left, then right
  bool preOrder(bool delegate(Child* node, bool nodeIsPair, long depth) dg, long depth = 0)
  {
    Child* thisAsChild = new Child;
    thisAsChild.pair = &this;
    if (!dg(thisAsChild, true, depth))
      return false;

    if (leftIsPair)
    {
      if (!left.pair.preOrder(dg, depth + 1))
        return false;
    }
    else
    {
      if (!dg(&left, leftIsPair, depth + 1))
        return false;
    }

    if (rightIsPair)
    {
      if (!right.pair.preOrder(dg, depth + 1))
        return false;
    }
    else
    {
      if (!dg(&right, rightIsPair, depth + 1))
        return false;
    }

    return true;
  }

  long magnitude() const
  {
    long m = 0;

    if (leftIsPair)
      m += 3 * left.pair.magnitude;
    else
      m += 3 * left.number;

    if (rightIsPair)
      m += 2 * right.pair.magnitude;
    else
      m += 2 * right.number;

    return m;
  }

  string toString() const
  {
    string l = leftIsPair ? left.pair.toString : left.number.to!string;
    string r = rightIsPair ? right.pair.toString : right.number.to!string;
    return format!"[%s,%s]"(l, r);
  }
}

Pair* add(Pair* a, Pair* b)
{
  Pair* pair = new Pair;

  pair.leftIsPair = true;
  pair.rightIsPair = true;

  pair.left.pair = a;
  pair.right.pair = b;

  return pair;
}

Pair* parse(char[] arr)
{
  Pair* pair = new Pair;

  // arr must be a pair
  assert(arr[0] == '[');
  assert(arr[$ - 1] == ']');

  // Find comma of this pair
  long commaPos;
  long depth;
  foreach (i, c; arr[1 .. $ - 1])
  {
    if (c == '[')
      depth++;
    else if (c == ']')
      depth--;
    else if (c == ',')
      if (depth == 0)
      {
        commaPos = i + 1; // We started at i=1
        break;
      }
  }
  assert(commaPos != 0);

  // Parse each child as pair or number
  char[] leftSlice = arr[1 .. commaPos];
  char[] rightSlice = arr[commaPos + 1 .. $ - 1];

  // Left
  if (leftSlice[0] == '[')
  {
    pair.leftIsPair = true;
    pair.left.pair = parse(leftSlice);
  }
  else
    pair.left.number = leftSlice.to!long;

  // Right
  if (rightSlice[0] == '[')
  {
    pair.rightIsPair = true;
    pair.right.pair = parse(rightSlice);
  }
  else
    pair.right.number = rightSlice.to!long;

  return pair;
}

bool explode(Pair* root)
{
  Pair* toExplode;
  Pair* toExplodeParent;
  long* firstLeft;
  long* firstRight;

  long skip; // Needed for skipping toExplode children
  root.preOrder((Pair.Child* node, bool nodeIsPair, long depth) {
    if (skip > 0)
    {
      skip--;
      return true;
    }

    // toExplode
    if (nodeIsPair && toExplode is null && depth == 4)
    {
      toExplode = node.pair;
      assert(toExplode !is null);
      skip = 2;
      return true;
    }

    // firstLeft
    if (!nodeIsPair && toExplode is null)
    {
      firstLeft = &node.number;
      return true;
    }

    // firstRight
    if (!nodeIsPair && toExplode !is null)
    {
      assert(firstRight is null);
      firstRight = &node.number;
      return false;
    }

    return true;
  });

  if (toExplode is null)
    return false;

  // Find toExplodeParent
  root.preOrder((Pair.Child* node, nodeIsPair, long depth) {
    if (nodeIsPair && depth == 3)
    {
      Pair* p = node.pair;
      if (p.leftIsPair && p.left.pair == toExplode)
        toExplodeParent = p;
      else if (p.rightIsPair && p.right.pair == toExplode)
        toExplodeParent = p;
    }
    return toExplodeParent is null;
  });
  assert(toExplodeParent !is null);

  // Perform explosion
  {
    // Note: "Exploding pairs will always consist of two regular numbers."
    assert(!toExplode.leftIsPair && !toExplode.rightIsPair);

    // Add numbers to first left and right
    if (firstLeft !is null)
      *firstLeft += toExplode.left.number;
    if (firstRight !is null)
      *firstRight += toExplode.right.number;

    // Set toExplode to 0
    if (toExplodeParent.leftIsPair && toExplodeParent.left.pair == toExplode)
    {
      toExplodeParent.leftIsPair = false;
      toExplodeParent.left.number = 0;
    }
    else if (toExplodeParent.rightIsPair && toExplodeParent.right.pair == toExplode)
    {
      toExplodeParent.rightIsPair = false;
      toExplodeParent.right.number = 0;
    }
    else
      assert(false);
  }

  return true;
}

bool split(Pair* root)
{
  bool result;

  root.preOrder((Pair.Child* node, bool nodeIsPair, long depth) {
    assert(!result);
    if (nodeIsPair)
    {
      Pair* pair = node.pair;
      if (!pair.leftIsPair && pair.left.number >= 10)
      {
        long number = pair.left.number;

        Pair* split = new Pair;
        split.left.number = number / 2;
        split.right.number = (number + 1) / 2;

        pair.leftIsPair = true;
        pair.left.pair = split;

        result = true;
        return false;
      }
      else if (!pair.rightIsPair && pair.right.number >= 10)
      {
        long number = pair.right.number;

        Pair* split = new Pair;
        split.left.number = number / 2;
        split.right.number = (number + 1) / 2;

        pair.rightIsPair = true;
        pair.right.pair = split;

        result = true;
        return false;
      }
    }

    return true;
  });

  if (result == false)
  {
    root.preOrder((Pair.Child* node, bool nodeIsPair, long depth) {
      if (!nodeIsPair)
        assert(node.number < 10);
      return true;
    });
  }

  return result;
}

void reduce(Pair* pair)
{
  while (true)
  {
    if (pair.explode)
    {
      // writeln("explode:  ", *pair);
      continue;
    }

    if (pair.split)
    {
      // writeln("split:    ", *pair);
      continue;
    }

    break;
  }
}

void main()
{
  Pair* root;

  foreach (line; stdin.byLine)
  {
    if (root is null)
      root = line.parse;
    else
    {
      Pair* pair = line.parse;
      // writeln("  ", *root);
      // writeln("+ ", *pair);
      root = add(root, pair);
      root.reduce;
      // writeln("= ", *root);
      // writeln;
    }
  }

  writeln(*root);
  writeln(root.magnitude);
}

unittest
{
  bool test(string input, string output)
  {
    Pair* p = input.to!(char[]).parse;
    p.reduce;
    return p.toString == output;
  }

  assert(test("[[[[[9,8],1],2],3],4]", "[[[[0,9],2],3],4]"));
  assert(test("[7,[6,[5,[4,[3,2]]]]]", "[7,[6,[5,[7,0]]]]"));
  assert(test("[[6,[5,[4,[3,2]]]],1]", "[[6,[5,[7,0]]],3]"));

  assert(test("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]", "[[3,[2,[8,0]]],[9,[5,[7,0]]]]"));

  assert(test("[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]", "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]"));
}
