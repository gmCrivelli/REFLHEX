void main() {

    vec2 st = v_tex_coord;
    float pct = 0.0;

    // a. The DISTANCE from the pixel to the center
    pct = distance(st, vec2(0.5));

    // b. The LENGTH of the vector
    //    from the pixel to the center
//     vec2 toCenter = vec2(0.5)-st;
//     pct = length(toCenter);

    // c. The SQUARE ROOT of the vector
    //    from the pixel to the center
//     vec2 tC = vec2(0.5)-st;
//     pct = sqrt(tC.x*tC.x+tC.y*tC.y);

    vec3 color = vec3(step(pct, 0.1));

    gl_FragColor = vec4( color, 1.0 );

//    vec2 xy = gl_FragCoord.xy / iResolution;
//
//    vec2 uv = v_tex_coord
//
//    float newX = xy.x * sqrt(1 - xy.y * xy.y / 2);
//    float newY = xy.y * sqrt(1 - xy.x * xy.x / 2);
//
//    vec2 coords = vec2(newX, newY);
//
//    gl_FragColor = texture2D(u_texture, coords);

//    vec4 original = texture2D(u_texture, v_tex_coord);
//    // CRT Shader
//    // Calcula os pixels que devem aparecer baseado na posicao y do pixel
//
//    float multiplier = -sin(0.07 * u_time) * (50 * u_time);
//
//    float vertical = mod(coords.y + multiplier, 45.0) -  35.0;
//    float dist_squared = vertical * vertical;
//
//    // gl_FragColor é a cor final do pixel, aqui verificamos se o ponto pertence
//    // a parte interna de um circulo, e retornamos a cor, caso não pertença
//    // retornamos transparente
//    gl_FragColor = (dist_squared < 25.0) ? original - vec4(0.07, 0.07, 0.07, 0.0): original;

}
