using System.Collections.Generic;
using Godot;

public struct FloorGenerationOutput
{
    // includes hub rooms
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

    public FloorGenerationOutput(Room[] rooms, Room[] hubRooms, Room[] subRooms, Rect2I[] hallPaths, Room startingRoom, Room endingRoom, Edge[] triangulation, Edge[] minimumSpanningTree, Edge[] finalGraph)
    {
        this.Rooms = rooms;
        this.HubRooms = hubRooms;
        this.SubRooms = subRooms;

        this.HallPaths = hallPaths;

        this.StartingRoom = startingRoom;
        this.EndingRoom = endingRoom;

        this.Triangulation = triangulation;
        this.MinimumSpanningTree = minimumSpanningTree;
        this.FinalGraph = finalGraph;

        FloorPositions = new HashSet<Vector2I>();
        
        foreach (var room in rooms)
        {   
            if (!room.isSubRoom && !room.isHubRoom)
            {
                continue;
            }

            for (int x = (int)room.Rect.Position.X; x < (int)room.Rect.End.X; x++)
            {
                for (int y = (int)room.Rect.Position.Y; y < (int)room.Rect.End.Y; y++)
                {
                    FloorPositions.Add(new Vector2I(x, y));
                }
            }
        }

        foreach (var path in hallPaths)
        {
            for (int x = (int)path.Position.X; x < (int)path.End.X; x++)
            {
                for (int y = (int)path.Position.Y; y < (int)path.End.Y; y++)
                {
                    FloorPositions.Add(new Vector2I(x, y));
                }
            }
        }
    }
}