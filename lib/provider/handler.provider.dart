import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef Handler = dynamic Function(Map<String, dynamic>);

final handlerProvider =
    StateNotifierProvider<HandlerProvider, Map<String, Handler>>(
  (ref) {
    return HandlerProvider();
  },
);

class HandlerProvider extends StateNotifier<Map<String, Handler>> {
  HandlerProvider() : super({});

  void register(String description, Handler body) {
    state = {
      ...state,
      ...{description: body}
    };
  }

  void remove(String description) {
    final updatedState = Map<String, Handler>.from(state);
    updatedState.remove(description);
    state = updatedState;
  }

  dynamic call(String description, Map<String, dynamic> parameter) {
    return state[description]?.call(parameter);
  }
}
