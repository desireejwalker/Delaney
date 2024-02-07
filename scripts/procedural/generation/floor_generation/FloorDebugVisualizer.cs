using Godot;
using System;

public partial class FloorDebugVisualizer : Node2D
{
    private readonly Color START_ROOM_COLOR = new Color(0, 1, 1, 0.05f);
    private readonly Color END_ROOM_COLOR = new Color(0, 1, 0, 0.05f);
    private readonly Color HUB_ROOM_COLOR = new Color(1, 1, 0, 0.05f);
    private readonly Color SUB_ROOM_COLOR = new Color(0, 0, 1, 0.05f);
    private readonly Color HALL_COLOR = new Color(1, 1, 1, 0.05f);
    private readonly Color GRAPH_COLOR = new Color(0, 1, 0);

    [Export]
    private FloorManager _floorManager;
    private bool _isFloorMapGenerated = false;

    public override void _Ready()
    {
        if (_floorManager == null) return;

        _floorManager.FloorMapGenerated += () => _isFloorMapGenerated = true;
    }

    public override void _Process(double delta)
    {
        QueueRedraw();
    }

    public override void _Draw()
    {
        if (!_isFloorMapGenerated) return;

        var rooms = _floorManager.CurrentFloor.FloorGenerationOutput.Rooms;
        foreach (var room in rooms)
        {
            if (!room.isHubRoom && !room.isSubRoom) continue;

            var color = new Color();
            if (room == _floorManager.CurrentFloor.FloorGenerationOutput.StartingRoom)
            {
                color = START_ROOM_COLOR;
            }
            else if (room == _floorManager.CurrentFloor.FloorGenerationOutput.EndingRoom)
            {
                color = END_ROOM_COLOR;
            }
            else if (room.isHubRoom)
            {
                color = HUB_ROOM_COLOR;
            }
            else if (room.isSubRoom)
            {
                color = SUB_ROOM_COLOR;
            }

            var roomRect = room.GetRect();
            DrawRect(new Rect2I(roomRect.Position * 16, roomRect.Size * 16), color);

            DrawString(
                ThemeDB.FallbackFont,
                room.Position * 16,
                room.RoomDefinition.ResourcePath.GetFile().TrimSuffix(".tres"),
                HorizontalAlignment.Center,
                -1,
                10
            );
        }

        foreach (var hall in _floorManager.CurrentFloor.FloorGenerationOutput.Halls)
        {
            DrawRect(new Rect2I(hall.Position * 16, hall.Size * 16), HALL_COLOR);
        }

        var floorFinalGraph = _floorManager.CurrentFloor.FloorGenerationOutput.FinalGraph;
        foreach (var edge in floorFinalGraph)
        {
            DrawLine(edge.pointA.ToVector2() * 16, edge.pointB.ToVector2() * 16, GRAPH_COLOR);
        }
    }
}
