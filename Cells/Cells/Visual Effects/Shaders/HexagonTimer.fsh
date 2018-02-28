void main()
{

  // Black/Green Hypnosis Shader
    
//  // Get coordinates and change ranges from (0.0,1.0) to (-1.0,1.0)
//    vec4 val = texture2D(u_texture, v_tex_coord);
//    vec2 uv = v_tex_coord * 2.0 - 1.0;
//
//  // Circular patterns using sin of the distance from fragment to center
//  //   We use time as a way to make the pattern move
//    float len = sin(16. * length(uv) - u_time * 4. ) * 0.5 + 0.5 ;
//  //   Color of the fragment depends on where it falls in the pattern
//    vec3 col = vec3(len) * vec3(0.,0.98,.0);
//  //   Set fragment color
//    gl_FragColor = val.a * vec4(col,1);
    
    
// Flip Texture Shader
    
//  // Get coordinates of corresponding spot in texture, then invert it
//    vec2 uv = v_tex_coord;
//    uv.y = 1 - uv.y;
//  // Texture is now upside-down (but has no horizontal flip)
//    vec4 texColor = texture2D(u_texture,uv);
//    gl_FragColor = texColor;

    
// Wave Shader
    
    // Get coordinates. Execute transforms based on Sin and Cos of time and position
    // in order to distort the texture.
//    vec2 uv = v_tex_coord;
//    uv.y += (cos((uv.y + (u_time * 0.4)) * 45.0) * 0.008) +
//    (cos((uv.y + (u_time * 0.2)) * 10.0) * 0.008);
//
//    uv.x += (sin((uv.y + (u_time * 0.07)) * 15.0) * 0.01) +
//    (sin((uv.y + (u_time * 0.2)) * 15.0) * 0.008);
//
//    vec4 texColor = texture2D(u_texture,uv);
//
//    gl_FragColor = texColor;
    

// Timer Shader
    // Uniforms: u_gradient - Hexagon with balck to white radial gradient
    // Attributes: a_time_to_live - Time to completely fill the hexagon with the timer

    // Load the pixel from our original texture, and the same place in the gradient hexagon
    vec4 val = texture2D(u_texture, v_tex_coord);
    vec4 grad = texture2D(u_gradient, v_tex_coord);

    // a_timep : Attribute with percentage of lifetime left

    // [1 - TIME CHECK] The gradient image has a black value less than the remaining time AND
    // [2 - MASKING] The hexagon and gradient pixel are not transparent
    if (grad.r < a_timep && grad.a * val.a > 0.99) {

    // Lower brightness for all pixels matching the above conditions
        vec3 pixelColor = val.rgb / val.a;
        pixelColor -= vec3(0.45 * a_timep);
        gl_FragColor = vec4(pixelColor, val.a);
    } else {
    //Otherwise, just leave the original color
        gl_FragColor = val;
    }
    
    
//    // COMBINED SHADER
//
//    // Wave Shader
//
//    // Get coordinates. Execute transforms based on Sin and Cos of time and position
//    // in order to distort the texture.
//        vec2 uv = v_tex_coord;
//        uv.y += (cos((uv.y + (u_time * 0.4)) * 45.0) * 0.008) +
//        (cos((uv.y + (u_time * 0.2)) * 10.0) * 0.008);
//
//        uv.x += (sin((uv.y + (u_time * 0.07)) * 15.0) * 0.01) +
//        (sin((uv.y + (u_time * 0.2)) * 15.0) * 0.008);
//
//
//    // Timer Shader
//        // Uniforms: u_gradient - Hexagon with balck to white radial gradient
//        // Attributes: a_time_to_live - Time to completely fill the hexagon with the timer
//
//        // Load the pixel from our original texture, and the same place in the gradient hexagon
//        vec4 val = texture2D(u_texture, uv);
//        vec4 grad = texture2D(u_gradient, uv);
//
//        // a_timep : Attribute with percentage of lifetime left
//
//        // [1 - TIME CHECK] The gradient image has a black value less than the remaining time AND
//        // [2 - MASKING] The hexagon and gradient pixel are not transparent
//        if (grad.r < a_timep && grad.a * val.a > 0.99) {
//
//        // Lower brightness for all pixels matching the above conditions
//            vec3 pixelColor = val.rgb / val.a;
//            pixelColor -= vec3(0.45 * a_timep);
//            gl_FragColor = vec4(pixelColor, val.a);
//        } else {
//        //Otherwise, just leave the original color
//            gl_FragColor = val;
//        }



    
}
