using Godot;
using System;

public partial class FloorDebugVisualizer : Node2D
{
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
            var color = new Color();
            if (room == _floorManager.CurrentFloor.FloorGenerationOutput.StartingRoom)
            {
                color = new Color(0, 1, 1, 0.5f);
            }
            else if (room == _floorManager.CurrentFloor.FloorGenerationOutput.EndingRoom)
            {
                color = new Color(0, 1, 0, 0.5f);
            }
            else if (room.isHubRoom)
            {
                color = new Color(1, 1, 0, 0.5f);
            }
            else if (room.isSubRoom)
            {
                color = new Color(0, 0, 1, 0.5f);
            }

            DrawRect(room.GetRect(), color);
        }

        foreach (var hallPath in _floorManager.CurrentFloor.FloorGenerationOutput.Halls)
        {
            DrawRect(hallPath, new Color(1, 1, 1, 0.5f));
        }

        var floorFinalGraph = _floorManager.CurrentFloor.FloorGenerationOutput.FinalGraph;
        foreach (var edge in floorFinalGraph)
        {
            DrawLine(edge.pointA.ToVector2(), edge.pointB.ToVector2(), new Color(0, 1, 0));
        }
    }
}
