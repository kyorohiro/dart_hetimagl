part of hetimagl;

class Vector4 {
  List<double> _binary;

  double get x => _binary[0];
  double get y => _binary[1];
  double get z => _binary[2];
  double get w => _binary[3];

  Vector4.zero() {
    _binary = new List.from([0.0, 0.0, 0.0, 0.0], growable: false);
  }

  Vector4.create(List<double> elements) {
    if (elements.length != 4) {
      throw new Exception("");
    }
    _binary = new List.from(elements, growable: false);
  }

  static Vector4 matrixProduct(Matrix4 a, Vector4 b, [Vector4 out = null]) {
    if (out == null) {
      out = new Vector4.zero();
    }
    int ROW = 4;
    for (int c = 0; c < 4; c++) {
      out._binary[c] = a._binary[c * ROW + 0] * b._binary[0] +
          a._binary[c * ROW + 1] * b._binary[1] +
          a._binary[c * ROW + 2] * b._binary[2] +
          a._binary[c * ROW + 3] * b._binary[3];
    }
    return out;
  }

  static double innerProduct(Vector4 a, Vector4 b) {
    double ret = 0.0;
    for (int i = 0; i < 4; i++) {
      ret += a._binary[i] * b._binary[i];
    }
    return ret;
  }

  static double scalarProduct(Vector4 a, double b) {
    double ret = 0.0;
    for (int i = 0; i < 4; i++) {
      ret += a._binary[i] * b;
    }
    return ret;
  }

  static double scalarProduct_(double b, Vector4 a) {
    return scalarProduct(a, b);
  }

  static Vector4 normalize(Vector4 a) {
    double l = Vector4.length(a);
    if (l == 0) {
      throw new Exception("");
    }
    return new Vector4.create([
      a._binary[0] / l,
      a._binary[1] / l,
      a._binary[2] / l,
      a._binary[3] / l
    ]);
  }



  static double length(Vector4 a) {
    double ret = 0.0;
    for (int i = 0; i < 4; i++) {
      ret += a._binary[i] * a._binary[i];
    }
    return math.sqrt(ret);
  }

  static Vector4 sub(Vector4 a, Vector4 b, [Vector4 out = null]) {
    if (out == null) {
      out = new Vector4.zero();
    }
    for (int i = 0; i < 4; i++) {
      out._binary[i] = a._binary[i] - b._binary[i];
    }
    return out;
  }

  static Vector4 add(Vector4 a, Vector4 b, [Vector4 out = null]) {
    if (out == null) {
      out = new Vector4.zero();
    }
    for (int i = 0; i < 4; i++) {
      out._binary[i] = a._binary[i] + b._binary[i];
    }
    return out;
  }

  Vector3 toVector3() {
    return new Vector3.create([x, y, z]);
  }

  String debugInfo() {
    return "${_binary[0]} ${_binary[1]} ${_binary[2]} ${_binary[3]}\n";
  }
}
