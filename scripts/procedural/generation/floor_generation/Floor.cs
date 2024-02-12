using Godot;
using Godot.Collections;
using Godot.NativeInterop;
using System;
using System.Collections.Generic;
using System.Linq;

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

		foreach (var room in FloorGenerationOutput.Rooms)
		{
			if (!room.isHubRoom && !room.isSubRoom) continue;
			DrawRoom(room);
		}

		foreach (var hall in FloorGenerationOutput.Halls)
		{
			DrawRect(hall, 0, 1, new Vector2I(16, 3));
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
		var rect = _tileMap.GetUsedRect().Grow(4);
		
		var floorPositions = FloorGenerationOutput.FloorPositions;

		// add layer for walls
		_tileMap.AddLayer(-1);
		_tileMap.SetLayerName(-1, "walls");
		var wallBases = new HashSet<WallBase>();

		// create all wall bases and set their bitmasks for surrounding floors
		for (int x = rect.Position.X; x < rect.End.X; x++)
		{
			for (int y = rect.Position.Y; y < rect.End.Y; y++)
			{
				var position = new Vector2I(x, y);

				// if the position is in the floor positions set, ignore it and continue
				if (floorPositions.Contains(position)) continue;

				var neighbors = Get8Neighbors(position).Values;

				// if none of the neighbors are in the floor position set, ignore this position and continue
				if (neighbors.All(neighbor => !floorPositions.Contains(neighbor))) continue;

				// if we made it here, this position should be a wall base
				wallBases.Add(new WallBase(position));
			}
		}

		

		foreach (var wallBase in wallBases)
		{
			var neighbors = Get8Neighbors(wallBase.Position);

			// check for floor neighbors first
			if (floorPositions.Contains(neighbors[Direction.East]))
				wallBase.eastType += (int)WallBase.SurroundingTileType.Floor;
			if (floorPositions.Contains(neighbors[Direction.South_East]))
				wallBase.southEastType += (int)WallBase.SurroundingTileType.Floor;
			if (floorPositions.Contains(neighbors[Direction.South]))
				wallBase.southType += (int)WallBase.SurroundingTileType.Floor;
			if (floorPositions.Contains(neighbors[Direction.South_West]))
				wallBase.southWestType += (int)WallBase.SurroundingTileType.Floor;
			if (floorPositions.Contains(neighbors[Direction.West]))
				wallBase.westType += (int)WallBase.SurroundingTileType.Floor;
			if (floorPositions.Contains(neighbors[Direction.North_West]))
				wallBase.northWestType += (int)WallBase.SurroundingTileType.Floor;
			if (floorPositions.Contains(neighbors[Direction.North]))
				wallBase.northType += (int)WallBase.SurroundingTileType.Floor;
			if (floorPositions.Contains(neighbors[Direction.North_East]))
				wallBase.northEastType += (int)WallBase.SurroundingTileType.Floor;

			// then check against wallBases (probably the time taker of all time since it uses LINQ)
			if (wallBases.Any(wallBase => wallBase.Position == neighbors[Direction.East]))
				wallBase.eastType += (int)WallBase.SurroundingTileType.Wall;
			if (wallBases.Any(wallBase => wallBase.Position == neighbors[Direction.South_East]))
				wallBase.southEastType += (int)WallBase.SurroundingTileType.Wall;
			if (wallBases.Any(wallBase => wallBase.Position == neighbors[Direction.South]))
				wallBase.southType += (int)WallBase.SurroundingTileType.Wall;
			if (wallBases.Any(wallBase => wallBase.Position == neighbors[Direction.South_West]))
				wallBase.southWestType += (int)WallBase.SurroundingTileType.Wall;
			if (wallBases.Any(wallBase => wallBase.Position == neighbors[Direction.West]))
				wallBase.westType += (int)WallBase.SurroundingTileType.Wall;
			if (wallBases.Any(wallBase => wallBase.Position == neighbors[Direction.North_West]))
				wallBase.northWestType += (int)WallBase.SurroundingTileType.Wall;
			if (wallBases.Any(wallBase => wallBase.Position == neighbors[Direction.North]))
				wallBase.northType += (int)WallBase.SurroundingTileType.Wall;
			if (wallBases.Any(wallBase => wallBase.Position == neighbors[Direction.North_East]))
				wallBase.northEastType += (int)WallBase.SurroundingTileType.Floor;


			// draw wallseg to tilemap
			WallSegment[] wallSegments;
            WallDefinition wallDefinition = FloorGenerationOutput.FloorGenerationParameters.WallDefinition;

			try
			{
                wallSegments = wallDefinition.GetWallSegmentsMatching(wallBase);
			}
			catch(WallSegementNotFoundException)
			{
				continue;
			}

			var wallSeg = wallSegments[GD.Randi() % wallSegments.Length];

			if (wallSeg.BaseTileAtlasPosition == -Vector2I.One) continue;
			_tileMap.SetCell(-1, wallBase.Position, 0, wallSeg.BaseTileAtlasPosition, 0);
			
			if (wallSeg.MiddleTileAtlasPosition == -Vector2I.One) continue;
			for (int i = 1; i < wallDefinition.MiddleHeight + 2; i++)
			{
				_tileMap.SetCell(-1, wallBase.Position + (Vector2I.Up * i), 0, wallSeg.MiddleTileAtlasPosition, 0);
			}

			if (wallSeg.TopTileAtlasPosition == -Vector2I.One) continue;
			_tileMap.SetCell(-1, wallBase.Position + (Vector2I.Up * (wallDefinition.MiddleHeight + 1)), 0, wallSeg.TopTileAtlasPosition, 0);
		}
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