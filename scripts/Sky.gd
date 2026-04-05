extends Node3D

@export_group("Time Settings")
@export_range(0, 24) var current_time: float = 6.0 
@export var day_length_seconds: float = 60.0       

@export_group("References")
@export var sun_light: DirectionalLight3D
@export var world_env: WorldEnvironment

# --- ตารางสีและขนาดพระอาทิตย์ (sun_max: กลางวัน 40, เช้า/เย็น 9) ---
var sky_data = {
    0.0:  {"top": Color("050508"), "hor": Color("0a1128"), "energy": 0.0, "sun_max": 12.0}, 
    5.0:  {"top": Color("131a3d"), "hor": Color("452d6a"), "energy": 0.1, "sun_max": 0.0},  # เช้ามืด
    6.5:  {"top": Color("4a6d9b"), "hor": Color("ff9d76"), "energy": 0.8, "sun_max": 70.0},  # เช้า
    12.0: {"top": Color("1a4e9b"), "hor": Color("87ceeb"), "energy": 1.2, "sun_max": 150.0}, # กลางวัน (ใหญ่พิเศษตามโจทย์)
    17.5: {"top": Color("4a2d5e"), "hor": Color("ff5e3a"), "energy": 0.9, "sun_max": 70.0},  # เย็น
    19.0: {"top": Color("131a3d"), "hor": Color("452d6a"), "energy": 0.2, "sun_max": 0.0},  # พลบค่ำ
    21.0: {"top": Color("050508"), "hor": Color("0a1128"), "energy": 0.0, "sun_max": 12.0}
}

func _process(delta: float) -> void:
    current_time += (delta / day_length_seconds) * 24.0
    if current_time >= 24.0:
        current_time = 0.0
    
    _update_system()

func _update_system():
    var rotation_angle = (current_time * 15.0) + 90.0
    
    if sun_light:
        sun_light.rotation_degrees = Vector3(rotation_angle, 0, 0)
        # ซ่อนไฟเมื่ออยู่ใต้ดินเพื่อประสิทธิภาพ
        sun_light.visible = (current_time > 5.0 and current_time < 19.5)

    _interpolate_sky_colors()

func _interpolate_sky_colors():
    var keys = sky_data.keys()
    keys.sort()
    
    var before_key = keys[0]
    var after_key = keys[0]
    
    for i in range(keys.size()):
        if current_time >= keys[i]:
            before_key = keys[i]
            after_key = keys[(i + 1) % keys.size()]
    
    var duration = after_key - before_key
    if duration <= 0: duration += 24.0
    var diff = current_time - before_key
    if diff < 0: diff += 24.0
    
    var weight = diff / duration
    
    # คำนวณค่าที่จะ Lerp
    var target_top = sky_data[before_key]["top"].lerp(sky_data[after_key]["top"], weight)
    var target_hor = sky_data[before_key]["hor"].lerp(sky_data[after_key]["hor"], weight)
    var target_energy = lerp(sky_data[before_key]["energy"], sky_data[after_key]["energy"], weight)
    var target_sun_max = lerp(sky_data[before_key]["sun_max"], sky_data[after_key]["sun_max"], weight)
    
    if world_env and world_env.environment and world_env.environment.sky:
        var sky_mat = world_env.environment.sky.sky_material
        if sky_mat is ProceduralSkyMaterial:
            sky_mat.sky_top_color = target_top
            sky_mat.sky_horizon_color = target_hor
            sky_mat.ground_bottom_color = target_top.darkened(0.7)
            sky_mat.ground_horizon_color = target_hor
            
            # --- ปรับขนาดพระอาทิตย์ตามโจทย์ ---
            sky_mat.sun_angle_max = target_sun_max
            # ปรับความคมให้ดูเป็นวงกลมสวยๆ (แนะนำค่า 0.01 - 0.02)
            sky_mat.sun_curve = 0.02 
            
        if sun_light:
            sun_light.light_energy = target_energy
            # ปรับสีไฟอาทิตย์ให้นุ่มนวลตามสีขอบฟ้า
            sun_light.light_color = target_hor.lerp(Color.WHITE, 0.5)
