import 'dart:html' as html;
import 'dart:web_gl' as webgl;
import 'dart:typed_data' as data;
import 'package:hetimagl/hetimagl.dart' as hetimagl;

void main() {
  var canvas = new html.CanvasElement(width: 500, height: 500);
  html.document.body.append(canvas);

  webgl.RenderingContext GL = canvas.getContext3d();
  GL.clearColor(0.6, 0.2, 0.2, 1.0);
  GL.clear(webgl.RenderingContext.COLOR_BUFFER_BIT);

  // setup shader
  webgl.Shader vertexShader = loadShader(GL, webgl.RenderingContext.VERTEX_SHADER, 
          "attribute vec3 vp;\n" +
          "void main() {\n" +
          "  gl_Position = vec4(vp, 1.0);\n" +
          "}\n");

  webgl.Shader fragmentShader = loadShader(GL, webgl.RenderingContext.FRAGMENT_SHADER, 
          "precision mediump float;\n" +
          "void main() {\n" +
          " gl_FragColor = vec4(0.0,1.0,0.0,1.0);\n" +
          "}\n");

  webgl.Program shaderProgram = GL.createProgram();
  GL.attachShader(shaderProgram, fragmentShader);
  GL.attachShader(shaderProgram, vertexShader);
  GL.linkProgram(shaderProgram);
  GL.useProgram(shaderProgram);

  if (false == GL.getProgramParameter(shaderProgram, webgl.RenderingContext.LINK_STATUS)) {
    String message = "alert: Failed to linked shader";
    throw new Exception("${message}\n");
  }

  //
  // setup
  // leftup (x, y, z), leftdown, rightup, rightdown
  data.TypedData rectData = new data.Float32List.fromList([-0.8, 0.8, 0.0, -0.8, -0.8, 0.0, 0.8, 0.8, 0.0, 0.8, -0.8, 0.0]);
  data.TypedData rectDataIndex = new data.Uint16List.fromList([0, 1, 2, 1, 3, 2]);

  webgl.Buffer rectBuffer = GL.createBuffer();
  GL.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, rectBuffer);
  GL.bufferData(webgl.ARRAY_BUFFER, rectData, webgl.RenderingContext.STATIC_DRAW);

  webgl.Buffer rectIndexBuffer = GL.createBuffer();
  GL.bindBuffer(webgl.ELEMENT_ARRAY_BUFFER, rectIndexBuffer);
  GL.bufferDataTyped(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, rectDataIndex, webgl.RenderingContext.STATIC_DRAW);

  //
  // draw
  int locationVertexPosition = GL.getAttribLocation(shaderProgram, "vp");
  GL.vertexAttribPointer(locationVertexPosition, 3, webgl.RenderingContext.FLOAT, false, 0, 0);
  GL.enableVertexAttribArray(locationVertexPosition);
  GL.drawElements(webgl.RenderingContext.TRIANGLES, 6, webgl.RenderingContext.UNSIGNED_SHORT, 0);
}

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

