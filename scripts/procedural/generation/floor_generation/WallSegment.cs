using Godot;

[GlobalClass]
public partial class WallSegment : Resource
{
    [Export]
    public Vector2I TopTileAtlasPosition { get; private set; }
    [Export]
    public Vector2I MiddleTileAtlasPosition { get; private set; }
    [Export]
    public Vector2I BaseTileAtlasPosition { get; private set; }
}