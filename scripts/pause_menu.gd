extends Control

func _input(event):
    # ตรวจสอบว่ากดปุ่ม ESC หรือไม่
    if event.is_action_pressed("ui_cancel"): # ui_cancel คือปุ่ม ESC โดยมาตรฐาน
        toggle_pause()

func toggle_pause():
    # สลับค่าการหยุดเกม (ถ้าหยุดอยู่ก็ให้เล่นต่อ ถ้าเล่นอยู่ก็ให้หยุด)
    var new_pause_state = !get_tree().paused
    get_tree().paused = new_pause_state
    
    # แสดงหรือซ่อนเมนู
    visible = new_pause_state
    
    # จัดการเรื่องเมาส์
    if new_pause_state:
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # โชว์เมาส์มาให้กดเมนู
    else:
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # ซ่อนเมาส์กลับไปเล่นเกม

# ปุ่ม Resume (กลับเข้าเกม)
func _on_resume_button_pressed():
    toggle_pause()

# ปุ่มกลับหน้าเมนูหลัก
func _on_main_menu_button_pressed():
    get_tree().paused = false # ต้องปลด Pause ก่อนเปลี่ยนฉาก ไม่งั้นฉากใหม่จะค้าง
    get_tree().change_scene_to_file("res://scenes/main scenes/master_main_menu.tscn")
    
# ฟังก์ชันสำหรับปุ่มออกเกม
func _on_quit_button_pressed():
    get_tree().quit()
