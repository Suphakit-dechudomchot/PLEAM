extends Control

@export_file("*.tscn") var start_game_scene: String = "res://scenes/main scenes/house.tscn"
@onready var rect = $ColorRect

func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    # ตั้งค่าเริ่มต้นให้ ColorRect มืดสนิท และ ปิดการมองเห็นไว้ก่อน
    rect.modulate.a = 0 
    rect.visible = false

func _on_start_button_pressed():
    if start_game_scene != "":
        fade_out_and_change_scene()
    else:
        print("Error: ไม่พบไฟล์ฉาก")

func fade_out_and_change_scene():
    rect.visible = true
    
    # สร้าง Tween สำหรับค่อยๆ ปรับค่า Alpha (ความโปร่งใส) จาก 0 ไป 1
    var tween = create_tween()
    # ปรับค่า modulate:a (Alpha) ไปที่ 1.0 ในเวลา 0.5 วินาที
    tween.tween_property(rect, "modulate:a", 1.0, 1)
    
    # รอจนกว่า Tween จะทำงานเสร็จ (Fade ดำสนิทแล้ว)
    await tween.finished
    
    # รออีกนิดเพื่อให้มั่นใจว่าหน้าจอดำสนิทชัวร์ๆ (0.1 วินาที)
    await get_tree().create_timer(0.1).timeout
    
    # เปลี่ยนฉาก
    get_tree().change_scene_to_file(start_game_scene)

func _on_quit_button_pressed():
    get_tree().quit()
