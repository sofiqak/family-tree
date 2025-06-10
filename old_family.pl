:-dynamic(woman/1).
woman(victoria_I).
woman(princesa_alice).
woman(princesa_vitoria).
woman(princesa_alice_young).
woman(princesa_margaret).
woman(elizabeth_II).
woman(anne).
woman(diana_spencer).
woman(kate_middleton).
woman(charlotte).
woman(meghan_markle).
woman(lilibet_diana).

:-dynamic(man/1).
man(edward_VII).
man(george_V).
man(edward_VIII).
man(george_VI).
man(henry).
man(george).
man(philip).
man(andrew).
man(edward).
man(charles_III).
man(william).
man(george_young).
man(louis).
man(harry).
man(archie).

:-dynamic(marry/2).
marry(elizabeth_II, philip).
marry(diana_spencer, charles_III).
marry(kate_middleton, william).
marry(meghan_markle, harry).

:-dynamic(parent/2).
% parent(x, y): x - родитель, y - ребенок
parent(victoria_I, princesa_alice).
parent(victoria_I, edward_VII).
parent(princesa_alice, princesa_vitoria).
parent(princesa_vitoria, princesa_alice_young).
parent(princesa_alice_young, philip).
parent(edward_VII, george_V).
parent(george_V, edward_VIII).
parent(george_V, george_VI).
parent(george_V, henry).
parent(george_V, george).
parent(george_VI, princesa_margaret).
parent(george_VI, elizabeth_II).
parent(philip, anne).
parent(philip, andrew).
parent(philip, edward).
parent(philip, charles_III).
parent(elizabeth_II, anne).
parent(elizabeth_II, andrew).
parent(elizabeth_II, edward).
parent(elizabeth_II, charles_III).
parent(charles_III, william).
parent(charles_III, harry).
parent(diana_spencer, william).
parent(diana_spencer, harry).
parent(william, george_young).
parent(william, charlotte).
parent(william, louis).
parent(kate_middleton, george_young).
parent(kate_middleton, charlotte).
parent(kate_middleton, louis).
parent(harry, archie).
parent(harry, lilibet_diana).
parent(meghan_markle, archie).
parent(meghan_markle, lilibet_diana).