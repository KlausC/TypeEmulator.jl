

@test NewModule(:Main, nothing).name == :Main
@test NewTypeVar(:T)  != nothing
@test NewDataType(NewTypeName(:DT, MainModule), nothing, NewEmpty, true, false, false) != nothing



