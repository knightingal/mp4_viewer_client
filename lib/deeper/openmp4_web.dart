external String stringify(Object obj);
external String consolelog(Object obj);

external String windowopen(String url);

void calljs() {
  consolelog(stringify("obj"));
}
