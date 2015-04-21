part of hetimagl;

class Matrix4 {
  List<double> _binary;

  double get m11 => _binary[0]; 
  double get m12 => _binary[1]; 
  double get m13 => _binary[2]; 
  double get m14 => _binary[3]; 
  double get m21 => _binary[4]; 
  double get m22 => _binary[5]; 
  double get m23 => _binary[6]; 
  double get m24 => _binary[7]; 
  double get m31 => _binary[8]; 
  double get m32 => _binary[9]; 
  double get m33 => _binary[10]; 
  double get m34 => _binary[11]; 
  double get m41 => _binary[12]; 
  double get m42 => _binary[13]; 
  double get m43 => _binary[14]; 
  double get m44 => _binary[15]; 


  Matrix4.create(List<double> elements) {
    if(elements.length != 16) {
      throw new Exception("");
    }
    _binary = new List.from(elements, growable:false);
  }

  Matrix4.identity() {
    _binary = new List.from(
        [
          1.0, 0.0, 0.0, 0.0,
          0.0, 1.0, 0.0, 0.0,
          0.0, 0.0, 1.0, 0.0,
          0.0, 0.0, 0.0, 1.0
        ], growable:false);    
  }
  Matrix4.zero() {
    _binary = new List.from(
        [
          0.0, 0.0, 0.0, 0.0,
          0.0, 0.0, 0.0, 0.0,
          0.0, 0.0, 0.0, 0.0,
          0.0, 0.0, 0.0, 0.0
        ], growable:false);
  }

  Matrix4.scale(num x, num y, num z) {
    _binary = new List.from(
        [
          x, 0.0, 0.0, 0.0,
          0.0, y, 0.0, 0.0,
          0.0, 0.0, z, 0.0,
          0.0, 0.0, 0.0, 1.0,        
        ], growable:false);
  }

  Matrix4.lookAt(Vector3 eye,Vector3 focus, Vector3 up) {
    Vector3 z = Vector3.sub(eye, focus);
    Vector3 x = Vector3.outerProduct(up, Vector3.normalize(z));
    Vector3 y = Vector3.outerProduct(Vector3.normalize(z), Vector3.normalize(x));

    double rotateEyeX = -1.0*Vector3.innerProduct(x,eye);
    double rotateEyeY = -1.0*Vector3.innerProduct(y,eye);
    double rotateEyeZ = -1.0*Vector3.innerProduct(z,eye);
    _binary = <double>[
      x._binary[0], x._binary[1], x._binary[2], rotateEyeX,
      y._binary[0], y._binary[1], y._binary[2], rotateEyeY,
      z._binary[0], z._binary[1], z._binary[2], rotateEyeZ,
      0.0, 0.0, 0.0, 1.0
      ];
  }

  // http://en.wikipedia.org/wiki/Orthographic_projection
  Matrix4.orthogonalProjection(
      double left, double right, double bottom, double top,
      double near, double far) {
    Matrix4 tra = new Matrix4.translation(-1*(right+left)/2, -1*(top+bottom)/2, (far+near)/2);
    Matrix4 sca = new Matrix4.scale(2.0/(right-left), 2.0/(top-bottom), -1*2.0/(far-near));// 2.0 is max screen size (-1.0 <----> 1.0)
    _binary = new List.from(Matrix4.matrixProduct(tra, sca)._binary, growable:false);
  }

  Matrix4.perspectiveMatrix(
      double left, double right, double bottom, double top,
      double near, double far) {
    _binary  = <double>[
          2.0*near/(right-left), 0.0, (right+left)/(right-left), 0.0,
          0.0, 2.0*near/(top-bottom), (top+bottom)/(top-bottom), 0.0,
          0.0, 0.0, -1.0*(far+near)/(far-near), -2.0*far*near/(far-near),
          0.0, 0.0, -1.0, 0.0
        ];
  }

  Matrix4.translation(num x, num y, num z) {
    _binary = new List.from(
        [
          1.0, 0.0, 0.0, x,
          0.0, 1.0, 0.0, y,
          0.0, 0.0, 1.0, z,
          0.0, 0.0, 0.0, 1.0,        
        ], growable:false);
  }

  Matrix4.rotationX(num radian) {
    _binary = new List.from(
        [
          1.0, 0.0, 0.0, 0.0,
          0.0, math.cos(radian), -1*math.sin(radian), 0.0,
          0.0, math.sin(radian),    math.cos(radian), 0.0,
          0.0, 0.0, 0.0, 1.0,
        ], growable:false);
  }

  Matrix4.rotationY(num radian) {
    _binary = new List.from(
        [
          math.cos(radian),    0.0, math.sin(radian), 0.0,
          0.0, 1.0, 0.0, 0.0,
          -1*math.sin(radian), 0.0, math.cos(radian), 0.0,
          0.0, 0.0, 0.0, 1.0,
        ], growable:false);
  }

  Matrix4.rotationZ(num radian) {
   _binary = new List.from(
        [
          math.cos(radian), -math.sin(radian), 0.0, 0.0,
          math.sin(radian), math.cos(radian), 0.0, 0.0,
          0.0, 0.0, 1.0, 0.0,
          0.0, 0.0, 0.0, 1.0,
        ], growable:false);
  }

  static Matrix4 scalarProduct(Matrix4 a, double b, [Matrix4 out = null]) {
    if(out == null) {
      out = new Matrix4.zero();
    }
    for(int i=0;i<16;i++) {
      out._binary[i] = a._binary[i] * b;
    }
    return out;
  }
  
  static Matrix4 matrixProduct(Matrix4 a, Matrix4 b, [Matrix4 out = null]) {
    if(out == null) {
      out = new Matrix4.zero();
    }
    int ROW = 4;
    for(int r=0;r<4;r++) {
      for(int c=0;c<4;c++) {
        out._binary[r*ROW+c] = 
            a._binary[r*ROW+0]*b._binary[c+ROW*0]
           +a._binary[r*ROW+1]*b._binary[c+ROW*1]
           +a._binary[r*ROW+2]*b._binary[c+ROW*2]
           +a._binary[r*ROW+3]*b._binary[c+ROW*3];
      }
    }
    return out;
  }


  static Matrix4 add(Matrix4 a, Matrix4 b, [Matrix4 out = null]) {
    if(out == null) {
      out = new Matrix4.zero();
    }
    for(int i=0;i<16;i++) {
        out._binary[i] = a._binary[i] + b._binary[i];
    }
    return out;
  }

  static Matrix4 sub(Matrix4 a, Matrix4 b, [Matrix4 out = null]) {
    if(out == null) {
      out = new Matrix4.zero();
    }
    for(int i=0;i<16;i++) {
        out._binary[i] = a._binary[i] - b._binary[i];
    }
    return out;
  }

  static Matrix4 orthogonal(Matrix4 a, [Matrix4 out = null]) {
    if(out == null) {
      out = new Matrix4.zero();
    }
    int ROW = 4;
    for(int r=0;r<4;r++) {
      for(int c=0;c<4;c++) {
        out._binary[r*ROW+c] = a._binary[c*ROW+r];
      }
    }
    return out;
  }

  static Matrix4 transposed(Matrix4 a, [Matrix4 out = null]) {
    if(out == null) {
      out = new Matrix4.zero();
    }
    int ROW = 4;
    for(int r=0;r<4;r++) {
      for(int c=0;c<4;c++) {
        out._binary[r*ROW+c] = a._binary[c*ROW+r];
      }
    }
    return out;
  }

  tdata.Float32List toWebGLBuffer() {
    return new tdata.Float32List.fromList(transposed(this)._binary);
  }
  
  String debugInfo() {
    String v = "";
    int ROW = 4;
    for(int r=0;r<4;r++) {
      v += "${_binary[r*ROW+0]} ${_binary[r*ROW+1]} ${_binary[r*ROW+2]} ${_binary[r*ROW+3]}\n";
    }
    return v;
  }
}