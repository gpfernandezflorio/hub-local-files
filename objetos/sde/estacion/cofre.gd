## SDE/Estacion/Cofre
## Objeto
## HUB3DLang

$altura=0.6
$profundidad=0.6
cube(!1.2,altura,profundidad):mfixed(cc8,t=madera)
(cube(!1.2,.2,profundidad):mfixed(99e,t=madera)&_):ntapa:oyaltura
face(!1,.4,y,.1):mfixed(fff,t=morse):oy(altura+.01):oz.1:nmensaje
body(static):cbox(!1.2,2*altura,!(2*profundidad))
(audio(punto,v=1)&(cube(!.1,!.1,.005):nm:mfixed(111):ozprofundidad:oyaltura)):sinteractive(candado,m=m,r=1,p=tip):ncandado
