class_name Knockback_Controller
extends Node

class Force_Data_Class:
	var damage_instance: DamageController.Damage_Instance
	var force_direction: Vector2
	var force_power: float
	var force_decay_time: float
	var tween: Tween  # Referência ao Tween para controlar a decaimento da força

var applied_forces: Array[Force_Data_Class] = []
var enemy: Enemy

func _ready():
	enemy = get_parent()

# Step 1
# Enemy send knockback parameters for knockback_controller
func call_knockback_controller(damage_Instance: DamageController.Damage_Instance, force_Direction: Vector2):
	populate_force_data(damage_Instance, force_Direction)
	## Make enemy hit all enemies around
	#enemy.strike_enemies_around()

# Step 2
# knockback_controller create a new force_data to store knockback parameters
func populate_force_data(damage_Instance: DamageController.Damage_Instance, force_Direction: Vector2):
	var data_force_instance: Force_Data_Class = Force_Data_Class.new()
	data_force_instance.damage_instance = damage_Instance
	data_force_instance.force_direction = force_Direction
	data_force_instance.force_power = damage_Instance.force_power
	data_force_instance.force_decay_time = damage_Instance.force_decay_time
	create_force_decay_tween(data_force_instance)

# Step 3
# Create a tween with current data_force_instance to decay force_power over force_time_decay time
func create_force_decay_tween(data_force_instance: Force_Data_Class):
	var knockback_tween: Tween = get_tree().create_tween()
	knockback_tween.set_ease(Tween.EASE_IN)
	knockback_tween.set_trans(Tween.TRANS_QUINT)
	knockback_tween.tween_property(data_force_instance, "force_power", 0, data_force_instance.force_decay_time)
	# Store tween reference in Force_Data_Class
	data_force_instance.tween = knockback_tween 
	# Store current force_instance in applied_forces array
	applied_forces.append(data_force_instance)

# Called Every Frame
func _process(delta):
	calculate_forces_sum()
	remove_zeroPower_forces()
	calculate_body_damage()
	get_strongest_force()

# Every Frame 1
# Sum all forces in applied_forces and set this on enemy.actual_knockback
func calculate_forces_sum():
	var all_forces_sum = Vector2.ZERO
	for force_data in applied_forces:
		all_forces_sum += force_data.force_direction * force_data.force_power
	enemy.actual_knockback = all_forces_sum

# Every Frame 2
# Remove applied_forces with force_power == 0
func remove_zeroPower_forces():
	var forces_to_remove: Array = []
	for force_data in applied_forces:
		if force_data.force_power == 0:
			forces_to_remove.append(force_data)
	for force_data in forces_to_remove:
		applied_forces = applied_forces.filter(func(item): return item != force_data)

# Every Frame 3
# Calculate actual enemy's body damage 
func calculate_body_damage():
	var total_damage: float = 0
	var force_count: int = applied_forces.size()
	for force_data in applied_forces:
		total_damage += force_data.damage_instance.force_power
	var average_damage: float = total_damage / force_count if force_count > 0 else 0
	var damage_multiplier: float = 1.0 + (force_count * 0.1)  # Por exemplo, 10% de aumento por força
	var body_damage: int = int(average_damage * damage_multiplier)
	enemy.actual_body_damage = body_damage

# Every Frame 4
func get_strongest_force():
	if applied_forces.size() == 0:
		enemy.major_knockback_force = null
		return
	
	var strongest_force = null
	var major_force = 0
	for force_data in applied_forces:
		if force_data['force_power'] > major_force:
			major_force = force_data['force_power']
			strongest_force = force_data
	
	# Não é mais necessário verificar se strongest_force é null
	enemy.major_knockback_force = strongest_force['damage_instance']

