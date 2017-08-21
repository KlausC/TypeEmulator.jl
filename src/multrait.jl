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
        push_new!(list, x)
    end
    list
end

export linearize

function push_new!(x::Vector{NewType}, y::NewType)
    if y ∉ x && y != x
        push!(x, y)
    end
    x
end

# isnewsub(x::NewType, y::NewType) = y != x && y ∈ linearise(x)

