--2.1
select ligacao.dataLig, ligacao.chipReceptor, ligacao.duracao from ligacao 
inner join chip on ligacao.chipEmissor=chip.idNumero
inner join auditoria on chip.idNumero=auditoria.idNumero
group by ligacao.dataLig, ligacao.chipReceptor, ligacao.duracao, auditoria.idNumero, auditoria.dataInicio, auditoria.dataTermino
having auditoria.idNumero='83985264220' 
and date(ligacao.dataLig) between auditoria.dataInicio and auditoria.dataTermino;

--2.2
select date_part('year', dataLig) as "Ano", date_part('month', dataLig) as "Mes",
date_part('day', dataLig) as "Dia", sum(duracao) as "Total"
from ligacao where chipEmissor='81985227078' 
group by rollup("Ano", "Mes", "Dia");



