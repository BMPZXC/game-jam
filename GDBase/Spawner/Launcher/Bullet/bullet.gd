extends Node2D
class_name Bullet

signal  to_recycle_self()

var shooter:Node
var velocity:Vector2
var life_timer:Timer
var mods:Array[Node]

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	position += velocity

func init(shooter_:Node,velocity_:Vector2,time:float = -1):
	velocity = velocity_
	shooter = shooter_
	rotation = velocity.angle()
	
	if time == -1:
		return
	_create_timer()
	life_timer.start(time)

func _create_timer():
	if life_timer:
		return
	life_timer = Timer.new()
	life_timer.one_shot = true
	life_timer.timeout.connect(_recycle_self)
	add_child(life_timer)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	_recycle_self()

func _recycle_self():
	to_recycle_self.emit()
	rotation = 0
	position = Vector2.ZERO

func _get_bullet_collisionshape2d()->CollisionShape2D:
	return $CollisionShape2D.duplicate()

func install_mod(mod:Node):
	add_child(mod)
	if mod is Area2D:
		mod.add_child(_get_bullet_collisionshape2d())
