part of hetimagl;

class Vector3 {
  List<double> _binary;

  double get x => _binary[0];
  double get y => _binary[1];
  double get z => _binary[2];

  Vector3.zero() {
    _binary = new List.from([0.0, 0.0, 0.0], growable: false);
  }

  Vector3.create(List<double> elements) {
    if (elements.length != 3) {
      throw new Exception("");
    }
    _binary = new List.from(elements, growable: false);
  }

  //
  static Vector3 outerProduct(Vector3 a, Vector3 b, [Vector3 out = null]) {
    if (out == null) {
      out = new Vector3.zero();
    }
    out._binary[0] = a._binary[1] * b._binary[2] - a._binary[2] * b._binary[1];
    out._binary[1] = a._binary[2] * b._binary[0] - a._binary[0] * b._binary[2];
    out._binary[2] = a._binary[0] * b._binary[1] - a._binary[1] * b._binary[0];
    return out;
  }

  static double innerProduct(Vector3 a, Vector3 b) {
    double ret = 0.0;
    for (int i = 0; i < 3; i++) {
      ret += a._binary[i] * b._binary[i];
    }
    return ret;
  }

  static double scalarProduct(Vector3 a, double b) {
    double ret = 0.0;
    for (int i = 0; i < 3; i++) {
      ret += a._binary[i] * b;
    }
    return ret;
  }

  static double scalarProduct_(double b, Vector3 a) {
    return scalarProduct(a, b);
  }

  static double length(Vector3 a) {
    double ret = 0.0;
    for (int i = 0; i < 3; i++) {
      ret += a._binary[i] * a._binary[i];
    }
    return math.sqrt(ret);
  }

  static Vector3 normalize(Vector3 a, [Vector3 out = null]) {
    if (out == null) {
      out = new Vector3.zero();
    }
    double length = Vector3.length(a);
    if (length == 0) {
      throw new Exception("");
    }
    out._binary[0] = a._binary[0] / length;
    out._binary[1] = a._binary[1] / length;
    out._binary[2] = a._binary[2] / length;
    return out;
  }

  static Vector3 sub(Vector3 a, Vector3 b, [Vector3 out = null]) {
    if (out == null) {
      out = new Vector3.zero();
    }
    for (int i = 0; i < 3; i++) {
      out._binary[i] = a._binary[i] - b._binary[i];
    }
    return out;
  }

  static Vector3 add(Vector3 a, Vector3 b, [Vector3 out = null]) {
    if (out == null) {
      out = new Vector3.zero();
    }
    for (int i = 0; i < 3; i++) {
      out._binary[i] = a._binary[i] + b._binary[i];
    }
    return out;
  }

}
