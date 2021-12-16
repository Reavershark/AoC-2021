import std.stdio;
import std.string : chomp;
import std.conv : to;
import std.format : format;

import std.bitmanip : BitArray, bitfields;
import std.algorithm : map, fold, minElement, maxElement;

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

  union Data
  {
    ulong literal;
    Packet[] subPackets;
  }

  Data data;
  alias data this;

  bool isLiteral() const
  {
    return typeId == 4;
  }

  ulong value()
  {
    final switch (typeId)
    {
    case 0:
      return subValues.fold!"a + b";
    case 1:
      return subValues.fold!"a * b";
    case 2:
      return subValues.minElement;
    case 3:
      return subValues.maxElement;
    case 4:
      return literal;
    case 5:
      return cast(ulong)(subPackets[0].value > subPackets[1].value);
    case 6:
      return cast(ulong)(subPackets[0].value < subPackets[1].value);
    case 7:
      return cast(ulong)(subPackets[0].value == subPackets[1].value);
    }
  }

  auto subValues()
  in (!isLiteral)
  {
    return subPackets.map!(p => p.value);
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

ulong readLiteralValue(ref BitStream bs)
{
  ulong value;

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

void main()
{
  string hex = readln.chomp;
  BitStream bs = BitStream.fromHexString(hex);

  Packet root = parse(bs);

  writeln(root.value);
}
