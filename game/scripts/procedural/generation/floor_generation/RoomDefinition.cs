using Godot;
using System;
using System.ComponentModel.DataAnnotations;

[GlobalClass]
public partial class RoomDefinition : Resource
{
    [Export]
    private PackedScene _roomScene;
    private Node2D _roomInstance;

    // prepare this RoomDefinition for use (should be called when the Room's RoomDefinition is set)
    public void Prepare()
    {
        _roomInstance = _roomScene.Instantiate<Node2D>();
    }

    public Node2D GetRoomInstance()
    {
        // if Prepare() hasn't been called on this RoomDefinition, throw an exception
        if (_roomInstance == null)
        {
            throw new UnpreparedRoomDefinitionException(this);
        }
        return _roomInstance;
    }
    public Vector2I GetSize()
    {
        // if Prepare() hasn't been called on this RoomDefinition, throw an exception
        if (_roomInstance == null)
        {
            throw new UnpreparedRoomDefinitionException(this);
        }

        var tilemap = _roomInstance.GetNode<TileMap>("TileMap");
        var tilemapRect = tilemap.GetUsedRect();
        return tilemapRect.Size;
    }
}

public class UnpreparedRoomDefinitionException : ApplicationException
{
    public RoomDefinition roomDefinition;

    public UnpreparedRoomDefinitionException(RoomDefinition roomDefinition): base()
    {
        this.roomDefinition = roomDefinition;
    }
}
