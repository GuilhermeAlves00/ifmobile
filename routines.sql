--geração de número telefônico / requisito 1

create or replace function gerarFone(dddOpt char, pref char)
returns varchar as $$
declare 
	fone varchar := '';
	restNum integer;
begin
	if exists(select ddd from estado where ddd=to_number(dddOpt,'999')) then
		fone := fone || dddOpt;
	else
		raise exception 'ddd % inexistente', dddOpt;
	end if;
	
	fone := fone || '9' || pref;
	restNum = 8 - length(pref);
	
	--adicionar números restantes após o prefixo randomicamente
	for i in 1..restNum loop
		fone := fone || to_char(floor(random() * 9 + 0)::int, '9');
	end loop;
	fone := replace(fone, ' ', '');
	
	--Evitar duplicidade e número terminados em zero
	if exists(select idnumero from chip where idnumero=fone) then
		return gerarFone(dddOpt, pref);
	elsif substr(fone, 8, 11) = '0000' then
		return gerarFone(dddOpt, pref);
	end if;	
	return fone;
end $$
language plpgsql;


--garantir chamadas apenas para chips ativos e indisponíveis / requisito 4
CREATE OR REPLACE FUNCTION chck_inativo_lig()
RETURNS TRIGGER AS $$
DECLARE
disp char(1);
atv char(1);
BEGIN
SELECT disponivel FROM chip WHERE NEW.chip_emissor = idnumero INTO disp;
SELECT ativo FROM chip WHERE NEW.chip_emissor = idnumero INTO atv;
IF NOT EXISTS (SELECT idnumero FROM chip WHERE idnumero = new.chip_emissor) 
OR NOT EXISTS (SELECT idnumero FROM chip WHERE idnumero = new.chip_receptor)
OR (disp = 'N' OR atv = 'N') THEN
	RAISE NOTICE 'Dado não inserido, verifique se o chip está inativo ou indisponivel';
	return null;
ELSE
	RAISE NOTICE 'Dado inserido na tabela ligação';
	return new;
END IF;
END;
$$ LANGUAGE PlPgSQL;


--associação de chip apenas a clientes com cadastro ativo / requisito 5
create or replace function verChipCli()
returns trigger as $$
declare
	clienteCan char;
	chipDisp char;
begin		
	select cancelado from cliente where idCliente=new.idCliente into clienteCan;
	select disponivel from chip where idNumero=new.idNumero into chipDisp;
	
    if clienteCan='S' and chipDisp='N' then
		raise exception 'Cliente e Chip indisponíveis';
	elsif clienteCan='S' then
		raise exception 'Cliente com contrato cancelado';
	elsif chipDisp='N' then
		raise exception 'Chip indisponível para associação';
	else 
        return new;
	end if;	
end $$
language plpgsql;

create trigger chipCliTri before insert on cliente_chip
for each row execute procedure verChipCli();




--Liberar os chips ligados a um cliente que teve o cadastro cancelado // Requisito 6
create or replace function libera_chips()
returns trigger as $$
declare
	allChips no scroll cursor 
	for select * from cliente_chip where idCliente=new.idCliente;
begin
	for linha in allChips loop
		update chip set disponivel='S' where idNumero=linha.idNumero;
	end loop;
	delete from cliente_chip where idCliente=new.idCliente;
	return new;
end $$
language plpgsql;

create trigger resetChipTri after update of cancelado on cliente
for each row execute procedure libera_chips();


--Função geradora de ligações / requisito 7
CREATE OR REPLACE FUNCTION preencher_tbl( mesano date )
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
	refcursor NO SCROLL CURSOR FOR SELECT idnumero FROM chip;
	random int;
	totaldia int;
	datainsert timestamp;
	uforg char(2);
	ufdest char(2);
	numrecpt char(11);
	tempo_rand time;
BEGIN
	totaldia := DATE_PART('days', DATE_TRUNC('month', mesano)
			  + '1 MONTH'::INTERVAL 
			  - '1 DAY'::INTERVAL);
	datainsert := to_timestamp(
	date_part('year', mesano)::varchar||'-'||date_part('month', mesano)::varchar||'-'||'1' ,'YYYY-MM-DD'); 
	FOR j IN 1..totaldia - 1 LOOP  
		tempo_rand := '00:10:00';
		FOR chip IN refcursor LOOP
				random := floor(random() * 10 + 1)::int;
				FOR i IN 1..random LOOP
					SELECT uf FROM estado ORDER BY RANDOM() LIMIT 1 INTO uforg;
					SELECT uf FROM estado ORDER BY RANDOM() LIMIT 1 INTO ufdest;
					SELECT idnumero FROM chip ORDER BY RANDOM() LIMIT 1 INTO numrecpt;
					INSERT INTO ligacao(datalig, chip_emissor, uforigem, chip_receptor, ufdestino, duracao)
					VALUES (datainsert, chip.idnumero, uforg, numrecpt, ufdest, tempo_rand);
					tempo_rand := interval '2 minutes' + tempo_rand;
					datainsert := interval '1 minute' + datainsert;
				END LOOP;
		END LOOP;
		datainsert := interval '1 day' + datainsert;
	END LOOP;
END $$;

CREATE TRIGGER chck_inativo_trg_lig BEFORE INSERT ON LIGACAO
FOR EACH ROW
EXECUTE PROCEDURE chck_inativo_lig();


--Tornar o chip indisponível quando associado a um cliente / requisito 8
create or replace function alterChip()
returns trigger as $$
begin		
	update chip set disponivel='N' where idNumero=new.idNumero;
	return new;
end $$
language plpgsql;

create trigger alterChipTri after insert on cliente_chip
for each row execute procedure alterChip();
