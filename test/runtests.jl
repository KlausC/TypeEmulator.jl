using JuliaTypeEmulator
using Base.Test

@testset "metadata"     begin include("metadata.jl") end
@testset "types"        begin include("types.jl") end
@testset "linear"       begin include("linear.jl") end
@testset "conversions"  begin include("typeconversions.jl") end
@testset "relations"    begin include("relations.jl") end
@testset "subtype"      begin include("subtype.jl") end

