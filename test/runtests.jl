using JuliaTypeEmulator
using Base.Test

@testset "metadata"     begin include("metadata.jl") end
@testset "types"        begin include("types.jl") end
@testset "multrait"     begin include("multrait.jl") end
@testset "conversions"  begin include("typeconversions.jl") end
@testset "relations"    begin include("relations.jl") end

