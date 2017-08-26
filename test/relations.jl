
const em = emulate
const issub = isnewsubtype

@test issub(em(Int), em(Number))
@test issub(NewBottom, em(Base.Bottom))
@test issub(NewBottom, em(Any))

typelist = (Int8, Int16, Int, Signed, UInt32, Unsigned, Integer, Rational, Real, Number, BigInt, BigFloat, Complex128, Complex, Irrational)
for s in typelist, t in typelist
    r = issub(em(s), em(t)) == (s <: t)
    r || println(STDERR, "(", s, ") <: (", t, ") ", (s<:t))
    @test issub(em(s), em(t)) == (s <: t)
end

typelist = (Int8, Array, Array{T,1} where T, Array{T,N} where {T<:Float64, Int8<:N<:Real})
for s in typelist, t in typelist
    @test issub(em(s), em(t)) == (s <: t)
    issub(em(s), em(t)) == (s <: t) || println("(", s, ") <: (", t, ") ", (s<:t))
end

typelist = (Vector{T} where Signed<:T<:Number, Vector{T} where Integer<:T<:Real)
for s in typelist, t in typelist
    issub(em(s), em(t)) == (s <: t) || println("(", s, ") <: (", t, ") ", (s<:t))
    @test issub(em(s), em(t)) == (s <: t)
end

typelist = (Union{Int,Signed}, Int, UInt8)
for s in typelist, t in typelist
    issub(em(s), em(t)) == (s <: t) || println("(", s, ") <: (", t, ") ", (s<:t))
    @test issub(em(s), em(t)) == (s <: t)
end

typelist = (Tuple{T, T} where T, Tuple{S, T} where {S, T})
for s in typelist, t in typelist
    issub(em(s), em(t)) == (s <: t) || println("(", s, ") <: (", t, ") ", (s<:t))
    @test issub(em(s), em(t)) == (s <: t)
end

typelist = (Tuple{Vector{S}, Vector{S}, Vector{T}} where {S,T}, Tuple{Vector{S}, Vector{T}, Vector{T}} where {S,T})
for s in typelist, t in typelist
    r = issub(em(s), em(t)) == (s <: t)
    r || println(STDERR, "(", s, ") <: (", t, ") ", (s<:t))
    if r
        @test issub(em(s), em(t)) == (s <: t)
    else
        @test_broken issub(em(s), em(t)) == (s <: t)
    end
end

typelist = (Tuple{Int, Integer}, Tuple{Integer, Int}, Tuple{S, T} where S<:T where T)
for s in typelist, t in typelist
    r = issub(em(s), em(t)) == (s <: t)
    r || println(STDERR, "(", s, ") <: (", t, ") ", (s<:t))
    if r
        @test issub(em(s), em(t)) == (s <: t)
    else
        @test_broken issub(em(s), em(t)) == (s <: t)
    end
end


