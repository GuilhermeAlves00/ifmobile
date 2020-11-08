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



--retornar até 5 números disponíveis / requisito 2 
create or replace function numeros_disponivel()
returns table (fone char) as $$
begin
	return query 
		select idNumero from chip where disponivel = 'S' order by random() 
        limit 5;
end;
$$ language plpgsql;



--rotina geradora de fatura / requisito 3
CREATE OR REPLACE FUNCTION veri_are_cobertu( est_atual char(2),  est_cobert char(2) )
	RETURNS CHAR(1)
AS $$
DECLARE
	igual char(1);
BEGIN
	IF (SELECT estado.idregiao FROM estado
	INNER JOIN cobertura ON cobertura.idregiao = estado.idregiao
	WHERE uf = est_atual) = (SELECT estado.idregiao FROM estado
	INNER JOIN cobertura ON cobertura.idregiao = estado.idregiao
	WHERE uf = est_cobert )	THEN
		igual := 'S';
	ELSE
		igual := 'N';
	END IF;
	RETURN igual; 
END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE PROCEDURE gerar_fatura( mes_referencia date )
AS $$
DECLARE
	refcursor NO SCROLL CURSOR FOR SELECT 
	chip.idnumero, chip.idplano, ligacao.datalig, ligacao.duracao, uforigem, ufdestino, chip_receptor 
	FROM chip
	INNER JOIN ligacao ON ligacao.chip_emissor = chip.idnumero
	;
	
	refcursor1 NO SCROLL CURSOR FOR SELECT
	chip.idnumero, chip.ativo, chip.idplano, plano.valor valorp, plano.fminin, plano.fminout  
	FROM chip
	INNER JOIN plano ON chip.idplano = plano.idplano;

	
	valor_pla numeric;
	min_m_op int;
	min_out_op int;
	
	valor_m_exced int;
	valor_out_exced int;
	
	val_exced numeric;
	roaming numeric;
	valor_total numeric;
	datainsert date;
	taxas record;
	
	valor_roaming numeric;
	valor_min_add_out numeric;
	valor_min_add_in numeric;
	chip_emissor_plan int;
BEGIN
	
	datainsert := to_date(date_part('year', mes_referencia)::varchar||'-'||date_part('month', mes_referencia)::varchar||'-'||DATE_PART('days', DATE_TRUNC('month', mes_referencia)
			  + '1 MONTH'::INTERVAL 
			  - '1 DAY'::INTERVAL), 'YYYY-MM-DD');
	-- Correndo os chips
	FOR numero1 IN refcursor1 LOOP
		min_m_op := 0;
		min_out_op := 0;
		valor_total := 0;
		roaming := 0;
		valor_m_exced := 0;
		valor_out_exced := 0;
		valor_pla := 0;
		val_exced := 0;
		valor_roaming :=0;
		valor_min_add_out := 0;
		valor_min_add_in := 0;
			-- Verificando se o chip esta ativo
		IF (numero1.ativo) = 'S' THEN
		FOR numero IN refcursor LOOP
			-- verificando se a ligação está no mesmo mês
			IF (numero1.idnumero = numero.idnumero)
			THEN
			IF (date_part('year', numero.datalig) = date_part('year', mes_referencia) AND date_part('month', mes_referencia) = date_part('month', numero.datalig))
			THEN
			--correr cada numero 
			
			IF (veri_are_cobertu(numero.uforigem, numero.ufdestino) = 'S') 
			THEN
			--Somando os valores de roaming por cada ligação
				SELECT tarifa.valor 
				FROM plano
				INNER JOIN plano_tarifa ON plano.idplano = plano_tarifa.idplano
				INNER JOIN tarifa ON plano_tarifa.idtarifa = tarifa.idtarifa
				WHERE tarifa.descricao = 'Roaming básico' AND numero1.idplano = plano.idplano
				INTO valor_roaming; 
				roaming := roaming + valor_roaming;
			END IF;
			SELECT idplano 
			FROM chip
			WHERE idnumero = numero.chip_receptor INTO chip_emissor_plan;
			
			IF(numero1.idplano = chip_emissor_plan)
			THEN 
			--pegando os minutos das ligações de mesma operadora
				min_m_op := min_m_op + date_part('minute', numero.duracao) + (date_part('hour', numero.duracao)*60) + (date_part('second', numero.duracao)/60);
			ELSE 
			--pegando os minutos das ligações de operadora diferente
				
				min_out_op := min_out_op + date_part('minute', numero.duracao) + (date_part('hour', numero.duracao)*60) + (date_part('second', numero.duracao)/60); 
			END IF;
			END IF;
			END IF;
		END LOOP;
	END IF;
			--aqui onde insere
		
			-- valor dos minutos adicional entre mesma operadora
			SELECT tarifa.valor 
			FROM plano
			INNER JOIN plano_tarifa ON plano.idplano = plano_tarifa.idplano
			INNER JOIN tarifa ON plano_tarifa.idtarifa = tarifa.idtarifa
			WHERE tarifa.descricao = 'Minuto adicional' AND numero1.idplano = plano.idplano
			INTO valor_min_add_in;
			IF 	(numero1.fminin - min_m_op) < 0 THEN
				valor_m_exced := ((numero1.fminin - min_m_op) * valor_min_add_in)*-1;
			END IF;
			
			SELECT tarifa.valor 
			FROM plano
			INNER JOIN plano_tarifa ON plano.idplano = plano_tarifa.idplano
			INNER JOIN tarifa ON plano_tarifa.idtarifa = tarifa.idtarifa
			WHERE tarifa.descricao = 'Minuto adicional outra operadora' AND numero1.idplano = plano.idplano
			INTO valor_min_add_out;		
					
			-- Valor dos minutos adicionais entre operadoras diferentes
			IF (numero1.fminout - min_out_op) < 0 THEN
			valor_out_exced := ((numero1.fminout - min_out_op) *  valor_min_add_out)*-1;			
			END IF;
			val_exced := valor_out_exced + valor_m_exced; 
			valor_total := roaming + valor_out_exced + valor_m_exced + numero1.valorp;
	
		
	
		INSERT INTO fatura (referencia, idnumero, valor_plano, tot_min_int, tot_min_ext, tx_min_exced, tx_roaming, total, pago) 
		VALUES (datainsert, numero1.idnumero, numero1.valorp, min_m_op, min_out_op, val_exced, roaming, valor_total, 'N');
	    --COMMIT;
        --BEGIN
        --EXCEPTION
        --    WHEN OTHERS THEN
        --        ROLLBACK;
        --END;        
	END LOOP;
END;
$$
LANGUAGE PLPGSQL;



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
OR (disp = 'S' OR atv = 'N') THEN
	RAISE NOTICE 'Dado não inserido, verifique se o chip está inativo ou indisponivel';
	return null;
ELSE
	RAISE NOTICE 'Dado inserido na tabela ligação';
	return new;
END IF;
END;
$$ LANGUAGE PlPgSQL;

CREATE trigger chck_inativo_trg_lig BEFORE INSERT ON ligacao
for each ROW EXECUTE PROCEDURE chck_inativo_lig();



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



--Liberar os chips ligados a um cliente que teve o cadastro cancelado / Requisito 6
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



--rotina geradora de ligações / requisito 7
CREATE OR REPLACE PROCEDURE preencher_lig( mesano date )
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
	tempo_rand := '00:01:00';
	totaldia := DATE_PART('days', DATE_TRUNC('month', mesano)
			  + '1 MONTH'::INTERVAL 
			  - '1 DAY'::INTERVAL) - 1;
	datainsert := to_timestamp(
	date_part('year', mesano)::varchar||'-'||date_part('month', mesano)::varchar||'-'||'1' ,'YYYY-MM-DD'); 
	FOR j IN 1..totaldia LOOP  
		FOR chip IN refcursor LOOP
				random := floor(random() * 10 + 1)::int;
				FOR i IN 1..random LOOP
					
					SELECT uf FROM estado ORDER BY RANDOM() LIMIT 1 INTO uforg;
					SELECT uf FROM estado ORDER BY RANDOM() LIMIT 1 INTO ufdest;
					SELECT idnumero FROM chip ORDER BY RANDOM() LIMIT 1 INTO numrecpt;
					IF (chip.idnumero = numrecpt) THEN
						CONTINUE;
					ELSE 
						INSERT INTO ligacao(datalig, chip_emissor, uforigem, chip_receptor, ufdestino, duracao)
						VALUES (datainsert, chip.idnumero, uforg, numrecpt, ufdest, tempo_rand);
					END IF;
					--tempo_rand := interval '2 minutes' + tempo_rand;
					datainsert := interval '1 minute' + datainsert;
				END LOOP;
		END LOOP;
		datainsert := interval '1 day' + datainsert;
	END LOOP;
END;
$$
LANGUAGE PlPGSQL;



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



--visão 1
CREATE VIEW ranking AS (
	select	plano.idplano,
    	plano.descricao,
    	COUNT(chip.idplano) AS planosativos,
		COUNT(chip.idplano) * plano.valor AS total
    	FROM chip
		INNER JOIN plano ON chip.idplano = plano.idplano
  		GROUP BY plano.idplano, plano.descricao
		ORDER BY COUNT(chip.idplano) DESC);

--visão 3
create view clientes_info as (
	select cliente.idCliente, 
		   cliente.nome, 
		   estado.uf, 
	       chip.idNumero as fone, 
	       plano.descricao as planoContratado,
		   age(current_date, cliente.dataCadastro) as tempoFidelidade
	from estado inner join cidade on estado.uf=cidade.uf
	inner join cliente on cidade.idCidade=cliente.idCidade
	inner join cliente_chip on cliente.idCliente=cliente_chip.idCliente
	inner join chip on cliente_chip.idNumero=chip.idNumero
	inner join plano on chip.idPlano=plano.idPlano);


--Gerador de auditorias
create or replace procedure ger_audit(numero char(11), inicio date, termino date) 
as $$
declare
	rec RECORD;
begin
		if exists(select idNumero from cliente_chip where idNumero=numero) then
			select idCliente into rec from cliente_chip where idNumero = numero;
			insert into auditoria (idNumero, idCliente, dataInicio, dataTermino)
			values (numero, rec.idCliente, inicio, termino);
		else
			raise exception 'O chip não está associado a um cliente';
		end if;
end;
$$
language plpgsql;

