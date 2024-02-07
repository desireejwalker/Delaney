using Godot;
using System;

[GlobalClass]
public partial class WallDefinition : Resource
{   
    [Export]
    public TileSet TileSet { get; private set; }

    [ExportGroup("Tile Atlas Config")]
    [Export]
    public WallSegment FloorNeighboringTopSideWallSegment { get; private set; }
    [Export]
    public WallSegment FloorNeighboringBottomSideWallSegment { get; private set; }
    [Export]
    public WallSegment FloorNeighboringRightSideWallSegment { get; private set; }
    [Export]
    public WallSegment FloorNeighboringLeftSideWallSegment { get; private set; }
    [Export]
    public WallSegment FloorNeighboringTopLeftCornerWallSegment { get; private set; }
    [Export]
    public WallSegment FloorNeighboringBottomLeftCornerWallSegment { get; private set; }
    [Export]
    public WallSegment FloorNeighboringTopRightCornerWallSegment { get; private set; }
    [Export]
    public WallSegment FloorNeighboringBottomRightCornerWallSegment { get; private set; }

    [Export]
    public int MiddleHeight { get; private set; }

    public WallSegment GetWallSegmentForCellNeighbor(TileSet.CellNeighbor cellNeighbor)
    {
        switch (cellNeighbor)
        {
            case TileSet.CellNeighbor.TopSide: return FloorNeighboringTopSideWallSegment;
            case TileSet.CellNeighbor.BottomSide: return FloorNeighboringBottomSideWallSegment;
            case TileSet.CellNeighbor.RightSide: return FloorNeighboringRightSideWallSegment;
            case TileSet.CellNeighbor.LeftSide: return FloorNeighboringLeftSideWallSegment;
            case TileSet.CellNeighbor.TopLeftCorner: return FloorNeighboringTopLeftCornerWallSegment;
            case TileSet.CellNeighbor.BottomLeftCorner: return FloorNeighboringBottomLeftCornerWallSegment;
            case TileSet.CellNeighbor.TopRightCorner: return FloorNeighboringTopRightCornerWallSegment;
            case TileSet.CellNeighbor.BottomRightCorner: return FloorNeighboringBottomRightCornerWallSegment;
            default: return FloorNeighboringBottomSideWallSegment;
        }
    }
}

public struct WallBase
{
	public readonly Vector2I Position;
	public readonly TileSet.CellNeighbor FloorCellNeighbor;

	public WallBase(Vector2I position, TileSet.CellNeighbor floorCellNeighbor)
	{
		this.Position = position;
		this.FloorCellNeighbor = floorCellNeighbor;
	}
}

