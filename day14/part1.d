import std.stdio;
import std.string : chomp;
import std.format : formattedRead;

import std.algorithm : minElement, maxElement;

struct Node
{
  Node* next;
  char c;
}

struct Pair
{
  char a, b;
}

char[Pair] rules;
Node* root;

void readTemplate()
{
  root = new Node(null, '/');

  Node* curr = root;
  foreach (c; readln.chomp)
  {
    curr.next = new Node(null, c);
    curr = curr.next;
  }
}

void readRules()
{
  foreach (line; stdin.byLine)
  {
    Pair p;
    char c;
    line.formattedRead("%c%c -> %c", p.a, p.b, c);
    rules[p] = c;
  }
}

void step()
{
  Node* curr = root.next;
  while (curr !is null && curr.next !is null)
  {
    Pair p = Pair(curr.c, curr.next.c);
    if (p in rules)
    {
      char c = rules[p];
      Node* insert = new Node(curr.next, c);
      curr.next = insert;
      curr = curr.next.next;
    }
    else
      curr = curr.next;
  }
}

void main()
{
  readTemplate;
  readln;
  readRules;

  foreach (i; 0 .. 10)
    step;

  int[char] freq;

  Node* curr = root.next;
  while (curr !is null)
  {
    freq[curr.c]++;
    curr = curr.next;
  }

  writeln(freq.byValue.maxElement - freq.byValue.minElement);
}
