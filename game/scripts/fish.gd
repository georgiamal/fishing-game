class_name Fish
extends Resource

var name: String
var rarity: int
var min_length: float
var max_length: float
var value: int
var sprite_path: String
var caught_length: float

func _init(name: String = "", rarity: int = 1, min_length: float = 5.0, max_length: float = 55.0, value: int = 0, sprite_path: String = ""):
		self.name = name
		self.rarity = rarity
		self.min_length = min_length
		self.max_length = max_length
		self.value = value
		self.sprite_path = sprite_path

func generate_length() -> void:
	caught_length = randf_range(min_length, max_length)
