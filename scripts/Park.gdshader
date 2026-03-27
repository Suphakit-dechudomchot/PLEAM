shader_type sky;

uniform sampler2D dog_sky_texture : filter_linear, source_color; // ใส่รูป HDRI ของคุณที่นี่
uniform vec4 sky_tint : source_color = vec4(1.0); // ตัวปรับสีท้องฟ้า
uniform float brightness : hint_range(0.0, 5.0) = 1.0; // ปรับความสว่าง

void sky() {
    // ดึงสีจาก HDRI มา
    vec3 sky_color = texture(dog_sky_texture, SKY_COORDS).rgb;
    
    // ย้อมสีเฉพาะท้องฟ้าตรงนี้!
    COLOR = sky_color * sky_tint.rgb * brightness;
}