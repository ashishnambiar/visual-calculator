enum OperationType {
  add,
  subtract,
}

class OperationNode {
  Iterable<double> input;
  Iterable<double> output;
  OperationType operation;
  OperationNode({
    required this.input,
    required this.output,
    required this.operation,
  });
}
