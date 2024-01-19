using Godot;
using System;

[GlobalClass]
public partial class FloorGenerationParameters : Resource
{
    [ExportGroup("Global Settings")]
    [Export]
    public int MinimumFloorLevelInclusive { get; private set; }
    [Export]
    public int MaximumFloorLevelInclusive { get; private set; }
    [Export]
    public TileSet TileSet { get; private set; }
    [Export]
    public PackedScene FXScene { get; private set; }

    [ExportGroup("Inital Room Placement Settings")]
    [Export]
    public RoomDefinition[] RoomDefinitions { get; private set; }
    [Export]
    public int RoomCount { get; private set; }
    [Export]
    public float RoomPlacementEllipseWidth { get; private set; }
    [Export]
    public float RoomPlacementEllipseHeight { get; private set; }
    
    [ExportGroup("Room Size Settings")]
    [Export]
    public float RoomSizeThresholdMultiplier { get; private set; }
    
    [ExportGroup("Hallway Settings")]
    [Export(PropertyHint.Range, "0, 1")]
    public float PercentOfDelaunayEdgesToKeep { get; private set; }
    [Export]
    public int HallwayPathThickness { get; private set; }

    public bool IsWithinGenerationBounds(int floorLevel)
    {
        return floorLevel >= MinimumFloorLevelInclusive && floorLevel <= MaximumFloorLevelInclusive;
    }
}
