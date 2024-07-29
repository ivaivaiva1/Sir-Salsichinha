class_name Knockback_Controller
extends Node

class Force_Data_Class:
	var damage_instance: DamageController.Damage_Instance
	var force_direction: Vector2
	var force_power: float
	var force_decay_time: float
	var tween: Tween  

var applied_forces: Array[Force_Data_Class] = []
var enemy: Enemy

func _ready():
	enemy = get_parent()

# Step 1
# Enemy send knockback parameters for knockback_controller
func call_knockback_controller(damage_Instance: DamageController.Damage_Instance, force_Direction: Vector2):
	populate_force_data(damage_Instance, force_Direction)

# Step 2
# knockback_controller create a new force_data to store knockback parameters
func populate_force_data(damage_Instance: DamageController.Damage_Instance, force_Direction: Vector2):
	var data_force_instance: Force_Data_Class = Force_Data_Class.new()
	data_force_instance.damage_instance = damage_Instance
	data_force_instance.force_direction = force_Direction
	data_force_instance.force_power = damage_Instance.force_power
	data_force_instance.force_decay_time = damage_Instance.force_decay_time
	create_force_decay_tween(data_force_instance)

# Adjust the decay time of the bounce based on the enemy's weight
func adjust_decay_time(base_decay_time: float) -> float:
	var min_adjustment: float = 1.5  # Increase by 50% for weight 0
	var max_adjustment: float = 0.5  # Decrease by 50% for weight 10
	var max_weight: float = 10.0
	var weight: float = enemy.weight
	var adjustment: float = min_adjustment + (weight / max_weight) * (max_adjustment - min_adjustment)
	return base_decay_time * adjustment

# Step 3
# Create a tween with current data_force_instance to decay force_power over force_time_decay time
func create_force_decay_tween(data_force_instance: Force_Data_Class):
	var knockback_tween: Tween = get_tree().create_tween()
	knockback_tween.set_ease(Tween.EASE_IN)
	knockback_tween.set_trans(Tween.TRANS_QUINT)
	knockback_tween.tween_property(data_force_instance, "force_power", 0, adjust_decay_time(data_force_instance.force_decay_time))
	knockback_tween.connect("finished", Callable(self, "_on_tween_finished").bind(data_force_instance))
	data_force_instance.tween = knockback_tween
	applied_forces.append(data_force_instance)

# Called on tween is finished
# Assign null on tween and erase force_data_instance in applied_forces
func _on_tween_finished(force_data_instance: Force_Data_Class):
	force_data_instance.tween.disconnect("finished", _on_tween_finished)
	force_data_instance.tween = null
	applied_forces.erase(force_data_instance)
	update_knockback()
	enemy.update_is_striking()

# Called Every Frame
func _process(delta):
	update_knockback()
	update_body_damage()
	update_strongest_force()

# Every Frame 1
# Sum all forces in applied_forces and set this on enemy.actual_knockback
func update_knockback():
	var all_forces_sum = Vector2.ZERO
	for force_data in applied_forces:
		all_forces_sum += force_data.force_direction * force_data.force_power
	enemy.actual_knockback = all_forces_sum

# Every Frame 2
# Calculate actual enemy's body damage 
func update_body_damage():
	var total_damage: float = 0
	var force_count: int = applied_forces.size()
	for force_data in applied_forces:
		total_damage += force_data.damage_instance.force_power
	var average_damage = total_damage / max(force_count, 1)
	var damage_multiplier: float = 1.0 + (force_count * 0.1)  # Por exemplo, 10% de aumento por força
	var body_damage: int = int(average_damage * damage_multiplier)
	enemy.actual_body_damage = body_damage

# Every Frame 3
# Get major force affecting enemy and assign this on enemy.major_knockback_force
func update_strongest_force():
	if applied_forces.size() == 0:
		enemy.major_knockback_force = null
		return
	
	var strongest_force: Force_Data_Class = null
	var major_force: float = 0
	
	for force_data in applied_forces:
		if force_data.force_power > major_force:
			major_force = force_data.force_power
			strongest_force = force_data
	
	if strongest_force == null: return
	enemy.major_knockback_force = strongest_force.damage_instance
