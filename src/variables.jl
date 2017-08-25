

export FreeVariables, NewTypeWithVar, getbinding, bind!, testbinding!

FreeVariables() = FreeVariables(Dict{Symbol,Any}())

# Working with the symbols of type variables
"""
    `push!(::FreeVariables, ::Symbol)`

Add a new type variable to stack. The variable has no value (is unbound).
"""
function Base.push!(fv::FreeVariables, s::Symbol)
    a = get!(fv.d, s) do
        []
    end
    push!(a, nothing)
    a
end

"""
    `pop!(::FreeVariables, ::Symbol)`

Remove variable from stack of free variables.
"""
function Base.pop!(fv::FreeVariables, s::Symbol)
    a = getindex(fv.d, s)
    ae = pop!(a)
    if isempty(a)
        delete!(fv.d, s)
    end
    ae
end

function getbinding(fv::FreeVariables, s::Symbol)
    a = getindex(fv.d, s)
    a[end]
end

function bind!(fv::FreeVariables, s::Symbol, t::Union{Symbol, NewTypeWithVar})
    a = getindex(fv.d, s)
    a[end] = t
end

"""
    `testbinding!(fv::FreeVariables, s::Symbol, t::newSymbol)`

If symbol is unbound, establish binding with new `Symbol`.
If symbol is bound to other `Symbol`, verify the new binding is identical.
If symbol is bound to Type, verify the new binding is same type.
If symbol is bound to value, verify the values are identical.

usage:
```
    testbinding(fv, :T, parameter) || return false
```
"""
function testbinding!(fv::FreeVariables, s::Symbol, t::Symbol)
    a = getindex(fv.d, s)
    ae = a[end]
    if ae == nothing
        a[end] = t
        true
    else
        ae == t
    end
end
       
"""
    `freevariables(a) -> Vector{Symbol}`

Return list of free variables in a type expression.
"""
freevariables(a) = Symbol[]
function freevariables(a::NewUnionAll)
    x = filter(x->x!=a.var.name, freevariables(a.body))
    union(x, freevariables(a.var.ub), freevariables(a.var.lb))
end
freevariables(a::NewUnion) = union(freevariables(a.a), freevariables(a.b))
freevariables(a::NewTypeVar) = union(freevariables(a.ub), freevariables(a.lb), [a.var])
freevariables(a::NewDataType) = mapfoldl(freevariables, union, Symbol[], a.parameters)




