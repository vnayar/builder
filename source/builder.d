/**
 * Templates used to add boiler plate builder API code to classes.
 */
module builder;

/**
 * When invoked from within a class, creates an inner class and methods to support a "builder" API.
 *
 * Advantages of a builder API:
 * - unambiguous: Parameter names rather than their order is used to set values.
 * - fluent: An object can be initialized in a single expression.
 *
 * Example initialization without a builder:
 * ```
 * class A1 {
 *   private int a;
 *   private string b;
 *   private int c = 3;
 *
 *   void setA(int a) {
 *     this.a = a;
 *   }
 *   // More setters...
 * }
 *
 * // One method to build a1, which is verbose.
 * A1 a1 = new A1();
 * a1.setA(3);
 * a1.setB("ham");
 * // Another way to build a1, which can make large numbers of parameters ambiguous.
 * A1 a1 = new A1(3, "ham");
 * myFunction(a1);
 * ```
 *
 * Using a builder pattern, it is now possible to create and initialize objects as a single
 * expression, which allows them to be built, for example, as function arguments.
 * ```
 * import builder : AddBuilder;
 *
 * // Parameter initializers and inheritance are both supported.
 * class A2 : A1 {
 *   string d = "sam";
 *
 *   mixin AddBuilder!(typeof(this));
 * }
 *
 * myFunction(A2.builder()
 *     .a(3)
 *     .b("ham")
 *     .d("sam")
 *     .build());
 * ```
 */
mixin template AddBuilder(T)
if (is(T == class))
{
  import std.range : iota;
  import std.traits : Fields, FieldNameTuple, BaseClassesTuple;

  // [Fields] returns the field types and [FieldNameTuple] returns the field names.
  static assert(Fields!(T).length == FieldNameTuple!(T).length);

  // Create an inner builder class which can access the private members.
  static class Builder {
    // Define fields that originate from base classes.
    static foreach (B; BaseClassesTuple!(T)) {
      mixin AddClassFields!(B);
    }
    // Define fields coming from the class itself.
    mixin AddClassFields!(T);

    T build() {
      T t = new T();
      static foreach (B; BaseClassesTuple!(T)) {
        static foreach (size_t i; iota(0, Fields!(B).length)) {
          mixin(
              "if (_", FieldNameTuple!(B)[i], "_isSet == true)",
              "  t.", FieldNameTuple!(B)[i], " = _", FieldNameTuple!(B)[i], ";");
        }
      }
      static foreach (size_t i; iota(0, Fields!(T).length)) {
        mixin(
            "if (_", FieldNameTuple!(T)[i], "_isSet == true)",
            "  t.", FieldNameTuple!(T)[i], " = _", FieldNameTuple!(T)[i], ";");
      }
      return t;
    }
  }

  static Builder builder() {
    return new Builder();
  }

  mixin template AddClassFields(C) {
    static foreach (size_t i; iota(0, Fields!(C).length)) {
      mixin AddField!(C, Fields!(C)[i], FieldNameTuple!(C)[i]);
      mixin AddSetter!(Fields!(C)[i], FieldNameTuple!(C)[i]);
    }
  }

  // TODO: Extract the initializer value and apply it rather than using a separate bool.
  mixin template AddField(CT, FT, string N) {
    mixin("private ", "bool _", N, "_isSet = false;");
    mixin("private ", FT, " _", N, ";");
  }

  mixin template AddSetter(FT, string N) {
    mixin(
        "Builder ", N, "(", FT, " ", N, ") {",
        "  this._", N, "_isSet = true;",
        "  this._", N, " = ", N, ";",
        "  return this;",
        "}");
  }

}
