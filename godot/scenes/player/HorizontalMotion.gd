extends Node

var player = null
var stateManager = null
var motion = Vector2(0,0)
const UP = Vector2(0,-1)

#------------------------------------------------------------
# At the moment I'm not differentiating between the player
# being on the ground or in the air, but can add if desired.
#-------------------------------------------------------------
var friction_accel = 2500	# How quickly the player slows down.
var ground_accel = 5000		# How quickly the player can accelerate on the ground.
var max_ground_vel = 1000	# How quickly the player can move on the ground.

var last_hit = "NEITHER"

#---------------------------------------------------------------------------------------------------
# I could use if (left_hit)...else(right_hit) to control motion, but if you hit both you just stop.
# This is maybe OK in the case where the player intentionally hits both, but if they're rapidly
# switching from going left to going right, there's the appearance of latency.
#----------------------------------------------------------------------------------------------------
func _input(event):
	if Input.is_action_just_pressed("ui_right"): last_hit = "RIGHT"
	if Input.is_action_just_pressed("ui_left"): last_hit = "LEFT"
	
func _physics_process(delta):
	
	if self.stateManager == null: self.stateManager = get_node("../StateManager")
	if self.player == null: self.player = get_parent()
	self.player.move_and_slide(	motion, UP )

	# Enact friction.
	if self.motion.x > friction_accel * delta:
		self.stateManager.request_state_change("SLIDE", 0, 1)
		self.motion.x -= friction_accel * delta
	elif self.motion.x < -friction_accel * delta:
		self.stateManager.request_state_change("SLIDE", 0, 1)
		self.motion.x += friction_accel * delta
	else:
		self.stateManager.request_state_change("IDLE", 0, 1)
		self.motion.x = 0
	
	# Move left.
	if Input.is_action_pressed("ui_left") and not (Input.is_action_pressed("ui_right") and last_hit == "RIGHT"):
		self.stateManager.request_state_change("RUN", 0, 1)
		if (self.motion.x > -max_ground_vel):
			self.motion.x -= ground_accel * delta
		else: self.motion.x = -max_ground_vel
	# Move right.
	if Input.is_action_pressed("ui_right") and not (Input.is_action_pressed("ui_left") and last_hit == "LEFT"):
		self.stateManager.request_state_change("RUN", 0, 1)
		if (self.motion.x < max_ground_vel):
			self.motion.x += ground_accel * delta
		else: self.motion.x = max_ground_vel
