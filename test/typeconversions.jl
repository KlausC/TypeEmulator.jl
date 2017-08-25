
const em = emulate

@test em(Int) != nothing
@test em(Integer) != nothing
@test em(Array) != nothing
@test em(Array{T,N} where T where N) != nothing
@test em(Tuple{Int8,Array{X,Y} where {X, Int8<:Y<:Int32}}) != nothing

@test em(Base.Bottom) == NewBottom
@test em(Any) == NewAny
# @test em(Tuple{Float16, Float64}) == NewDataType(NewTypeVar(:Tuple, BaseModule))
