using Godot;
using Godot.Collections;
using System;
using System.Collections.Generic;

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
			_DrawRoom(room);
		}

		foreach (var hall in FloorGenerationOutput.Halls)
		{
			var tilesArray = new Godot.Collections.Array<Vector2I>();
			for (int x = hall.Position.X; x < hall.End.X; x++)
			{
				for (int y = hall.Position.Y; y < hall.End.Y; y++)
				{
					tilesArray.Add(new Vector2I(x, y));
				}
			}

			_SetCells(0, tilesArray, 1, Vector2I.Zero);
		}
	}

	private void _DrawRoom(Room room)
	{
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

					var roomTileMapCoords = new Vector2I(x, y);
					var floorTileMapCoords = new Vector2I(x + roomPosition.X, y + roomPosition.Y);

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

			_DrawTerrainTiles(roomTileMap, roomPosition, layer + 1, terrainTiles);
		}
	}

	// acepts a godot array of Vector2I, sorts that array by the terrain index that they are in
	// and draws them to the tilemap.
	// NOTE: assumes the terrainSet of the tile is of index 0.
	private void _DrawTerrainTiles(TileMap inputTileMap, Vector2I outputPosition, int layer, Godot.Collections.Array<Vector2I> inputTerrainTiles)
	{
		var terrains = new System.Collections.Generic.Dictionary<int, Godot.Collections.Array<Vector2I>>();
		for (int terrainIndex = 0; terrainIndex < _tileMap.TileSet.GetTerrainsCount(0); terrainIndex++)
		{
			terrains[terrainIndex] = new Godot.Collections.Array<Vector2I>();
		}
		foreach (var tile in inputTerrainTiles)
		{
			var tileData = inputTileMap.GetCellTileData(layer, tile);
			terrains[tileData.Terrain].Add(new Vector2I(tile.X + outputPosition.X, tile.Y + outputPosition.Y));
		}
		foreach (var terrainIndex in terrains.Keys)
		{
			_tileMap.SetCellsTerrainConnect(layer, terrains[terrainIndex], 0, terrainIndex);
		}
	}

	private void _SetCells(int layer, Godot.Collections.Array<Vector2I> coordsArray, int sourceId, Vector2I atlasCoords)
	{
		foreach (var coord in coordsArray)
		{
			_tileMap.SetCell(layer, coord, sourceId, atlasCoords);
		}
	}
}