
# test implementation
struct NewTrait<:NewType
    name::Symbol
    super::Any
end
Base.show(io::IO, x::NewTrait) = print(io, x.name)
JuliaTypeEmulator.supertypes(x::NewTrait) = x.super
JuliaTypeEmulator.is_pushed(::Type{NewTrait}) = true
isnewsub(a::NewTrait, b::NewTrait) = a != b && b ∈ linearize(a)


# Test

Anny = NewTrait(:Any, NewTrait[])

Animal = NewTrait(:Animal, [Anny])
HasLegs = NewTrait(:HasLegs, [Animal])
FourLegged = NewTrait(:FourLegged, [HasLegs])
TwoLegged = NewTrait(:TwoLegged, [HasLegs])
Furry = NewTrait(:Furry, [Animal])
Cat = NewTrait(:Cat, [Animal, FourLegged, Furry])

@test linearize(Anny) == [Anny]
@test linearize(Animal) == reverse([Animal, Anny])
@test linearize(FourLegged) == reverse([FourLegged, HasLegs, Animal, Anny])
@test linearize(Cat) == reverse([Cat, Furry, FourLegged, HasLegs, Animal, Anny])

@test isnewsub(Cat, Animal)
@test isnewsub(Cat, HasLegs)
@test !isnewsub(Anny, Anny)
@test !isnewsub(Cat, Cat)
@test isnewsub(FourLegged, HasLegs)
