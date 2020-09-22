--2.1
select ligacao.dataLig, ligacao.chip_receptor, ligacao.duracao from ligacao 
inner join chip on ligacao.chip_emissor=chip.idNumero
inner join auditoria on chip.idNumero=auditoria.idNumero
group by ligacao.dataLig, ligacao.chip_receptor, ligacao.duracao, auditoria.idNumero, auditoria.dataInicio, auditoria.dataTermino
having auditoria.idNumero='61985264220' 
and date(ligacao.dataLig) between auditoria.dataInicio and auditoria.dataTermino;

--2.2
select date_part('year', dataLig) as "Ano", date_part('month', dataLig) as "Mes",
date_part('day', dataLig) as "Dia", sum(duracao) as "Total"
from ligacao where chip_emissor='61985264220' 
group by rollup("Ano", "Mes", "Dia");



