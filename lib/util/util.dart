part of hetimagl;

webgl.Shader loadShader(webgl.RenderingContext context, int type, var src) {
  webgl.Shader shader = context.createShader(type);
  context.shaderSource(shader, src);
  context.compileShader(shader);
  if (false == context.getShaderParameter(shader, webgl.RenderingContext.COMPILE_STATUS)) {
    String message = "Error compiling shader ${context.getShaderInfoLog(shader)}";
    throw new Exception("${message}\n");
    context.deleteShader(shader);
    return null;
  }
  return shader;
}

void linkShader(webgl.RenderingContext context, webgl.Program shaderProgram, webgl.Shader vertexShader, webgl.Shader fragmentShader) {
  context.attachShader(shaderProgram, vertexShader);
  context.attachShader(shaderProgram, fragmentShader);
  context.linkProgram(shaderProgram);
  if (false == context.getProgramParameter(shaderProgram, webgl.RenderingContext.LINK_STATUS)) {
    String message = "alert: Failed to linked shader: ${context.getProgramInfoLog(shaderProgram)}";
    throw new Exception("${message}\n");
  }
}
