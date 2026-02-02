shader_type canvas_item;

uniform float strength : hint_range(0.0, 5.0) = 0.5;
uniform float radius : hint_range(0.5, 3.0) = 1.0;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 pixel_size = SCREEN_PIXEL_SIZE * radius;

    vec4 original = texture(SCREEN_TEXTURE, uv);

    // Simple blur (9-tap)
    vec4 blur = vec4(0.0);
    blur += texture(SCREEN_TEXTURE, uv + pixel_size * vec2(-1.0, -1.0));
    blur += texture(SCREEN_TEXTURE, uv + pixel_size * vec2( 0.0, -1.0));
    blur += texture(SCREEN_TEXTURE, uv + pixel_size * vec2( 1.0, -1.0));
    blur += texture(SCREEN_TEXTURE, uv + pixel_size * vec2(-1.0,  0.0));
    blur += texture(SCREEN_TEXTURE, uv);
    blur += texture(SCREEN_TEXTURE, uv + pixel_size * vec2( 1.0,  0.0));
    blur += texture(SCREEN_TEXTURE, uv + pixel_size * vec2(-1.0,  1.0));
    blur += texture(SCREEN_TEXTURE, uv + pixel_size * vec2( 0.0,  1.0));
    blur += texture(SCREEN_TEXTURE, uv + pixel_size * vec2( 1.0,  1.0));
    blur /= 9.0;

    // Unsharp mask
    vec4 sharpened = original + (original - blur) * strength;

    COLOR = vec4(sharpened.rgb, original.a);
}