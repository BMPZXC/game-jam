extends Node
class_name Spawner
##想要让生成器生成的实体能够自己回收自己，为他们加上to_recycle_self信号

@export var spawned_instance_packedscene:PackedScene
@export var max_instance_num:int = 10
@export var spawn_instances_once_num:int = 5
var inactive_instances:Array
var available_instances:Array

func init(instance_packedscene:PackedScene,
		_max_instance_num:int = max_instance_num,
		_spawn_instances_once_num:int = spawn_instances_once_num):
	spawned_instance_packedscene = instance_packedscene
	max_instance_num = _max_instance_num
	spawn_instances_once_num = _spawn_instances_once_num

func request_instance() ->Node:
	if available_instances.is_empty():
		_spawn_instances()
	var instance:Node = available_instances.pop_back()
	inactive_instances.append(instance)
	instance.process_mode = instance.PROCESS_MODE_INHERIT
	instance.show()
	return instance

func request_certain_instance(instance:Node)->Node:
	if !available_instances.has(instance):
		push_error("请求的实体不在生成器的可用实体池中")
		return
	available_instances.erase(instance)
	inactive_instances.append(instance)
	instance.process_mode = instance.PROCESS_MODE_INHERIT
	instance.show()
	return instance

func recycle_instance(instance:Node):
	assert(inactive_instances.has(instance),"要求生成器回收不属于它的实例"+str(instance))
	if available_instances.size() >= max_instance_num:
		instance.queue_free()
	else :
		_reset_instance(instance)
		inactive_instances.erase(instance)
		available_instances.append(instance)
		print("回收了实例"+str(instance))

func _reset_instance(instance:Node):
	var instance_parent = instance.get_parent()
	if instance_parent:
		instance_parent.call_deferred("remove_child",instance)
	instance.set_deferred("process_mode",PROCESS_MODE_DISABLED)
	instance.hide()

func _spawn_instances():
	for i in spawn_instances_once_num:
		_spawn_instance()

func _spawn_instance():
	var instance = spawned_instance_packedscene.instantiate()
	instance.process_mode = instance.PROCESS_MODE_DISABLED
	instance.hide()
	available_instances.append(instance)
	##不使用die这个更常用的信号是为了有选择地赋予需要的实体自回收功能。
	if instance.has_signal("to_recycle_self"):
		instance.to_recycle_self.connect(recycle_instance.bind(instance))
