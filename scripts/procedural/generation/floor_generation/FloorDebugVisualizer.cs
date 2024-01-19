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
        GD.Print("draw");

        var floorFinalGraph = _floorManager.CurrentFloor.FloorGenerationOutput.MinimumSpanningTree;
        foreach (var edge in floorFinalGraph)
        {
            DrawLine(edge.pointA.ToVector2(), edge.pointB.ToVector2(), new Color(1, 0, 0));
        }
    }
}
