import 'dart:html' as html;
import 'dart:web_gl' as gl;

void main() {
  var canvas = new html.CanvasElement(width: 500, height: 500);
  html.document.body.append(canvas);
  gl.RenderingContext GL = canvas.getContext3d();
  int w = canvas.width;
  int h = canvas.height;
  GL.clearColor(0.6, 0.2, 0.2, 1.0);
  GL.viewport(0, 0, w, h);
  GL.clear(gl.RenderingContext.COLOR_BUFFER_BIT);
}
