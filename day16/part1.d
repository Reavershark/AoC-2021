import std.stdio;
import std.string : chomp;
import std.conv : to;
import std.format : format;

import std.bitmanip : BitArray, bitfields;
import std.range : take;

struct BitStream
{
  BitArray arr;
  int index;

  bool front() const
  in (!empty)
  {
    return arr[index];
  }

  void popFront()
  in (!empty)
  {
    index++;
  }

  bool empty() const
  {
    return index >= arr.length;
  }

  void reset()
  {
    index = 0;
  }

  size_t length() const
  {
    if (empty)
      return 0;
    return arr.length - index;
  }

  uint readDec(int bits)
  in (bits <= length)
  {
    uint ret = 0;
    foreach (i; 0 .. bits)
    {
      ret <<= 1;
      ret = ret | cast(uint) front;
      popFront;
    }
    return ret;
  }

  static BitStream fromHexString(string hex)
  {
    BitStream bs;

    import std.range : chunks;
    import std.format : singleSpec, unformatValue;

    auto spec = singleSpec("%X");

    foreach (hexByte; hex.chunks(2))
    {
      ubyte b = hexByte.unformatValue!ubyte(spec);
      foreach (i; 0 .. 8)
      {
        bs.arr ~= cast(bool)(b & 0x80);
        b <<= 1;
      }
    }

    return bs;
  }
}

struct Packet
{
  mixin(bitfields!(
      uint, "ver", 3,
      uint, "typeId", 3,
      uint, "", 2
  ));

  long literal;
  Packet[] subPackets;

  bool isLiteral() const
  {
    return typeId == 4;
  }

  string toString() const
  {
    string var;
    if (isLiteral)
      var = "literal: " ~ literal.to!string;
    else
      var = "subPackets: " ~ subPackets.to!string;
    return format!"Packet(ver: %u, typeId: %u, %s)"(ver, typeId, var);
  }
}

Packet parse(ref BitStream bs)
{
  Packet p;

  p.ver = bs.readDec(3);
  p.typeId = bs.readDec(3);

  if (p.isLiteral)
  {
    p.literal = bs.readLiteralValue;
  }
  else
  {
    bool lengthType = bs.front;
    bs.popFront;

    if (lengthType == 0)
    {
      uint subPacketBitLength = bs.readDec(15);

      int bitsRead;
      int lastBsIndex = bs.index;
      while (bitsRead < subPacketBitLength)
      {
        p.subPackets ~= parse(bs);

        int diff = bs.index - lastBsIndex;
        bitsRead += diff;

        lastBsIndex = bs.index;
      }
    }
    else
    {
      uint subPacketCount = bs.readDec(11);

      foreach (i; 0 .. subPacketCount)
        p.subPackets ~= parse(bs);
    }
  }

  return p;
}

long readLiteralValue(ref BitStream bs)
{
  long value;

  bool notLastGroup;
  do
  {
    notLastGroup = bs.front;
    bs.popFront;

    uint group = bs.readDec(4);

    value <<= 4;
    value |= group;
  }
  while (notLastGroup);

  return value;
}

uint versionSum(Packet p)
{
  uint sum;
  sum += p.ver;
  if (!p.isLiteral)
    foreach(s; p.subPackets)
      sum += s.versionSum;
  return sum;
}

void main()
{
  string hex = readln.chomp;
  BitStream bs = BitStream.fromHexString(hex);

  Packet root = bs.parse;

  writeln(root.versionSum);
}
