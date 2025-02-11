using System.Collections.Generic;
using System.Linq;
using Godot;

public partial class FloorGenerationOutput : Resource
{
    // includes hub rooms and sub rooms
    public readonly Room[] Rooms;
    public readonly Room[] HubRooms;
    public readonly Room[] SubRooms;

    public readonly Rect2I[] Halls;

    public readonly Room StartingRoom;
    public readonly Room EndingRoom;

    public readonly Vector2I[] FloorPositions;

    public readonly Edge[] Triangulation;
    public readonly Edge[] MinimumSpanningTree;
    public readonly Edge[] FinalGraph;

    public readonly FloorGenerationParameters FloorGenerationParameters;

    public FloorGenerationOutput(Room[] rooms, Room[] hubRooms, Room[] subRooms, Rect2I[] halls, Room startingRoom, Room endingRoom, Edge[] triangulation, Edge[] minimumSpanningTree, Edge[] finalGraph, FloorGenerationParameters floorGenerationParameters)
    {
        this.Rooms = rooms;
        this.HubRooms = hubRooms;
        this.SubRooms = subRooms;

        this.Halls = halls;

        this.StartingRoom = startingRoom;
        this.EndingRoom = endingRoom;

        this.Triangulation = triangulation;
        this.MinimumSpanningTree = minimumSpanningTree;
        this.FinalGraph = finalGraph;

        this.FloorGenerationParameters = floorGenerationParameters;

        var floorPositions = new HashSet<Vector2I>();
        
        foreach (var room in rooms)
        {   
            if (!room.isSubRoom && !room.isHubRoom)
            {
                continue;
            }

            for (int x = room.GetRect().Position.X; x < room.GetRect().End.X; x++)
            {
                for (int y = room.GetRect().Position.Y; y < room.GetRect().End.Y; y++)
                {
                    floorPositions.Add(new Vector2I(x, y));
                }
            }
        }

        foreach (var path in halls)
        {
            for (int x = (int)path.Position.X; x < (int)path.End.X; x++)
            {
                for (int y = (int)path.Position.Y; y < (int)path.End.Y; y++)
                {
                    floorPositions.Add(new Vector2I(x, y));
                }
            }
        }

        FloorPositions = floorPositions.ToArray();
    }
}