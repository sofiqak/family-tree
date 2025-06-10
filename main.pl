:- [old_family].

married(X, Y) :- marry(X, Y); marry(Y, X).
sibling_father(X, Y) :- parent(Z, Y), man(Z), parent(Z, X), dif(X, Y). % брат или сестра
sibling_mother(X, Y) :- parent(Z, Y), woman(Z), parent(Z, X), dif(X, Y).
sibling(X, Y) :- sibling_father(X, Y); not(sibling_father(X, Y)), sibling_mother(X, Y).

brother(X, Y) :- sibling(X, Y), man(X). % X - брат для Y
sister(X, Y) :- sibling(X, Y), woman(X). % X - сестра для Y
uncle(X, Y) :- parent(Z, Y), sibling(X, Z), man(X). % x - дядя, y - ребенок
aunt(X, Y) :- parent(Z, Y), sibling(X, Z), woman(X). % x - тетя, y - ребенок
grandfather(X, Y) :- parent(Z, Y), parent(X, Z), man(X). % X - дедушка для Y
grandmother(X, Y) :- parent(Z, Y), parent(X, Z), woman(X). % X - бабушка для Y
cousin(X, Y) :-  parent(T, Y), sibling(Z, T), parent(Z, X). % X, Y - двоюродные брат/сестра
father_in_law(X, Y) :- married(Y, Z), parent(X, Z), man(X). % X - тесть/свекор для Y
mother_in_law(X, Y) :- married(Y, Z), parent(X, Z), woman(X). % X - теща/свекровь для Y
brother_in_law(X, Y) :- married(Z, Y), sibling(X, Z), man(X). % X - шурин/деверь для Y
brother_in_law(X, Y) :- sibling(Z, Y), married(X, Z), man(X). % X - зять (муж сестры) для Y
sister_in_law(X, Y) :- married(Z, Y), sibling(X, Z), woman(X). % X - золовка/свояченница для Y
sister_in_law(X, Y) :- sibling(Z, Y), married(X, Z), woman(X). % X - невестка для Y

error_database :- write('Database error'), nl, !, fail.
error_outOfRange :- write('Value out of range'), nl, !, fail.
error_wrongName :- write('Not unique name'), nl, !, fail.
error_enter :- write('Wrong enter'), nl, !, fail.

% Список всех людей
get_people(L) :- findall(X, man(X); woman(X), L).

% Печать списка 
print_list(L) :- p_list(L, 1).
p_list([], _).
p_list([X | L], I) :- write(I), write('. '), write(X), nl, INew is I + 1, p_list(L, INew).

% Получить человека (2й аргумент) по номеру в списке L
get_person(X, X, L) :- not(number(X)), member(X, L).
get_person(X, R, L) :- number(X), Index is X - 1, nth0(Index, L, R), !; error_outOfRange.

% Вывод всех видов отношений
all_rels(L, R) :- write('Enter relationship type (number): '), nl, print_list(L), read(X), get_person(X, R, L).
all_relation(R) :- all_rels([parent, brother, sister, uncle, aunt, cousin, grandfather, grandmother, 
    spouse, 'father-in-law', 'mother-in-law', 'brother-in-law', 'sister-in-law'], R).
all_relation(man, R) :- all_rels([parent, brother, uncle, cousin, grandfather, grandmother, spouse, 'father-in-law', 'brother-in-law'], R).
all_relation(woman, R) :- all_rels([parent, sister, aunt, cousin, grandmother, spouse, 'mother_in_law', 'sister-in-law'], R).

% Если человек в браке и известен пол супруга, то не можем поменять пол
not_change_gen(Person) :- married(Person, Y), (man(Y); woman(Y)).

print_relation(Person, R) :- not_change_gen(Person), !, (man(Person), all_relation(man, R); woman(Person), all_relation(woman, R); all_relation(R)).
print_relation(_, R) :- all_relation(R).

check_man(X) :- man(X), !.
check_man(X) :- woman(X), !, write('Error: '), write(X), write(' is a woman'), nl, 
    (not_change_gen(X), write("Can't change this gender"), nl, !, fail;
    write('Change the gender? [y/n]: '), read(R), 
    (R = y, retract(woman(X)), assert(man(X)); R = n, error_database; error_enter)).
check_man(X) :- assert(man(X)).

check_woman(X) :- woman(X), !.
check_woman(X) :- man(X), !, write('Error: '), write(X), write(' is a man'), nl, 
    (not_change_gen(X), write("Can't change this gender"), nl, !, fail;
    write('Change the gender? [y/n]: '), read(R), 
    (R = y, retract(man(X)), assert(woman(X)); R = n, error_database; error_enter)).
check_woman(X) :- assert(woman(X)).

check_parent(Parent, Child) :- parent(Parent, Child), !.
check_parent(Parent, Child) :- assert(parent(Parent, Child)).

check_marry(X, Y) :- married(X, Y), !.
check_marry(X, Y) :- man(X), check_woman(Y), assert(marry(Y, X)), !.
check_marry(X, Y) :- woman(X), check_man(Y), assert(marry(X, Y)), !.
check_marry(X, Y) :- write('Enter '), write(X), write(' gender [m/w]: '), read(G),
    (G = m, check_man(X), check_woman(Y); G = w, check_woman(X), check_man(Y); error_enter).

% Найти родственника
before_check(R) :- write('All people:'), nl, get_people(L), print_list(L),
    write('Enter the person (whose relative): '), read(X), get_person(X, R, L), write(R).
after_check([]) :- write('none'), nl.
after_check([X | T]) :- nl, print_list([X | T]).

check_relation :- all_relation(Relation), before_check(Person),
    (Relation = parent, write("'s parents: "), findall(X, parent(X, Person), L);
    Relation = brother, write("'s brothers: "), findall(X, brother(X, Person), L);
    Relation = sister, write("'s sisters: "), findall(X, sister(X, Person), L);
    Relation = uncle, write("'s uncles: "), findall(X, uncle(X, Person), L);
    Relation = aunt, write("'s aunts: "), findall(X, aunt(X, Person), L);
    Relation = cousin, write("'s cousins: "), findall(X, cousin(X, Person), L);
    Relation = grandfather, write("'s grandfathers: "), findall(X, grandfather(X, Person), L);
    Relation = grandmother, write("'s grandmothers: "), findall(X, grandmother(X, Person), L);
    Relation = spouse, write("'s spouses: "), findall(X, married(X, Person), L);
    Relation = 'father-in-law', write("'s fathers-in-law: "), findall(X, father_in_law(X, Person), L);
    Relation = 'mother-in-law', write("'s mothers-in-law: "), findall(X, mother_in_law(X, Person), L);
    Relation = 'brother-in-law', write("'s brothers-in-law: "), findall(X, brother_in_law(X, Person), L);
    Relation = 'sister-in-law', write("'s sisters-in-law: "), findall(X, sister_in_law(X, Person), L)
    ), after_check(L).

add_person(R, new) :- get_people(L), member(R, L), !, error_wrongName.
add_person(_, new).
add_person(R, old) :- get_people(L), member(R, L), !.
add_person(R, old) :- write('Enter '), write(R), write("'s gender' [m/w]: "), read(Answer),
    (Answer = m, check_man(R); Answer = w, check_woman(R); error_enter).

prolog_add(R1, R2) :- write('All people:'), nl, get_people(L), print_list(L),
    write('Enter the person (relative): '), read(X), get_person(X, R1, L),
    write('Enter a new person (whose relative): '), read(R2), add_person(R2, new).

% Добавление отношения. предполагается, что R1 есть в базе знаний, R2 - нет
add_relation :- prolog_add(R1, R2), print_relation(R1, R),
    (R = parent, check_parent(R1, R2);
    (R = brother, check_man(R1); R = sister, check_woman(R1)), add_sibling(R1, R2);
    (R = uncle, check_man(R1); R = aunt, check_woman(R1)), add_aunt_or_uncle(R1, R2);
    R = cousin, add_cousin(R1, R2);
    (R = grandfather, check_man(R1); R = grandmother, check_woman(R1)), add_grandparent(R1, R2);
    R = spouse, check_marry(R1, R2);
    (R = 'father-in-law', check_man(R1); R = 'mother-in-law', check_woman(R1)), add_parent_in_law(R1, R2);
    (R = 'brother-in-law', check_man(R1); R = 'sister-in-law', check_woman(R1)), add_sibling_in_law(R1, R2)),
    add_person(R2, old), write('The relationship has been added.'), nl.

add_list(_, [], _).
add_list(child, [R1 | T], R2) :- check_parent(R1, R2), add_list(child, T, R2).

choose_person(L, Person) :- print_list(L), write('Enter the person (number): '), read(X), get_person(X, Person, L). 

add_sibling(R1, R2) :- findall(X, parent(X, R1), []), !, 
    write('Enter parent for '), write(R1), write(' and '), write(R2), write(': '), 
    read(Parent), add_person(Parent, new), check_parent(Parent, R1), check_parent(Parent, R2), add_person(Parent, old).
add_sibling(R1, R2) :- findall(X, parent(X, R1), L), add_list(child, L, R2).

add_aunt_or_uncle(R1, R2) :- findall(X, sibling(R1, X), []), !, add_sibling(R1, R), check_parent(R, R2).
add_aunt_or_uncle(R1, R2) :- findall(X, sibling(R1, X), L), 
    write('Choose '), write(R1), write("'s sibling, who will be "), write(R2), write("'s parent"), nl,
    choose_person(L, Parent), check_parent(Parent, R2).
    
add_grandparent(R1, R2) :-  findall(X, parent(R1, X), []), !, 
    write('Enter '), write(R2), write("'s parent, who is "), write(R1), write("'s child: "), 
    read(X), add_person(X, new), check_parent(R1, X), check_parent(X, R2), add_person(X, old).
add_grandparent(R1, R2) :- findall(X, parent(R1, X), L), 
    write('Choose '), write(R1), write("'s child, who will be "), write(R2), write("'s parent"), nl,
    choose_person(L, Parent), check_parent(Parent, R2).

add_cousin(R1, R2) :- findall(X, parent(X, R1), []), !, 
    write('Enter '), write(R1), write("'s parent, who is "), write(R2), write("'s aunt/uncle: "), 
    read(X), add_person(X, new), check_parent(X, R1), add_aunt_or_uncle(X, R2), add_person(X, old).
add_cousin(R1, R2) :- findall(X, parent(X, R1), L), 
    write('Choose '), write(R1), write("'s parent, who will be "), write(R2), write("'s aunt/uncle"), nl,
    choose_person(L, Parent), add_aunt_or_uncle(Parent, R2).

add_parent_in_law(R1, R2) :- findall(X, parent(R1, X), []), !, 
    write('Enter '), write(R1), write("'s child, who is "), write(R2), write("'s spouse: "), 
    read(X), add_person(X, new), check_parent(R1, X), check_marry(X, R2), add_person(X, old).
add_parent_in_law(R1, R2) :- findall(X, parent(R1, X), L),
    write('Choose '), write(R1), write("'s child, who will be "), write(R2), write("'s spouse"), nl,
    choose_person(L, R), check_marry(R, R2).

add_sibling_in_law(R1, R2) :- findall(X, sibling(X, R1); married(X, R1), []), !, 
    write('Enter '), write(R1), write("'s sibling, who is "), write(R2), write("'s spouse: "), 
    read(X), add_person(X, new), add_sibling(R1, X), check_marry(X, R2), add_person(X, old).
add_sibling_in_law(R1, R2) :- findall(X, sibling(X, R1), []), !, findall(X, married(X, R1), L),
    write('Choose '), write(R1), write("'s spouse, who will be "), write(R2), write("'s sibling"), nl,
    choose_person(L, R), add_sibling(R, R2).
add_sibling_in_law(R1, R2) :- findall(X, sibling(X, R1), L), !, 
    write('Choose '), write(R1), write("'s sibling, who will be "), write(R2), write("'s spouse"), nl,
    choose_person(L, R), check_marry(R, R2).

delete_relation :-
    write('All people:'), nl, get_people(L), print_list(L),
    write('Enter the person (relative): '), read(X), get_person(X, R1, L), print_relation(R1, R),
    (R = parent, delete_parent(R1);
    R = brother, delete_brother(R1);
    R = sister, delete_sister(R1);
    R = uncle, delete_uncle(R1);
    R = aunt, delete_aunt(R1);
    R = cousin, delete_cousin(R1);
    R = grandfather, delete_grandfather(R1);
    R = grandmother, delete_grandmother(R1);
    R = spouse, delete_spouse(R1);
    R = 'father-in-law', delete_father_in_law(R1);
    R = 'mother-in-law', delete_mother_in_law(R1);
    R = 'brother-in-law', delete_brother_in_law(R1);
    R = 'sister-in-law', delete_sister_in_law(R1)), 
    write('The relationship has been deleted.'), nl.

% R2 - кто-то для R1
delete_list(_, [], _).
delete_list(parent, [R1 | T], R2) :- parent(R2, R1),  retract(parent(R2, R1)), delete_list(parent, T, R2).
delete_list(child, [R1 | T], R2) :- parent(R1, R2),  retract(parent(R1, R2)), delete_list(child, T, R2).
delete_list(sibling, [R1 | T], R2) :- sibling(R1, R2), del_sibling(R2, R1), delete_list(sibling, T, R2).
delete_list(brother, [R1 | T], R2) :- brother(R2, R1),  del_sibling(R2, R1), delete_list(brother, T, R2).
delete_list(sister, [R1 | T], R2) :- sister(R2, R1),  del_sibling(R2, R1), delete_list(sister, T, R2).
delete_list(married, [R1 | T], R2) :- (marry(R1, R2), retract(marry(R1, R2)); marry(R2, R1), retract(marry(R2, R1))), delete_list(married, T, R2).

del_prolog(L, R2) :- write('Relatives:'), nl, print_list(L), write('Choose the person: '), read(X), get_person(X, R2, L).

delete_parent(R1) :- findall(X, parent(R1, X), []), write('No such relatives'), nl, !.
delete_parent(R1) :- findall(X, parent(R1, X), L), del_prolog(L, R2), retract(parent(R1, R2)).

delete_spouse(R1) :- findall(X, married(R1, X), []), write('No such relatives'), nl, !.
delete_spose(R1) :- findall(X, married(R1, X), L), del_prolog(L, R2), (marry(R1, R2), retract(marry(R1, R2)); marry(R2, R1), retract(marry(R2, R1))).

del_sibling(R1, R2) :- findall(X, parent(X, R1), P1List), findall(X, parent(X, R2), P2List), intersection(P1List, P2List, R), delete_list(child, R, R1).

delete_brother(R1) :- check_man(R1), findall(X, brother(R1, X), []), write('No such relatives'), nl, !. 
delete_brother(R1) :- check_man(R1), findall(X, brother(R1, X), L), del_prolog(L, R2), del_sibling(R1, R2).

delete_sister(R1) :- check_woman(R1), findall(X, sister(R1, X), []), write('No such relatives'), nl, !.
delete_sister(R1) :- check_woman(R1), findall(X, sister(R1, X), L), del_prolog(L, R2), del_sibling(R1, R2).

delete_uncle(R1) :- check_man(R1), findall(X, uncle(R1, X), []), write('No such relatives'), nl, !.
delete_uncle(R1) :- check_man(R1), findall(X, uncle(R1, X), L), del_prolog(L, R2), del_uncle(R1, R2).

del_uncle(R1, R2) :- findall(X, brother(R1, X), L1), findall(X, parent(X, R2), L2), intersection(L1, L2, L), delete_list(brother, L, R1).

delete_aunt(R1) :- check_woman(R1), findall(X, aunt(R1, X), []), write('No such relatives'), nl, !.
delete_aunt(R1) :- check_woman(R1), findall(X, aunt(R1, X), L), del_prolog(L, R2), del_aunt(R1, R2).

del_aunt(R1, R2) :- findall(X, sister(R1, X), L1), findall(X, parent(X, R2), L2), intersection(L1, L2, L), delete_list(sister, L, R1).

delete_grandfather(R1) :- check_man(R1), findall(X, grandfather(R1, X), []), write('No such relatives'), nl, !.
delete_grandfather(R1) :- check_man(R1), findall(X, grandfather(R1, X), L), del_prolog(L, R2), del_grandparent(R1, R2).

del_grandparent(R1, R2) :- findall(X, parent(R1, X), L1), findall(X, parent(X, R2), L2), intersection(L1, L2, L), delete_list(parent, L, R1).

delete_grandmother(R1) :- check_woman(R1), findall(X, grandmother(R1, X), []), write('No such relatives'), nl, !.
delete_grandmother(R1) :- check_woman(R1), findall(X, grandmother(R1, X), L), del_prolog(L, R2), del_grandparent(R1, R2).

delete_cousin(R1) :- findall(X, cousin(R1, X), []), write('No such relatives'), nl, !.
delete_cousin(R1) :- findall(X, cousin(R1, X), L), del_prolog(L, R2), del_cousin(R1, R2). 

del_cousin(R1, R2) :- findall(X, parent(X, R1), L1), findall(X, aunt(X, R2); uncle(X, R2), L2), intersection(L1, L2, L), delete_list(child, L, R1).

delete_father_in_law(R1) :- check_man(R1), findall(X, father_in_law(R1, X), []), write('No such relatives'), nl, !.
delete_father_in_law(R1) :- check_man(R1), findall(X, father_in_law(R1, X), L), del_prolog(L, R2), del_parent_in_law(R1, R2).

del_parent_in_law(R1, R2) :- findall(X, parent(R1, X), L1), findall(X, married(X, R2), L2), intersection(L1, L2, L), delete_list(parent, L, R1).

delete_mother_in_law(R1) :- check_woman(R1), findall(X, mother_in_law(R1, X), []), write('No such relatives'), nl, !.
delete_mother_in_law(R1) :- check_woman(R1), findall(X, mother_in_law(R1, X), L), del_prolog(L, R2), del_parent_in_law(R1, R2).

delete_brother_in_law(R1) :- check_man(R1), findall(X, brother_in_law(R1, X), []), write('No such relatives'), nl, !.
delete_brother_in_law(R1) :- check_man(R1), findall(X, brother_in_law(R1, X), L), del_prolog(L, R2), del_brother_in_law(R1, R2).

del_sibling_in_law(R1, R2) :- findall(X, married(R1, X), L1), findall(X, sibling(R2, X), L2), intersection(L1, L2, L), delete_list(married, L, R1).

del_brother_in_law(R1, R2) :- findall(X, brother(R1, X), L1_0), findall(X, married(X, R2), L2_0), intersection(L1_0, L2_0, []), !, del_sibling_in_law(R1, R2).
del_brother_in_law(R1, R2) :- findall(X, brother(R1, X), L1), findall(X, married(X, R2), L2), intersection(L1, L2, L), delete_list(brother, L, R1).

delete_sister_in_law(R1) :- check_woman(R1), findall(X, sister_in_law(R1, X), []), write('No such relatives'), nl, !.
delete_sister_in_law(R1) :- check_woman(R1), findall(X, sister_in_law(R1, X), L), del_prolog(L, R2), del_sister_in_law(R1, R2).

del_sister_in_law(R1, R2) :- findall(X, sister(R1, X), L1_0), findall(X, married(X, R2), L2_0), intersection(L1_0, L2_0, []), !, del_sibling_in_law(R1, R2).
del_sister_in_law(R1, R2) :- findall(X, sister(R1, X), L1), findall(X, married(X, R2), L2), intersection(L1, L2, L), delete_list(sister, L, R1).

% Найти родство между двумя людьми
find_relation :-  write('All people:'), nl, get_people(L), print_list(L), 
    write('Enter first person: '), read(X), get_person(X, R1, L), 
    write('Enter second person: '), read(Y), get_person(Y, R2, L),
    (main_find_relate(R1, R2, R), !, print_rels(R); write(R1), write(' and '), write(R2), write(" are not related"), nl).

% R1 ближе к листу, чем R2. R - отношение родства. 
% Подсписки устроены следующим образом: [родственник | родственные отношения]. например, [louis, father, grandmother]
main_find_relate(R1, R2, R) :- find_relate(R1, R2, Res1, yes), find_relate(R2, R1, Res2, yes), !, min_len([Res1, Res2], R).
main_find_relate(R1, R2, R) :- find_relate(R1, R2, R, yes), !.
main_find_relate(R1, R2, R) :- find_relate(R2, R1, R, yes).

find_relate(R1, R2, R, FlagRev) :- fr(R2, [[R1]], R, FlagRev).

fr(End, L, [End | R], _) :- memberp(End, L, R), !.
fr(End, L, R, yes) :- step(End, L, [], []), !, fr_reverse(End, L, R). % если End оказался выше всех вершин в дереве
fr(End, L, _, no) :- step(End, L, [], []), !, fail.
fr(End, L, R, FlagRev) :- step(End, L, [], Res), fr(End, Res, R, FlagRev).

step(_, [], Res, Res).
step(End, [X | T], Acc, Res) :- list_relative(End, X, R1), list_married(End, X, R2), 
    (append(R1, R2, []), !, step(End, T, Acc, Res); append(R1, R2, R), append(R, Acc, AccNew), step(End, T, AccNew, Res)).   

fr_reverse(End, L, R) :- get_head(L, Headers), fr_rev(End, Headers, Res), min_len(Res, MinR), smart_append(MinR, L, R).

% Получить первые элементы подсписков
get_head([], []).
get_head([[X | _] | T], [X | R]) :- get_head(T, R).

% Для каждой вершины из Headers найти родственное отношение с End
fr_rev(_, [], []).
fr_rev(End, [X | T], [R | RS]) :- find_relate(End, X, R, no), fr_rev(End, T, RS).

% Найти список с минимальной длиной
min_len([X | T], MinR) :- length(X, N), min_l(T, N, X, MinR).
min_l([], _, R, R).
min_l([X | T], MinLen, _, Res) :- length(X, N), N > 0, N < MinLen, !, min_l(T, N, X, Res).
min_l([_ | T], MinLen, MinL, Res) :- min_l(T, MinLen, MinL, Res).

% Склеивание списков, если совпадает конец первого и начало второго. minR - плоский список, L - список списков
smart_append([X | T], L, R) :- memberp(X, L, R2), append([X | T], [X | R2], R).

% Обновление списка родственников для одного списка 
list_relative(End, [Top | Rels], [[End, parent, Top | Rels]]) :- parent(End, Top), !.
list_relative(End, [Top | Rels], [[End, brother, Top | Rels]]) :- brother(End, Top), !.
list_relative(End, [Top | Rels], [[End, sister, Top | Rels]]) :- sister(End, Top), !.
list_relative(End, [Top | Rels], [[End, cousin, Top | Rels]]) :- cousin(End, Top), !.
list_relative(End, [Top | Rels], [[End, aunt, Top | Rels]]) :- aunt(End, Top), !.
list_relative(End, [Top | Rels], [[End, uncle, Top | Rels]]) :- uncle(End, Top), !.
list_relative(End, [Top | Rels], [[End , spouse, X, parent, Top | Rels]]) :- parent(X, Top), married(X, End), !.
list_relative(_, [Top | Rels], R) :- findall(X, grandfather(X, Top), L1), findall(X, grandmother(X, Top), L2), 
    append_list(L1, [Top | Rels], grandfather, R1), append_list(L2, [Top | Rels], grandmother, R2), append(R1, R2, R).

% Обновление списка для случая брака 
list_married(End, [Top | Rels], [[End, spouse, Top | Rels]]) :- married(End, Top), !.
list_married(End, [Top | Rels], [[End, brother-in-law, Top | Rels]]) :- brother_in_law(End, Top), !.
list_married(End, [Top | Rels], [[End, sister-in-law, Top | Rels]]) :- sister_in_law(End, Top), !.
list_married(_, [Top | Rels], R) :- findall(X, father_in_law(X, Top), L1), findall(X, mother_in_law(X, Top), L2), 
    append_list(L1, [Top | Rels], father-in-law, R1), append_list(L2, [Top | Rels], mother-in-law, R2), append(R1, R2, R).

% Найти подсписок, в котором есть EL на первом месте. Детерминированные вычисления.
memberp(EL, [[EL | L] | _], L) :- !.
memberp(EL, [_ | T], SubL) :- memberp(EL, T, SubL).

% Добавить вершину из списка в каждый список
append_list([], _, _, []).
append_list([Top | T], L, S, [[Top | [S | L]] | R]) :- append_list(T, L, S, R). 

% Печать родственных отношений. 
print_rels([X | T]) :- write(X), print_rels(no, T).
print_rels(_, []).
print_rels(yes, [X | T]) :- (man(X); woman(X)), !, write(' and '), write(X), print_rels(no, T).
print_rels(no, [X | T]) :- (man(X); woman(X)), !, write(X), print_rels(yes, T).
print_rels(yes, [X | T]) :- write(', who is the '), write(X), write(' of '), print_rels(no, T).
print_rels(no, [X | T]) :- write(' is the '), write(X), write(' of '), print_rels(no, T).

% Сохранение фактов
save_facts(Filename) :- tell(Filename), 
    listing(woman/1), listing(man/1), listing(parent/2), listing(marry/2),
    told, write('Database in '), write(Filename), nl.

% Интерфейс с пользователем
start :-
    write('Make a choice:'), nl,
    print_list(['Find a relationship between 2 people', 'Find 1 relative', 'Add relationship', 'Delete relationship', 'Stop']),
    write('Your choice: '), read(Choice),
    (Choice = 5, save_facts('new_family.pl'), write('Bye!'), !;
    (Choice = 1, find_relation;
    Choice = 2, check_relation;
    Choice = 3, add_relation;
    Choice = 4, delete_relation), !, nl, start;
    error_enter; nl, start).
