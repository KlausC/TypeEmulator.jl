
Anny = NewTrait(:Any, NewTrait[])

Animal = NewTrait(:Animal, [Anny])
HasLegs = NewTrait(:HasLegs, [Animal])
FourLegged = NewTrait(:FourLegged, [HasLegs])
TwoLegged = NewTrait(:TwoLegged, [HasLegs])
Furry = NewTrait(:Furry, [Animal])
Cat = NewTrait(:Cat, [Animal, FourLegged, Furry])

@test linearise(Anny) == [Anny]
@test linearise(Animal) == reverse([Animal, Anny])
@test linearise(FourLegged) == reverse([FourLegged, HasLegs, Animal, Anny])
@test linearise(Cat) == reverse([Cat, Furry, FourLegged, HasLegs, Animal, Anny])

@test isnewsub(Cat, Animal)
@test isnewsub(Cat, HasLegs)
@test !isnewsub(Anny, Anny)
@test !isnewsub(Cat, Cat)
@test isnewsub(FourLegged, HasLegs)
