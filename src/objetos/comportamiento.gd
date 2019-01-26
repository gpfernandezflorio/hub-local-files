## Comportamiento
## SRC

# El script de comportamiento base de un objeto.
# Permite almacenar más de un script para el mismo objeto.

extends Node

var HUB

func inicializar(hub):
	HUB = hub
	return true