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

		for (int x = tileMapUsedRect.Position.X; x < tileMapUsedRect.End.X; x++)
		{
			for (int y = tileMapUsedRect.Position.Y; y < tileMapUsedRect.End.Y; y++)
			{
				var position = new Vector2I(x, y);
				var neighbor = position;

				// if the position isnt in the floor positions set, ignore it and continue
				if (!FloorGenerationOutput.FloorPositions.Contains(position)) continue;

				// get neighbors of this position
				// starting with the north side
				DetermineWallBase(position, position + new Vector2I(0, -1));
				// south
				DetermineWallBase(position, position + new Vector2I(0, 1));
				// east
				DetermineWallBase(position, position + new Vector2I(1, 0));
				// west
				DetermineWallBase(position, position + new Vector2I(-1, 0));

				if (!FloorGenerationOutput.FloorGenerationParameters.FillCorners) continue;
				
				// northwest
				DetermineWallBase(position, position + new Vector2I(-1, -1));
				// southwest
				DetermineWallBase(position, position + new Vector2I(-1, 1));
				// northeast
				DetermineWallBase(position, position + new Vector2I(1, -1));
				// southeast
				DetermineWallBase(position, position + new Vector2I(1, 1));
			}
		}

		void DetermineWallBase(Vector2I position, Vector2I neighbor)
        {
            // if this neighbor isnt in the floor positions set, either the tile at position or the tile at neighbor
            // should be added to the wallBasePositions set, depending on if FloorGenerationParameters.CreateWallsOnInnerEdge
            if (FloorGenerationOutput.FloorPositions.Contains(neighbor)) return;

            if (FloorGenerationOutput.FloorGenerationParameters.CreateWallsOnInnerEdge)
            {
                wallBases.Add(new WallBase(
                    position,
                    GetCellNeighborFrom(position, neighbor, FloorGenerationOutput.FloorGenerationParameters.FillCorners)
                ));
            }
            else
            {
                wallBases.Add(new WallBase(
                    neighbor,
                    GetCellNeighborFrom(neighbor, position, FloorGenerationOutput.FloorGenerationParameters.FillCorners)
                ));
            }
        }

        // create walls layer
        _tileMap.AddLayer(-1);
		foreach (var wallBase in wallBases)
		{
			GD.Print(wallBase.Position + ", floor neighbor: " + wallBase.FloorCellNeighbor);
			var wallSegment = FloorGenerationOutput.FloorGenerationParameters.WallDefinition.GetWallSegmentForCellNeighbor(wallBase.FloorCellNeighbor);

			// first draw base tile from the walldef
			if (wallSegment.BaseTileAtlasPosition == -Vector2I.One) continue;

			_tileMap.SetCell(-1, wallBase.Position, 0, wallSegment.BaseTileAtlasPosition);

			// then draw the mid tiles from the walldef for how high the middle height value is
			if (wallSegment.MiddleTileAtlasPosition == -Vector2I.One) continue;

			for (int i = 0; i < FloorGenerationOutput.FloorGenerationParameters.WallDefinition.MiddleHeight; i++)
			{
				_tileMap.SetCell(
					-1,
					wallBase.Position - new Vector2I(0, 1 + i),
					0,
					wallSegment.MiddleTileAtlasPosition
				);
			}

			// lastly draw the top tile from the walldef
			if (wallSegment.TopTileAtlasPosition == -Vector2I.One) continue;

			_tileMap.SetCell(
				-1,
				wallBase.Position - new Vector2I(0, 1 + FloorGenerationOutput.FloorGenerationParameters.WallDefinition.MiddleHeight),
				0,
				wallSegment.TopTileAtlasPosition
			);
		}
	}

	// will return CellNeighbor.TopSide if somehow cannot evaluate
	TileSet.CellNeighbor GetCellNeighborFrom(Vector2I position, Vector2I neighbor, bool includeCorners)
	{
		switch (neighbor)
		{
			case var n when _tileMap.GetNeighborCell(position, TileSet.CellNeighbor.TopSide) == n:
				return TileSet.CellNeighbor.TopSide;
			case var n when _tileMap.GetNeighborCell(position, TileSet.CellNeighbor.BottomSide) == n:
				return TileSet.CellNeighbor.BottomSide;
			case var n when _tileMap.GetNeighborCell(position, TileSet.CellNeighbor.RightSide) == n:
				return TileSet.CellNeighbor.RightSide;
			case var n when _tileMap.GetNeighborCell(position, TileSet.CellNeighbor.LeftSide) == n:
				return TileSet.CellNeighbor.LeftSide;
			case var n when _tileMap.GetNeighborCell(position, TileSet.CellNeighbor.TopLeftCorner) == n && includeCorners:
				return TileSet.CellNeighbor.TopLeftCorner;
			case var n when _tileMap.GetNeighborCell(position, TileSet.CellNeighbor.BottomLeftCorner) == n && includeCorners:
				return TileSet.CellNeighbor.BottomLeftCorner;
			case var n when _tileMap.GetNeighborCell(position, TileSet.CellNeighbor.TopRightCorner) == n && includeCorners:
				return TileSet.CellNeighbor.TopRightCorner;
			case var n when _tileMap.GetNeighborCell(position, TileSet.CellNeighbor.BottomRightCorner) == n && includeCorners:
				return TileSet.CellNeighbor.BottomRightCorner;
				
			default:
				return TileSet.CellNeighbor.TopSide;
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