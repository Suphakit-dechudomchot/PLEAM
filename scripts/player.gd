extends CharacterBody3D

@export var walk_speed = 3.0
@export var run_speed = 7.0
@export var jump_velocity = 4.5 
@export var air_control = 0.3        # ตัวคูณความเร็วเมื่ออยู่บนอากาศ (0.3 แปลว่าเคลื่อนที่ได้แค่ 30%)
@export var mouse_sensitivity = 0.002

# การตั้งค่า FOV
@export var normal_fov = 65.0
@export var run_fov = 100.0
@export var fov_change_speed = 8.0

# --- ส่วนที่เพิ่มเข้ามาสำหรับ Head Bobbing ---
const BOB_FREQ = 2.8      
const BOB_AMP = 0.06       
var t_bob = 0.0           
# ----------------------------------------

@onready var camera = $Camera3D 
@onready var footstep_audio = $FootstepAudio 

var rotation_x = 0.0 
var last_bob_val = 0.0 

func _ready():
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
    if event is InputEventMouseMotion:
        rotate_y(-event.relative.x * mouse_sensitivity)
        rotation_x -= event.relative.y * mouse_sensitivity
        rotation_x = clamp(rotation_x, deg_to_rad(-80), deg_to_rad(80))
        camera.rotation.x = rotation_x

func _physics_process(delta):
    # 1. แรงโน้มถ่วง (Gravity)
    if not is_on_floor():
        velocity += get_gravity() * delta

    # 2. ระบบกระโดด (Jump)
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity

    # 3. ระบบเช็คความเร็วและ FOV
    var current_speed = walk_speed
    var target_fov = normal_fov
    
    var input_dir = Input.get_vector("left", "right", "forward", "backward")
    
    # เช็คการวิ่ง (Sprint)
    if Input.is_action_pressed("sprint") and input_dir != Vector2.ZERO:
        current_speed = run_speed
        target_fov = run_fov
    
    # --- ส่วนที่เพิ่ม: ลดความเร็วเมื่ออยู่บนอากาศ ---
    if not is_on_floor():
        current_speed *= air_control
    # ---------------------------------------
    
    camera.fov = lerp(camera.fov, target_fov, delta * fov_change_speed)

    # 4. คำนวณการเคลื่อนที่ (Movement)
    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if direction:
        # ถ้าอยู่บนอากาศ เราจะใช้ lerp เพื่อให้การเปลี่ยนทิศทางไม่ฉับไวเกินไป (ดูหน่วงๆ สมจริง)
        if is_on_floor():
            velocity.x = direction.x * current_speed
            velocity.z = direction.z * current_speed
        else:
            # ค่อยๆ เปลี่ยนความเร็วในอากาศ (นุ่มนวลขึ้น)
            velocity.x = lerp(velocity.x, direction.x * current_speed, delta * 2.0)
            velocity.z = lerp(velocity.z, direction.z * current_speed, delta * 2.0)
    else:
        # แรงเสียดทานเมื่อหยุดเดิน
        var friction = 1.0 if is_on_floor() else air_control
        velocity.x = move_toward(velocity.x, 0, current_speed * friction)
        velocity.z = move_toward(velocity.z, 0, current_speed * friction)

    # 5. ระบบ Head Bobbing และ Footstep Audio
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

func play_footstep_sound():
    if is_on_floor():
        footstep_audio.pitch_scale = randf_range(0.85, 1.15)
        footstep_audio.play()

func _process(_delta):
    if Input.is_action_just_pressed("ui_cancel"):
        if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        else:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
