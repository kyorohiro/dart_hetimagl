import 'dart:html' as html;
import 'dart:web_gl' as webgl;
import 'dart:typed_data' as data;
import 'package:hetimagl/hetimagl.dart' as hetimagl;

void main() {
  var canvas = new html.CanvasElement(width: 500, height: 500);
  html.document.body.append(canvas);

  webgl.RenderingContext GL = canvas.getContext3d();
  double r = 0.6;
  double g = 0.2;
  double b = 0.2;
  double a = 1.0;
  GL.clearColor(r, g, b, a);
  GL.clear(webgl.RenderingContext.COLOR_BUFFER_BIT);
  //
  // setup shader
  //
  webgl.Shader vertexShader = hetimagl.loadShader(GL, webgl.RenderingContext.VERTEX_SHADER, 
      "attribute vec3 vertexPosition;\n"+
      "void main() {\n"+
      "  gl_Position = vec4(vertexPosition,1.0);\n"+
      "}\n");

  webgl.Shader fragmentShader = hetimagl.loadShader(GL, webgl.RenderingContext.FRAGMENT_SHADER, 
      "precision mediump float;\n"+ 
      "void main() {\n"+
      " float c = gl_FragCoord.y / 500.0;\n"+
      " gl_FragColor = vec4(c,c,c,1.0);\n"+
      "}\n");

  webgl.Program shaderProgram = GL.createProgram();
  hetimagl.linkShader(GL, shaderProgram, vertexShader, fragmentShader);
  GL.useProgram(shaderProgram);

  //
  webgl.Buffer rectBuffer = GL.createBuffer();
  GL.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, rectBuffer);
  GL.bufferData(
      webgl.ARRAY_BUFFER,
      new data.Float32List.fromList([
          -0.5, 0.5, 0.0, // 左上 x, y, z
          -0.5, -0.5, 0.0, // 左下
          0.5, 0.5, 0.0, // 右上
          0.5, -0.5, 0.0]), // 右下
      webgl.RenderingContext.STATIC_DRAW);

  webgl.Buffer rectIndexBuffer = GL.createBuffer();
  GL.bindBuffer(webgl.ELEMENT_ARRAY_BUFFER, rectIndexBuffer);
  GL.bufferDataTyped(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER,
      new data.Uint16List.fromList([0,1,2, 1,3,2]), webgl.RenderingContext.STATIC_DRAW);

  int locationVertexPosition = GL.getAttribLocation(shaderProgram, "vertexPosition");
  GL.vertexAttribPointer(locationVertexPosition, 3, webgl.RenderingContext.FLOAT, false, 0, 0);

  
  GL.enableVertexAttribArray(locationVertexPosition);
  GL.drawElements(webgl.RenderingContext.TRIANGLES, 6, webgl.RenderingContext.UNSIGNED_SHORT, 0);
}
