shader_type spatial;
render_mode unshaded;

uniform sampler2D screen_texture : source_color, hint_screen_texture, filter_nearest;
uniform sampler2D depth_texture : source_color, hint_depth_texture, filter_nearest;
uniform sampler2D normal_texture : source_color, hint_normal_roughness_texture, filter_nearest;

uniform float edge_threshold : hint_range(0, 1) = 0.1;
uniform float saturation_strength : hint_range(0, 1) = 2.05;
uniform float contrast_strength : hint_range(0, 1) = 2.05;

void vertex() {
    POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
    vec4 color = texture(screen_texture, SCREEN_UV);
    
    // Sample depth and normal textures
    float depth = texture(depth_texture, SCREEN_UV).r;
    vec3 normal = texture(normal_texture, SCREEN_UV).rgb;

    // Calculate edge strength
    float depth_diff_x = abs(depth - texture(depth_texture, SCREEN_UV + vec2(0.001, 0)).r);
    float depth_diff_y = abs(depth - texture(depth_texture, SCREEN_UV + vec2(0, 0.001)).r);
    float depth_edge = smoothstep(0.0, edge_threshold, depth_diff_x + depth_diff_y);

    vec3 normal_diff_x = abs(normal - texture(normal_texture, SCREEN_UV + vec2(0.001, 0)).rgb);
    vec3 normal_diff_y = abs(normal - texture(normal_texture, SCREEN_UV + vec2(0, 0.001)).rgb);
    float normal_edge = smoothstep(0.0, edge_threshold, length(normal_diff_x + normal_diff_y));

    // Combine edge strengths
    float edge = max(depth_edge, normal_edge);
    
    // Convert to linear color space
    vec3 linear_color = color.rgb / max(color.a, 0.0001);  // Avoid division by zero
    
    // Apply saturation
    vec3 gray = vec3(dot(vec3(0.2126, 0.7152, 0.0722), linear_color));
    vec3 saturated_color = mix(gray, linear_color, saturation_strength);
    
    // Apply contrast
    vec3 contrasted_color = (saturated_color - 0.55) * contrast_strength + 0.5;
    
    // Mix original color with edge-enhanced color based on edge strength
    vec3 final_color = mix(contrasted_color, linear_color, edge);
    
    // Output the final color
    ALBEDO = vec3(final_color);
}
