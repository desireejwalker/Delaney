using Godot;
using Godot.Collections;
using System;
using System.Linq;
using System.Threading.Tasks;


public partial class FloorManager : Node
{
    public event Action FloorMapGenerated;

    [Export]
    private Array<FloorGenerationParameters> _floorGenerationParameters;
    private PackedScene _floorScene;
    public Floor CurrentFloor { get; private set; }
    private FloorGenerator _floorGenerator;

    public override void _Ready()
    {
        _floorScene = GD.Load<PackedScene>("res://scenes/generation/floor.tscn");
        CurrentFloor = _floorScene.Instantiate<Floor>();
        CurrentFloor.Setup(0);
        GenerateFloor();
    }

    private async void GenerateFloor()
    {
        // var stopWatch = new System.Diagnostics.Stopwatch();
        // stopWatch.Start();

        var floorGenerationParameters = GetFloorGenerationParametersFor(CurrentFloor.Level)[GD.RandRange(0, GetFloorGenerationParametersFor(CurrentFloor.Level).Length - 1)];

        await DoFloorMapGeneration(floorGenerationParameters);
        CurrentFloor.DrawFloor();
    }

    private async Task DoFloorMapGeneration(FloorGenerationParameters floorGenerationParameters)
    {
        // Create a new floor and add it as a child of this node
        var lastFloorLevel = CurrentFloor.Level;
        CurrentFloor.QueueFree();
        CurrentFloor = _floorScene.Instantiate<Floor>();
        CurrentFloor.Setup(lastFloorLevel + 1);
        AddChild(CurrentFloor);

        _floorGenerator = new FloorGenerator(CurrentFloor, floorGenerationParameters);
        
        int iterations = 0;
        GD.Print("Generating new floor...");
        while (_floorGenerator.InvalidGeneration)
        {
            if (iterations > 0)
            {
                GD.Print("Regenerating new floor... (iteration " + iterations + ")");
            }

            _floorGenerator.GenerateRooms();
            await _floorGenerator.SettleRooms();
            _floorGenerator.GenerateFloorGraph();
            iterations++;
        }
        CurrentFloor.SetFloorData(_floorGenerator.GetOutput());

        FloorMapGenerated?.Invoke();
    }

    private FloorGenerationParameters[] GetFloorGenerationParametersFor(int floorLevel)
    {
        return _floorGenerationParameters.Where(floorGenerationParameters => floorGenerationParameters.IsWithinGenerationBounds(floorLevel)).ToArray();
    }
}
