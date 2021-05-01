extends Node2D

func _ready() -> void:
	$TileMap.add_to_group("tm")

func _process(_delta: float) -> void:
	var half =((get_global_mouse_position() - $player.global_position) / 3) + $player.global_position
	$cam.global_position = lerp($cam.global_position, half, 0.07)
