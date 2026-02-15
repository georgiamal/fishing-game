extends Node

var all_fish = [
	Fish.new("Angelfish", 1, 5, 10, 0, "res://assets/fish/Angelfish.png"),
	Fish.new("Bass", 1, 10, 75, 0, "res://assets/fish/Bass.png"),
	Fish.new("Catfish", 1, 25, 130, 0, "res://assets/fish/Catfish.png"),
	Fish.new("Goldfish", 1, 5, 38, 0, "res://assets/fish/Goldfish.png"),
	Fish.new("Rainbow Trout", 1, 10, 75, 0, "res://assets/fish/Rainbow Trout.png")
]

func get_random_fish() -> Fish:
	return all_fish[randi() % all_fish.size()]
