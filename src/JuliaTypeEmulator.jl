module JuliaTypeEmulator

export
    emulate, MainModule, 
    NewModule, NewDataType, NewAny, NewBottom, NewFunction, 
    NewType, NewTypeVar, NewUnionAll, NewUnion,
    NewFunction, NewMethod, NewMethodList, NewMethodTable, NewTypeMapEntry, 
    supertypes, isnewsubtype, linearize, register!

import Base:    show, subtypes, supertype

include("types.jl")
include("typeconversions.jl")
include("multrait.jl")

end # module
