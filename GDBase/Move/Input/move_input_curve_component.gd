extends MoveComponentBase
class_name MoveInCurveByInputComponent
##该脚本用于赋予节点由输入控制的移动能力
##将该脚本挂载到任意Node类节点上，将mover赋值为需要移动能力的CharacterBody2D节点

@export var mover:CharacterBody2D
@export var turn_in_point:bool
@export var max_speed:float = 128.0
@export var gravity:float = 0
##请注意，若需要加速时间严格等于下方时间，需要您的加速曲线在结尾处才达到最高点
##减速时间同理，在结尾处达到最低点
@export var time_faster:float = 1 ##加速时间
##这里注明，当速度方向与加速度方向相反时，减速时间会更少
@export var time_slower:float = 1 ##减速时间
##由于转弯过程不宜用时间计算，故采用系数命名，它不是真正的转弯时间
@export var time_turn:float = 1 ##转弯时间系数
@export var faster_curve:Curve ##加速曲线
@export var slower_curve:Curve ##减速曲线
@export var turn_curve:Curve
var faster_progress:float = 0: ##加速进度
	set(value):
		faster_progress = clamp(value,0,1)
var slower_progress:float = 0: ##减速进度
	set(value):
		slower_progress = clamp(value,0,1)
var turn_progress:float = 0: ##转弯进度
	set(value):
		turn_progress = clamp(value,0,1)

var input_dir:Vector2 ##输入方向
var is_input_changed:bool = false

enum MovementState {
	ACCELERATING,
	DECELERATING,
	TURNING,
	Idle
}

var current_state:MovementState = MovementState.Idle

func _physics_process(delta: float) -> void:
	if !mover:
		return
	check_input()
	update_state()
	match current_state:
		MovementState.Idle:
			pass
		MovementState.ACCELERATING:
			accelerate(delta)
		MovementState.DECELERATING:
			deceleration(delta)
		MovementState.TURNING:
			turn(delta)
	mover.velocity.y += gravity
	mover.move_and_slide()

func check_input():
	var pre_input_dir = input_dir
	input_dir = Input.get_vector("move_left","move_right","move_up","move_down")
	if pre_input_dir !=  input_dir:
		is_input_changed = true
	else:
		is_input_changed = false

func update_state():
	var angle = mover.velocity.angle_to(input_dir)
	var is_moving:bool = (mover.velocity != Vector2.ZERO)
	var have_input:bool = (input_dir != Vector2.ZERO)
	
	if !is_moving and have_input:
		##当无速度但存在输入时，即单位做速度从零开始的加速运动。这只持续一帧，但我们不能缺少这一判断。
		if current_state == MovementState.ACCELERATING and !is_input_changed:
			return
		current_state = MovementState.ACCELERATING
	elif is_moving and !have_input:
		##当有速度但无输入时，即单位做沿速度方向做直线减速
		if current_state == MovementState.DECELERATING and !is_input_changed:
			return
		current_state = MovementState.DECELERATING
	elif input_dir == - mover.velocity.normalized() and turn_in_point:
		##当输入方向与速度方向相反时，即单位做逆向加速运动时
		##额外判断是否能够原地逆向加速，如果不行进入转弯状态
		if current_state == MovementState.DECELERATING and !is_input_changed:
			return
		current_state = MovementState.DECELERATING
	elif angle <= PI / 18 and angle >= - PI / 18:
		##当输入方向与速度方向大致一致时，即单位做直线加速或匀速运动
		if current_state == MovementState.ACCELERATING:
			return
		current_state = MovementState.ACCELERATING
	elif angle > PI / 18 or angle < - PI / 18:
		##当输入方向与速度方向有偏差时，即单位做转向运动
		if current_state == MovementState.TURNING and !is_input_changed:
			return
		current_state = MovementState.TURNING
	else :
		##当输入与速度都为零时
		current_state = MovementState.Idle

func accelerate(delta:float):
	add_faster_progress(delta)
	faster_progress += delta / time_faster
	var curve_value = faster_curve.sample(faster_progress)
	mover.velocity = max_speed * curve_value * input_dir

func deceleration(delta:float):
	add_slower_progress(delta)
	var curve_value = slower_curve.sample(slower_progress)
	var mover_velocity_dir:Vector2 = mover.velocity.normalized()
	if input_dir == Vector2.ZERO:
		mover.velocity = max_speed * curve_value * mover_velocity_dir
	else:
		mover.velocity = max_speed * curve_value * mover_velocity_dir.lerp(input_dir,slower_progress)

func turn(delta:float):
	add_turn_progress(delta)
	turn_progress += delta / time_turn
	var mover_velocity_dir:Vector2 = mover.velocity.normalized()
	var curve_value = turn_curve.sample(turn_progress)
	mover.velocity = max_speed * curve_value * mover_velocity_dir.slerp(input_dir,turn_progress)


func add_faster_progress(delta:float):
	faster_progress += delta / time_faster
	slower_progress -= delta / time_slower
	turn_progress = 0

func add_slower_progress(delta:float):
	faster_progress -= delta / time_faster
	slower_progress += delta / time_slower
	turn_progress = 0

func add_turn_progress(delta:float):
	slower_progress -= delta / time_slower
	turn_progress += delta / time_turn
