using Godot;
using Godot.Collections;
using Godot.NativeInterop;
using System;
using System.Collections.Generic;
using System.Linq;

public partial class Floor : Node
{
	const int WALL_TILEMAP_RECT_GROWTH = 2;

	public int Level { get; private set; }
	public FloorGenerationOutput FloorGenerationOutput { get; private set; }
	private FloorGenerationParameters _floorGenerationParameters;

	private TileMap _tileMap;

	public void Setup(int level)
	{
		Level = level;

		_tileMap = GetNode<TileMap>("TileMap");
	}

	public void SetFloorData(FloorGenerationOutput floorGenerationOutput)
	{
		FloorGenerationOutput = floorGenerationOutput;
		_floorGenerationParameters = FloorGenerationOutput.FloorGenerationParameters;
	}

	public void DrawFloor()
	{
		// set the tileset of the tilemap to the one specified in the FloorGenerationParameters
		_tileMap.TileSet = _floorGenerationParameters.TileSet;

		foreach (var room in FloorGenerationOutput.Rooms)
		{
			if (!room.isHubRoom && !room.isSubRoom) continue;
			DrawRoom(room);
		}

		foreach (var hall in FloorGenerationOutput.Halls)
		{
			DrawRect(hall, 0, 1, _floorGenerationParameters.HallTileAtlasPosition);
		}

		CreateWalls();
	}

	private void DrawRoom(Room room)
	{
		var roomDefinition = room.RoomDefinition;
		var roomInstance = roomDefinition.GetRoomInstance();
		var roomPosition = room.GetRect().Position;
		var roomTileMap = roomInstance.GetNode<TileMap>("TileMap");
		var roomTileMapUsedRect = roomTileMap.GetUsedRect();

		while (_tileMap.GetLayersCount() - 1 < roomTileMap.GetLayersCount())
		{
			_tileMap.AddLayer(-1);
		}
		
		for (int layer = 1; layer < _tileMap.GetLayersCount(); layer++)
		{
			var terrainTiles = new Array<Vector2I>();

			for (int x = 0; x < roomTileMapUsedRect.Size.X; x++)
			{
				for (int y = 0; y < roomTileMapUsedRect.Size.Y; y++)
				{
					// if the layer index is at or above the layer count for this room, continue
					if (layer > roomTileMap.GetLayersCount()) continue;

					var roomTileMapCoords = new Vector2I(x, y);
					var floorTileMapCoords = new Vector2I(x + roomPosition.X, y + roomPosition.Y);

					var tileData = roomTileMap.GetCellTileData(layer - 1, roomTileMapCoords);
					if (tileData == null) continue;

					if (tileData.Terrain >= 0)
					{
						terrainTiles.Add(roomTileMapCoords);
						continue;
					}

					var atlasCoords = roomTileMap.GetCellAtlasCoords(layer - 1, roomTileMapCoords);
					var sourceId = roomTileMap.GetCellSourceId(layer - 1, roomTileMapCoords);

					_tileMap.SetCell(layer, floorTileMapCoords, 0, atlasCoords);
				}
			}
			
			DrawTerrainTiles(roomTileMap, layer - 1, roomPosition, layer, terrainTiles);
		}
	}

	private void DrawRect(Rect2I rect, int layer, int sourceId, Vector2I atlasCoords)
	{
		var tilesArray = new Array<Vector2I>();
		for (int x = rect.Position.X; x < rect.End.X; x++)
		{
			for (int y = rect.Position.Y; y < rect.End.Y; y++)
			{
				tilesArray.Add(new Vector2I(x, y));
			}
		}

		SetCells(layer, tilesArray, 0, atlasCoords);
	}

	private void CreateWalls()
	{
		var rect = _tileMap.GetUsedRect().Grow(WALL_TILEMAP_RECT_GROWTH);
		
		var floorPositions = FloorGenerationOutput.FloorPositions;
		var wallPositions = new HashSet<Vector2I>();

		// get all positions within this rect and add them to wallPositions
		for (int x = rect.Position.X; x < rect.End.X; x++)
		{
			for (int y = rect.Position.Y; y < rect.End.Y; y++)
			{
				wallPositions.Add(new Vector2I(x, y));
			}
		}

		// remove all floorPositions from wallPositions
		wallPositions.ExceptWith(floorPositions);

		// add layer for walls
		_tileMap.AddLayer(-1);
		_tileMap.SetLayerName(-1, "walls");

		//// This seems to take a while... But it is the easiest way to get this working.
		//// Hopefully we can find a better method soon. this pushes level generation times
		//// up past 10000ms (10 seconds).
		//// - Des
		// nevermind? This only adds a bit of time to floor generation. freakin' sweet!!
		_tileMap.SetCellsTerrainConnect(
			-1,
			new Array<Vector2I>(wallPositions),
			_floorGenerationParameters.WallTerrainSet,
			_floorGenerationParameters.WallTerrain
		);

		// remove wall tiles that aren't adjacent to a floor tile
		var wallPositionsToRemove = new HashSet<Vector2I>();
		foreach (var position in wallPositions)
		{
			if (Get8Neighbors(position).Values.Any(neighbor => floorPositions.Contains(neighbor))) continue;

			wallPositionsToRemove.Add(position);
			_tileMap.EraseCell(-1, position);
		}
		wallPositions.ExceptWith(wallPositionsToRemove);


		// # TALL BACK WALL GENERATION #
		// // see what tiles we can turn into tall walls (search for walls that border a floor tile on its lower side.)
		// foreach (var position in wallPositions)
		// {
		// 	// search for floor tiles and wall tiles above, within WallMiddleHeight
		// 	bool foundFloorAbove = false;
		// 	bool foundWallAbove = false;
		// 	for (int i = 0; i < FloorGenerationOutput.FloorGenerationParameters.WallMiddleHeight; i++)
		// 	{
		// 		if (floorPositions.Contains(position + new Vector2I(0, -1 - i))) foundFloorAbove = true;
		// 		if (wallPositions.Contains(position + new Vector2I(0, -1 - i))) foundWallAbove = true;

		// 		if (foundFloorAbove && foundFloorAbove) break;
		// 	}

		// 	// if found floor or wall above and not finding a floor tile below, ignore this
		// 	if ((foundFloorAbove || foundWallAbove) ) continue;

		// 	_tileMap.SetCell(
		// 		-1,
		// 		position,
		// 		FloorGenerationOutput.FloorGenerationParameters.SourceID,
		// 		FloorGenerationOutput.FloorGenerationParameters.BackWall.BaseTileAtlasPosition
		// 	);
		// }
	}

	Godot.Collections.Dictionary<Direction, Vector2I> Get8Neighbors(Vector2I position)
	{
		Godot.Collections.Dictionary<Direction, Vector2I> neighbors = new Godot.Collections.Dictionary<Direction, Vector2I>
        {
            { Direction.East, new Vector2I(position.X + 1, position.Y) },
            { Direction.South_East, new Vector2I(position.X + 1, position.Y + 1) },
            { Direction.South, new Vector2I(position.X, position.Y + 1) },
            { Direction.South_West, new Vector2I(position.X - 1, position.Y + 1) },
            { Direction.West, new Vector2I(position.X - 1, position.Y) },
            { Direction.North_West, new Vector2I(position.X - 1, position.Y - 1) },
            { Direction.North, new Vector2I(position.X, position.Y - 1) },
            { Direction.North_East, new Vector2I(position.X + 1, position.Y - 1) }
        };
		return neighbors;
	}

	// will return Direction.South if somehow cannot evaluate
	Direction GetDirectionToNeighborCell(Vector2I position, Vector2I neighborCell, bool includeCorners)
	{
		switch (neighborCell)
		{
			case var n when _tileMap.GetNeighborCell(position, TileSet.CellNeighbor.TopSide) == n:
				return Direction.North;
			case var n when _tileMap.GetNeighborCell(position, TileSet.CellNeighbor.BottomSide) == n:
				return Direction.South;
			case var n when _tileMap.GetNeighborCell(position, TileSet.CellNeighbor.RightSide) == n:
				return Direction.East;
			case var n when _tileMap.GetNeighborCell(position, TileSet.CellNeighbor.LeftSide) == n:
				return Direction.West;
			case var n when _tileMap.GetNeighborCell(position, TileSet.CellNeighbor.TopLeftCorner) == n && includeCorners:
				return Direction.North_West;
			case var n when _tileMap.GetNeighborCell(position, TileSet.CellNeighbor.BottomLeftCorner) == n && includeCorners:
				return Direction.South_West;
			case var n when _tileMap.GetNeighborCell(position, TileSet.CellNeighbor.TopRightCorner) == n && includeCorners:
				return Direction.North_East;
			case var n when _tileMap.GetNeighborCell(position, TileSet.CellNeighbor.BottomRightCorner) == n && includeCorners:
				return Direction.South_East;
				
			default:
				return Direction.South;
		}
	}
	
	// acepts a godot array of Vector2I, sorts that array by the terrain index that they are in
	// and draws them to the tilemap.
	// NOTE: assumes the terrainSet of the tile is of index 0.
	private void DrawTerrainTiles(TileMap inputTileMap, int inputLayer, Vector2I outputPosition, int outputLayer, Godot.Collections.Array<Vector2I> inputTerrainTiles)
	{
		var terrains = new System.Collections.Generic.Dictionary<int, Godot.Collections.Array<Vector2I>>();
		for (int terrainIndex = 0; terrainIndex < _tileMap.TileSet.GetTerrainsCount(0); terrainIndex++)
		{
			terrains[terrainIndex] = new Godot.Collections.Array<Vector2I>();
		}
		foreach (var tile in inputTerrainTiles)
		{
			if (outputLayer > inputTileMap.GetLayersCount()) continue;

			var tileData = inputTileMap.GetCellTileData(inputLayer, tile);
			if (tileData == null) continue;

			terrains[tileData.Terrain].Add(new Vector2I(tile.X + outputPosition.X, tile.Y + outputPosition.Y));
		}
		foreach (var terrainIndex in terrains.Keys)
		{
			_tileMap.SetCellsTerrainConnect(outputLayer, terrains[terrainIndex], 0, terrainIndex);
		}
	}

	private void SetCells(int layer, Godot.Collections.Array<Vector2I> coordsArray, int sourceId, Vector2I atlasCoords)
	{
		foreach (var coord in coordsArray)
		{
			_tileMap.SetCell(layer, coord, sourceId, atlasCoords);
		}
	}
}