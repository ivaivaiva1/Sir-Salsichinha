shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform int red_levels : hint_range(2, 16) = 5;    // Níveis de tons para o canal vermelho
uniform int green_levels : hint_range(2, 16) = 4;  // Níveis de tons para o canal verde
uniform int blue_levels : hint_range(2, 16) = 5;   // Níveis de tons para o canal azul
uniform float saturation : hint_range(0.0, 1.0) = 0.85; // Controle de saturação, 0 = sem cor, 1 = cor original

void fragment() {
    // Obtém a cor da tela no ponto atual
    vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);

    // Limita cada canal de cor para emular a paleta do NES
    screen_color.r = floor(screen_color.r * float(red_levels)) / float(red_levels - 1);
    screen_color.g = floor(screen_color.g * float(green_levels)) / float(green_levels - 1);
    screen_color.b = floor(screen_color.b * float(blue_levels)) / float(blue_levels - 1);

    // Calcula a luminância (valor em tons de cinza)
    float gray = dot(screen_color.rgb, vec3(0.3, 0.59, 0.11)); // Pesos comuns para luminosidade

    // Mistura a cor quantizada com a luminância para ajustar a saturação
    screen_color.rgb = mix(vec3(gray), screen_color.rgb, saturation);

    // Define a cor final do fragmento com a cor da tela modificada
    COLOR = screen_color;
}