from django.shortcuts import render
from .models import *
import psycopg2

try:
    conn = psycopg2.connect(host='127.0.0.1',
                            port=5432, 
                            database='ifmobile',
                            user='postgres', 
                            password='0000')
    
except:
    print('Erro na conexão com o banco de dados')


def exibir_cidades(request):
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT * FROM CIDADE")
        query = cursor.fetchall()
    finally:
        cursor.close()
    return render(request, 'ifmobile_pages/cidade.html',{'query': query})    


def exibir_ligacoes(request):
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT * FROM LIGACAO")
        query = cursor.fetchall()
    finally:
        cursor.close()
    return render(request, 'ifmobile_pages/ligacao.html',{'query': query})    


def exibir_coberturas(request):
    context = {'lista_cobertura': Cobertura.objects.all()}
    return render(request, 'ifmobile_pages/cobertura.html', context)

def exibir_estados(request):
    context = {'lista_estado': Estado.objects.all()}
    return render(request, 'ifmobile_pages/estado.html', context)

def exibir_clientes(request):
    context = {'lista_cliente': Cliente.objects.all()}
    return render(request, 'ifmobile_pages/cliente.html', context)    

def exibir_cliente_chip(request):
    context = {'lista_cliente_chip': ClienteChip.objects.all()}
    return render(request, 'ifmobile_pages/cliente_chip.html', context)        

def exibir_chips(request):
    context = {'lista_chip': Chip.objects.all()}
    return render(request, 'ifmobile_pages/chip.html', context)        

def exibir_operadoras(request):
    context = {'lista_operadoras': Operadora.objects.all()}
    return render(request, 'ifmobile_pages/operadora.html', context)        

def exibir_planos(request):
    context = {'lista_plano': Plano.objects.all()}
    return render(request, 'ifmobile_pages/plano.html', context)        

def exibir_plano_tarifa(request):
    context = {'lista_plano_tarifa': PlanoTarifa.objects.all()}
    return render(request, 'ifmobile_pages/plano_tarifa.html', context)        

def exibir_auditorias(request):
    context = {'lista_auditoria': Auditoria.objects.all()}
    return render(request, 'ifmobile_pages/auditoria.html', context)        

def exibir_tarifas(request):
    context = {'lista_tarifa': Tarifa.objects.all()}
    return render(request, 'ifmobile_pages/tarifa.html', context)        

def exibir_faturas(request):
    context = {'lista_fatura': Fatura.objects.all()}
    return render(request, 'ifmobile_pages/fatura.html', context)        
