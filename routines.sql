--geração de número telefônico - requisito 1
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

--associação de chip - requisito 5
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

--Tornar o chip indisponível quando associado a um cliente - requisito 10
create or replace function alterChip()
returns trigger as $$
begin		
	update chip set disponivel='N' where idNumero=new.idNumero;
	return new;
end $$
language plpgsql;

create trigger alterChipTri after insert on cliente_chip
for each row execute procedure alterChip();
