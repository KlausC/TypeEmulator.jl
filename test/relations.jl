
const em = emulate

@test issubtype(em(Int), em(Number))
@test issubtype(NewBottom, em(Base.Bottom))
@test issubtype(NewBottom, em(Any))

typelist = (Int8, Int16, Int, Signed, UInt32, Unsigned, Integer, Rational, Real, Number, BigInt, BigFloat, Complex128, Complex, Irrational)
for s in typelist, t in typelist
    @test issubtype(em(s), em(t)) == (s <: t)
end

typelist = (Int8, Array, Array{T,1} where T, Array{T,N} where {T<:Float64, Int8<:N<:Real})
for s in typelist, t in typelist
    @test issubtype(em(s), em(t)) == (s <: t)
    issubtype(em(s), em(t)) == (s <: t) || println("(", s, ") <: (", t, ") ", (s<:t))
end

typelist = (Vector{T} where Signed<:T<:Number, Vector{T} where Integer<:T<:Real)
for s in typelist, t in typelist
    issubtype(em(s), em(t)) == (s <: t) || println("(", s, ") <: (", t, ") ", (s<:t))
    @test issubtype(em(s), em(t)) == (s <: t)
end

typelist = (Union{Int,Signed}, Int, UInt8)
for s in typelist, t in typelist
    issubtype(em(s), em(t)) == (s <: t) || println("(", s, ") <: (", t, ") ", (s<:t))
    @test issubtype(em(s), em(t)) == (s <: t)
end

typelist = (Tuple{T, T} where T, Tuple{S, T} where {S, T})
for s in typelist, t in typelist
    issubtype(em(s), em(t)) == (s <: t) || println("(", s, ") <: (", t, ") ", (s<:t))
    @test issubtype(em(s), em(t)) == (s <: t)
end

typelist = (Tuple{Vector{S}, Vector{S}, Vector{T}} where {S,T}, Tuple{Vector{S}, Vector{T}, Vector{T}} where {S,T})
for s in typelist, t in typelist
    issubtype(em(s), em(t)) == (s <: t) || println(STDERR, "(", s, ") <: (", t, ") ", (s<:t))
    @test issubtype(em(s), em(t)) == (s <: t)
end



