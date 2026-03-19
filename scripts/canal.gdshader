shader_type spatial;

uniform sampler2D texture_normal;         // ใส่ Noise ตรงนี้
uniform float scroll_speed = 0.05;        // ความเร็วการไหล
uniform float texture_scale = 1.0;       // ขนาดลายน้ำ

varying vec3 uv1_triplanar_pos;
varying vec3 uv1_power_normal;

void vertex() {
	// คำนวณตำแหน่งแบบ Triplanar เพื่อไม่ให้ลายยืดเวลาขยายบล็อก
	uv1_power_normal = pow(abs(NORMAL), vec3(10.0));
	uv1_power_normal /= dot(uv1_power_normal, vec3(1.0));
	uv1_triplanar_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz * texture_scale;
	
	// สั่งให้น้ำขยับตามเวลา (TIME)
	uv1_triplanar_pos.xz += TIME * scroll_speed;
}

vec4 triplanar_texture(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos) {
	vec4 samp = vec4(0.0);
	samp += texture(p_sampler, p_triplanar_pos.xy) * p_weights.z;
	samp += texture(p_sampler, p_triplanar_pos.xz) * p_weights.y;
	samp += texture(p_sampler, p_triplanar_pos.zy) * p_weights.x;
	return samp;
}

void fragment() {
	// ดึงค่าจาก Standard Material มาใช้ (สี, ความใส, ความเงา ปรับใน Inspector ได้เลย)
	// แต่ดึง Normal มาทำให้ขยับ
	NORMAL_MAP = triplanar_texture(texture_normal, uv1_power_normal, uv1_triplanar_pos).rgb;
}