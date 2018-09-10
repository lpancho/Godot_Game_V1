extends Node

var jumps = 0
var max_jumps = 2
var jump_velocity = 1200
var gravity_accel = 3000

var motion = Vector2(0,0)
const UP = Vector2(0,-1)

var player = null
var stateManager = null
var jump_pressed = false

func _physics_process(delta):
	
	if self.stateManager == null: self.stateManager = get_node("../StateManager")
	if self.player == null: self.player = get_parent()

	self.player.move_and_slide(	motion, UP )
	
	# Quadratic function has a linear derivative.
	self.motion.y += delta * self.gravity_accel 

	# Landing on the floor resets the player's
	# jump counter, and their downwards velocity.
	if self.player.is_on_floor():
		self.motion.y = 0
		self.jumps = 0
		self.jump_pressed = false # This is so the player can 'bounce'.
		
		if self.stateManager.state == "JUMP":
			self.stateManager.request_state_change("IDLE", 0, 2)

	# -----------------------------------------------------------------
	# You *cannot* just use Input.is_action_just_pressed("ui_up") here.
	# Because we're calling in _process rather than _input, just_pressed
	# can be evaluated true more than once for a single press, which
	# results in the double jump being eaten on the first jump.
	#
	# I avoid using _input here because if I did it would make 'bouncing'
	# (see line 26) more tedious to implement.
	# ------------------------------------------------------------------
	if Input.is_action_pressed("ui_up"):
		
		if not self.jump_pressed:
			
			if self.jumps < self.max_jumps:
				
				self.stateManager.request_state_change("JUMP", 1, 2)
				
				self.jump_pressed = true
				self.motion.y = -self.jump_velocity
				self.jumps += 1
				
	else:
		self.jump_pressed = false