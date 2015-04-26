import 'dart:async' as async;

class Token {

}


abstract class Command {
  void check();
}

class MatchCommand extends Command {
  void check() {
    ;
  }
}

class CharCommand extends Command {
  void check() {
    ;
  }
}

class Task {

}

class RegexVM {
  List<Command> _commands = [];
  List<Task> task = [];
  
  RegexVM.createFromCommand(List<Command> command) {
    _commands = new List.from(command);
  }

  void addCommand(Command command) {
    _commands.add(command);
  }

  async.Future<bool> match(List<int> text) {
    
  }
}
