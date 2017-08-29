

export FreeVariables, NewTypeWithVar, getbinding, bind!, testbinding!

FreeVariables() = FreeVariables(Dict{Symbol,Any}())

# Working with the symbols of type variables
"""
    `push!(::FreeVariables, ::Symbol)`

Add a new type variable to stack. The variable has no value (is unbound).
"""
function Base.push!(env::FreeVariables, s::NewTypeVar)
    a = get!(env.d, s) do
        []
    end
    push!(a, nothing)
    env
end

"""
    `pop!(::FreeVariables, ::Symbol)`

Remove variable from stack of free variables.
"""
function Base.pop!(env::FreeVariables, s::NewTypeVar)
    a = getindex(env.d, s)
    ae = pop!(a)
    if isempty(a)
        delete!(env.d, s)
    end
    ae
end

function binding(env::FreeVariables, s::NewTypeVar)
    a = getindex(env.d, s)
    a[end]
end

function bind!(env::FreeVariables, s::NewTypeVar, t::Any)
    a = getindex(env.d, s)
    a[end] = t
end

"""
    `testbinding!(env::FreeVariables, s::Symbol, t::newSymbol)`

If symbol is unbound, establish binding with new `Symbol`.
If symbol is bound to other `Symbol`, verify the new binding is identical.
If symbol is bound to Type, verify the new binding is same type.
If symbol is bound to value, verify the values are identical.

usage:
```
    testbinding(env, :T, parameter) || return false
```
"""
function testbinding!(env::FreeVariables, s::NewTypeVar, t::NewType)
    # println("testbinding-type $s $t")
    # map(println, stacktrace())
    a = getindex(env.d, s)
    ae = a[end]
    r = if ae == nothing
        a[end] = t
        true
    else
        issubenv(t, ae, env)
    end
end

function testbinding!(env::FreeVariables, s::NewTypeVar, t::Any)
    # println("testbinding-any $env $s $t")
    a = getindex(env.d, s)
    ae = a[end]
    r = if ae == nothing
        a[end] = t
        true
    else
        ae == t
    end
end
       
"""
    `freevariables(a) -> Vector{Symbol}`

Return list of free variables in a type expression.
obsolete
"""
freevariables(a) = Symbol[]
function freevariables(a::NewUnionAll)
    x = filter(x->x!=a.var.name, freevariables(a.body))
    union(x, freevariables(a.var.ub), freevariables(a.var.lb))
end
freevariables(a::NewUnion) = union(freevariables(a.a), freevariables(a.b))
freevariables(a::NewTypeVar) = union(freevariables(a.ub), freevariables(a.lb), [a.var])
freevariables(a::NewDataType) = mapfoldl(freevariables, union, Symbol[], a.parameters)




