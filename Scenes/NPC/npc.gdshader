shader_type canvas_item;

void fragment() {
    // Get the exact alpha (transparency) of the sprite
    vec4 tex_color = texture(TEXTURE, UV);
    // Replace all colored pixels with white, keep the alpha
    COLOR = vec4(1.0, 1.0, 1.0, tex_color.a);
}