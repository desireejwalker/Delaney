using System;
using System.IO.Pipes;
using Godot;

[GlobalClass]
public partial class Room : RigidBody2D
{
	public readonly RoomDefinition RoomDefinition;
	public bool isSubRoom = false;
	public bool isHubRoom = false;

	public Rect2 Rect { get; private set; }
	public void SetPosition(Vector2 position)
	{
		Rect = Rect with {Position = position};
	}

	public RigidBody2D PhysicsBody { get; private set; }
	public CollisionShape2D collisionShape;

	public Room(Rect2 rect)
	{
		this.Rect = rect;
	}
	public Room(Rect2 rect, RoomDefinition roomDefinition)
	{
		this.Rect = rect;
		this.RoomDefinition = roomDefinition;
	}
	public static Room RandomSizeAt(Vector2I position, int minWidth, int maxWidth, int minHeight, int maxHeight)
	{
		return new Room(new Rect2(
			position,
			new Vector2I(GD.RandRange(minWidth, maxWidth), GD.RandRange(minHeight, maxHeight))
		));
	}
	public static Room CreateFromDefinitionAt(Vector2I position, RoomDefinition definition)
	{
		var rect = new Rect2(position, Vector2.Zero);
		return new Room(
			rect,
			definition
		);
		// return new Room(
		//     new BoundsInt((Vector3Int)position, new Vector3Int(definition.Layers[0].cellBounds.size.x, definition.Layers[0].cellBounds.size.y, 1)),
		//     definition
		// );
	}
}
