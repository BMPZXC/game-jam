extends MoveComponentBase
class_name MoveGravityByInputComponent

@export var mover:CharacterBody2D
@export var max_speed:float = 128.0
@export var gravity:float = 12
@export var jump_power:float = 12
@export var max_jump_num:int = 1:
	set(value):
		max_jump_num = value
		jump_num = min(max_jump_num,jump_num)
@export var jump_num:int = 1:
	set(value):
		jump_num = clamp(value,0,max_jump_num)
@export var empty_jump_time:float = 0
##请注意，若需要加速时间严格等于下方时间，需要您的加速曲线在结尾处才达到最高点
##减速时间同理，在结尾处达到最低点
@export var time_faster:float = 1 ##加速时间
##这里注明，当速度方向与加速度方向相反时，减速时间会更少
@export var time_slower:float = 1 ##减速时间
@export var faster_curve:Curve ##加速曲线
@export var slower_curve:Curve ##减速曲线
var faster_progress:float = 0: ##加速进度
	set(value):
		faster_progress = clamp(value,0,1)
var slower_progress:float = 0: ##减速进度
	set(value):
		slower_progress = clamp(value,0,1)

var empty_jump_timer:Timer

var input_x:float
var input_y:float

enum State{
	Ground,
	Air
}

var current_state:State

func _ready() -> void:
	_create_empty_jump_timer()

func _physics_process(delta: float) -> void:
	if !mover:
		return
	_check_input()
	_check_state()
	_set_mover_velocity_x(delta)
	_set_mover_veloctiy_y()
	mover.move_and_slide()

func _check_input():
	input_x = Input.get_axis("move_left","move_right")
	input_y = Input.is_action_pressed("move_up")

func _check_state():
	if mover.is_on_floor():
		if current_state == State.Ground:
			return
		jump_num = max_jump_num
		empty_jump_timer.stop()
		current_state = State.Ground
	else:
		if current_state == State.Air:
			return
		if empty_jump_timer.is_stopped():
			empty_jump_timer.start()
		current_state = State.Air

func _set_mover_velocity_x(delta:float):
	if input_x == 0 and mover.velocity.x != 0:
		_deceleration(delta)
	elif input_x == - mover.velocity.x:
		_deceleration(delta)
	elif input_x != 0:
		_accelerate(delta)

func _accelerate(delta:float):
	faster_progress += delta / time_faster
	slower_progress -= delta / time_faster
	var curve_value = faster_curve.sample(faster_progress)
	mover.velocity.x = max_speed * curve_value * input_x

func _deceleration(delta:float):
	faster_progress -= delta / time_faster
	slower_progress += delta / time_faster
	var curve_value = slower_curve.sample(slower_progress)
	var mover_velocity_x:float = mover.velocity.normalized().x
	if input_x == 0:
		mover.velocity.x = max_speed * curve_value * input_x
	else:
		mover.velocity.x = max_speed * curve_value * lerpf(mover_velocity_x,input_x,slower_progress)

func _set_mover_veloctiy_y():
	if mover.is_on_floor():
		if jump_num > 0 and input_y != 0:
			mover.velocity.y = -input_y * jump_power
			jump_num -= 1
	elif !empty_jump_timer.is_stopped():
		if jump_num > 0 and input_y != 0:
			mover.velocity.y = -input_y * jump_power
			jump_num -= 1
		else:
			mover.velocity.y += gravity
	else:
		mover.velocity.y += gravity
func _create_empty_jump_timer():
	if empty_jump_timer:
		return
	empty_jump_timer = Timer.new()
	empty_jump_timer.one_shot = true
	empty_jump_timer.wait_time = empty_jump_time
	add_child(empty_jump_timer)
