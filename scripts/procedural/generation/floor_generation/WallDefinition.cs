using Godot;
using System;
using System.Linq;

[GlobalClass]
public partial class WallDefinition : Resource
{   
    [Export]
    public TileSet TileSet { get; private set; }
    [Export]
    private Godot.Collections.Array<WallSegment> _wallSegments;

    [Export]
    public int MiddleHeight { get; private set; }

    public WallSegment[] GetWallSegmentsMatching(WallBase wallBase)
    {
        var result = _wallSegments.Where(wallSeg => {
            var isMatching = (wallSeg.SouthType < 0 || wallSeg.SouthType == wallBase.southType) &&
                             (wallSeg.SouthWestType < 0 || wallSeg.SouthWestType == wallBase.southWestType) &&
                             (wallSeg.WestType < 0 || wallSeg.WestType == wallBase.westType) &&
                             (wallSeg.NorthWestType < 0 || wallSeg.NorthWestType == wallBase.northWestType) &&
                             (wallSeg.NorthType < 0 || wallSeg.NorthType == wallBase.northType) &&
                             (wallSeg.NorthEastType < 0 || wallSeg.NorthEastType == wallBase.northEastType) &&
                             (wallSeg.EastType < 0 || wallSeg.EastType == wallBase.eastType) &&
                             (wallSeg.SouthEastType < 0 || wallSeg.SouthEastType == wallBase.southEastType);
            return isMatching;
        }).ToArray();

        if (result.Length == 0)
        {
            throw new WallSegementNotFoundException(this, wallBase);
        }

        return result;
    }
}

public class WallSegementNotFoundException : ApplicationException
{
    public WallDefinition wallDefinition;
    public WallBase wallBase;

    public WallSegementNotFoundException(WallDefinition wallDefinition, WallBase wallBase) : base(
        $@"Could not find WallSegement on {wallDefinition.ResourcePath} with the following required surrounding types:
        south: {wallBase.southType}
        southwest: {wallBase.southWestType}
        west: {wallBase.westType}
        northwest: {wallBase.northWestType}
        north: {wallBase.northType}
        northeast: {wallBase.northEastType}
        east: {wallBase.eastType}
        southeast: {wallBase.southEastType}"
    )
    {
        this.wallDefinition = wallDefinition;
        this.wallBase = wallBase;
    }
}

