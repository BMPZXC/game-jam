extends Area2D
class_name DamageComponent

@export var whitelist:Array[Node]
@export_group("伤害参数")
##伤害量
@export var damage_amount:int = 1
##伤害次数
@export var damage_num:int = 1
@export_group("附加效果")
@export var is_bleed_damage:bool = false
@export var bleed_damage_amout:int = 1
@export var bleed_num:int = 1

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func set_node_enter_whitelist(node:Node):
	whitelist.append(node)

func reset():
	whitelist.clear()

func _on_area_entered(area: Area2D) -> void:
	if !(area is HealthComponent):
		return
	if whitelist.has(area.get_parent()):
		return
	for i in damage_num:
		area.damage(damage_amount)
	
	if is_bleed_damage:
		for child in area.get_children():
			if child is HealthBleedComponent:
				child.enable_health_bleed(bleed_num,bleed_damage_amout)
