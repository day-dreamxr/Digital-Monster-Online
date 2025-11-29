extends AnimatedSprite2D

signal stats_changed

var current_digimon: Dictionary = preload("res://digimon/botamon/data.json").data

var id: int = 0

@export var digimon_name: String
@export var stage: String
@export var age: int = 0
@export var weight: int = 0

@export var hunger: int = 0
@export var strength: int = 0
@export var effort: int = 0

@export var attribute: String
@export var power: int = 0
@export var battles: int = 0

@export var care_mistakes: int = 0
@export var overfeeds: int = 0
@export var bedtime: int = 0000

func start_evolution_timer() -> void:
	var time: int
	match stage:
		"Egg":
			time = 60
		"Fresh":
			time = 600
		"In-Training":
			time = 21600
		"Rookie":
			time = 86400
		"Champion":
			time = 129600
		"Ultimate":
			time = 172800
	$EvolutionTimer.start(time)

func _on_evolution_timer_timeout() -> void:
	if stage == "Mega":
		return
	var can_evolve: bool
	for digimon in current_digimon["digimon"]:
		if id == digimon["id"]:
			for evolution in digimon["evolutions"]:
				can_evolve = true
				for requirement in evolution["requirements"]:
					match requirement:
						"care_mistakes":
							if care_mistakes > evolution["requirements"]["care_mistakes"]:
								can_evolve = false
						"effort":
							if effort < evolution["requirements"]["effort"]:
								can_evolve = false
						"battles":
							if battles < evolution["requirements"]["battles"]:
								can_evolve = false
						"overfeeds":
							if overfeeds < evolution["requirements"]["overfeeds"]:
								can_evolve = false
				if can_evolve:
					digivolve(evolution["id"])
					return
	die()

func _on_hunger_care_timer_timeout() -> void:
	care_mistakes += 1
	save_digimon()

func _on_strength_care_timer_timeout() -> void:
	care_mistakes += 1
	save_digimon()

func _on_sleep_care_timer_timeout() -> void:
	care_mistakes += 1
	save_digimon()

func set_sprites(sprite_id: int):
	var frames = load("res://digimon/botamon/sprites/"+str(sprite_id)+".tres")
	self.frames = frames
	self.play("idle")

func digivolve(new_id: int):
	if stage == "Egg":
		initialize_timers()
	for digimon in current_digimon["digimon"]:
		if new_id == digimon["id"]:
			id = digimon["id"]
			digimon_name = digimon["name"]
			stage = digimon["stage"]
			attribute = digimon["attribute"]
			power = digimon["base_power"]
			effort = 0
			battles = 0
			care_mistakes = 0
			overfeeds = 0
			if digimon["bedtime"] is int:
				bedtime = digimon["bedtime"]
			set_sprites(digimon["id"])
			stats_changed.emit()
	start_evolution_timer()
	save_digimon()

func die():
	print("rip")

func save_digimon():
	SaveData.id = id
	SaveData.age = age
	SaveData.weight = weight
	SaveData.hunger = hunger
	SaveData.strength = strength
	SaveData.effort = effort
	SaveData.battles = battles
	SaveData.care_mistakes = care_mistakes
	SaveData.overfeeds = overfeeds
	SaveData.time_until_evolution = $EvolutionTimer.time_left
	
	SaveData.save_when_ready()

func load_digimon():
	for digimon in current_digimon["digimon"]:
		if SaveData.id == digimon["id"]:
			id = SaveData.id
			digimon_name = digimon["name"]
			stage = digimon["stage"]
			age = SaveData.age
			weight = SaveData.weight
			hunger = SaveData.hunger
			strength = SaveData.strength
			effort = SaveData.effort
			attribute = digimon["attribute"]
			power = digimon["base_power"]
			battles = SaveData.battles
			care_mistakes = SaveData.care_mistakes
			overfeeds = SaveData.overfeeds
			if digimon["bedtime"] is int:
				bedtime = digimon["bedtime"]
			if SaveData.time_until_evolution == 0.0:
				start_evolution_timer()
			else:
				$EvolutionTimer.start(SaveData.time_until_evolution)
			set_sprites(SaveData.id)
	stats_changed.emit()

func _on_hunger_drain_timer_timeout() -> void:
	hunger -= 1
	if hunger == 0:
		$HungerCareTimer.start(600)
	else:
		$HungerDrainTimer.start(3600)
	save_digimon()

func _on_strength_drain_timer_timeout() -> void:
	strength -= 1
	if strength == 0:
		$StrengthCareTimer.start(600)
	else:
		$StrengthDrainTimer.start(3600)
	save_digimon()

func initialize_timers():
	if stage != "Egg":
		if hunger == 0:
			$HungerCareTimer.start(600)
		else:
			$HungerDrainTimer.start(3600)
		if strength == 0:
			$StrengthCareTimer.start(600)
		else:
			$StrengthDrainTimer.start(3600)
