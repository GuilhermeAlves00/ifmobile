--geração de número telefônico
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