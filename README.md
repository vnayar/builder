## Introduction

This small project provides a boiler-plate free mechanism to add a Builder API to classes.

Advantages of a Builder API:
- **unambiguous**: Parameter names rather than their order is used to set values.
- **fluent**: An object can be initialized in a single expression, allowing them to be used inline
  as function arguments, etc.
- **consistent**: When used throughout a project, class construction becomes uniform and consistent,
  improving code readability.
- **portable**: Such patterns are common in other languages, such as Java, and using them can help
  people more easily transition into D projects.

## Usage

Example initialization without a builder:

```d
class A1 {
  private int a;
  private string b;
  private int c = 3;

  void setA(int a) {
    this.a = a;
  }
  // More setters...
}

// One method to build a1, which is verbose.
A1 a1 = new A1();
a1.setA(3);
a1.setB("ham");
// Another way to build a1, which can make large numbers of parameters ambiguous.
A1 a1 = new A1(3, "ham");
myFunction(a1);
```

Using the `AddBuilder` template from within a class, creates an inner class and methods to support a
Builder API. Using this pattern, it is now possible to create and initialize objects as a single
expression, which allows them to be built, for example, as function arguments.

```d
import builder : AddBuilder;

// Parameter initializers and inheritance are both supported.
class A2 : A1 {
  string d = "sam";

  mixin AddBuilder!(typeof(this));
}

myFunction(A2.builder()
    .a(3)
    .b("ham")
    .d("sam")
    .build());
```

The Builder API is heavily influenced by [Project Lombok's
Builder](https://projectlombok.org/features/Builder) for Java.
