using System;
using System.Drawing;
using System.IO.Pipes;
using System.Numerics;
using Godot;

[GlobalClass]
public partial class Room : RigidBody2D
{
	public RoomDefinition RoomDefinition { get; private set; }
	public bool isSubRoom = false;
	public bool isHubRoom = false;

	private CollisionShape2D _collisionShape;

    public override void _Ready()
    {
        _collisionShape = GetNode<CollisionShape2D>("CollisionShape2D");
    }
	public void SetSize(Vector2I size)
	{
		var shape = (RectangleShape2D)_collisionShape.Shape;
		shape.Size = size;
	}
	public Rect2I GetRect()
	{
		var shape = (RectangleShape2D)_collisionShape.Shape;
		var rectPosition = Position - (shape.Size / 2);
		return new Rect2I(
			new Vector2I((int)rectPosition.X, (int)rectPosition.Y),
			new Vector2I((int)shape.Size.X, (int)shape.Size.Y)
		);
	}
	public void SetRoomDefinition(RoomDefinition roomDefinition)
	{
		RoomDefinition = roomDefinition;
	}
}
