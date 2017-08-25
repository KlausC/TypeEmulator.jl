
# convert the originals of the Julia reflection data to the New versions

import Base.MethodList

emulate(a::Type{Union{}}) = NewBottom
emulate(a::Type{T}) where T<:Union = NewUnion(emulate(a.a), emulate(a.b))

emulate(x) = x

emulate(x::TypeName) = NewTypeName(x.name, emulate(x.module)) 
emulate(x::TypeVar) = NewTypeVar(x.name, emulate(x.lb), emulate(x.ub))

function emulate(x::DataType)
    x == Any && return NewAny
    m = emulate(x.name.module)
    super = [emulate(x.super)]
    parameters = map(emulate, x.parameters)
    dtkey = DataTypeKey(x.name.name, parameters)
    getconstant!(m, dtkey) do
        NewDataType(emulate(x.name), super, parameters, x.abstract, x.mutable, x.isleaftype)
    end
end

emulate(x::T) where T<:Union = NewUnion(emulate(x.a), emulate(x.b))

emulate(x::UnionAll) = NewUnionAll(emulate(x.var), emulate(x.body))

function emulate(x::Module)
    name = module_name(x)
    name == :Main && return MainModule
    parent = emulate(module_parent(x))
    getconstant!(parent, name) do
        NewModule(module_name(x), parent)
    end
end

function emulate(x::Method)
    NewMethod(x.name, emulate(x.module), x.file, x.line, emulate(x.sig), x.nargs, x.pure)
end

function emulate(x::TypeMapEntry)
    next = emulate(x.next)
    sig = emulate, x.sig
    NewTypeMapEntry(next, sig, emulate(x.func), x.isleafsig, x.issimplesig, x.va)
end

function emulate(x::MethodTable)
    NewMethodTable(x.name, emulate(x.defs), x.max_args, emulate(x.module))
end

emulate(x::MethodList) = NewMethodList(map(emulate, x.ms), emulate(x.mt))

