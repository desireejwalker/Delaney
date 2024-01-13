using Godot;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

public class FloorGenerator
{
    private Floor _floor;

    public bool InvalidGeneration { get; private set; }

    private FloorGenerationParameters _parameters;

    private Room[] _roomArray;

    private Room[] _hubRoomArray;
    private HashSet<Point> _hubRoomPoints;
    private Dictionary<Point, Room> _pointToHubRoomDict;

    private HashSet<Edge> _triangulation; 
    private List<Edge> _minimumSpanningTree;
    private HashSet<Edge> _finalGraph;

    private HashSet<Rect2I> _hallPaths;

    private float _averageRoomSize;

    private Room _startingRoom;
    private Room _endingRoom;

    public FloorGenerator(Floor floor, FloorGenerationParameters parameters)
    {
        _floor = floor;
        _parameters = parameters;

        InvalidGeneration = true;
    }

    public void GenerateRooms()
    {
        var sizeSum = 0f;
        
        if (_roomArray != null)
        {
            foreach (var room in _roomArray)
            {
                room.QueueFree();
            }
        }
        _roomArray = new Room[_parameters.RoomCount];

        for (int i = 0; i < _roomArray.Length; i++)
        {
            // Load the room scene, instantiate it, and properly set its values 
            _roomArray[i] = GD.Load<Room>("res://scenes/generation/world.tscn");
            _roomArray[i].SetRoomDefinition(_parameters.RoomDefinitions[GD.RandRange(0, _parameters.RoomDefinitions.Length)]);
            _roomArray[i].Position = GetRandomPointInEllipse(_parameters.RoomPlacementEllipseWidth, _parameters.RoomPlacementEllipseHeight);

            _floor.AddChild(_roomArray[i]);

            sizeSum += _roomArray[i].GetRect().Size.Length();
        }

        _averageRoomSize = sizeSum / _parameters.RoomCount;

        Engine.TimeScale = 100;
    }
    public void GenerateFloorGraph()
    {
        Engine.TimeScale = 1;

        DecideHubRooms();
        _triangulation = Triangulate(_hubRoomPoints);
        _minimumSpanningTree = Kruskal.MinimumSpanningTree(_triangulation);
        
        _finalGraph = new HashSet<Edge>(_minimumSpanningTree);
        _finalGraph.UnionWith(PercentOfDelaunayEdges(_triangulation, _parameters.PercentOfDelaunayEdgesToKeep));

        FindHallwayPaths();
        FindSubRooms();

        _startingRoom = FindFarthestRoomFrom(Vector2.Zero);
        _endingRoom = FindClosestRoomTo(-_startingRoom.Position);
    }

    public async Task RoomsAreSleeping()
    {
        while (_roomArray.All(room => !room.Sleeping))
        {
            await Task.Delay(100);
        }
    }

    private void DecideHubRooms()
    {
        _pointToHubRoomDict = new Dictionary<Point, Room>();

        foreach (var room in _roomArray)
        {
            // room.StopBeingPhysical();
            if (room.GetRect().Size.Length() > _averageRoomSize * _parameters.RoomSizeThresholdMultiplier)
            {
                room.isHubRoom = true;
            }
        }

        _hubRoomArray = _roomArray.Where(room => room.isHubRoom == true).ToArray();

        _hubRoomPoints = new HashSet<Point>();
        foreach (var room in _hubRoomArray)
        {
            var hubRoomPoint = new Point(
                (Vector2I)room.Position
            );
            _hubRoomPoints.Add(hubRoomPoint);
            _pointToHubRoomDict.Add(hubRoomPoint, room);
        }
    }
    private HashSet<Edge> Triangulate(HashSet<Point> points)
    {
        var triangles = BowyerWatson.Triangulate(points);

        var graph = new HashSet<Edge>();
        var trianglePoints = new HashSet<Point>();
        foreach (var triangle in triangles)
        {
            graph.UnionWith(triangle.edges);
            foreach (var edge in triangle.edges)
            {
                trianglePoints.Add(edge.pointA);
                trianglePoints.Add(edge.pointB);
            }
        }

        if (trianglePoints.Count == points.Count)
        {
            InvalidGeneration = false;
        }

        return graph;
    }
    private HashSet<Edge> PercentOfDelaunayEdges(HashSet<Edge> delaunayTriangulation, float percent)
    {
        var triangulation = delaunayTriangulation.ToArray();
        var extraEdges = new HashSet<Edge>();

        for (int i = 0; i < (int)((triangulation.Length) * percent); i++)
        {
            var edge = triangulation[i];
            extraEdges.Add(edge);
        }

        return extraEdges;
    }
    private void FindHallwayPaths()
    {
        _hallPaths = new HashSet<Rect2I>();

        foreach (var point in _hubRoomPoints)
        {
            var startHubRoom = _pointToHubRoomDict[point];

            var connectedEdges = _finalGraph.Where(edge => edge.pointA == point);

            foreach (var edge in connectedEdges)
            {
                var endHubRoom = _pointToHubRoomDict[edge.pointB];

                var midpointPosition = (point.ToVector2() + edge.pointB.ToVector2()) / 2;
                var midpointX = (int)midpointPosition.X;
                var midpointY = (int)midpointPosition.Y;

                // if midpoint x position is within 
                // the Rect of the currently
                // analyzed hub room, create pointA 
                // vertical path connecting the 
                // two points
                if (midpointPosition.X > startHubRoom.GetRect().Position.X && midpointPosition.X < startHubRoom.GetRect().End.X)
                {
                    var path = new Rect2I(
                        midpointX,
                        (int)startHubRoom.Position.Y,
                        _parameters.HallwayPathThickness,
                        (int)endHubRoom.Position.Y - (int)startHubRoom.Position.Y
                    );
                    _hallPaths.Add(path);

                    continue;
                }

                // if midpoint y position is within 
                // the Rect of the currently
                // analyzed hub room, create pointA 
                // horizontal path connecting the 
                // two points
                if (midpointPosition.Y > startHubRoom.GetRect().Position.Y && midpointPosition.Y < startHubRoom.GetRect().End.X)
                {
                    var path = new Rect2I(
                        (int)startHubRoom.GetRect().GetCenter().X,
                        midpointY,
                        (int)endHubRoom.Position.X - (int)startHubRoom.Position.X,
                        _parameters.HallwayPathThickness
                    );
                    _hallPaths.Add(path);

                    continue;
                }

                // vertical half
                var aHalfL = new Rect2I(
                    (int)startHubRoom.Position.X,
                    (int)startHubRoom.Position.Y,
                    _parameters.HallwayPathThickness,
                    (int)endHubRoom.Position.Y - (int)startHubRoom.Position.Y
                );
                // horizontal half
                var bHalfL = new Rect2I(
                    (int)endHubRoom.Position.X,
                    (int)endHubRoom.Position.Y,
                    (int)startHubRoom.Position.X - (int)endHubRoom.Position.X,
                    _parameters.HallwayPathThickness
                );
                _hallPaths.Add(aHalfL);
                _hallPaths.Add(bHalfL);
            }
        }
    }
    private void FindSubRooms()
    {
        foreach (var room in _roomArray.Where(room => !room.isHubRoom))
        {
            foreach (var path in _hallPaths)
            {
                if (room.GetRect().Intersects(path))
                {
                    room.isSubRoom = true;
                }
            }
        }
    }

    private Room FindFarthestRoomFrom(Vector2 position)
    {
        var maxDist = position.DistanceTo(_hubRoomArray[0].GetRect().GetCenter());
        var maxDistRoom = _hubRoomArray[0];

        foreach (var hubRoom in _hubRoomArray)
        {
            var lastMax = maxDist;
            maxDist = Mathf.Max(
                position.DistanceTo(maxDistRoom.GetRect().GetCenter()),
                position.DistanceTo(hubRoom.GetRect().GetCenter())
            );

            if (maxDist == lastMax)
            {
                continue;
            }

            maxDistRoom = hubRoom;
        }

        return  maxDistRoom;
    }
    private Room FindClosestRoomTo(Vector2 position)
    {
        var minDist = position.DistanceTo(_hubRoomArray[0].GetRect().GetCenter());
        var minDistRoom = _hubRoomArray[0];

        foreach (var hubRoom in _hubRoomArray)
        {
            var lastMin = minDist;
            minDist = Mathf.Min(
                position.DistanceTo(minDistRoom.GetRect().GetCenter()),
                position.DistanceTo(hubRoom.GetRect().GetCenter())
            );

            if (minDist == lastMin)
            {
                continue;
            }

            minDistRoom = hubRoom;
        }

        return minDistRoom;
    }

    public FloorGenerationOutput GetOutput()
    {
        return new FloorGenerationOutput(
            _roomArray,
            _hubRoomArray,
            _roomArray.Where(room => room.isSubRoom && !room.isHubRoom).ToArray(),
            
            _hallPaths.ToArray(),

            _startingRoom,
            _endingRoom,

            _triangulation.ToArray(),
            _minimumSpanningTree.ToArray(),
            _finalGraph.ToArray()
        );
    }

    // public void CleanUp(Transform roomParent)
    // {
    //     foreach (var room in _roomArray)
    //     {
    //         room.Initialize(roomParent);
    //     }
    // }

    private Vector2I GetRandomPointInEllipse(float width, float height)
    {
        var t = 2 * Mathf.Pi * GD.Randf();
        var u = GD.Randf() + GD.Randf();
        var r = 0f;
        if (u > 1)
        {
            r = 2 - u;
        }
        else
        {
            r = u;
        }

        return new Vector2I(
            (int)(width * r * Mathf.Cos(t) / 2), 
            (int)(height * r * Mathf.Sin(t) / 2)
        );
    }
}