class_name Knockback_Controller
extends Node

class Force_Data_Class:
	var damage_instance: DamageController.Damage_Instance
	var force_direction: Vector2
	var tween: Tween  # Referência ao Tween para controlar a decaimento da força

var applied_forces: Array[Force_Data_Class] = []
var enemy: Enemy

func _ready():
	enemy = get_parent()

# Step 1
# Enemy send knockback parameters for knockback_controller
func call_knockback_controller(damage_instance: DamageController, force_direction: Vector2):
	damage_amount /= 1.3  # Ajusta o valor de damage_amount
	populate_force_data(knockback_direction, knockback_force, damage_amount)
	# Make enemy hit all enemies around his
	enemy.strike_enemies_around(damage_id)

# Step 2
# knockback_controller create a new force_data to store knockback parameters
func populate_force_data(force_direction: Vector2, force_power: float, damage_amount: float):
	var force_instance: Force_Data_Class = Force_Data_Class.new()
	force_instance.force_direction = force_direction
	force_instance.force_power = force_power
	force_instance.force_decay_time = 0.35
	force_instance.damage_amount = damage_amount
	create_force_decay_tween(force_instance)

# Step 3
# Create a tween with current force_instance to decay force_power over force_time_decay time
func create_force_decay_tween(force_instance: Force_Data_Class):
	var knockback_tween: Tween = get_tree().create_tween()
	knockback_tween.set_ease(Tween.EASE_IN)
	knockback_tween.set_trans(Tween.TRANS_QUINT)
	knockback_tween.tween_property(force_instance, "force_power", 0, force_instance.force_decay_time)
	# Store tween reference in Force_Data_Class
	force_instance.tween = knockback_tween 
	# Store current force_instance in applied_forces array
	applied_forces.append(force_instance)

# Called Every Frame
func _process(delta):
	calculate_forces_sum()
	remove_zeropower_forces()
	calculate_body_damage()

# Every Frame 1
# Sum all forces in applied_forces and set this on enemy.actual_knockback
func calculate_forces_sum():
	var all_forces_sum = Vector2.ZERO
	for force_data in applied_forces:
		all_forces_sum += force_data.force_direction * force_data.force_power
	enemy.actual_knockback = all_forces_sum

# Every Frame 2
# Remove applied_forces with force_power == 0
func remove_zeropower_forces():
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
		total_damage += force_data.damage_amount
	var average_damage: float = total_damage / force_count if force_count > 0 else 0
	var damage_multiplier: float = 1.0 + (force_count * 0.1)  # Por exemplo, 10% de aumento por força
	var body_damage: int = int(average_damage * damage_multiplier)
	enemy.actual_body_damage = body_damage
