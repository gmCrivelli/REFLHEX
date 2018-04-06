// Wave Shader

// Get coordinates. Execute transforms based on Sin and Cos of time and position
// in order to distort the texture.
    vec2 uv = v_tex_coord;
    uv.y += (cos((uv.y + (u_time * 0.4)) * 45.0) * 0.008) +
    (cos((uv.y + (u_time * 0.2)) * 10.0) * 0.008);

    uv.x += (sin((uv.y + (u_time * 0.07)) * 15.0) * 0.01) +
    (sin((uv.y + (u_time * 0.2)) * 15.0) * 0.008);

    vec4 texColor = texture2D(u_texture, uv);

    gl_FragColor = texColor;
