extends Node2D
class_name Launcher

@onready var spawner: Spawner = $Spawner

@export var shooter:Node
@export var gun:Node2D ##最好gun与launcher属于同级节点
@export var control:ControlType
@export_group("射击参数")
@export var fire_interval:float = 0.1
@export var fire_bullet_num:int = 1
@export var max_scatter_angle:float
@export_group("弹匣参数")
@export var magaazine_capacity:int = 30
@export var remaining_bullets:int = -1:
	set(value):
		remaining_bullets = clampi(value,-1,magaazine_capacity)
@export var reload_time:float
@export_group("子弹参数")
@export var bullet_velocity:float
@export var bullet_exit_time:float = -1
var is_fire_interval:bool
var fire_interval_timer:Timer

enum ControlType{
	MOUSE,
	KEYBOARD,
	OTHERS,
}


@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if control == ControlType.OTHERS:
		return
	if is_fire_interval:
		return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var dir = get_local_mouse_position() - gun.position
		fires(dir.normalized())
		is_fire_interval = true
		_start_interval_timer()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		reload()

func _start_interval_timer():
	if !fire_interval_timer:
		fire_interval_timer = Timer.new()
		fire_interval_timer.one_shot = true
		fire_interval_timer.timeout.connect(func():is_fire_interval = false)
		add_child(fire_interval_timer)
	fire_interval_timer.start(fire_interval)

func fires(fire_dir:Vector2,bullet_mods:Array[Node] = []):
	for i in fire_bullet_num:
		fire(fire_dir,bullet_mods)
		await get_tree().create_timer(0.02).timeout

func fire(fire_dir:Vector2,bullet_mods:Array[Node] = []):
	if remaining_bullets != 0:
		var bullet:Bullet = spawner.request_instance()
		bullet.position = gun.position
		for mod in bullet_mods:
			bullet.install_mod(mod)
		add_child(bullet)
		var scatter_angel = randf_range(-max_scatter_angle,+max_scatter_angle)
		var dir = fire_dir.rotated(scatter_angel)
		bullet.init(shooter,bullet_velocity * dir,bullet_exit_time)
	
	if remaining_bullets > 0:
		remaining_bullets = max(0,remaining_bullets - 1)

func reload():
	if remaining_bullets != -1:
		await get_tree().create_timer(reload_time).timeout
		remaining_bullets = magaazine_capacity
