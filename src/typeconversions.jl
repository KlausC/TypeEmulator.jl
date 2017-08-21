
# convert the originals of the Julia reflection data to the New versions

import Base.convert
import Base.MethodList

assoctype(::Void) = Void
assoctype(::TypeName) = NewTypeName
assoctype(::DataType) = NewDataType
assoctype(::Union) = NewUnion
# assoctype(::TypeVar) = NewTypeVar
assoctype(::UnionAll) = NewUnionAll
assoctype(::Method) = NewMethod
assoctype(::TypeMapEntry) = NewTypeMapEntry
assoctype(::MethodTable) = NewMethodTable
assoctype(::MethodList) = NewMethodList

const MTypes = Union{Void, TypeName, DataType, Union, UnionAll, Method, TypeMapEntry, MethodTable, MethodList}

convert(a::T) where T<:MTypes =  a == Any ? NewAny : convert(assoctype(a), a)
convert(a::Type{Union{}}) = NewBottom
convert(a::Type{T}) where T<:Union = NewUnion(convert(a.a), convert(a.b))

convert(x) = x

convert(::Type{NewTypeName}, x::TypeName) = NewTypeName(x.name) 

function convert(::Type{NewDataType}, x::DataType)
    parameters = map(convert, x.parameters)
    dtkey = DataTypeKey(x.name.name, parameters)
    gettype!(dtkey) do
        super = [gettype!(dtkey) do ; convert(x.super) end]
        NewDataType(x.name, super, parameters, x.abstract, x.mutable, x.isleaftype)
    end
end

convert(::Type{NewUnion}, x::T) where T<:Union = NewUnion(convert(x.a), convert(x.b))

# convert(::Type{NewTypeVar}, x::TypeVar) = NewTypeVar(x.name, convert(x.lb), convert(x.ub))

convert(::Type{NewUnionAll}, x::UnionAll) = NewUnionAll(convert(x.var), convert(x.body))

function convert(::Type{NewMethod}, x::Method)
    sig = map(convert, x.sig)
    NewMethod(x.name, x.module, x.file, x.line, sig, x.nargs, x.pure)
end

function convert(::Type{NewTypeMapEntry}, x::TypeMapEntry)
    next = convert(x.next)
    sig = map(convert, x.sig)
    NewTypeMapEntry(next, sig, convert(x.func), x.isleafsig, x.issimplesig, x.va)
end

function NewMethodTable(::Type{NewMethodTable}, x::MethodTable)
    defs = convert(x.defs)
    NewMethodTable(x.name, defs, x.max_args, x.module)
end

convert(::Type{NewMethodList}, x::MethodList) = NewMethodList(map(convert, x.ms), convert(x.mt))

