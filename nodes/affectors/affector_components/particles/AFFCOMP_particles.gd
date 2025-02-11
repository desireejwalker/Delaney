@tool
class_name ParticlesAffectorComponent extends AffectorComponent

var gpu_particles_3d: GPUParticles3D

func _get_configuration_warnings():
	if get_children().size() != 1 or not get_child(0) is GPUParticles3D:
		return ["this AffectorComponent requires one (1) GPUParticles3D child to function correctly.
				Please add a GPUParticles3D node as a child."]
	else:
		return []

func _ready():
	if Engine.is_editor_hint():
		return
	
	gpu_particles_3d = get_child(0)
	gpu_particles_3d.emitting = false

func _apply():
	if Engine.is_editor_hint():
		return
	
	gpu_particles_3d.emitting = true
