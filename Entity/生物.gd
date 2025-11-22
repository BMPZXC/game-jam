extends CharacterBody2D
class_name 生物

#回合时间,人反应的时间
const 单位_时间=1
const 时间_上线=3

const 单位_防御=4
const 单位_攻击=2
const 单位_休息=1

var 点数_防御=1
var 点数_攻击=1
var 点数_休息=1

#1 小怪,3 玩家 ,5 boss (影响[时间]回复速度,即出招频率
@export_range(1,5) var 星级:int=1

var 生命_回复
@export_range(2,99) var 生命_上线:float=10

var 护盾_回复
var 护盾_上线

var 攻击力
var 失衡_上线
#设置初始属性 或 重制操作
func 点数_设置():
	pass
func _init() -> void:
	点数_设置()
	生命_回复=单位_休息*点数_休息
	#生命_上线=单位_时间*单位_攻击*点数_休息*20
	
	护盾_回复=单位_防御*点数_防御
	护盾_上线=单位_时间*单位_防御*点数_防御*2
	
	攻击力=单位_攻击*点数_攻击
	失衡_上线=5
	
	生命=生命_上线
func 初始():
	生命=生命_上线
	时间=时间_上线
	失衡=0
	护盾=0
	强化=0
signal 生命_变动
signal 护盾_变动
signal 失衡_变动
signal 强化_变动
var 生命:
	set(a):
		a=max(0,a)
		a=min(生命_上线,a)
		生命_变动.emit(a,生命)
		生命=a
var 护盾=0:
	set(a):
		a=max(0,a)
		a=min(护盾_上线,a)
		护盾_变动.emit(a,护盾)
		护盾=a
		
		
var 失衡_上次时间:float=-99
var 失衡中=false
signal 失衡_
var 失衡=0:
	set(a):
		a=max(0,a)
		a=min(失衡_上线,a)
		if not 失衡中 :
			if a>失衡:
				失衡_上次时间=Time.get_unix_time_from_system()
			if  a==失衡_上线:
				失衡中=true
				失衡=失衡_上线
				失衡_.emit()
		else :
			if a>失衡:
				return
			if a==0:
				失衡中=false
			
		失衡_变动.emit(a,失衡)
		失衡=a
		
var 强化=0:
	set(a):
		强化_变动.emit(a,强化)
		强化=a
		

var 时间=时间_上线:
	set(a):
		a=min(时间_上线,a)
		时间=a
		
signal 受击_
signal 死亡_

signal 格挡_
signal 击破_
#signal 盾反_

func _has_sijian(sijian:float)->bool:
	if 时间<=0:
		print("时间不足")
		return false
	if 失衡中:
		print("失衡中")
		return false
	时间-=sijian
	return true

signal 受击_子弹
func 受击(攻击方:子弹):
	受击_子弹.emit(攻击方)
	var a=攻击方.攻击力
	if 护盾>0:
		if  护盾>=a:
			护盾-=a
			攻击方.攻击方.失衡+=攻击方.攻击力
			格挡_.emit()
			return
		a-=护盾
		失衡+=护盾
		护盾=0
		击破_.emit()
		
	生命-=a
	失衡+=a
	if 生命<=0:
		死亡_.emit()
	else :
		强化=0
		受击_.emit()
	
	
func 防御(sijian:float):
	if not _has_sijian(sijian):return
	护盾+=护盾_回复*sijian
	_防御=true
	return true

func 休息(sijian:float):
	if not _has_sijian(sijian):return
	生命+=生命_回复*sijian
	强化+=sijian
	return true

func 攻击(sijian:float)->子弹:
	if not _has_sijian(sijian):return
	return 子弹.new(self,sijian)
class 子弹:
	var 攻击力=0
	var 攻击方:生物
	var 强化值:float=0
	func _init(a:生物,sijian:float) -> void:
		攻击方=a
		强化值=a.强化
		攻击力=a.攻击力*(1*sijian+a.强化)
		a.强化=0
		
	func 攻击(a)->bool:
		if a is 生物 and not a==攻击方:
			a.受击(self)
			return true
		return false
#
func process(_delta: float) -> void:
	pass
func _process(delta: float) -> void:
	var a=[process,_时间_回复,_防御_衰减,_失衡_衰减]
	for i in a:
		i.call(delta)
		
func _时间_回复(sijian:float):
	时间+=sijian*星级/3
var _防御=false
func _防御_衰减(sijian:float):
	if _防御:
		_防御=false
		return
	if 护盾>护盾_上线*0.5:
		护盾-=护盾_回复*sijian
	elif 护盾>0:
		护盾-=护盾_回复*sijian*0.4
func _失衡_衰减(sijian:float):
	if 失衡中 or Time.get_unix_time_from_system()-失衡_上次时间>=时间_上线:
		失衡-=sijian
		
const 单位_速度=500
var 锁定_移动:bool=false
func physics_process(_delta: float) -> void:
	pass
func _physics_process(delta: float) -> void:
	var a=[physics_process,_速度_阻力]
	for i in a:
		i.call(delta)
#请在每帧调用。默认true
var 水平_阻力:bool=true
func _速度_阻力(delta: float):
	if  锁定_移动:
		move_and_slide()
		return
	if 水平_阻力:
		var a=sign(velocity.x)
		if velocity.x!=0:
			velocity.x-=(单位_速度*4+velocity.x*a*4)*a*delta
			if velocity.x*a<0:
				velocity.x=0
	水平_阻力=true
		
	if not is_on_floor() or velocity.y<0:
		velocity.y+=单位_速度*delta*5
	else:
		velocity.y=0
	move_and_slide()
var 锁定_动画:bool=false
