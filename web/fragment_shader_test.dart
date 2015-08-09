import 'dart:html' as html;
import 'dart:web_gl' as webgl;
import 'dart:typed_data' as data;
import 'dart:async';

void main() {
  var canvas = new html.CanvasElement(width: 500, height: 500);
  html.document.body.append(canvas);
  double x = 0.0;
  double y = 0.0;
  canvas.onMouseMove.listen((html.MouseEvent e) {
    html.Rectangle t =  canvas.getBoundingClientRect();
    x = e.clientX - t.left;
    y = e.clientY - t.top;
  });

  webgl.RenderingContext GL = canvas.getContext3d();

  // setup shader
  webgl.Shader vertexShader = loadShader(GL,
      webgl.RenderingContext.VERTEX_SHADER,
          "attribute vec3 vp;\n" +
          "void main() {\n" +
          "  gl_Position = vec4(vp, 1.0);\n" +
          "}\n");

  webgl.Shader fragmentShader = loadShader(GL,
      webgl.RenderingContext.FRAGMENT_SHADER, 
      "precision mediump float;\n" +
      "uniform float t;\n" +
      "uniform float x;\n" +
      "uniform float y;\n" +
          "void main() {\n" +
          " float r = (cos(t)+1.0)/2.0;\n"
          " float g = (sin(t)+1.0)/2.0;\n"
          " gl_FragColor = vec4(r, x/500.0,y/500.0,t);\n" +
          "}\n");

  webgl.Program shaderProgram = GL.createProgram();
  GL.attachShader(shaderProgram, fragmentShader);
  GL.attachShader(shaderProgram, vertexShader);
  GL.linkProgram(shaderProgram);
  GL.useProgram(shaderProgram);

  if (false ==
      GL.getProgramParameter(
          shaderProgram, webgl.RenderingContext.LINK_STATUS)) {
    String message = "alert: Failed to linked shader";
    throw new Exception("${message}\n");
  }

  //
  // setup
  // leftup (x, y, z), leftdown, rightup, rightdown
  data.TypedData rectData = new data.Float32List.fromList(
      [-0.8, 0.8, 0.0, -0.8, -0.8, 0.0, 0.8, 0.8, 0.0, 0.8, -0.8, 0.0]);
  data.TypedData rectDataIndex =
      new data.Uint16List.fromList([0, 1, 2, 1, 3, 2]);

  webgl.Buffer rectBuffer = GL.createBuffer();
  GL.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, rectBuffer);
  GL.bufferData(
      webgl.ARRAY_BUFFER, rectData, webgl.RenderingContext.STATIC_DRAW);

  webgl.Buffer rectIndexBuffer = GL.createBuffer();
  GL.bindBuffer(webgl.ELEMENT_ARRAY_BUFFER, rectIndexBuffer);
  GL.bufferDataTyped(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, rectDataIndex,
      webgl.RenderingContext.STATIC_DRAW);

  //
  // draw

  int startTime = new DateTime.now().millisecondsSinceEpoch;
  int count = 0;
  render(_) {
    count++;
    GL.clearColor(0.6, 0.2, 0.2, 1.0);
    GL.clear(webgl.RenderingContext.COLOR_BUFFER_BIT);

    int locationVertexPosition = GL.getAttribLocation(shaderProgram, "vp");
    GL.vertexAttribPointer(
        locationVertexPosition, 3, webgl.RenderingContext.FLOAT, false, 0, 0);
    GL.enableVertexAttribArray(locationVertexPosition);

    int lastTime = new DateTime.now().millisecondsSinceEpoch;
    double t = (lastTime - startTime) *0.001;
    //print("##${t}");

    webgl.UniformLocation timeLocation = GL.getUniformLocation(shaderProgram, "t");
    GL.uniform1f(timeLocation, t);
    
    webgl.UniformLocation mouseX = GL.getUniformLocation(shaderProgram, "x");
    webgl.UniformLocation mouseY = GL.getUniformLocation(shaderProgram, "y");
    GL.uniform1f(mouseX, x);
    GL.uniform1f(mouseY, y);

    GL.drawElements(webgl.RenderingContext.TRIANGLES, 6,
        webgl.RenderingContext.UNSIGNED_SHORT, 0);

    new Future.delayed(new Duration(milliseconds:10)).then((render));
    if(count %100 == 0) {
      print("fps=${count/t.toInt()};x=${x};y=${y}");
    }
  }

  render(0);
}

webgl.Shader loadShader(webgl.RenderingContext context, int type, var src) {
  webgl.Shader shader = context.createShader(type);
  context.shaderSource(shader, src);
  context.compileShader(shader);
  if (false ==
      context.getShaderParameter(
          shader, webgl.RenderingContext.COMPILE_STATUS)) {
    String message =
        "Error compiling shader ${context.getShaderInfoLog(shader)}";
    context.deleteShader(shader);
    throw new Exception("${message}\n");
  }
  return shader;
}
