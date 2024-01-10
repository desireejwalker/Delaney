using Godot;
using Godot.Collections;
using System;
using System.Linq;
using System.Threading.Tasks;


public partial class FloorManager : Node
{
    private Floor _currentFloor;

    [Export]
    private Array<FloorGenerationParameters> _floorGenerationParameters;
    private FloorGenerationParameters[] GetFloorGenerationParametersFor(int floorLevel)
    {
        return _floorGenerationParameters.Where(floorGenerationParameters => floorGenerationParameters.IsWithinGenerationBounds(floorLevel)).ToArray();
    }

    private FloorGenerator _floorGenerator;

    public override void _Ready()
    {
        _currentFloor = new Floor(0);
        GenerateFloor();
    }

    private async void GenerateFloor()
    {
        var stopWatch = new System.Diagnostics.Stopwatch();
        stopWatch.Start();

        var floorGenerationParameters = GetFloorGenerationParametersFor(_currentFloor.Level)[GD.RandRange(0, GetFloorGenerationParametersFor(_currentFloor.Level).Length)];

        await DoFloorMapGeneration(floorGenerationParameters);
    }

    private async Task DoFloorMapGeneration(FloorGenerationParameters floorGenerationParameters)
    {
        _floorGenerator = new FloorGenerator(floorGenerationParameters);
        while (_floorGenerator.InvalidGeneration)
        {
            _floorGenerator.Start();
            await _floorGenerator.CheckIfRoomsAreAsleep();
            _floorGenerator.GenerateFloorGraph();
        }
        var lastFloorLevel = _currentFloor.Level;
        _currentFloor = new Floor(lastFloorLevel + 1, _floorGenerator.GetOutput());
        AddChild(_currentFloor);
    }

}
