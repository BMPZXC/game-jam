extends RefCounted
class_name SpawnerMgr

const MAX_INSTANCE_IN_SPAWNER_NUM = 10
const SPAWN_INSTANCE_IN_SPAWNER_ONCE_NUM = 5

var spawners:Dictionary[String,Spawner] = {}

func get_spawner(scene_path)->Spawner:
	assert(spawners.has(scene_path),"请求获取不存在的生成器"+scene_path)
	return spawners[scene_path]

func request_instance(scene_path:String,
					max_instance_num:int = MAX_INSTANCE_IN_SPAWNER_NUM,
					spawn_instances_once_num:int = SPAWN_INSTANCE_IN_SPAWNER_ONCE_NUM)->Node:
	if !spawners.has(scene_path):
		_register_spawner(scene_path,max_instance_num,spawn_instances_once_num)
	return spawners[scene_path].request_instance()

func request_certain_instance(instance:Node):
	if spawners.has(instance.scene_file_path):
		spawners[instance.scene_file_path].request_certain_instance(instance)
	return instance

func recycle_instance(instance:Node):
	var instance_path:String = instance.scene_file_path
	if spawners.has(instance_path):
		spawners[instance_path].recycle_instance(instance)
	else:
		assert(false,"尝试回收不是由SpawnerMgr生成的实体")

func _register_spawner(scene_path:String,
					max_instance_num:int = MAX_INSTANCE_IN_SPAWNER_NUM,
					spawn_instances_once_num:int = SPAWN_INSTANCE_IN_SPAWNER_ONCE_NUM):
	if spawners.has(scene_path):
		return
	var new_spawner:Spawner = Spawner.new()
	var new_spawned_instance:PackedScene = _get_packedscene(scene_path)
	new_spawner.init(new_spawned_instance,max_instance_num,spawn_instances_once_num)
	spawners[scene_path] = new_spawner

func _get_packedscene(scene_path:String)->PackedScene:
	var new_scene = load(scene_path)
	assert(new_scene is PackedScene,"生成器读取了错误的文件路径"+scene_path+"它不是一个有效的场景文件")
	print_debug("生成器读取成功，文件路径为"+ scene_path)
	return new_scene
