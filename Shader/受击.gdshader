shader_type canvas_item;
render_mode blend_mix;

uniform bool is_hit = false;
const vec4 flash_color = vec4(1.0,1.0,1.0,0.3);

uniform float qiang_hua=0.0;
uniform vec4 outline_color : source_color = vec4(1.0);
const float outline_width = 1.0;

void fragment() {
	if (is_hit){
		vec4 tex = texture(TEXTURE, UV);
		COLOR = is_hit ? tex + flash_color * flash_color.a : tex;
		COLOR.a = tex.a;   // 保持原始透明
	}
	else if (qiang_hua>0.0)
	{
	float alpha = texture(TEXTURE, UV).a;
	if (alpha<0.01){
		vec2 px = TEXTURE_PIXEL_SIZE * outline_width;   // 单像素步长
    // 4 样板
    float a1 = texture(TEXTURE, UV + vec2( px.x, 0.0)).a;
    float a2 = texture(TEXTURE, UV + vec2(-px.x, 0.0)).a;
    float a3 = texture(TEXTURE, UV + vec2(0.0,  px.y)).a;
    float a4 = texture(TEXTURE, UV + vec2(0.0, -px.y)).a;

    float outline1 = max(max(a1, a2), max(a3, a4));  // 只要边缘
	if (outline1>0.01){
   		 COLOR = vec4(outline_color.rgb*qiang_hua,min(1,qiang_hua));
		}
	}

	
	}
  
}