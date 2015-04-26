part of hetimaregex;

/*
import 'dart:async' as async;
import 'package:hetima/hetima.dart' as heti;
 */

class Token {}

abstract class Command {
  bool isMatched() {
    return false;
  }
  bool isSave() {
    return false;
  }
  async.Future<List<int>> check(RegexVM vm, heti.EasyParser parser);
}

class MatchCommand extends Command {
  bool isMatched() {
    return true;
  }

  async.Future<List<int>> check(RegexVM vm, heti.EasyParser parser) {
    return null;
  }
}

class JumpTaskCommand extends Command {
  static final int LM1 = -1;
  static final int L0 = 0;
  static final int L1 = 1;
  static final int L2 = 2;
  static final int L3 = 3;
  int _pos1 = 0;

  JumpTaskCommand.create(int pos1) {
    _pos1 = pos1;
  }

  async.Future<List<int>> check(RegexVM vm, heti.EasyParser parser) {
    async.Completer<List<int>> c = new async.Completer();
    Task currentTask = vm.getCurrentTask();
    if (currentTask == null) {
      throw new Exception("");
    }

    int currentPos = currentTask._commandPos;
    currentTask._commandPos = currentPos + _pos1;
    c.complete([]);
    return c.future;
  }
}

class SplitTaskCommand extends Command {
  static final int LM1 = -1;
  static final int L0 = 0;
  static final int L1 = 1;
  static final int L2 = 2;
  static final int L3 = 3;
  int _pos1 = 0;
  int _pos2 = 0;

  SplitTaskCommand.create(int pos1, int pos2) {
    _pos1 = pos1;
    _pos2 = pos2;
  }

  async.Future<List<int>> check(RegexVM vm, heti.EasyParser parser) {
    async.Completer<List<int>> c = new async.Completer();
    Task currentTask = vm.getCurrentTask();
    if (currentTask == null) {
      throw new Exception("");
    }

    int currentPos = currentTask._commandPos;
    currentTask._commandPos = currentPos + _pos1;
    vm.addTask(new Task.fromCommnadPos(currentPos + _pos2, parser));

    c.complete([]);
    return c.future;
  }
}

class CharCommand extends Command {
  List<int> _expect = [];
  CharCommand.createFromList(List<int> v) {
    _expect = new List.from(v);
  }

  async.Future<List<int>> check(RegexVM vm, heti.EasyParser parser) {
    async.Completer<List<int>> c = new async.Completer();
    int length = _expect.length;
    parser.push();
    parser.nextBuffer(length).then((List<int> v) {
      if (v.length != length) {
        parser.back();
        parser.pop();
        c.completeError(new Exception(""));
        return;
      }
      for (int i = 0; i < length; i++) {
        if (_expect[i] != v[i]) {
          parser.back();
          parser.pop();
          c.completeError(new Exception(""));
          return;
        }
      }
      parser.pop();
      Task t = vm.getCurrentTask();
      t._commandPos++;
      c.complete(v);
    });
    return c.future;
  }
}

class Task {
  int _commandPos = 0;
  heti.EasyParser _parser = null;
  int get commandPos => _commandPos;

  Task.fromCommnadPos(int commandPos, heti.EasyParser parser) {
    _commandPos = commandPos;
    _parser = parser.toClone();
  }

  async.Future<List<List<int>>> match(RegexVM vm) {
    async.Completer completer = new async.Completer();
    List<List<int>> ret = [];
    a() {
      if (_commandPos > vm._commands.length) {
        completer.completeError(new Exception(""));
        return;
      }

      Command c = vm._commands[_commandPos];
      if (c.isMatched() == true) {
        completer.complete(ret);
      } else {
        c.check(vm, _parser).then((List<int> v) {
          if (c.isSave() == true) {
            ret.add(v);
          }
          a();
        }).catchError((e) {
          completer.completeError(e);
        });
      }
    }
    a();
    return completer.future;
  }
}

class RegexVM {
  List<Command> _commands = [];
  List<Task> _tasks = [];

  RegexVM.createFromCommand(List<Command> command) {
    _commands = new List.from(command);
  }

  void addCommand(Command command) {
    _commands.add(command);
  }

  void addTask(Task task) {
    _tasks.add(task);
  }

  Task getCurrentTask() {
    if (_tasks.length > 0) {
      return _tasks[0];
    } else {
      return null;
    }
  }

  Task popCurrentTask() {
    if (_tasks.length > 0) {
      Task t = _tasks[0];
      _tasks.removeAt(0);
      return t;
    } else {
      return null;
    }
  }

  async.Future<List<List<int>>> match(List<int> text) {
    async.Completer completer = new async.Completer();
    List<List<int>> ret = [];
    heti.EasyParser parser =
        new heti.EasyParser(new heti.ArrayBuilder.fromList(text, true));
    _tasks.add(new Task.fromCommnadPos(0, parser));

    a() {
      Task task = getCurrentTask();
      if (task == null) {
        completer.completeError(new Exception());
        return;
      }
      task.match(this).then((List<List<int>> v) {
        completer.complete(v);
      }).catchError((e) {
        popCurrentTask();
        a();
      });
    }
    ;
    a();
    return completer.future;
  }
}
