from django.shortcuts import render
from .models import *

def main(request):
    return render(request, 'ifmobile_pages/base.html')

def exibir_coberturas(request):
    context = {'lista_cobertura': Cobertura.objects.all()}
    return render(request, 'ifmobile_pages/cobertura.html', context)

def exibir_estados(request):
    context = {'lista_estado': Estado.objects.all()}
    return render(request, 'ifmobile_pages/estado.html', context)

def exibir_cidades(request):
    context = {'lista_cidade': Cidade.objects.all()}
    return render(request, 'ifmobile_pages/cidade.html', context)

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

def exibir_ligacoes(request):
    context = {'lista_ligacao': Ligacao.objects.all()}
    return render(request, 'ifmobile_pages/ligacao.html', context)        

def exibir_faturas(request):
    context = {'lista_fatura': Fatura.objects.all()}
    return render(request, 'ifmobile_pages/fatura.html', context)        
