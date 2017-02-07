function F1 = F1_measure(P, R)

F1 = 2*(P.*R)./(P+R);

end
