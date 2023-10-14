import 'package:js/js.dart';

@JS('JSON.stringify')
external String stringify(Object obj);
@JS('console.log')
external String consolelog(Object obj);

@JS('window.open')
external String windowopen(String url);

void calljs() {
  consolelog(stringify("obj"));
}
