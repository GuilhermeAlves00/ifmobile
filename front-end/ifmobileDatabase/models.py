# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models



class AuthGroup(models.Model):
    name = models.CharField(unique=True, max_length=150)

    class Meta:
        managed = False
        db_table = 'auth_group'


class AuthGroupPermissions(models.Model):
    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)
    permission = models.ForeignKey('AuthPermission', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_group_permissions'
        unique_together = (('group', 'permission'),)


class AuthPermission(models.Model):
    name = models.CharField(max_length=255)
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING)
    codename = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'auth_permission'
        unique_together = (('content_type', 'codename'),)


class AuthUser(models.Model):
    password = models.CharField(max_length=128)
    last_login = models.DateTimeField(blank=True, null=True)
    is_superuser = models.BooleanField()
    username = models.CharField(unique=True, max_length=150)
    first_name = models.CharField(max_length=150)
    last_name = models.CharField(max_length=150)
    email = models.CharField(max_length=254)
    is_staff = models.BooleanField()
    is_active = models.BooleanField()
    date_joined = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'auth_user'


class AuthUserGroups(models.Model):
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_user_groups'
        unique_together = (('user', 'group'),)


class AuthUserUserPermissions(models.Model):
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    permission = models.ForeignKey(AuthPermission, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_user_user_permissions'
        unique_together = (('user', 'permission'),)

class Plano(models.Model):
    idplano = models.AutoField(primary_key=True)
    descricao = models.CharField(max_length=50)
    fminin = models.IntegerField()
    fminout = models.IntegerField()
    valor = models.DecimalField(max_digits=7, decimal_places=2)

    def get_idplano(self):
        return self.idplano


    class Meta:
        managed = False
        db_table = 'plano'

class Operadora(models.Model):
    idoperadora = models.AutoField(primary_key=True)
    nome = models.CharField(max_length=40)

    def get_idoperadora(self):
        return self.idoperadora

    class Meta:
        managed = False
        db_table = 'operadora'

class Chip(models.Model):
    idnumero = models.CharField(primary_key=True, max_length=11)
    idoperadora = models.ForeignKey(Operadora, models.DO_NOTHING, db_column='idoperadora')
    idplano = models.ForeignKey(Plano, models.DO_NOTHING, db_column='idplano')
    ativo = models.CharField(max_length=1)
    disponivel = models.CharField(max_length=1)

    def get_idnumero(self):
        return self.idnumero

    class Meta:
        managed = False
        db_table = 'chip'

class Cobertura(models.Model):
    idregiao = models.AutoField(primary_key=True)
    descricao = models.CharField(max_length=40)

    def get_idregiao(self):
        return self.idregiao

    class Meta:
        managed = False
        db_table = 'cobertura'


class Estado(models.Model):
    uf = models.CharField(primary_key=True, max_length=2)
    nome = models.CharField(max_length=40)
    ddd = models.IntegerField(unique=True)
    idregiao = models.ForeignKey(Cobertura, models.DO_NOTHING, db_column='idregiao')

    def get_uf(self):
        return self.uf

    class Meta:
        managed = False
        db_table = 'estado'

class Cidade(models.Model):
    idcidade = models.AutoField(primary_key=True)
    nome = models.CharField(max_length=50)
    uf = models.ForeignKey('Estado', models.DO_NOTHING, db_column='uf')
    
    def get_idcidade(self):
        return self.idcidade

    class Meta:
        managed = False
        db_table = 'cidade'


class Cliente(models.Model):
    idcliente = models.AutoField(primary_key=True)
    nome = models.CharField(max_length=50)
    endereco = models.CharField(max_length=60, blank=True, null=True)
    bairro = models.CharField(max_length=30, blank=True, null=True)
    idcidade = models.ForeignKey('Cidade', models.DO_NOTHING, db_column='idcidade')
    datacadastro = models.DateField(blank=True, null=True)
    cancelado = models.CharField(max_length=1)

    def get_idcliente(self):
        return self.idcliente

    class Meta:
        managed = False
        db_table = 'cliente'

class ClienteChip(models.Model):
    idnumero = models.OneToOneField(Chip, models.DO_NOTHING, db_column='idnumero', primary_key=True)
    idcliente = models.ForeignKey(Cliente, models.DO_NOTHING, db_column='idcliente')

    class Meta:
        managed = False
        db_table = 'cliente_chip'
        unique_together = (('idnumero', 'idcliente'),)


class Auditoria(models.Model):
    idnumero = models.OneToOneField('Chip', models.DO_NOTHING, db_column='idnumero', primary_key=True)
    idcliente = models.ForeignKey('Cliente', models.DO_NOTHING, db_column='idcliente')
    datainicio = models.DateField()
    datatermino = models.DateField()

    class Meta:
        managed = False
        db_table = 'auditoria'
        unique_together = (('idnumero', 'idcliente', 'datainicio'),)



class DjangoAdminLog(models.Model):
    action_time = models.DateTimeField()
    object_id = models.TextField(blank=True, null=True)
    object_repr = models.CharField(max_length=200)
    action_flag = models.SmallIntegerField()
    change_message = models.TextField()
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING, blank=True, null=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'django_admin_log'


class DjangoContentType(models.Model):
    app_label = models.CharField(max_length=100)
    model = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'django_content_type'
        unique_together = (('app_label', 'model'),)


class DjangoMigrations(models.Model):
    app = models.CharField(max_length=255)
    name = models.CharField(max_length=255)
    applied = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_migrations'


class DjangoSession(models.Model):
    session_key = models.CharField(primary_key=True, max_length=40)
    session_data = models.TextField()
    expire_date = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_session'


class Fatura(models.Model):
    referencia = models.DateField(primary_key=True)
    idnumero = models.ForeignKey(Chip, models.DO_NOTHING, db_column='idnumero')
    valor_plano = models.DecimalField(max_digits=7, decimal_places=2)
    tot_min_int = models.IntegerField()
    tot_min_ext = models.IntegerField()
    tx_min_exced = models.DecimalField(max_digits=5, decimal_places=2)
    tx_roaming = models.DecimalField(max_digits=5, decimal_places=2)
    total = models.DecimalField(max_digits=7, decimal_places=2)
    pago = models.CharField(max_length=1)

    class Meta:
        managed = False
        db_table = 'fatura'
        unique_together = (('referencia', 'idnumero'),)


class Ligacao(models.Model):
    datalig = models.DateTimeField(primary_key=True)
    chip_emissor = models.ForeignKey(Chip, models.DO_NOTHING, db_column='chip_emissor', related_name='%(class)s_chip_emissor')
    uforigem = models.ForeignKey(Estado, models.DO_NOTHING, db_column='uforigem', related_name='%(class)s_uf_origem')
    chip_receptor = models.ForeignKey(Chip, models.DO_NOTHING, db_column='chip_receptor')
    ufdestino = models.ForeignKey(Estado, models.DO_NOTHING, db_column='ufdestino')
    duracao = models.DurationField()

    class Meta:
        managed = False
        db_table = 'ligacao'
        unique_together = (('datalig', 'chip_emissor'),)


class Tarifa(models.Model):
    idtarifa = models.AutoField(primary_key=True)
    descricao = models.CharField(max_length=50)
    valor = models.DecimalField(max_digits=5, decimal_places=2)

    def get_idtarifa(self):
        return self.idtarifa

    class Meta:
        managed = False
        db_table = 'tarifa'


class PlanoTarifa(models.Model):
    idplano = models.OneToOneField(Plano, models.DO_NOTHING, db_column='idplano', primary_key=True)
    idtarifa = models.ForeignKey('Tarifa', models.DO_NOTHING, db_column='idtarifa')

    class Meta:
        managed = False
        db_table = 'plano_tarifa'
        unique_together = (('idplano', 'idtarifa'),)


