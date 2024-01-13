using Godot;
using System;

[GlobalClass]
public partial class RoomDefinition : Resource
{
    [Export]
    public PackedScene RoomScene { get; private set; }
   
}
