extends Node2D
class_name OrbitComponent
##为什么不和其他移动组件一样继承MoveComponentBase？
##因为这一组件是自己移动，与其他移动组件有本质区别。
##为什么要允许这一组件自己移动？
##其他移动组件不能自己移动是因为其他移动组件实现的移动功能一般是角色场景父节点需要的移动功能
##而这一移动组件一般是场景子节点需要的移动。

@export var active:bool
@export var rotation_center: Node2D
@export var sprite:Sprite2D
@export var radius :float= 40.0
@export var angle_in_radians:float = PI / 4
@export var angular_velocity:float = PI / 2
@export var to_mouse:bool
@export var to_center:bool

func start():
	active = true
func stop():
	active = false

func _ready() -> void:
	radius = (rotation_center.global_position - global_position).length()

func _process(delta):
	if !active:
		return
	if rotation_center:
		orbit(delta)

func toward(dir:Vector2):
	angle_in_radians = dir.angle()
	var offset := Vector2(cos(angle_in_radians), sin(angle_in_radians)) * radius
	global_position = rotation_center.global_position + offset
	rotation = angle_in_radians
	if sprite:
		_sprite_flip()

func orbit(delta):
	if to_mouse:
		var mouse_pos = get_global_mouse_position()
		var center_to_mouse = mouse_pos - rotation_center.position
		var center_to_mouse_dir = (center_to_mouse).normalized()
		angle_in_radians = center_to_mouse_dir.angle()
		look_at(mouse_pos)
	else:
		angle_in_radians += delta * angular_velocity
	
	if to_center:
		look_at(rotation_center.position)
	
	if sprite:
		_sprite_flip()
	
	var offset := Vector2(cos(angle_in_radians), sin(angle_in_radians)) * radius
	global_position = rotation_center.global_position + offset
	
func _sprite_flip():
	if position.x > 0:
		sprite.flip_v = false
	elif position.x < 0:
		sprite.flip_v = true
