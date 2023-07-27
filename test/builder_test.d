import builder : AddBuilder;

import std.stdio;
import std.typecons : Nullable, nullable;

class A1 {
  int a;
  string b;

  mixin AddBuilder!(typeof(this));
}

/// Test a simple class.
unittest {
  A1 a1 = A1.builder()
      .a(3)
      .b("ham")
      .build();
  assert(a1.a == 3);
  assert(a1.b == "ham");
}

class A2 {
  int a;
  string b;
}

class B2 : A2 {
  int c;

  mixin AddBuilder!(typeof(this));
}

/// All inherited fields should be available from the builder.
unittest {
  B2 b2 = B2.builder()
      .a(3)
      .b("ham")
      .c(4)
      .build();

  assert(b2.a == 3);
  assert(b2.b == "ham");
  assert(b2.c == 4);
}

class A3 {
  private int a;
  public string b;
  package int c;

  mixin AddBuilder!(typeof(this));
}

/// Visibility settings should not prevent the builder from working.
unittest {
  A3 a3 = A3.builder()
      .a(1).b("fish").c(2)
      .build();
  assert(a3.a == 1);
  assert(a3.b == "fish");
  assert(a3.c == 2);
}

class A4 {
  int a = 3;
  int b = 4;

  mixin AddBuilder!(typeof(this));
}

/// Assure that field initializers are not averted.
unittest {
  A4 a4 = A4.builder()
      .b(5)
      .build();
  assert(a4.a == 3);
  assert(a4.b == 5);
}

template MakeA5(alias T) {
  struct A5 {
    int a = 3;
    string b = "ham";

    mixin AddBuilder!(typeof(this));
  }
}

/// For now, only classes are supported, and not structs.
unittest {
  assert(__traits(compiles, MakeA5!1) == false);
}

/// Assure that values that are assignable work with fields.
class A6 {
  Nullable!int a;
  Nullable!int b;
  Nullable!int c;
  mixin AddBuilder!(typeof(this));
}

unittest {
  import std.typecons : nullable;
  A6 a6 = A6.builder()
      .a(nullable(1))
      .b(2)
      .c(false)
      .build();
  assert(a6.a == 1);
  assert(a6.b == 2);
  assert(a6.c == 0);
}
