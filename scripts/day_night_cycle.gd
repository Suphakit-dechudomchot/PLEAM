extends Node

@export var sun_path: NodePath
@onready var sun = get_node(sun_path)

@export var day_length_minutes: float = 6 # 1 วันในเกมใช้เวลากี่นาทีจริง
var time = 0.0
var day_speed = 1.0

func _ready():
    # คำนวณความเร็วในการหมุน
    # 360 องศา / (นาที * 60 วินาที)
    day_speed = 360.0 / (day_length_minutes * 60.0)
    
    # ตั้งค่าเริ่มต้น (เช่น เริ่มที่ตอนเช้า 90 องศา)
    sun.rotation_degrees.x = -90 

func _process(delta):
    # หมุนพระอาทิตย์ไปเรื่อยๆ ตามแกน X
    sun.rotation_degrees.x += day_speed * delta
    
    # ป้องกันค่าเกิน 360
    if sun.rotation_degrees.x >= 360:
        sun.rotation_degrees.x = 0
