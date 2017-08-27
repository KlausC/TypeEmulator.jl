# TypeEmulator

[![Build Status](https://travis-ci.org/KlausC/TypeEmulator.jl.svg?branch=master)](https://travis-ci.org/KlausC/TypeEmulator.jl)
[![Coverage Status](https://coveralls.io/repos/KlausC/TypeEmulator.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/KlausC/TypeEmulator.jl?branch=master)
[![codecov.io](http://codecov.io/github/KlausC/TypeEmulator.jl/coverage.svg?branch=master)](http://codecov.io/github/KlausC/TypeEmulator.jl?branch=master)

**TypeEmulator**

For educational purposes to obtain some insight to the Julia type system and the methods dispatching mechanisms.

 The method `emulate`can transform all Julia `Type`, `Tuple`, `Union`, `UnionAll, and `method lists and required components into a meta-representation. On the meta-representation several methods of Julia are implemented.
 
- subtype relation 
  - <:
  - typeintersect
- method dispatching

Extensive tests verify, that the results in the meta space coincide with the current Julia behaviour.

Speculative extensions of Julia may be included and sandboxed in the future.
- multiple inheritance
- type extensions
- traits
- interfaces / protocols

The meta-objects can be modified in order to extend the

Usage example:

```
  using TypeEmulator
  
  isnewsubtype(emulate(Int), emulate(Integer))
  isnewsubtypes(emulate(Tuple{Array{T,1} where T<:Number}, emulate(Tuple{Vector})) 


