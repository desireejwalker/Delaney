using Godot;
using System;

[GlobalClass]
public partial class WallDefinition : Resource
{   
    [Export]
    public TileSet TileSet { get; private set; }

    [ExportGroup("Tile Atlas Config")]
    [Export]
    public WallSegment NorthWallSegment { get; private set; }
    [Export]
    public WallSegment SouthWallSegment { get; private set; }
    [Export]
    public WallSegment EastWallSegment { get; private set; }
    [Export]
    public WallSegment WestWallSegment { get; private set; }
    [Export]
    public WallSegment NorthWestWallSegment { get; private set; }
    [Export]
    public WallSegment SouthWestWallSegment { get; private set; }
    [Export]
    public WallSegment NorthEastWallSegment { get; private set; }
    [Export]
    public WallSegment SouthEastWallSegment { get; private set; }

    [Export]
    public int MiddleHeight { get; private set; }

    public WallSegment GetWallSegmentForDirection(Direction direction)
    {
        switch (direction)
        {
            case Direction.North: return NorthWallSegment;
            case Direction.South: return SouthWallSegment;
            case Direction.East: return EastWallSegment;
            case Direction.West: return WestWallSegment;
            case Direction.North_West: return NorthWestWallSegment;
            case Direction.South_West: return SouthWestWallSegment;
            case Direction.North_East: return NorthEastWallSegment;
            case Direction.South_East: return SouthEastWallSegment;
            default: return SouthWallSegment;
        }
    }
}

