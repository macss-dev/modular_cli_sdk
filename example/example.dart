import 'dart:io';

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Example CLI with two modules: greetings and math.
//
// Usage:
//   dart run example/example.dart greetings hello --name World
//   dart run example/example.dart greetings hello --name World --json
//   dart run example/example.dart math add --a 3 --b 7
//   dart run example/example.dart math add --a 3 --b 7 --json
//   dart run example/example.dart help
// ═══════════════════════════════════════════════════════════════════════════

Future<void> main(List<String> args) async {
  final code = await runExample(args);
  exit(code);
}

Future<int> runExample(List<String> args) async {
  final cli = ModularCli();

  cli.module('greetings', buildGreetingsModule);
  cli.module('math', buildMathModule);

  return cli.run(args);
}

// ── Greetings module ────────────────────────────────────────────────────────

void buildGreetingsModule(ModuleBuilder m) {
  m.command<HelloInput, HelloOutput>(
    'hello',
    (req) => HelloCommand(HelloInput.fromCliRequest(req)),
    description: 'Say hello to someone',
  );
}

class HelloInput extends Input {
  final String name;
  HelloInput({required this.name});

  factory HelloInput.fromCliRequest(CliRequest req) =>
      HelloInput(name: req.flagString('name') ?? 'World');

  @override
  Map<String, dynamic> toJson() => {'name': name};
}

class HelloOutput extends Output {
  final String greeting;
  HelloOutput({required this.greeting});

  @override
  Map<String, dynamic> toJson() => {'greeting': greeting};

  @override
  int get exitCode => ExitCode.ok;
}

class HelloCommand implements Command<HelloInput, HelloOutput> {
  @override
  final HelloInput input;
  HelloCommand(this.input);

  @override
  String? validate() => null;

  @override
  Future<HelloOutput> execute() async =>
      HelloOutput(greeting: 'Hello, ${input.name}!');
}

// ── Math module ─────────────────────────────────────────────────────────────

void buildMathModule(ModuleBuilder m) {
  m.command<AddInput, AddOutput>(
    'add',
    (req) => AddCommand(AddInput.fromCliRequest(req)),
    description: 'Add two numbers',
  );

  m.command<AddInput, AddOutput>(
    'multiply',
    (req) => MultiplyCommand(AddInput.fromCliRequest(req)),
    description: 'Multiply two numbers',
  );
}

class AddInput extends Input {
  final int a;
  final int b;
  AddInput({required this.a, required this.b});

  factory AddInput.fromCliRequest(CliRequest req) =>
      AddInput(a: req.flagInt('a') ?? 0, b: req.flagInt('b') ?? 0);

  @override
  Map<String, dynamic> toJson() => {'a': a, 'b': b};
}

class AddOutput extends Output {
  final int result;
  final String operation;
  AddOutput({required this.result, required this.operation});

  @override
  Map<String, dynamic> toJson() => {'operation': operation, 'result': result};

  @override
  int get exitCode => ExitCode.ok;
}

class AddCommand implements Command<AddInput, AddOutput> {
  @override
  final AddInput input;
  AddCommand(this.input);

  @override
  String? validate() => null;

  @override
  Future<AddOutput> execute() async => AddOutput(
    result: input.a + input.b,
    operation: '${input.a} + ${input.b}',
  );
}

class MultiplyCommand implements Command<AddInput, AddOutput> {
  @override
  final AddInput input;
  MultiplyCommand(this.input);

  @override
  String? validate() => null;

  @override
  Future<AddOutput> execute() async => AddOutput(
    result: input.a * input.b,
    operation: '${input.a} * ${input.b}',
  );
}
