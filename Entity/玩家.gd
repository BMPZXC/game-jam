extends 生物


func 点数_设置():
	点数_休息=1
	点数_攻击=1
	点数_防御=1
	星级=3
signal gongji
var suiping_fangxing_zeng=1

@onready var animation_player: AnimationPlayer = $AnimationPlayer/AnimationPlayer
@onready var ico=$"Icon".material

func _ready() -> void:
	$ui.visible=true
	受击_.connect(func ():animation_player.play("受击"))
	强化_变动.connect(func (a,_b):ico.set("shader_parameter/qiang_hua",a/单位_时间))
func process(delta: float) -> void:
	if 时间<=0 or 锁定_移动 or 失衡中:return
	#if Input.is_action_just_pressed("闪现"):
		##锁定_移动=true
		##时间-=1
		#var f=suiping_fangxing_zeng
		#var yidong= Input.get_axis("移动.左","移动.右")
		#yidong=sign(yidong)
		#if yidong!=0:
			#f=yidong
		#var a=create_tween()
		#a.finished.connect(func ():锁定_移动=false)
		#velocity.x=单位_速度*3*f
		#a.tween_property(self,"velocity.x",单位_速度*3*f,0.1)
		#a.set_ease(Tween.EASE_OUT)
		#a.set_trans(Tween.TRANS_CIRC)
		#return
	if Input.is_action_just_pressed("攻击"):
		var a=攻击(单位_时间)
		if a:
			gongji.emit(a)
		return
	if Input.is_action_just_pressed("防御") :
		防御(单位_时间)
	elif  Input.is_action_pressed("防御"):
		防御(delta)
	if Input.is_action_just_pressed("休息"):
		休息(单位_时间)
	if Input.is_action_pressed("休息"):
		休息(delta)

var tesuzuang_yidong:int=0
func physics_process(delta: float) -> void:
	if  锁定_移动 or 失衡中:return
		
	if Input.is_action_just_pressed("跳跃"):
		if is_on_floor():
			velocity.y=-单位_速度*2

	var yidong= Input.get_axis("移动.左","移动.右")
	if yidong:
		var a=sign(yidong)
		if suiping_fangxing_zeng*a<0:
			suiping_fangxing_zeng=a
			scale.x=-scale.x
		yi(yidong,delta)
			

		
func  yi(yidong,delta):
	if abs(velocity.x)>单位_速度*2:
		return
	if yidong*velocity.x<0:
		velocity.x=-velocity.x*0.5
		return
	velocity.x+=yidong*delta*单位_速度*2
	if abs(velocity.x)>=单位_速度:
		velocity.x=单位_速度*yidong
	水平_阻力=false
	
