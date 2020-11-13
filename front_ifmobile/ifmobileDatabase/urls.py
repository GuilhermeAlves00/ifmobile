from django.urls import path, include
from . import views

urlpatterns = [
   path('tabelas/main', views.menu), 
   path('tabelas/cobertura', views.exibir_coberturas),
   path('tabelas/estado', views.exibir_estados),
   path('tabelas/cidade', views.exibir_cidades),
   path('tabelas/cliente', views.exibir_clientes),
   path('tabelas/cliente_chip', views.exibir_cliente_chip),
   path('tabelas/chip', views.exibir_chips),
   path('tabelas/operadora', views.exibir_operadoras),
   path('tabelas/plano', views.exibir_planos),
   path('tabelas/plano_tarifa', views.exibir_plano_tarifa),
]