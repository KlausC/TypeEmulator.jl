
# data type and constructors to mimic some internal definitions of julia

mutable struct NewModule
    name::Symbol
    parent::Union{NewModule,Void}
    constants::Dict{Any,Any}
end

abstract type NewType end

struct NewBottomType <: NewType end

struct NewTypeName
    name::Symbol
    modul::NewModule
end

NewTypeBounds = Union{NewType,Any}
mutable struct NewTypeVar
    name::Symbol
    lb::NewTypeBounds
    ub::NewTypeBounds
end
NewTypeBounds = Union{NewType,NewTypeVar}

mutable struct NewDataType <: NewType
    name::NewTypeName
    super::Any # NewType
    parameters::Vector
    abstr::Bool
    mutable::Bool
    isleaftype::Bool
    function NewDataType(name, super, parameters, abstr, mutable, isleaftype)
        dt = new(name, super, parameters, abstr, mutable, isleaftype)
        register!(dt)
    end
end

struct DataTypeKey
    name::Symbol
    parameters::Vector
end

struct NewUnionAll <: NewType
    var::NewTypeVar
    body::NewType
end

struct NewUnion <: NewType
    a
    b
    NewUnion(a::NewType, b::NewType, ::Bool) = new(a, b)
end

mutable struct NewMethod
    name::Symbol
    modul::NewModule
    file::Symbol
    line::Int32
    sig::Union{NewDataType,NewUnionAll}
    nargs::Int32
    pure::Bool
end

#mutable struct NewMethodInstance
#end

mutable struct NewTypeMapEntry
    next::Union{NewTypeMapEntry, Void}
    sig::Tuple
    func::NewMethod
    isleafsig::Bool
    issimplesig::Bool
    va::Bool
end

mutable struct NewMethodTable
    name::Symbol
    defs::Union{NewTypeMapEntry,Void}
    max_args::Int64
    modul::NewModule
end

mutable struct NewMethodList
    ms::Array{NewMethod,1}
    mt::NewMethodTable
    NewMethodList(ms::Array{NewMethod,1}, mt::NewMethodTable) = new(ms, mt)
end

struct FreeVariables
    d::Dict{NewTypeVar,Any} # Array{Union{Void,NewTypeVar,NewType,Bitstype}}
end

