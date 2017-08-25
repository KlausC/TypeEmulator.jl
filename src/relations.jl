
# methods which check the subtype relationships between NewTypes

import Base.issubtype

const NewWithParameters = Union{NewDataType, NewUnionAll}

issubtype(a::NewType, b::NewType) = a == b || b == NewAny
issubtype(a::NewType, b::NewUnion) = issubtype(a, b.a) || issubtype(a, b.b)
issubtype(::NewBottomType, b::NewType) = true

function issubtype(a::NewWithParameters, b::NewType)
    a == b && return true
    for st in linearize(a)
        issimplesubtype(st, b) && return true
    end
    false
end

typebody(x::NewType) = x
typebody(x::NewUnionAll) = typebody(x.body)

issimplesubtype(a::NewType, b::NewType) = a == b || b == NewAny
function issimplesubtype(a::NewWithParameters, b::NewWithParameters)
    a == b || b == NewAny && return true
    ba = typebody(a)
    bb = typebody(b)
    ba.name != bb.name && return false
    np = length(ba.parameters)
    np != length(bb.parameters) && return false
    for k = 1:np
        !issubvar(ba.parameters[k], bb.parameters[k]) && return false
    end
    true
end

issubvar(a, b) = a == b
function issubvar(a, b::NewTypeVar)
    em = emulate(typeof(a))
    issubtype(b.lb, em) && issubtype(em, b.ub)
end
issubvar(a::NewTypeVar, b) = false
issubvar(a::NewType, b::NewType) = issubtype(a, b)
issubvar(a::NewTypeVar, b::NewType) = false
issubvar(a::NewType, b::NewTypeVar) = issubvar(b.lb, a) && issubvar(a, b.ub)
issubvar(a::NewTypeVar, b::NewTypeVar) = issubvar(b.lb, a.lb) && issubvar(a.ub, b.ub)




