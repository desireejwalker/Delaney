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
		var tileMapUsedRect = _tileMap.GetUsedRect();

		var wallBases = new HashSet<WallBase>();

		// create all wall bases and set their bitmasks for surrounding floors
		for (int x = tileMapUsedRect.Position.X; x < tileMapUsedRect.End.X; x++)
		{
			for (int y = tileMapUsedRect.Position.Y; y < tileMapUsedRect.End.Y; y++)
			{
				var position = new Vector2I(x, y);
				var neighbor = position;

				// if the position isnt in the floor positions set, ignore it and continue
				if (!FloorGenerationOutput.FloorPositions.Contains(position)) continue;

				var wallBasePosition = neighbor;
				if (FloorGenerationOutput.FloorGenerationParameters.CreateWallsOnInnerEdge)
				{
					wallBasePosition = position;
				}

				// create the wallbase and set its position
				var wallBase = new WallBase(wallBasePosition);

				// set the wallbases surrounding tile types
				var south = new Vector2I(x, y+1);
				var west = new Vector2I(x-1, y);
				var north = new Vector2I(x, y-1);
				var east = new Vector2I(x+1, y);

				if (FloorGenerationOutput.FloorPositions.Contains(south))
				{
					wallBase.southType += (int)WallBase.SurroundingTileType.Floor;
				}
				if (FloorGenerationOutput.FloorPositions.Contains(west))
				{
					wallBase.westType += (int)WallBase.SurroundingTileType.Floor;
				}
				if (FloorGenerationOutput.FloorPositions.Contains(north))
				{
					wallBase.northType += (int)WallBase.SurroundingTileType.Floor;
				}
				if (FloorGenerationOutput.FloorPositions.Contains(east))
				{
					wallBase.eastType += (int)WallBase.SurroundingTileType.Floor;
				}

				// do corners if the params allow it
				if (FloorGenerationOutput.FloorGenerationParameters.FillCorners) continue;

				var southWest = new Vector2I(x-1, y+1);
				var northWest = new Vector2I(x-1, y-1);
				var northEast = new Vector2I(x+1, y-1);
				var southEast = new Vector2I(x+1, y+1);

				if (FloorGenerationOutput.FloorPositions.Contains(southWest))
				{
					wallBase.southWestType += (int)WallBase.SurroundingTileType.Floor;
				}
				if (FloorGenerationOutput.FloorPositions.Contains(northWest))
				{
					wallBase.northWestType += (int)WallBase.SurroundingTileType.Floor;
				}
				if (FloorGenerationOutput.FloorPositions.Contains(northEast))
				{
					wallBase.northEastType += (int)WallBase.SurroundingTileType.Floor;
				}
				if (FloorGenerationOutput.FloorPositions.Contains(southEast))
				{
					wallBase.southEastType += (int)WallBase.SurroundingTileType.Floor;
				}
			}
		}

		// search through every wallbase to see if it neighbors another
		// then draw the wallsegments to the tilemap
		foreach (var wallBase in wallBases)
		{
			var south = new Vector2I(wallBase.Position.X, wallBase.Position.Y+1);
			var west = new Vector2I(wallBase.Position.X-1, wallBase.Position.Y);
			var north = new Vector2I(wallBase.Position.X, wallBase.Position.Y-1);
			var east = new Vector2I(wallBase.Position.X+1, wallBase.Position.Y);

			// check against the entire set of wallBases to see if there are any neighboring wallbases
			if (wallBases.Where(x => x.Position == south).ToArray().Length == 1)
			{
				wallBase.southType += (int)WallBase.SurroundingTileType.Wall;
			}
			if (wallBases.Where(x => x.Position == west).ToArray().Length == 1)
			{
				wallBase.westType += (int)WallBase.SurroundingTileType.Wall;
			}
			if (wallBases.Where(x => x.Position == north).ToArray().Length == 1)
			{
				wallBase.northType += (int)WallBase.SurroundingTileType.Wall;
			}
			if (wallBases.Where(x => x.Position == east).ToArray().Length == 1)
			{
				wallBase.eastType += (int)WallBase.SurroundingTileType.Wall;
			}

			// do corners if the params allow it
			if (FloorGenerationOutput.FloorGenerationParameters.FillCorners)
			{
				var southWest = new Vector2I(wallBase.Position.X-1, wallBase.Position.Y+1);
				var northWest = new Vector2I(wallBase.Position.X-1, wallBase.Position.Y-1);
				var northEast = new Vector2I(wallBase.Position.X+1, wallBase.Position.Y-1);
				var southEast = new Vector2I(wallBase.Position.X+1, wallBase.Position.Y+1);

				if (wallBases.Where(x => x.Position == southWest).ToArray().Length == 1)
				{
					wallBase.southWestType += (int)WallBase.SurroundingTileType.Wall;
				}
				if (wallBases.Where(x => x.Position == northWest).ToArray().Length == 1)
				{
					wallBase.northWestType += (int)WallBase.SurroundingTileType.Wall;
				}
				if (wallBases.Where(x => x.Position == northEast).ToArray().Length == 1)
				{
					wallBase.northEastType += (int)WallBase.SurroundingTileType.Wall;
				}
				if (wallBases.Where(x => x.Position == southEast).ToArray().Length == 1)
				{
					wallBase.southEastType += (int)WallBase.SurroundingTileType.Wall;
				}
			}

			// draw wallseg
			_tileMap.AddLayer(-1);
			_tileMap.SetCell(-1, wallBase.Position, 1, Vector2I.Zero, 0);
		}
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