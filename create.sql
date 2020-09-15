CREATE DATABASE ifmobile;

DROP TABLE IF EXISTS cobertura CASCADE;
DROP TABLE IF EXISTS estado CASCADE;
DROP TABLE IF EXISTS cidade CASCADE;
DROP TABLE IF EXISTS cliente CASCADE;
DROP TABLE IF EXISTS chip CASCADE;
DROP TABLE IF EXISTS cliente_chip CASCADE;
DROP TABLE IF EXISTS auditoria CASCADE;
DROP TABLE IF EXISTS tarifa CASCADE;
DROP TABLE IF EXISTS plano CASCADE;
DROP TABLE IF EXISTS fatura CASCADE; 
DROP TABLE IF EXISTS ligacao CASCADE;

CREATE TABLE estado(
    uf CHAR(2) NOT NULL,
    nome VARCHAR(40) NOT NULL,
    ddd INTEGER NOT NULL,
    CONSTRAINT PK_estado PRIMARY KEY(uf),
    CONSTRAINT UNQ_estado UNIQUE(ddd)
);

CREATE TABLE cobertura(
    uf CHAR(2) NOT NULL,
    ddd INTEGER NOT NULL,
    CONSTRAINT PK_cobertura PRIMARY KEY(uf),
    CONSTRAINT FK_cobertura_estado FOREIGN KEY(uf) REFERENCES estado(uf),
    CONSTRAINT UNQ_cobertura UNIQUE(ddd)
);

CREATE TABLE cidade(
    idCidade SERIAL NOT NULL,
    nome VARCHAR(50) NOT NULL,
    uf CHAR(2) NOT NULL,
    CONSTRAINT PK_cidade PRIMARY KEY(idCidade),
    CONSTRAINT FK_cidade_estado FOREIGN KEY(uf) REFERENCES estado(uf)
);

CREATE TABLE cliente(
    idCliente SERIAL NOT NULL,
    nome VARCHAR(50) NOT NULL,
    endereco VARCHAR(60) NOT NULL,
    bairro VARCHAR(30) NOT NULL,
    idCidade INTEGER NOT NULL,
    dataCadastro DATE NOT NULL,
    cancelado CHAR(1) NOT NULL DEFAULT 'N',
    CONSTRAINT PK_cliente PRIMARY KEY(idCliente),
    CONSTRAINT FK_cliente_cidade FOREIGN KEY(idCidade) REFERENCES cidade(idCidade),
    CONSTRAINT CHK_cliente_cancelado CHECK (cancelado = 'S' OR cancelado = 'N')
);

CREATE TABLE tarifa(
    idTarifa SERIAL NOT NULL,
    descricao VARCHAR(50) NOT NULL,
    valor DECIMAL NOT NULL DEFAULT 0,
    CONSTRAINT PK_tarifa PRIMARY KEY(idTarifa)
);

CREATE TABLE plano(
    idPlano SERIAL NOT NULL,
    descricao VARCHAR(50) NOT NULL,
    fminIn INTEGER NOT NULL DEFAULT 0,
    fminOut INTEGER NOT NULL DEFAULT 0,
    addLigacao INTEGER NOT NULL,
    roaming INTEGER NOT NULL,
    valor DECIMAL NOT NULL,
    CONSTRAINT PK_plano PRIMARY KEY(idPlano),
    CONSTRAINT FK_plano_tarifa_addLigacao FOREIGN KEY(addLigacao) REFERENCES tarifa(idTarifa),
    CONSTRAINT FK_plano_tarifa_roaming FOREIGN KEY(roaming) REFERENCES tarifa(idTarifa)
);

CREATE TABLE chip(
    idNumero CHAR(11) NOT NULL,
    idPlano INTEGER NOT NULL,
    ativo CHAR(1) NOT NULL DEFAULT 'S',
    disponivel CHAR(1) NOT NULL DEFAULT 'S',
    CONSTRAINT PK_chip PRIMARY KEY(idNumero),
    CONSTRAINT FK_plano FOREIGN KEY(idPlano) REFERENCES plano(idPlano),
    CONSTRAINT CHK_chip_ativo CHECK (ativo = 'S' OR ativo = 'N'),
    CONSTRAINT CHK_chip_disponivel CHECK (disponivel = 'S' OR disponivel = 'N'),
    CONSTRAINT CHK_idNumero CHECK (idNumero <> '###985[1-2]#####' OR idNumero <> '[!##985[1-2]#0000]')
);

CREATE TABLE cliente_chip(
    idCliente INTEGER NOT NULL,
    idNumero CHAR(11) NOT NULL,
    CONSTRAINT PK_cliente_chip PRIMARY KEY(idCliente, idNumero),
    CONSTRAINT FK_cliente_chip_idCliente FOREIGN KEY(idCliente) REFERENCES cliente(idCliente),
    CONSTRAINT FK_cliente_chip_idNumero FOREIGN KEY(idNumero) REFERENCES chip(idNumero)
);

CREATE TABLE auditoria(
    idCliente INTEGER NOT NULL,
    idNumero CHAR(11) NOT NULL,
    dataInicio DATE NOT NULL,
    dataTermino DATE NOT NULL,
    CONSTRAINT PK_auditoria PRIMARY KEY(idCliente, idNumero, dataInicio),
    CONSTRAINT FK_cliente_chip_idCliente FOREIGN KEY(idCliente) REFERENCES cliente(idCliente),
    CONSTRAINT FK_cliente_chip_idNumero FOREIGN KEY(idNumero) REFERENCES chip(idNumero)
);

CREATE TABLE fatura(
    referencia DATE NOT NULL,
    idNumero CHAR(11) NOT NULL,
    valorPlano NUMERIC NOT NULL,
    totMinIn INTEGER NOT NULL,
    totMinOut INTEGER NOT NULL,
    txMinExced NUMERIC NOT NULL,
    txRoaming NUMERIC NOT NULL,
    total NUMERIC NOT NULL,
    pago CHAR(1) NOT NULL DEFAULT 'N',
    CONSTRAINT PK_referencia PRIMARY KEY(referencia),
    CONSTRAINT FK_fatura_chip_idNumero FOREIGN KEY(idNumero) REFERENCES chip(idNumero),
    CONSTRAINT CHK_pago CHECK (pago = 'S' or pago = 'N')
);

CREATE TABLE ligacao(
    dataLig TIMESTAMP NOT NULL,
    chipEmissor CHAR(11) NOT NULL,
    ufOrigem CHAR(2) NOT NULL,
    chipReceptor INTEGER NOT NULL,
    ufDestino CHAR(2) NOT NULL,
    duracao TIME NOT NULL,
    CONSTRAINT PK_dataLig PRIMARY KEY(dataLig),
    CONSTRAINT FK_ligacao_estado_chipEmissor FOREIGN KEY(chipEmissor) REFERENCES chip(idNumero),
    CONSTRAINT FK_ligacao_estado_ufOrigem FOREIGN KEY(ufOrigem) REFERENCES estado(uf),
    CONSTRAINT FK_ligacao_estado_ufDestino FOREIGN KEY(ufDestino) REFERENCES estado(uf)
);







