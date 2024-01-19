using System;
using System.Collections.Generic;
using Godot;

public partial class Floor : Node
{
    public int Level { get; private set; }

    public FloorGenerationOutput FloorGenerationOutput { get; private set; }

    public void Setup(int level)
    {
        Level = level;
    }

    public void SetFloorData(FloorGenerationOutput floorGenerationOutput)
    {
        FloorGenerationOutput = floorGenerationOutput; 
    }

    public void DrawFloor()
    {
        foreach (var room in FloorGenerationOutput.Rooms)
        {
            var roomDefinition = room.RoomDefinition;
            var roomInstance = roomDefinition.GetRoomInstance();
            var roomPositionInTilemap = new Vector2I((int)(room.Position.X / 16), (int)(room.Position.Y / 16));
            var roomSizeInTilemap = new Vector2I(room.GetRect().Size.X / 16, room.GetRect().Size.Y / 16);

            for (int x = roomPositionInTilemap.X; x < roomPositionInTilemap.X + roomSizeInTilemap.X; x++)
            {
                for (int y = roomPositionInTilemap.Y; y < roomPositionInTilemap.Y + roomSizeInTilemap.Y; y++)
                {
                    var inputPosition = new Vector2I(x - roomPositionInTilemap.X, y - roomPositionInTilemap.Y);
                    var inputRoomTileAtlasCoords = roomInstance.GetNode<TileMap>("TileMap").GetCellAtlasCoords(
                        0,
                        inputPosition
                    );
                    if (inputRoomTileAtlasCoords == -Vector2I.One)
                    {
                        continue;
                    }
                    GD.Print("Tile at " + inputPosition + " is on atlas position " + inputRoomTileAtlasCoords);
                }
            }
        }
    }
}