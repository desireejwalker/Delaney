using System;
using System.Collections.Generic;
using Godot;

public partial class Floor : Node
{
    public int Level { get; private set; }
    public FloorGenerationOutput FloorGenerationOutput { get; private set; }

    private TileMap _tileMap;

    public void Setup(int level)
    {
        Level = level;

        _tileMap = GetNode<TileMap>("TileMap");
    }

    public void SetFloorData(FloorGenerationOutput floorGenerationOutput)
    {
        FloorGenerationOutput = floorGenerationOutput; 
    }

    public void DrawFloor()
    {
        // set the tileset of the tilemap to the one specified in the FloorGenerationParameters
        _tileMap.TileSet = FloorGenerationOutput.FloorGenerationParameters.TileSet;

        // draw rooms
        foreach (var room in FloorGenerationOutput.Rooms)
        {
            if (!room.isHubRoom && !room.isSubRoom) continue;

            var roomDefinition = room.RoomDefinition;
            var roomInstance = roomDefinition.GetRoomInstance();
            var roomPosition = room.GetRect().Position;
            var roomTileMap = roomInstance.GetNode<TileMap>("TileMap");
            var roomTileMapUsedRect = roomTileMap.GetUsedRect();

            for (int layer = 0; layer < _tileMap.GetLayersCount(); layer++)
            {
                while (_tileMap.GetLayersCount() - 1 < roomTileMap.GetLayersCount())
                {
                    _tileMap.AddLayer(-1);
                }

                for (int x = 0; x < roomTileMapUsedRect.Size.X; x++)
                {
                    for (int y = 0; y < roomTileMapUsedRect.Size.Y; y++)
                    {
                        // if the layer index is at or above the layer count for this room, continue
                        if (layer >= roomTileMap.GetLayersCount()) continue;

                        var atlasCoords = roomTileMap.GetCellAtlasCoords(layer, new Vector2I(x, y));
                        var sourceId = roomTileMap.GetCellSourceId(layer, new Vector2I(x, y));
                        // add 1 to the layer index to avoid adding to the halls layer
                        _tileMap.SetCell(layer + 1, new Vector2I(x + roomPosition.X, y + roomPosition.Y), sourceId, atlasCoords);
                    }
                }
            }
        }

        foreach (var hall in FloorGenerationOutput.Halls)
        {
            for (int x = hall.Position.X; x < hall.End.X; x++)
            {
                for (int y = hall.Position.Y; y < hall.End.Y; y++)
                {
                    GD.Print($"{x}, {y}");
                    // layer 0 is the halls layer
                    _tileMap.SetCell(0, new Vector2I(x, y), 1, Vector2I.Zero);
                }
            }
        }

        _tileMap.UpdateInternals();
    }
}