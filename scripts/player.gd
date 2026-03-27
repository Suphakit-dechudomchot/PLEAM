extends CharacterBody3D

# --- ตัวแปรเดิมของคุณ ---
@export var walk_speed = 4.0
@export var run_speed = 8.0
@export var jump_velocity = 4.5 
@export var air_control = 0.3
@export var mouse_sensitivity = 0.002
@export var normal_fov = 80.0
@export var run_fov = 100.0
@export var fov_change_speed = 8.0

const BOB_FREQ = 2.8      
const BOB_AMP = 0.06       
var t_bob = 0.0           

@onready var camera = $Camera3D 
@onready var footstep_audio = $FootstepAudio 

var rotation_x = 0.0 
var last_bob_val = 0.0 

# --- ส่วนที่เพิ่มสำหรับการล็อคและกล้องสมูท (Witcher Style) ---
var is_locked: bool = false
@export var lock_limit_angle = 15.0 # องศาที่ยอมให้ส่ายหัวได้ตอนโดนล็อค
@export var smooth_speed = 5.0     # ความสมูทของการส่ายหน้า

var target_rot_x = 0.0
var target_rot_y = 0.0
var actual_rot_x = 0.0
var actual_rot_y = 0.0
var base_rotation_y = 0.0 # เก็บค่าหันหน้าเริ่มต้นตอนโดนล็อค

func _ready():
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# ฟังก์ชันสำหรับเรียกใช้จาก SceneManager หรือ Intro Script
func set_lock(status: bool):
    is_locked = status
    if is_locked:
        # เก็บค่าการหันปัจจุบันไว้เป็นจุดศูนย์กลางของการส่ายหน้า
        base_rotation_y = rotation.y
        target_rot_x = rotation_x
        target_rot_y = 0.0 
        actual_rot_x = rotation_x
        actual_rot_y = 0.0
    else:
        # เมื่อปลดล็อค ให้กล้องกลับเป็นปกติ
        camera.transform.origin = Vector3.ZERO

func _input(event):
    if event is InputEventMouseMotion:
        if not is_locked:
            # --- โหมดเดินปกติ ---
            rotate_y(-event.relative.x * mouse_sensitivity)
            rotation_x -= event.relative.y * mouse_sensitivity
            rotation_x = clamp(rotation_x, deg_to_rad(-80), deg_to_rad(80))
            camera.rotation.x = rotation_x
            camera.rotation.y = 0 # รีเซ็ตการหันแกน Y ของกล้องลูก
        else:
            # --- โหมดโดนล็อค (ส่ายหัวสมูท) ---
            target_rot_y -= event.relative.x * mouse_sensitivity
            target_rot_x -= event.relative.y * mouse_sensitivity
            
            var limit_rad = deg_to_rad(lock_limit_angle)
            target_rot_y = clamp(target_rot_y, -limit_rad, limit_rad)
            target_rot_x = clamp(target_rot_x, -limit_rad, limit_rad)

func _physics_process(delta):
    # ถ้าโดนล็อค ให้จัดการแค่เรื่องกล้องสมูทแล้วจบฟังก์ชัน (ห้ามเดิน)
    if is_locked:
        handle_locked_camera(delta)
        # ทำให้ความเร็วเป็น 0 ทันที
        velocity.x = move_toward(velocity.x, 0, walk_speed)
        velocity.z = move_toward(velocity.z, 0, walk_speed)
        if not is_on_floor():
            velocity += get_gravity() * delta
        move_and_slide()
        return # หยุดการทำงานข้างล่างทั้งหมด

    # --- ส่วนของการเคลื่อนที่เดิมของคุณ (Physics Process ปกติ) ---
    if not is_on_floor():
        velocity += get_gravity() * delta

    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity

    var current_speed = walk_speed
    var target_fov = normal_fov
    var input_dir = Input.get_vector("left", "right", "forward", "backward")
    
    if Input.is_action_pressed("sprint") and input_dir != Vector2.ZERO:
        current_speed = run_speed
        target_fov = run_fov
    
    if not is_on_floor():
        current_speed *= air_control
    
    camera.fov = lerp(camera.fov, target_fov, delta * fov_change_speed)

    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if direction:
        if is_on_floor():
            velocity.x = direction.x * current_speed
            velocity.z = direction.z * current_speed
        else:
            velocity.x = lerp(velocity.x, direction.x * current_speed, delta * 2.0)
            velocity.z = lerp(velocity.z, direction.z * current_speed, delta * 2.0)
    else:
        var friction = 1.0 if is_on_floor() else air_control
        velocity.x = move_toward(velocity.x, 0, current_speed * friction)
        velocity.z = move_toward(velocity.z, 0, current_speed * friction)

    # Head Bobbing (ทำงานเฉพาะตอนไม่ล็อค)
    if is_on_floor() and velocity.length() > 0.1:
        t_bob += delta * velocity.length()
        var bob_pos = Vector3.ZERO
        var bob_sin = sin(t_bob * BOB_FREQ)
        bob_pos.y = bob_sin * BOB_AMP
        bob_pos.x = cos(t_bob * BOB_FREQ / 2) * BOB_AMP
        camera.transform.origin = bob_pos
        if last_bob_val > 0 and bob_sin <= 0:
            play_footstep_sound()
        last_bob_val = bob_sin
    else:
        t_bob = 0.0
        camera.transform.origin = camera.transform.origin.lerp(Vector3.ZERO, delta * 10)
        last_bob_val = 0.0

    move_and_slide()

# ฟังก์ชันจัดการกล้องตอนโดนล็อค
func handle_locked_camera(delta):
    actual_rot_x = lerp(actual_rot_x, target_rot_x, delta * smooth_speed)
    actual_rot_y = lerp(actual_rot_y, target_rot_y, delta * smooth_speed)
    
    camera.rotation.x = actual_rot_x
    camera.rotation.y = actual_rot_y # ใช้ rotation.y ของกล้องลูกในการส่ายซ้ายขวา

func play_footstep_sound():
    if is_on_floor():
        footstep_audio.pitch_scale = randf_range(0.85, 1.15)
        footstep_audio.play() 
