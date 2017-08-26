
# methods which check the subtype relationships between NewTypes

const FV = FreeVariables

isnewsubtype(a::NewType, b::NewType) = issubenv(a, b, FV())
isnewsubtype(a::Type, b::Type) = (a <: b)

"""
    `issubenv(a, b, env)`

Test if type a is subtype of type b with the given variables and their bindings.
"""
issubenv(a::NewType, b::NewUnion, env::FV) = issubenv(a, b.a, env) || issubenv(a, b.b, env)
issubenv(::NewBottomType, b::NewType, env::FV) = true

# is any of the "supertypes" of `a` a direct subtype of `b`?
issubenv(a::NewType, b::NewType, env::FV) = any(isdirect1(st, b, env) for st in linearize(a))

# perform trivial checks before calling specialized functions
function isdirect1(a::NewType, b::NewType, env::FV)
    equaltypes(a, b, env) || b == NewAny || isdirect(a, b, env)
end

# maintain stack of free variables and delegate to body
isdirect(a::NewType, b::NewUnionAll, env::FV) = withvariable(isdirect, a, b, env)

# check name identity then specialize for ordinary data types and tuple types 
function isdirect(a::NewType, b::NewDataType, env::FV)
    a = typebody(a)
    a.name == b.name || return false
    if isatuple(b)
        walktuple(a, b, env, iscovar)
    else
        walkordinary(a, b, env, isinvar)
    end
end

# handle the parameter lists of ordinary types
function walkordinary(a::NewDataType, b::NewDataType, env::FV, func::Function)
    pa = a.parameters; na = length(pa)
    pb = b.parameters; nb = length(pb)
    na == nb && all(func(pa[k], pb[k], env) for k = 1:na)
end

# handle the parameter lists of tuples (with varargs)
function walktuple(a::NewDataType, b::NewDataType, env::FV, func::Function)
    pa = a.parameters; na = length(pa)
    pb = b.parameters; nb = length(pb)
    nb == 0 && return na == 0
    tbb = typebody(pb[nb])
    if na == 0
        return nb == 1 && isavararg(tbb) && !isa(tbb.parameters[2], Integer)
    end
    tba = typebody(pa[na])
    if isavararg(tbb)
        vtb = tbb.parameters[1]
        vlb = tbb.parameters[2]
        if isavararg(tba)
            nc = min(na, nb)
            all(func(pa[k], pb[k], env) for k = 1:nc-1) || return false
            vta = tba.parameters[1]
            vla = tba.parameters[2]
            if isa(vla, Integer)
                if isa(vlb, Integer)
                    na + vla == nb + vlb || return false
                    vla == 0 || vlb == 0 || func(vta, vtb, env) || return false
                else
                    na + vla <= nb || return false
                    vla == 0 || func(vta, vtb, env) || return false
                end
            else
                if isa(vlb, Integer)
                    na >= nb + vlb || return false
                    vlb == 0 || func(vta, vtb, env) || return false
                else
                    na >= nb || return false
                    func(vta, vtb, env) || return false
                end
            end
            all(func(vta, pb[k], env) for k = nc:nb-1) &&
            all(func(pa[k], vtb, env) for k = nc:na-1)
        else
            na >= nb - 1 || return false
            all(func(pa[k], pb[k], env) for k=1:nb-1) || return false
            if isa(vlb, Integer)
                nb - 1 + vlb == na || return false
            end
            all(func(pa[k], vtb, env) for k = nb:na)
        end
    else
        !isavararg(tba) && na == nb && all(func(pa[k], pb[k], env) for k=1:nb)
    end
end

# parameters checking if type variables may be involved
# parameters can be NewVarType, NewType, or any bits type
# if no type variables are involved, invariant version requires type equality
# while covariant version tests the subtype relation.
# if on of the arguments is a type variable, there is no difference
# between covariant and invariant case.

iscovar(a, b, env::FV) = isinvar(a, b, env)
iscovar(a::NewType, b::NewType, env::FV) = issubenv(a, b, env)

isinvar(a, b, env::FV) = equaltypes(a, b, env)
isinvar(a::NewTypeVar, b, env::FV) = false
#isinvar(a::NewType, b::NewType, env::FV) = equaltypes(a, b, env)
isinvar(a::NewTypeVar, b::NewType, env::FV) = false

# if the second argument is a type variable, the first argument is bound to it
# if it is already bound to another value false is returned
# additionally the lower and upper bounds are verified
function isinvar(a, b::NewTypeVar, env::FV)
    testbinding!(env, b.name, a) do
        true
    end
end
function isinvar(a::NewType, b::NewTypeVar, env::FV)
    testbinding!(env, b.name, a) do
        nenv = deepcopy(env)
        iscovar(b.lb, a, env) &&
        iscovar(a, b.ub, nenv)
    end
end

function isinvar(a::NewTypeVar, b::NewTypeVar, env::FV)
    testbinding!(env, b.name, a.name) do
        # nenv = deepcopy(env)
        iscovar(b.lb, a.lb, env) &&
        iscovar(a.ub, b.ub, env)
    end
end    


# utility functions

function withvariable(f::Function, a, b::NewUnionAll, env::FV)
    push!(env, b.var.name)
    r = f(a, b.body, env)
    pop!(env, b.var.name)
    r
end

equaltypes(a, b, env::FV) = a == b
equaltypes(a, b::NewTypeVar, env::FV) = isinvar(a, b, env)
equaltypes(a, b::NewUnionAll, env::FV) = withvariable(equaltypes, a, b, env)

equaltypes(a::NewType, b::NewDataType, env::FV) = equaltypes(typebody(a), b, env)

function equaltypes(a::NewDataType, b::NewDataType, env::FV)
    a.name == b.name || return false
    if isatuple(a)
        walktuple(a, b, env, equaltypes)
    else
        walkordinary(a, b, env, equaltypes)
    end
end

typebody(x::Any) = x
typebody(x::NewUnionAll) = typebody(x.body)

isavararg(x) = isaspecial(x, :Vararg)
isatuple(x) = isaspecial(x, :Tuple)
isaspecial(x, ::Symbol) = false
isaspecial(x::NewDataType, s::Symbol) = x.name.name == s
isaspecial(x::NewUnionAll, s::Symbol) = isaspecial(typebody(x), s)

