module JuliaTypeEmulator

export
    emulate, MainModule, CoreModule, NewEmpty, 
    NewModule, NewDataType, NewAny, NewBottom, NewFunction, 
    NewType, NewTypeName, NewTypeVar, NewUnionAll, NewUnion,
    NewFunction, NewMethod, NewMethodList, NewMethodTable, NewTypeMapEntry, 
    supertypes, isnewsubtype, linearize, register!

import Base:    show, subtypes, supertype

include("metadata.jl")
include("types.jl")
include("typeconversions.jl")
include("linear.jl")
include("relations.jl")
include("variables.jl")

end # module
