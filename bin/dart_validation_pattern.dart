abstract class ValidateState<T> {
  final T? data;
  final String? error;

  const ValidateState({this.data, this.error});
}

class ValidateSuccess<T> extends ValidateState<T> {
  const ValidateSuccess(T data) : super(data: data);
}

class ValidateFailed<T> extends ValidateState<T> {
  const ValidateFailed(String error) : super(error: error);
}

abstract class Validator<T> {
  /// Returns true if the [value] is valid.
  ValidateState<String> validate(T value);

  /// Set next validator to be called if this validator returns true.
  T handleNext(T value);

  Validator<T> setNext(Validator<T> handler);
}

class ValidatorChain<T> implements Validator<T> {
  Validator<T>? _nextValidator;

  @override
  ValidateState<String> validate(T value) {
    if (_nextValidator == null) {
      return const ValidateSuccess<String>('');
    }
    return _nextValidator!.validate(value);
  }

  @override
  T handleNext(T value) {
    if (_nextValidator == null) {
      return value;
    }
    return _nextValidator!.handleNext(value);
  }

  @override
  Validator<T> setNext(Validator<T> handler) {
    _nextValidator = handler;
    return _nextValidator!;
  }
}

class ValidatorName extends ValidatorChain<String> {
  @override
  ValidateState<String> validate(String value) {
    if (value.isEmpty) {
      return const ValidateFailed<String>('Email is required');
    }
    if (!RegExp(
            r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
        .hasMatch(value)) {
      return const ValidateFailed<String>('Email is invalid');
    }
    return super.validate(value);
  }
}

class ValidatorEmail extends ValidatorChain<String> {
  @override
  ValidateState<String> validate(String value) {
    if (value.isEmpty) {
      return const ValidateFailed<String>('Email is required');
    }
    if (!RegExp(
            r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
        .hasMatch(value)) {
      return const ValidateFailed<String>('Email is invalid');
    }
    return super.validate(value);
  }
}

class ValidatorPassword extends ValidatorChain<String> {
  @override
  ValidateState<String> validate(String value) {
    if (value.isEmpty) {
      return const ValidateFailed<String>('Password is required');
    }
    if (value.length < 6) {
      return const ValidateFailed<String>('Password is too short');
    }
    return super.validate(value);
  }
}

void main() {
  String email = 'ccc@gmail.com';
  String password = 'dwdwdwddwdwd';
  List<String> params = [];
  params.add(email);
  params.add(password);

  List<ValidatorChain> validatorChain = [];
  validatorChain.add(ValidatorEmail());
  validatorChain.add(ValidatorPassword());

  for (var i = 0; i < params.length; i++) {
    var result = validatorChain[i].validate(params[i]);
    if (result is ValidateFailed) {
      print(result.error);
    } else {
      print('validate success');
    }
  }
}
