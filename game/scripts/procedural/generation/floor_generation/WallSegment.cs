using Godot;

[GlobalClass]
public partial class WallSegment : Resource
{
    [Export]
    public Vector2I TopTileAtlasPosition { get; private set; } = -Vector2I.One;
    [Export]
    public Vector2I MiddleTileAtlasPosition { get; private set; } = -Vector2I.One;
    [Export]
    public Vector2I BaseTileAtlasPosition { get; private set; } = -Vector2I.One;

    // -1 - Any
    // 0 - Empty/Air
    // 1 - Floor
    // 2 - Wall
    // 3 - Floor + Wall
    [ExportGroup("Required Surrounding Types")]
    [Export]
    public int SouthType { get; private set; } = -1;
    [Export]
	public int SouthWestType { get; private set; } = -1;
    [Export]
	public int WestType { get; private set; } = -1;
    [Export]
	public int NorthWestType { get; private set; } = -1;
    [Export]
	public int NorthType { get; private set; } = -1;
    [Export]
	public int NorthEastType { get; private set; } = -1;
    [Export]
	public int EastType { get; private set; } = -1;
    [Export]
	public int SouthEastType { get; private set; } = -1;
}