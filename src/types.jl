
# mimic some internal definitions of julia which are implemented in C
# the commented definitions are re-used

NewModule(n::Symbol, p::Union{Void,NewModule}) = NewModule(n, p, Dict())

import Base.convert
Base.convert(::Type{NewTypeVar}, name::Symbol) = NewTypeVar(name, NewBottom, NewAny)
NewTypeVar(name::Symbol, upper::NewType) = NewTypeVar(name, NewBottom, upper)

import Base.<<
<<(lb::NewType, name::Symbol) = NewTypeVar(name, lb)
<<(tv::NewTypeVar, ub::NewType) = NewTypeVar(tv.name, tv.ub, ub)
<<(name::Symbol, ub::NewType) = NewTypeVar(name, ub)

Base.show(io::IO, tv::NewTypeVar) = print(io, string2(tv, string))

function string2(tv::NewTypeVar, sfun::Function)
    s1 = sfun != string2 && tv.lb != NewBottom ? string(string2(tv.lb, string2), "<:") : ""
    s2 = string(tv.name)
    s3 = sfun != string2 && tv.ub != NewAny ? string("<:", string2(tv.ub, string2)) : ""
    string(s1, s2, s3)
end

show(io::IO, m::NewModule) = print(io, mname(m))

mname(m::NewModule) = begin f = fullname(m); isempty(f) ? "Main" : join(f, '.') end

function Base.fullname(m::NewModule)
    m.name == :Main && return ()
    m.parent == :Main && return (m.name,)
    m.parent == m && return (m.name,)
    tuple(fullname(m.parent)..., m.name)
end

show(io::IO, tn::NewTypeName) = print(io, "New_", tn.name)

convert(::Type{DataTypeKey}, a::NewDataType) = DataTypeKey(a.name.name, a.parameters)

function Base.hash(d::DataTypeKey, h::UInt)
    h = hash(d.name, h)
    for x in d.parameters
        h = hash(x, h)
    end
    h
end
import Base.hash

hash(d::NewDataType, h::UInt) = hash(DataTypeKey(d), h)
hash(a::NewTypeName, h::UInt) = hash(a.name, h)
hash(a::NewTypeVar, h::UInt) = hash(a.ub, hash(a.lb, hash(a.name)))
hash(a::NewUnionAll, h::UInt) = hash(a.body, hash(a.var, hash("A")))
hash(a::NewUnion, h::UInt) = hash(a.b, hash(a.a, hash("U", h)))

import Base.==
function ==(a::DataTypeKey, b::DataTypeKey)
    a.name != b.name && return false
    length(a.parameters) != length(b.parameters) && return false
    for i in 1:length(b.parameters)
        a.parameters[i] != b.parameters[i] && return false
    end
    return true
end
==(a::NewDataType, b::NewDataType) = DataTypeKey(a) == DataTypeKey(b)
==(a::NewTypeName, b::NewTypeName) = a.name == b.name
==(a::NewTypeVar, b::NewTypeVar) = a.name == b.name && a.ub == b.ub && a.lb == b.lb
==(a::NewUnionAll, b::NewUnionAll) = a.var == b.var && a.body == b.body
==(a::NewUnion, b::NewUnion) = a.a == b.a && b.a == b.b

show(io::IO, dt::Union{NewDataType,DataTypeKey}) = print(io, string2(dt, string))

function string2(dt::Union{NewDataType,DataTypeKey}, sfun::Function)
    if isempty(dt.parameters)
        sfun(dt.name)
    else
        plist = join(map(sfun, dt.parameters), ',')
        string(dt.name, "{", plist, "}")
    end
end

_NewUnion(a::NewType, b::NewType) = NewUnion(a, b, true)
_NewUnion() = NewBottom
_NewUnion(t::NewType) = t
_NewUnion(t::NewType, u::NewType, v::NewType, ts::NewType...) = _NewUnion(t, _NewUnion(u, v, ts...))
NewUnion(ts::NewType...) = _NewUnion(unique(ts)...)

show(io::IO, ::NewBottomType) = print(io, "NewUnion{}")

show(io::IO, x::NewUnion) = print(io, string2(x, string))
string2(x::NewUnion, sfun::Function) = string("NewUnion{", x.a, showtail(x.b, sfun), "}")

showtail(x::Any, sfun::Function) = string(", ", sfun(x))
showtail(x::NewUnion, sfun::Function) = string( ", ", x.a, showtail(x.b, sfun))

string2(x::Any) = string(x)
string2(x::NewTypeVar) = string(x.name)

show(io::IO, u::NewUnionAll) = print(io, string2(u, string2))
string2(u::NewUnionAll, sfun::Function) = string3(u, sfun, string2)
function string3(u::NewUnionAll, sfun::Function, sfunbody::Function)
    string(sfunbody(u.body, sfun), " where ", u.var)
end

Base.show(io::IO, m::NewMethod) = print(io, string2(m, string))

function string2(m::NewMethod, sfun::Function)
    s = isa(m.sig, NewUnionAll) ? string3(m.sig, string2, argbody) : argbody(m.sig, sfun)
    string(m.name, s, " in ", m.modul, " at ", m.file, ":", m.line)
end

function argbody(dt::NewDataType, sfun::Function)
   argt = mapreduce(x->", ::" * string2(x, sfun), *, "", dt.parameters[2:end])
   string("(", argt[3:end], ")")
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
    NewType(name, abstr, mutable, (NewTypeVar(typeparams),), parent)
end
function NewType(name::Symbol, abstr::Bool, mutable::Bool, typeparams::NewTypeVar, parent::Any)
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
        tt = isa(t, Symbol) ? NewTypeVar(t) : t
        dt = NewUnionAll(tt, dt)
    end
    dt
end

function NewMethod(name::Symbol, arglist::Tuple)
    fun = NewDataType(NewTypeName(Symbol('#', name)), NewFunction, NewEmpty, NewEmpty, false, false, true)
    sig = (fun, arglist...)
    modul = current_module()
    file = ""
    line = 1
    NewMethod(name, modul, file, line, sig, length(arglist) + 1, false) 
end

supertypes(ty::NewDataType) = ty.super == nothing ? NewType[] : ty.super
supertypes(ty::NewUnionAll) = supertypes(ty.body)

isnewsubtype(a::NewUnionAll, b::NewDataType) = b == NewAny || isnewsubtype(a.body, b)
isnewsubtype(a::NewUnionAll, b::NewUnionAll) = a == b || isnewsubtype(a.body, b)
isnewsubtype(a::NewDataType, b::NewUnionAll) = false
isnewsubtype(a::NewDataType, b::NewDataType) = b == NewAny || a == b || (a.super != nothing && any(p->isnewsubtype(p, b), a.super))
isnewsubtype(a::NewType, b::NewType) = a == b
isnewsubtype(::Void, ::NewType) = false
isnewsubtype(::NewType, ::NewBottomType) = false
isnewsubtype(::NewBottomType, ::NewType) = true


# Module simulation - registration

current_modul() = _current_module
set_module(m::NewModule) = _current_module = m

register!(x) = register!(current_name(), x)

function getconstant!(f::Function, m::NewModule, s::Union{DataTypeKey,Symbol})
    get(m.constants, s) do
        f()
    end
end

function register!(m::NewModule)
    parent = m.parent == nothing ? current_modul() : m.parent
    s = m.name
    if haskey(parent.constants, s)
        error("invalid redefinition of module $s in module $(parent.name)")
    end
    parent.constants[s] = m
end

function register!(dt::NewDataType)
    m = dt.name.modul
    s = DataTypeKey(dt.name.name, dt.parameters)
    if haskey(m.constants, s)
        error("invalid redefinition of constant $s in module $(m.name)")
    end
    m.constants[s] = dt
end

# global modules and constants

const MainModule = NewModule(:Main, nothing)
global _current_module = MainModule
const CoreModule = NewModule(:Core, MainModule)

const NewEmpty = NewDataType[]
const NewBottom = NewBottomType()
const NewAny = NewDataType(NewTypeName(:Any, CoreModule), nothing, NewEmpty, true, false, false)
const NewFunction = NewDataType(NewTypeName(:Function, CoreModule), [NewAny], NewEmpty, true, false, false)


