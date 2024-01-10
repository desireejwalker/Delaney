using System.Collections.Generic;
using Godot;

public partial class Floor : Node
{
    public int Level { get; }

    public Room[] Rooms;
    public Room[] HubRooms;
    public Room[] SubRooms;

    public Rect2I[] HallPaths;

    public Room StartingRoom;
    public Room EndingRoom;

    public HashSet<Vector2I> FloorPositions;

    public Edge[] Triangulation;
    public Edge[] MinimumSpanningTree;
    public Edge[] FinalGraph;

    public Floor(int level)
    {
        this.Level = level;

        Rooms = null;
        HubRooms = null;
        SubRooms = null;

        HallPaths = null;

        StartingRoom = null;
        EndingRoom = null;

        FloorPositions = null;

        Triangulation = null;
        MinimumSpanningTree = null;
        FinalGraph = null;
    }
    public Floor(int level, FloorGenerationOutput floorGenerationOutput)
    {
        Level = level;

        Rooms = floorGenerationOutput.Rooms;
        HubRooms = floorGenerationOutput.HubRooms;
        SubRooms = floorGenerationOutput.SubRooms;

        HallPaths = floorGenerationOutput.HallPaths;

        StartingRoom = floorGenerationOutput.StartingRoom;
        EndingRoom = floorGenerationOutput.EndingRoom;

        FloorPositions = floorGenerationOutput.FloorPositions;

        Triangulation = floorGenerationOutput.Triangulation;
        MinimumSpanningTree = floorGenerationOutput.MinimumSpanningTree;
        FinalGraph = floorGenerationOutput.FinalGraph;
    }
}