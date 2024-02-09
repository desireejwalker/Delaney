using Godot;

public class WallBase
{
	public readonly Vector2I Position;
	
	public enum SurroundingTileType
	{
		Empty = 0,
		Floor = 1,
		Wall = 2
	}

	// bit(?) masks for surrounding tile types
	public int southType = (int)SurroundingTileType.Empty;
	public int southWestType = (int)SurroundingTileType.Empty;
	public int westType = (int)SurroundingTileType.Empty;
	public int northWestType = (int)SurroundingTileType.Empty;
	public int northType = (int)SurroundingTileType.Empty;
	public int northEastType = (int)SurroundingTileType.Empty;
	public int eastType = (int)SurroundingTileType.Empty;
	public int southEastType = (int)SurroundingTileType.Empty;

	public WallBase(Vector2I position)
	{
		this.Position = position;
	}
}