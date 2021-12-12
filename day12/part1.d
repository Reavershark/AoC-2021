import std.stdio;
import std.format : formattedRead;

import std.container : SList;
import std.uni : isLower;
import std.algorithm : canFind;

/// Adjacency list 
string[][string] graph;

void readGraph()
{
  foreach (line; stdin.byLine)
  {
    string node1, node2;
    line.formattedRead("%s-%s", node1, node2);

    graph[node1] ~= node2;
    graph[node2] ~= node1;
  }
  graph.rehash;
}

bool isSmallCave(string s)
in (s.length > 0)
{
  return s[0].isLower;
}

/// Tree of unique paths
struct Tree
{
  string id;
  string[] ancestors;

  Tree[] children()
  {
    Tree[] result;

    foreach (node; graph[id])
      if (node != "start")
        if (!(node.isSmallCave && ancestors.canFind(node)))
          result ~= Tree(node, id ~ ancestors);

    return result;
  }
}

void main()
{
  readGraph;

  Tree root = Tree("start");
  SList!Tree stack = [root];

  int paths;

  while (!stack.empty)
  {
    Tree tree = stack.front;
    stack.removeFront;

    if (tree.id == "end")
    {
      paths++;
      continue;
    }

    foreach (child; tree.children)
      stack.insertFront(child);
  }

  paths.writeln;
}
