extends Node2D

@export var throned_body_position_y:float = 16
@export var throned_body_position_x:float = 16
@export var is_fall:bool##刺是否会下落

func _on_damage_component_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		if is_fall:
			var tween = create_tween()
			tween.tween_property(self,"position",position + Vector2.DOWN * 128,1)
