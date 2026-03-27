extends Node3D

@onready var cam = $Camera3D
@export var mouse_sensitivity = 0.001
@export var limit_angle = 15.0 
@export var smooth_speed = 1.0 # ยิ่งเยอะยิ่งไว ยิ่งน้อยยิ่งหน่วง/สมูท

var target_rot_x = 0.0
var target_rot_y = 0.0
var actual_rot_x = 0.0
var actual_rot_y = 0.0

func _ready():
    # ล็อคเมาส์และซ่อนเมาส์ทันทีที่โปรเจกต์เริ่มทำงาน
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    
    # ถ้าเรากดรันซีนนี้เดี่ยวๆ (เพื่อทดสอบ) ให้มันทำงานทันที
    if get_tree().current_scene == self:
        activate()

func _input(event):
    # ปลดล็อคเมาส์ด้วยปุ่ม ESC (เผื่อไว้สำหรับกดออกมาปิดโปรแกรมได้ง่ายขึ้น)
    if event.is_action_pressed("ui_cancel"):
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

    # ทำงานเฉพาะเมื่อกล้องตัวนี้ถูกใช้งานอยู่
    if cam.current and event is InputEventMouseMotion:
        # 1. คำนวณค่าเป้าหมาย (Target)
        target_rot_y -= event.relative.x * mouse_sensitivity
        target_rot_x -= event.relative.y * mouse_sensitivity
        
        # 2. จำกัดมุม (Clamp) ตามที่คุณกำหนดไว้
        var limit_rad = deg_to_rad(limit_angle)
        target_rot_y = clamp(target_rot_y, -limit_rad, limit_rad)
        target_rot_x = clamp(target_rot_x, -limit_rad, limit_rad)

func _process(delta):
    if cam.current:
        # 3. ทำให้ค่าปัจจุบันค่อยๆ วิ่งหาค่าเป้าหมาย (Interpolation)
        actual_rot_x = lerp(actual_rot_x, target_rot_x, delta * smooth_speed)
        actual_rot_y = lerp(actual_rot_y, target_rot_y, delta * smooth_speed)
        
        # 4. นำค่าที่สมูทแล้วไปใส่ในกล้อง
        cam.rotation.x = actual_rot_x
        cam.rotation.y = actual_rot_y

func activate():
    cam.make_current()
    # ตรวจสอบให้แน่ใจว่าเมาส์ถูกล็อคเมื่อเรียกใช้ฟังก์ชันนี้
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    
    # รีเซ็ตค่า
    target_rot_x = 0.0
    target_rot_y = 0.0
    actual_rot_x = 0.0
    actual_rot_y = 0.0
    cam.rotation = Vector3.ZERO
