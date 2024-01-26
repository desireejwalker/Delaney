using System;
using System.Collections.Generic;
using Godot;
using Godot.Collections;

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

                var terrainTiles = new Godot.Collections.Array<Vector2I>();

                for (int x = 0; x < roomTileMapUsedRect.Size.X; x++)
                {
                    for (int y = 0; y < roomTileMapUsedRect.Size.Y; y++)
                    {
                        // if the layer index is at or above the layer count for this room, continue
                        if (layer >= roomTileMap.GetLayersCount()) continue;

                        Vector2I roomTileMapCoords = new Vector2I(x, y);
                        Vector2I floorTileMapCoords = new Vector2I(x + roomPosition.X, y + roomPosition.Y);

                        var atlasCoords = roomTileMap.GetCellAtlasCoords(layer, roomTileMapCoords);
                        var sourceId = roomTileMap.GetCellSourceId(layer, roomTileMapCoords);
                        var tileData = roomTileMap.GetCellTileData(layer, roomTileMapCoords);

                        // if no tileData, theres no tile to read
                        if (tileData == null)
                        {
                            continue;
                        }

                        // check if the tile is in a terrain set. If so, add it to terrainTilesDict 
                        // for batching with SetCellsTerrainConnect()
                        // add 1 to the layer index to avoid adding to the halls layer
                        if (tileData.TerrainSet == -1)
                        {
                            _tileMap.SetCell(layer + 1, floorTileMapCoords, sourceId, atlasCoords);
                            continue;
                        }

                        if (tileData.Terrain >= 0)
                        {
                            terrainTiles.Add(roomTileMapCoords);
                        }
                    }
                }

                var terrains = new System.Collections.Generic.Dictionary<int, Godot.Collections.Array<Vector2I>>();
                for (int terrainIndex = 0; terrainIndex < _tileMap.TileSet.GetTerrainsCount(0); terrainIndex++)
                {
                    terrains[terrainIndex] = new Godot.Collections.Array<Vector2I>();
                }
                foreach (var tile in terrainTiles)
                {
                    var tileData = roomTileMap.GetCellTileData(layer, tile);
                    terrains[tileData.Terrain].Add(new Vector2I(tile.X + roomPosition.X, tile.Y + roomPosition.Y));
                }
                foreach (var terrainIndex in terrains.Keys)
                {
                    _tileMap.SetCellsTerrainConnect(layer + 1, terrains[terrainIndex], 0, terrainIndex);
                }
            }
        }

        foreach (var hall in FloorGenerationOutput.Halls)
        {
            for (int x = hall.Position.X; x < hall.End.X; x++)
            {
                for (int y = hall.Position.Y; y < hall.End.Y; y++)
                {
                    _tileMap.SetCell(0, new Vector2I(x, y), 1, Vector2I.Zero);
                }
            }
        }

        _tileMap.UpdateInternals();
    }
}