#import "template.typ": *
#import "@preview/tablex:0.0.8": tablex, hlinex, vlinex, colspanx, rowspanx

#set math.equation(numbering: "(1)")

#show: project.with(
  title: "Seminario 1",
  subtitle: "Redes Bayesianas en Juegos",
  author: (
    "Pablo Santana González",
    "Pablo Hernández Jiménez",
    "Álvaro Fontenla León"
  ),
  affiliation: "Universidad de La Laguna",
  date: datetime.today().display(),
  Licence: "Curso 2023-2024",
  UE: "Inteligencia Artificial Avanzada",
  logo: "/assets/ull-logo.png",
  main_color: "#5c068c",
  toc_title: "Índice",
)

= Introducción

En este seminario se va a realizar el diseño y análisis de una red bayesiana que modela el comportamiento de un bot en un videojuego.

La implementación de la red bayesiana se ha realizado con el software `GeNIe` y se ha exportado a un archivo `.xdsl`.
Y está basada en la publicación "Teaching Bayesian Behaviours to Video Game Characters". @article

== Porcentaje de Participación

#tablex(
  columns: 4,
  rows: 3,
  align: center + horizon,
  auto-vlines: false,
  repeat-header: true,
  [*Identificador ALU*], [*Apellidos*], [*Nombres*], [*Participación*],
  [alu0101480541], [Santana González], [Pablo], [33.3%],
  [alu0101495934], [Hernández Jiménez], [Pablo], [33.3%],
  [alu0101437989], [Fontenla León], [Álvaro], [33.3%]
)

#pagebreak()

= Red Utilizada

#figure(
  image("/assets/GeNIe.png"),
  caption: ["Red Bayesiana"]
) <red_bayesiana>

== Descripción de la Red

$
    &P(S_t, S_(t+1), H, W, "OW", "HN", "NE", "PW", "PH") \
    = &P(S_t)\
    &P(H|S_(t+1))\
    &P(W|S_(t+1))\
    &P("OW"|S_(t+1))\
    &P("HN"|S_(t+1))\
    &P("NE"|S_(t+1))\
    &P("PW"|S_(t+1))\
    &P("PH"|S_(t+1))
$

== Respuesta a Cuestion Planteada en el Apartado 2

A la cuestion "La factorización no sigue la causalidad pues
variables en tiempo t dependen de variables en tiempo t+1."
Se plantean las siguientes preguntas:

===  ¿Por qué crees que se ha hecho así?

La principal razón por la que la red no se ha diseñado de esta manera es el tamaño de las tablas de probabilidad condicional. La red se ha diseñado estableciendo cómo se esperaría que el personaje perciba su entorno y actúe en función de sus acciones futuras y del estado en el que se encontrará en el siguiente paso del tiempo, haciendo que las variables en $t$, dependan del estado del bot en $t+1$, reduciendo así el tamaño de las tablas de manera significativa.

=== ¿Cómo sería la red puesta de forma causal? ¿Cuál el tamaño de las tablas?

En la red causal, el nodo de $S_(t+1)$ dependería de todos los nodos de $S_t$, $H$, $W$, $"OW"$, $"HN"$, $"NE"$, $"PW"$, $"PH"$.
Por lo que el tamaño de las tablas de probabilidad condicional sería de $2^7 * 6 = 768$ combinaciones a rellenar.
Podemos observar que las combinaciones a rellenar son significativamente mayores si la red se diseñara de manera causal.

= Personalidad del Bot

Hemos considerado que el bot tiene una personalidad agresiva, por lo que atacará siempre que pueda.
Sin embargo, tampoco queremos que sea un bot suicida, por lo que si detecta peligro, atacará con una probabilidad casi segura si no está herido, pero si lo está buscará energía hasta que la encuentre.

= Justificación de las Tablas de Probabilidad Condicional

A continuación se justificará la tabla de probabilidad condicional de cada nodo de la red.

== Estado del Bot $S_t$

#tablex(columns: 2, rows: 7,
  [$S_t$], [%],
  [$"atacar"$],	[0.1666666666666667],
  [$"recoger_arma"$], [0.1666666666666667], [$"recoger_energía"$], [0.1666666666666667],
  [$"explorar"$], [0.1666666666666667],
  [$"huir"$], [0.1666666666666667],
  [$"detectar_peligro"$],	[0.1666666666666667]
)

Para esta tabla se ha considerado que el bot tiene una probabilidad uniforme de realizar cada acción.
Puesto que no depende de ningún otro nodo.

#pagebreak()

== Estado del Bot $S_(t+1)$

#tablex(columns: 7, rows: 6,
  [$S_t$], [*atacar*], [*buscar_armas*], [*buscar energia*], [*explorar*], [*huir*], [*detectar_peligro*],
  [*atacar*], [0.9999], [0.83329], [1e-05], [0.249995], [0.33332], [0.99995],
  [*buscar_armas*], [1e-05], [0.16666], [1e-05], [0.249995], [1e-05], [1e-05],
  [*buscar_energia*], [1e-05], [1e-05], [0.99995], [0.249995], [1e-05], [1e-05],
  [*explorar*], [1e-05], [1e-05], [1e-05], [0.249995], [0.33332], [1e-05],
  [*huir*], [1e-05], [1e-05], [1e-05], [1e-05], [0.33332], [1e-05],
  [*detectar_peligro*], [1-e05], [1e-05], [1e-05], [1e-05], [1e-05], [1e-05]
)

Donde cada columna representa el estado del bot en el tiempo $t$ y cada fila
representa el estado del bot en el tiempo $t+1$.

Para esta tabla se han tenido las siguientes consideraciones para cada estado:

- *$S_t = "atacar"$*: El bot tiene una probabilidad alta de seguir atacando y una probabilidad infinitesimal de realizar cualquier otra acción.

  Por su personalidad agresiva, cuando el bot ataca seguirá atacando hasta que no detecte peligro.

- *$S_t = "buscar_armas"$*: El bot tiene una probabilidad alta  de que en $S_(t+1)$ de atacar y una probalidad más baja de seguir buscando armas.

  Si esta buscando armas, es porque no tiene armas, por lo que tiene una probabilidad alta de atacar en el siguiente estado. Y si no encuentra armas, lo más probable es que siga buscando.

- *$S_t = "buscar_energia"$*: El bot tiene una probabilidad alta de seguir buscando energía y una probabilidad más baja de realizar cualquier otra acción.

  Aunque su personalidad es agresiva, si no tiene energía, buscará energía hasta que la encuentre.

- *$S_t = "explorar"$*: El bot tiene una probabilidad uniforme
  de realizar cualquiera de las acciones (*atacar*, *buscar_armas*, *buscar_energia*, *explorar*) y una probabilidad infinitesimal de realizar cualquier otra acción.

- *$S_t = "huir"$*: El bot tiene una probabilidad uniforme de seguir huyendo, atacar o huir y una probabilidad infinitesimal de realizar cualquier otra acción.

- *$S_t = "detectar_peligro"$*: El bot tiene una probabilidad
  casi segura de atacar y una probabilidad infinitesimal de realizar cualquier otra acción.

#pagebreak()

== Estado del Sensor del Bot $H$

#tablex(columns: 7, rows: 2,
  [Salud], [$"atacar"$], [$"buscar_armas"$], [$"buscar_energia"$], [$"explorar"$], [$"huir"$], [$"detectar_peligro"$],
  [$"Alta"$], [0.7], [0.5], [0.3], [0.7], [0.3], [0.5],
  [$"Baja"$], [0.3], [0.5], [0.7], [0.3], [0.7], [0.5]
)

Para esta tabla se ha considerado que el bot tiene una probabilidad alta de atacar si tiene la salud alta y una probabilidad alta de buscar energía si tiene la salud baja. Y una probilidad alta de huir si tiene la salud baja.

== Estado del Sensor del Bot $W$

#tablex(columns: 7, rows: 2,
  [Armas], [$"atacar"$], [$"buscar_armas"$], [$"buscar_energia"$], [$"explorar"$], [$"huir"$], [$"detectar_peligro"$],
  [$"Armado"$], [0.9], [0.1], [0.5], [0.7], [0.1], [0.5],
  [$"Desarmado"$], [0.1], [0.9], [0.5], [0.3], [0.9], [0.5]
)

Para esta tabla se ha considerado que el bot tiene una probabilidad alta de atacar si tiene armas y una probabilidad alta de buscar armas si no tiene armas.
Si no tiene armas, las probabilidaded de huir son extremadamente alta.
Tambien tiene una probabilidad alta de explorar si tiene armas.

== Estado del Sensor del Bot $"OW"$

#tablex(columns: 7, rows: 2,
  [Armas\ Oponente], [$"atacar"$], [$"buscar_armas"$], [$"buscar_energia"$], [$"explorar"$], [$"huir"$], [$"detectar_peligro"$],
  [$"Armado"$], [0.49], [0.5], [0.5], [0.5], [0.5], [0.5],
  [$"Desarmado"$], [0.51], [0.5], [0.5], [0.5], [0.5], [0.5]
)

Para esta tabla se ha considerado que el bot tiene una probabilidad casi uniforme de realizar cualquier acción si el oponente tiene armas o no. Es decir que le importa poco si el oponente tiene armas o no.

== Estado del Sensor del Bot $"HN"$

#tablex(columns: 7, rows: 2,
  [Sonido], [$"atacar"$], [$"buscar_armas"$], [$"buscar_energia"$], [$"explorar"$], [$"huir"$], [$"detectar_peligro"$],
  [$"Si"$], [0.9], [0.5], [0.5], [0.7], [0.5], [0.9],
  [$"No"$], [0.1], [0.5], [0.5], [0.3], [0.5], [0.1]
)

Para esta tabla se ha considerado que el bot tiene una probabilidad alta de atacar si detecta un sonido y una probabilidad alta de detectar peligro si detecta un sonido.
Tambien tiene una probabilidad alta de explorar si detecta un sonido.

#pagebreak()

== Estado del Sensor del Bot $"NE"$

#tablex(columns: 7, rows: 2,
  [Enemigos\ Cercanos], [$"atacar"$], [$"buscar_armas"$], [$"buscar_energia"$], [$"explorar"$], [$"huir"$], [$"detectar_peligro"$],
  [$"Si"$], [0.9999], [0.6], [0.6], [1e-05], [1], [1e-05],
  [$"No"$], [1e-05], [0.4], [0.4], [0.9999], [0], [0.9999]
)

Para esta tabla se ha considerado que el bot tiene una probabilidad alta de atacar si tiene enemigos cercanos,
una probabilidad alta de buscar armas si no tiene enemigos cercanos y soló huirá si hay enemigos cercanos.

== Estado del Sensor del Bot $"PW"$

#tablex(columns: 7, rows: 2,
  [Armas\ Cercanas], [$"atacar"$], [$"buscar_armas"$], [$"buscar_energia"$], [$"explorar"$], [$"huir"$], [$"detectar_peligro"$],
  [$"Si"$], [0.5], [0.1], [0.5], [0.5], [0.5], [0.5],
  [$"No"$], [0.5], [0.9], [0.5], [0.5], [0.5], [0.5]
)

Para esta tabla se ha considerado que el bot tiene una probabilidad alta de atacar si tiene armas cercanas y una probabilidad alta de buscar armas si no tiene armas cercanas.

== Estado del Sensor del Bot $"PH"$

#tablex(columns: 7, rows: 2,
  [Energía\ Cercana], [$"atacar"$], [$"buscar_armas"$], [$"buscar_energia"$], [$"explorar"$], [$"huir"$], [$"detectar_peligro"$],
  [$"Si"$], [0.7], [0.5], [0.1], [0.5], [0.5], [0.5],
  [$"No"$], [0.3], [0.5], [0.9], [0.5], [0.5], [0.5]
)

Para esta tabla se ha considerado que el bot tiene una probabilidad alta de buscar energía si tiene energía cercana y una probabilidad más alta de atacar si tiene energía cercana.

#pagebreak()

= Ejemplos de Calculo con el `GeNIe`

== Ejemplo 1

#figure(
  image("/assets/example1.png"),
  caption: ["Ejemplo 1"]
)

Como se puede observar en la imagen, si el estado actual del
bot es *atacar*, tiene la salud alta, no detecta sonido y no
tiene enemigos cercanos, el estado del bot en $S_(t+1)$ tendrá una probabilidad alta de ser *explorar*.

== Ejemplo 2

#figure(
  image("/assets/example2.png"),
  caption: ["Ejemplo 2"]
)

Como se puede observar en la imagen, si el estado actual del bot
es *huir* y tiene la salud baja, está armado y tiene enemigos cercanos lo más probable es que ataque en $S_(t+1)$,
lo que encaja con la personalidad agresiva del bot.

#pagebreak()

== Ejemplo 3

#figure(
  image("/assets/example3.png"),
  caption: ["Ejemplo 3"]
)

En este caso se puede observar que si el estado actual del bot es *detectar_peligro* con casi total seguridad,
incluso con la salud baja y desarmado,
el bot atacará en $S_(t+1)$. Es decir el bot si se siente amenazado atacará aunque no tenga armas, usando cuerpo a cuerpo o lo que pueda.

== Ejemplo 4

#figure(
  image("/assets/example4.png"),
  caption: ["Ejemplo 4"]
)

En esta situación el bot se encuentra en un estado de *explorar*, tiene la salud alta, está desarmado y tiene enemigos cercanos.
Por tanto la decisión más probable del bot en $S_(t+1)$ es
es buscar un arma y como observaremos en el siguiente ejemplo,
tras encontrar el arma, lo siguiente que hará será atacar.

#pagebreak()

== Ejemplo 5

#figure(
  image("/assets/example5.png"),
  caption: ["Ejemplo 5"]
)

Como mencionado en el ejemplo, tras encontrar un arma y tener enemigos cercanos,
el bot con bastante seguridad atacará en $S_(t+1)$.

#pagebreak()

#bibliography("bibliography.bib")
