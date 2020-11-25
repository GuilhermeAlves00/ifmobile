from django.urls import path, include
from . import views

urlpatterns = [
   #path('tabelas/', views.main), 
   path('cobertura', views.exibir_coberturas),
   path('estado', views.exibir_estados),
   path('cidade', views.exibir_cidades),
   path('cliente', views.exibir_clientes),
   path('cliente_chip', views.exibir_cliente_chip),
   path('chip', views.exibir_chips),
   path('operadora', views.exibir_operadoras),
   path('plano', views.exibir_planos),
   path('plano_tarifa', views.exibir_plano_tarifa),
   path('tarifa', views.exibir_tarifas),
   path('auditoria', views.exibir_auditorias),
   path('ligacao', views.exibir_ligacoes),
   path('fatura', views.exibir_faturas),
]