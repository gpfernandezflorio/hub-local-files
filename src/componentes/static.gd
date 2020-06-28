## STATIC
## SRC

# Script para los componentes de tipo StaticBody

extends StaticBody

var HUB
var yo

func inicializar(hub, yo):
	HUB = hub
	self.yo = yo
	return true