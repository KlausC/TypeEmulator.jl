# TypeEmulator

[![Build Status](https://travis-ci.org/KlausC/TypeEmulator.jl.svg?branch=master)](https://travis-ci.org/KlausC/TypeEmulator.jl)
[![Coverage Status](https://coveralls.io/repos/KlausC/TypeEmulator.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/KlausC/TypeEmulator.jl?branch=master)
[![codecov.io](http://codecov.io/github/KlausC/TypeEmulator.jl/coverage.svg?branch=master)](http://codecov.io/github/KlausC/TypeEmulator.jl?branch=master)

**TypeEmulator**

For educational purposes to obtain some insight to the Julia type system and the methods dispatching mechanisms.

 The method `emulate`can transform all Julia `Type`, `Tuple`, `Union`, `UnionAll`, and method lists and required components into a meta-representation. On the meta-representation several methods of Julia are implemented.
 
- subtype relation 
  - <:
  - typeintersect
  - union
- method dispatching
  - is_more_specific

The documentation found in https://docs.julialang.org/en/latest/devdocs/types/ shall be followed.
The test cases in https://github.com/JuliaLang/julia/test/subtype.jl shall be proved.

Extensive tests verify, that the results in the meta space coincide with the current Julia behaviour.

Speculative extensions of Julia may be included in the future.
- multiple inheritance
- type extensions
- traits
- interfaces / protocols
- method invokation delegation

For this purpose, the meta-objects can be modified to simulate the speculative extensions in a sandbox.
It is currently not planned to emulate object instantiation and related peculiarities.

Usage example:

```
  using TypeEmulator
  
  isnewsubtype(emulate(Int), emulate(Integer))  ===  Int <: Integer
  
  A = Tuple{Array{T,1} where T<:Number}
  B = Tuple{Vector}
  isnewsubtypes(emulate(A), emulate(B)) === A <: B
  
  ml = emulate(methods(exp))
  ml.ms[1].sig
```

WORK IN PROGRESS !!!

