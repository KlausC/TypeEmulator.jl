
@test NewModule(:Main, nothing, Dict()) != nothing
@test NewTypeName(:TN, MainModule) != nothing
@test NewTypeVar(:X, NewBottom, NewAny) != nothing
