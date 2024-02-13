@tool
extends EditorPlugin

var plugin = preload("res://addons/wall_segment_rule_plugin/inspector_plugin.gd")

func _enter_tree():
	# Initialization of the plugin goes here.
	plugin = plugin.new()
	add_inspector_plugin(plugin)


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_inspector_plugin(plugin)
