using Godot;
using Godot.Collections;
using Godot.NativeInterop;
using System;
using System.Collections.Generic;
using System.Linq;

public partial class Floor : Node
{
	const int HALL_FLOOR_TILEMAP_LAYER = 1;
	const int ROOM_FLOOR_TILEMAP_LAYER = 0, ROOM_PROP_TILEMAP_LAYER = 2, ROOM_WALL_TILEMAP_LAYER = 3;
	const int FLOOR_WALL_TILEMAP_LAYER = 4;

	const int WALL_TILEMAP_RECT_GROWTH = 2;

	public int Level { get; private set; }
	public FloorGenerationOutput FloorGenerationOutput { get; private set; }
	private FloorGenerationParameters _floorGenerationParameters;

	private TileMap _markerTileMap;
	private NavigationRegion2D _navigationRegion2d;
	private TileMap _tileMap;

	public TileMap GetMarkerTileMap() => _markerTileMap;

	private bool _drawn = false;

	public void Setup(int level)
	{
		Level = level;

		_navigationRegion2d = GetNode<NavigationRegion2D>("NavigationRegion2D");
		_markerTileMap = _navigationRegion2d.GetNode<TileMap>("MarkerTileMap");
		_tileMap = GetNode<TileMap>("TileMap");

		// create all of the tilemap layers for this floor
		_tileMap.AddLayer(ROOM_FLOOR_TILEMAP_LAYER);
		_tileMap.SetLayerName(ROOM_FLOOR_TILEMAP_LAYER, "rooms/floors");
		_tileMap.AddLayer(HALL_FLOOR_TILEMAP_LAYER);
		_tileMap.SetLayerName(HALL_FLOOR_TILEMAP_LAYER, "halls/floors");
		_tileMap.AddLayer(ROOM_PROP_TILEMAP_LAYER);
		_tileMap.SetLayerName(ROOM_PROP_TILEMAP_LAYER, "rooms/props");
		_tileMap.AddLayer(ROOM_WALL_TILEMAP_LAYER);
		_tileMap.SetLayerName(ROOM_WALL_TILEMAP_LAYER, "rooms/walls");
		_tileMap.AddLayer(FLOOR_WALL_TILEMAP_LAYER);
		_tileMap.SetLayerName(FLOOR_WALL_TILEMAP_LAYER, "floor/walls");
	}

	public void SetFloorData(FloorGenerationOutput floorGenerationOutput)
	{
		FloorGenerationOutput = floorGenerationOutput;
		_floorGenerationParameters = FloorGenerationOutput.FloorGenerationParameters;
		
		// set the tileset of the tilemap to the one specified in the FloorGenerationParameters
		_tileMap.TileSet = _floorGenerationParameters.TileSet;
	}

	public void DrawFloor()
	{
		foreach (var room in FloorGenerationOutput.Rooms)
		{
			if (!room.isHubRoom && !room.isSubRoom) continue;
			DrawRoomFloors(room);
			DrawRoomProps(room);
			DrawRoomWalls(room);
		}

		foreach (var hall in FloorGenerationOutput.Halls)
		{
			DrawRect(hall, HALL_FLOOR_TILEMAP_LAYER, _floorGenerationParameters.SourceID, _floorGenerationParameters.HallTileAtlasPosition);
		}

		DrawFloorWalls();

		_drawn = true;
	}

	public void CreateNavigation()
	{
		if (!_drawn)
		{
			throw new Exception("Error! This floor ain't drawn yet bestie... Can't make the nav mesh without it!");
		}

		var navMesh = new NavigationPolygon();
		var tilemapRect = _markerTileMap.GetUsedRect();
		Vector2[] boundingOutline = {
			tilemapRect.Position,
			new Vector2(tilemapRect.Position.X, tilemapRect.Position.Y + tilemapRect.Size.Y),
			tilemapRect.End,
			new Vector2(tilemapRect.Position.X + tilemapRect.Size.X, tilemapRect.Position.Y)
		};
		navMesh.AddOutline(boundingOutline);
		NavigationServer2D.BakeFromSourceGeometryData(navMesh, new NavigationMeshSourceGeometryData2D());
		_navigationRegion2d.NavigationPolygon = navMesh;
		navMesh.AgentRadius = 16;

		_navigationRegion2d.BakeNavigationPolygon();
	}

	/*
	Draws the floor tiles of a Room to the Floor tilemap at ROOM_FLOOR_TILEMAP_LAYER.
	Will expect all floor tiles of a Room to be on layer 0 of the Room's tilemap.

	Will also copy this to the MarkerTileMap for use with the minimap.
	*/
	private void DrawRoomFloors(Room room)
	{
		// first, see if roomTileMap even has layer 0
		var roomTileMap = room.RoomDefinition.GetRoomInstance().GetNode<TileMap>("TileMap");
		if (roomTileMap.GetLayersCount() < 1)
		{
			GD.Print("Warning: RoomDefinition " + room.RoomDefinition.ResourcePath.GetFile().TrimSuffix(".tres") + "has 0 layers.");
			return;
		}

		var roomPosition = room.GetRect().Position;

		var terrainTiles = new Array<Vector2I>();

		foreach (var roomTileMapCoords in roomTileMap.GetUsedCells(0))
		{
			// the supposed output (where the input tile will be placed in the Floor tilemap (_tilemap))
			var floorTileMapCoords = roomTileMapCoords + roomPosition;

			// if the tile at roomTileMapCoords is not a part of a terrainSet,
			// simply place it at floorTileMapCoords.
			var tileData = roomTileMap.GetCellTileData(0, roomTileMapCoords);
			if (tileData.TerrainSet == -1)
			{
				var atlasCoords = roomTileMap.GetCellAtlasCoords(0, roomTileMapCoords);
				_tileMap.SetCell(ROOM_FLOOR_TILEMAP_LAYER, floorTileMapCoords, _floorGenerationParameters.SourceID, atlasCoords);
				continue;
			}

			// add the tile to the terrainTiles array to pass to DrawTerrainTiles()
			terrainTiles.Add(roomTileMapCoords);

			// draw tiles to the MarkerTileMap
			// (0, 0) is a floor tile marker
			_markerTileMap.SetCell(0, floorTileMapCoords, 0, Vector2I.Zero);
		}
		
		// draw any tiles that are a part of a terrain set
		DrawTerrainTiles(roomTileMap, 0, roomPosition, ROOM_FLOOR_TILEMAP_LAYER, terrainTiles);
	}
	/*
	Draws the props of a Room to the Floor tilemap at ROOM_PROP_TILEMAP_LAYER.
	Will expect all props of a Room to be on layer 1 of the Room's tilemap.
	*/
	private void DrawRoomProps(Room room)
	{
		// first, see if roomTileMap even has layer 1
		var roomTileMap = room.RoomDefinition.GetRoomInstance().GetNode<TileMap>("TileMap");
		if (roomTileMap.GetLayersCount() < 2) return;

		var roomPosition = room.GetRect().Position;

		foreach (var roomTileMapCoords in _tileMap.GetUsedCells(1))
		{
			// the supposed output (where the input tile will be placed in the Floor tilemap (_tilemap))
			var floorTileMapCoords = roomTileMapCoords + roomPosition;
			var atlasCoords = roomTileMap.GetCellAtlasCoords(1, roomTileMapCoords);
			_tileMap.SetCell(ROOM_PROP_TILEMAP_LAYER, floorTileMapCoords, _floorGenerationParameters.SourceID, atlasCoords);
		}
	}
	/*
	Draws the wall tiles of a Room to the Floor tilemap at ROOM_WALL_TILEMAP_LAYER.
	Will expect all wall tiles of a Room to be on layer 2 of the Room's tilemap.
	*/
	private void DrawRoomWalls(Room room)
	{
		// first, see if roomTileMap even has layer 2
		var roomTileMap = room.RoomDefinition.GetRoomInstance().GetNode<TileMap>("TileMap");
		if (roomTileMap.GetLayersCount() < 3) return;

		var roomPosition = room.GetRect().Position;

		foreach (var roomTileMapCoords in _tileMap.GetUsedCells(2))
		{
			// the supposed output (where the input tile will be placed in the Floor tilemap (_tilemap))
			var floorTileMapCoords = roomTileMapCoords + roomPosition;
			var atlasCoords = roomTileMap.GetCellAtlasCoords(2, roomTileMapCoords);
			_tileMap.SetCell(ROOM_WALL_TILEMAP_LAYER, floorTileMapCoords, _floorGenerationParameters.SourceID, atlasCoords);

			// draw tiles to the MarkerTileMap
			// (1, 0) is a wall tile marker
			_tileMap.SetCell(0, floorTileMapCoords, 0, new Vector2I(1, 0));
		}
	}

	/*
	Draw a rectangle rect of tiles of atlasCoords on _tileMap.
	*/
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

		SetCells(_tileMap, layer, tilesArray, 0, atlasCoords);
		// draw tiles to the MarkerTileMap
		// (0, 0) is a floor tile marker
		SetCells(_markerTileMap, 0, tilesArray, 0, Vector2I.Zero);
	}

	/*
	Draws the wall tiles of the Floor to the Floor tilemap at FLOOR_WALL_TILEMAP_LAYER
	according to the FloorPositions set in FloorGenerationOutput.
	*/
	private void DrawFloorWalls()
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

		//// This seems to take a while... But it is the easiest way to get this working.
		//// Hopefully we can find a better method soon. this pushes level generation times
		//// up past 10000ms (10 seconds).
		//// - Des
		// nevermind? This only adds a bit of time to floor generation. freakin' sweet!!
		_tileMap.SetCellsTerrainConnect(
			FLOOR_WALL_TILEMAP_LAYER,
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
			_tileMap.EraseCell(FLOOR_WALL_TILEMAP_LAYER, position);
		}
		wallPositions.ExceptWith(wallPositionsToRemove);

		// draw tiles to the MarkerTileMap
		// (1, 0) is a wall tile marker
		SetCells(
			_markerTileMap,
			1,
			new Array<Vector2I>(wallPositions),
			0,
			new Vector2I(1, 0)
		);

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

	private void SetCells(TileMap outputTileMap, int layer, Godot.Collections.Array<Vector2I> coordsArray, int sourceId, Vector2I atlasCoords)
	{
		foreach (var coord in coordsArray)
		{
			outputTileMap.SetCell(layer, coord, sourceId, atlasCoords);
		}
	}
}