import 'dart:html' as html;
import 'dart:web_gl' as webgl;
import 'dart:typed_data' as data;
import 'dart:async';

class Stage {
  html.CanvasElement _canvas = null;
  html.CanvasElement get canvas => _canvas;
  webgl.RenderingContext GL = null;
  webgl.Shader vertexShader = null;
  webgl.Shader fragmentShader = null;
  webgl.Program shaderProgram = null;

  Stage({int width: 500, height: 500}) {
    _canvas = new html.CanvasElement(width: width, height: height);
    html.document.body.append(_canvas);
  }

  Scene _scene = null;
  changeScene(Scene scene) {
    _scene = scene;
  }

  Future init() async {
    GL = _canvas.getContext3d();
    GL.clearColor(0.6, 0.2, 0.2, 1.0);
    GL.clear(webgl.RenderingContext.COLOR_BUFFER_BIT);

    // setup shader
    vertexShader = loadShader(GL, webgl.RenderingContext.VERTEX_SHADER,
        "attribute vec3 vp;\n" +
            "void main() {\n" +
            "  gl_Position = vec4(vp, 1.0);\n" +
            "}\n");

    fragmentShader = loadShader(GL, webgl.RenderingContext.FRAGMENT_SHADER,
        "precision mediump float;\n" +
            "void main() {\n" +
            " gl_FragColor = vec4(0.0,1.0,0.0,1.0);\n" +
            "}\n");

    shaderProgram = GL.createProgram();
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
  }

  Future start([int interval = 10]) async {
    int startTime = new DateTime.now().millisecondsSinceEpoch;
    int count = 0;
    update() async {
      count++;
      int lastTime = new DateTime.now().millisecondsSinceEpoch;
      double t = (lastTime - startTime) * 0.001;
      await new Future.delayed(new Duration(milliseconds: interval));
      await _scene.draw(this);

      if (count % 100 == 0) {
        print("fps=${count/t.toInt()} ${count} ${t}");
      }
      update();
    }
    update();
  }

  Future<Scene> createScene() async {
    return new Scene();
  }
}

class DisplayObject {}

class Scene {
  draw(Stage stage) {
    webgl.RenderingContext GL = stage.canvas.getContext3d();
    GL.clearColor(0.6, 0.2, 0.2, 1.0);
    GL.clear(webgl.RenderingContext.COLOR_BUFFER_BIT);
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
    GL.bufferDataTyped(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER,
        rectDataIndex, webgl.RenderingContext.STATIC_DRAW);

    //
    // draw
    int locationVertexPosition =
        GL.getAttribLocation(stage.shaderProgram, "vp");
    GL.vertexAttribPointer(
        locationVertexPosition, 3, webgl.RenderingContext.FLOAT, false, 0, 0);
    GL.enableVertexAttribArray(locationVertexPosition);
    GL.drawElements(webgl.RenderingContext.TRIANGLES, 6,
        webgl.RenderingContext.UNSIGNED_SHORT, 0);
  }
}

void main() {
  main_a();
}

Future main_a() async {
  Stage stage = new Stage();
  await stage.init();
  stage.changeScene(await stage.createScene());
  await stage.start();

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
