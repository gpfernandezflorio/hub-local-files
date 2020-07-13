## SDE/Estacion/Cofre
## Objeto
## HUB3DLang

$altura=0.6
$profundidad=0.6
cube(!1.2,altura,profundidad):mfixed(cc8,t=madera)
(cube(!1.2,.2,profundidad):mfixed(99e,t=madera)&_):ntapa:oyaltura
face(!1,.4,y):mfixed(fff):oy(altura+.01):oz.1
body(static):cbox(!1.2,2*altura,!(2*profundidad))
(audio(punto)&(cube(!.1,!.1,.005):nm:mfixed(111):ozprofundidad:oyaltura)):sinteractive(candado,m=m,r=1):ncandado
