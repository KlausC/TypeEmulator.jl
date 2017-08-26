# TypeEmulator

[![Build Status](https://travis-ci.org/KlausC/TypeEmulator.jl.svg?branch=master)](https://travis-ci.org/KlausC/TypeEmulator.jl)
[![Coverage Status](https://coveralls.io/repos/KlausC/TypeEmulator.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/KlausC/TypeEmulator.jl?branch=master)
[![codecov.io](http://codecov.io/github/KlausC/TypeEmulator.jl/coverage.svg?branch=master)](http://codecov.io/github/KlausC/TypeEmulator.jl?branch=master)

**TypeEmulator**

For educational purposes to obtain some insight to the Julia type system and the methods dispatching mechanisms.

The existing API can tranform all Julia Types into a meta-representation. On the meta-representation several methods of Julia have been emulated.

emulating | original
--------------------
`isnewsubsys` | `issubtype`, `<:`

