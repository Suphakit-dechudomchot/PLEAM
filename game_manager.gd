extends Node

func _ready():
    # ตั้งค่าให้เกมเริ่มมาเป็น Fullscreen ทันที (ถ้าต้องการ)
    # หรือจะข้ามไปก่อนถ้าอยากแก้ใน Project Settings
    # DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
    pass

func _input(event):
    # 1. กด F11 เพื่อสลับ Fullscreen (มาตรฐานเกม PC)
    if event is InputEventKey and event.keycode == KEY_F11 and event.pressed:
        toggle_fullscreen()

    # 2. กด Esc เพื่อออกจากเกม (เฉพาะหน้าเมนู หรือตามใจคุณ)
    if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
        # ถ้าอยู่ในฉากเมนู อาจจะให้ปิดเกมเลย
        # get_tree().quit() 
        pass

func toggle_fullscreen():
    if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
