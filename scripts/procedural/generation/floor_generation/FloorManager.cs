using Godot;
using Godot.Collections;
using System;
using System.Linq;
using System.Threading.Tasks;


public partial class FloorManager : Node
{
	[Signal]
	public delegate void FloorMapGeneratedEventHandler();
	[Signal]
	public delegate void FloorDrawnEventHandler();
	[Signal]
	public delegate void FloorReadyEventHandler();

	public Floor CurrentFloor { get; private set; }
	
	[Export]
	private Array<FloorGenerationParameters> _floorGenerationParameters;
	private PackedScene _floorScene;
	private FloorGenerator _floorGenerator;

	public override void _Ready()
	{
		_floorScene = GD.Load<PackedScene>("res://scenes/generation/floor.tscn");
		_ResetCurrentFloor();
	}

	private void _ResetCurrentFloor()
	{
		if (CurrentFloor != null)
		{
			CurrentFloor.QueueFree();
		}
		CurrentFloor = _floorScene.Instantiate<Floor>();
		CurrentFloor.Setup(0);
	}

	public void GenerateFloor() => _GenerateFloor();
	public void ClearFloor() => _ClearFloor();

	private async void _GenerateFloor()
	{
		var stopWatch = new System.Diagnostics.Stopwatch();
		stopWatch.Start();

		var floorGenerationParameters = GetFloorGenerationParametersFor(CurrentFloor.Level)[GD.RandRange(0, GetFloorGenerationParametersFor(CurrentFloor.Level).Length - 1)];

		await DoFloorMapGeneration(floorGenerationParameters);
		CurrentFloor.DrawFloor();
		EmitSignal(SignalName.FloorDrawn);

		stopWatch.Stop();
		GD.Print($"Floor generation took {stopWatch.ElapsedMilliseconds}ms.");

		EmitSignal(SignalName.FloorReady);
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
		
		GD.Print("Generating new floor...");

		_floorGenerator.GenerateRooms();
		await _floorGenerator.SettleRooms();
		_floorGenerator.GenerateFloorGraph();

		CurrentFloor.SetFloorData(_floorGenerator.GetOutput());

		EmitSignal(SignalName.FloorMapGenerated);
	}

	private void _ClearFloor()
	{
		_ResetCurrentFloor();
	}

	private FloorGenerationParameters[] GetFloorGenerationParametersFor(int floorLevel)
	{
		return _floorGenerationParameters.Where(floorGenerationParameters => floorGenerationParameters.IsWithinGenerationBounds(floorLevel)).ToArray();
	}
}
