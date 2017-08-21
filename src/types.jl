
# mimic some internal definitions of julia which are implemented in C
# the commented definitions are re-used

mutable struct NewModule
    name::Symbol
    constants::Dict{Any,Any}
end

NewModule(n::Symbol) = NewModule(n, Dict{Any,Any}())


abstract type NewType end
struct NewBottomType <: NewType end

struct NewTypeName
    name::Symbol
end

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

function Base.hash(d::DataTypeKey, h::UInt)
    h = hash(d.name, h)
    for x in d.parameters
        h = hash(x, h)
    end
    h
end

import Base.==
function ==(a::DataTypeKey, b::DataTypeKey)
    a.name != b.name && return false
    length(a.parameters) != length(b.parameters) && return false
    for i in 1:length(b.parameters)
        a.parameters[i] != b.parameters[i] && return false
    end
    return true
end

function show(io::IO, dt::Union{NewDataType,DataTypeKey})
    if isempty(dt.parameters)
        print(io, dt.name)
    else
        plist = mkstring(map(string2, dt.parameters))
        print(io, dt.name, "{", plist, "}")
    end
end

show(io::IO, tn::NewTypeName) = print(io, "New_", tn.name)

struct NewUnion <: NewType
    a
    b
    NewUnion(a::NewType, b::NewType, ::Bool) = new(a, b)
end

_NewUnion(a::NewType, b::NewType) = NewUnion(a, b, true)
_NewUnion() = NewBottom
_NewUnion(t::NewType) = t
_NewUnion(t::NewType, u::NewType, v::NewType, ts::NewType...) = _NewUnion(t, _NewUnion(u, v, ts...))
NewUnion(ts::NewType...) = _NewUnion(unique(ts)...)

show(io::IO, ::NewBottomType) = print(io, "Union{}")

show(io::IO, x::NewUnion) = print(io, "Union{", x.a, showtail(x.b), "}")

showtail(x::Any) = string(", ", x)
showtail(x::NewUnion) = string( ", ", x.a, showtail(x.b))

mutable struct NewTypeVar
    name::Symbol
    lb::NewType
    ub::NewType
end
Base.convert(::Type{NewTypeVar}, name::Symbol) = NewTypeVar(name, NewBottom, NewAny)
NewTypeVar(name::Symbol, upper::NewType) = NewTypeVar(name, NewBottom, upper)

string2(x::Any) = string(x)
string2(x::NewTypeVar) = string(x.name)

import Base.<<
<<(lb::NewType, name::Symbol) = NewTypeVar(name, lb)
<<(tv::NewTypeVar, ub::NewType) = NewTypeVar(tv.name, tv.ub, ub)
<<(name::Symbol, ub::NewType) = NewTypeVar(name, ub)

function Base.show(io::IO, tv::NewTypeVar)
    if tv.lb != NewBottom
        print(io, string(tv.lb), "<:")
    end
    print(io, tv.name)
    if tv.ub != NewAny
        print(io, "<:", string(tv.ub))
    end
end

struct NewUnionAll <: NewType
    var::TypeVar
    body::NewType
end

function show(io::IO, u::NewUnionAll)
    tl, ty = tlist(u)
    print(io, ty, " where {", mkstring(tl), "}")
end

function tlist(u::NewUnionAll)
    tl, ty = tlist(u.body)
    [u.var; tl], ty
end
tlist(u::NewType) = TypeVar[], u
mkstring(itr) = isempty(itr) ? "" : mapreduce(string, (a,b)->a*","*b, itr)

#struct Void
#end
#const nothing = Void()

#abstract type AbstractArray{T,N} end
#abstract type DenseArray{T,N} <: AbstractArray{T,N} end

#mutable struct Array{T,N} <: DenseArray{T,N}
#end

mutable struct NewMethod
    name::Symbol
    modul::NewModule
    file::Symbol
    line::Int32
    sig::Tuple
    nargs::Int32
    pure::Bool
end

function Base.show(io::IO, m::NewMethod)
    argt = mapreduce(x->", ::" * string(x), *, "", m.sig[2:end])
    print(io, m.name, "(", argt[3:end], ") in ", m.modul)
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
    modul::Module
end

mutable struct NewMethodList
    ms::Array{NewMethod,1}
    mt::NewMethodTable
end

function NewMethodList(modul::Module, name::Symbol)
    NewMethodList(Array{NewMethod,1}[], NewMethodTable(name, nothing, 0, modul))  
end

# iterate all the methods in linked list
Base.start(mt::NewTypeMapEntry) = mt
Base.done(mt::NewTypeMapEntry, me) = me === nothing
Base.next(mt::NewTypeMapEntry, me) = me, me.next

function Base.push!(ml::NewMethodList, m::NewMethod)
    push!(ml.ms, m)
    x = ml.mt.defs
    for x in ml.mt end
    me = NewMethodTableEntry(nothing, m.sig, m, true, true, true)
    if x == nothing
        mt.defs = me
    else
        x.next = me
    end
    ml
end

#mutable struct CodeInfo
#end

#mutable struct TypeMapLevel
#end

"""
    `create_type(name::Symbol, abstr,typeparams::Tuple, parent::NewType)` single inheritance.
    `create_type(name::Symbol, typeparams::Tuple, parent::NTuple{n,NewType)}` multiple inh.

Create a representative for a new type - corresponds to
    `abstract type name{params} <: parent end`
"""
function NewType(name::Symbol, abstr::Bool, mutable::Bool, typeparams::Symbol, parent::Any)
    NewType(name, abstr, mutable, (TypeVar(typeparams),), parent)
end
function NewType(name::Symbol, abstr::Bool, mutable::Bool, typeparams::TypeVar, parent::Any)
    NewType(name, abstr, mutable, (typeparams,), parent)
end
function NewType(name::Symbol, abstr::Bool, mutable::Bool, typeparams, parent::Any)
    name = NewTypeName(name)
    super = isa(parent, AbstractArray)  ? parent : [parent]
    parameters = collect(typeparams)
    types = parameters
    isleaftype = !abstr && length(typeparams) == 0
    dt = NewDataType(name, super, parameters, types, abstr, mutable, isleaftype)
    for t in reverse(typeparams)
        tt = isa(t, Symbol) ? TypeVar(t) : t
        dt = NewUnionAll(tt, dt)
    end
    dt
end

function NewMethod(name::Symbol, arglist::Tuple)m =

    fun = NewDataType(NewTypeName(Symbol('#', name)), NewFunction, NewEmpty, NewEmpty, false, false, true)
    sig = (fun, arglist...)
    modul = current_module()
    file = ""
    line = 1
    NewMethod(name, modul, file, line, sig, length(arglist) + 1, false) 
end

supertypes(ty::NewDataType) = ty.super
supertypes(ty::NewUnionAll) = [NewAny]

isnewsubtype(a::NewUnionAll, b::NewDataType) = b == NewAny || isnewsubtype(a.body, b)
isnewsubtype(a::NewUnionAll, b::NewUnionAll) = a == b || isnewsubtype(a.body, b)
isnewsubtype(a::NewDataType, b::NewUnionAll) = false
isnewsubtype(a::NewDataType, b::NewDataType) = b == NewAny || a == b || (a.super != nothing && any(p->isnewsubtype(p, b), a.super))
isnewsubtype(a::NewType, b::NewType) = a == b
isnewsubtype(::Void, ::NewType) = false
isnewsubtype(::NewType, ::NewBottomType) = false
isnewsubtype(::NewBottomType, ::NewType) = true

mutable struct NewGlobal
    modules::Dict{Symbol,NewModule}
end

current_name() = module_name(@__MODULE__)

register!(x) = register!(current_name(), x)

function gettype!(f::Function, s::DataTypeKey)
    m = ensure_module(current_name())
    get(m.constants, s) do
        f()
    end
end

ensure_module(mname::Symbol) = get!(GlobalModules.modules, mname) do ; NewModule(mname) end

function register!(mname::Symbol, x)
    m = ensure_module(mname)
    register!(m, x)
end

function register!(m::NewModule, dt::NewDataType)
    s = DataTypeKey(dt.name.name, dt.parameters)
    haskey(m.constants, s) && error("invalid redefinition of constant $s")
    m.constants[s] = dt
end

# global constants

global const GlobalModules = NewGlobal(Dict{Symbol,NewModule}())

const NewEmpty = NewDataType[]
const NewBottom = NewBottomType()
const NewAny = NewDataType(NewTypeName(:Any), nothing, NewEmpty, true, false, false)
const NewFunction = NewDataType(NewTypeName(:Function), [NewAny], NewEmpty, true, false, false)


