"""
    `linearize(t::NewType) -> Vector{NewType}`

Return ordered list of all types, which type `t` can inherit from.
The fist element of the list is `Any`, the last element is `t`.
If `i` <= `j` then list[j] isa list[i]
"""

function linearize(x::NewType)
    _linearize(NewType[], x)
end
function _linearize(list::Vector{NewType}, x::NewType)
    if x ∉ list
        for y in supertypes(x)
            _linearize(list, y)
        end
        push_new!(list, x, is_pushed(typeof(x)))
    end
    list
end

export linearize

is_pushed(::Type) = false
is_pushed(::Type{NewDataType}) = true
is_pushed(::Type{NewUnionAll}) = true

function push_new!(x::Vector{NewType}, y::NewType, doit::Bool)
    if doit && y ∉ x && y != x
        push!(x, y)
    end
    x
end

push_new!(x::Vector{NewType}, y::NewUnionAll, doit::Bool) = push_new!(x, y.body, doit)

function linearize(x::Type)
    _linearize(Type[], x)
end
function _linearize(list::Vector{Type}, x::Type)
    if x ∉ list
        for y in supertypes(x)
            _linearize(list, y)
        end
        push_new!(list, x)
    end
    list
end

export linearize

function push_new!(x::Vector{Type}, y::DataType)
    if y ∉ x && y != x
        push!(x, y)
    end
    x
end

push_new!(x::Vector{Type}, y::UnionAll) = push_new!(x, y.body)
push_new!(x::Vector{Type}, y::Type) = x

supertypes(x::DataType) = x == Any ? Type[] : [supertype(x)]
supertypes(x::UnionAll) = supertypes(x.body)

