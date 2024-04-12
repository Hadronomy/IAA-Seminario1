#import "template.typ": *
#import "@preview/tablex:0.0.8": tablex, hlinex, vlinex, colspanx, rowspanx

#set math.equation(numbering: "(1)")

#show: project.with(
  title: "Seminario 1",
  subtitle: [
    Redes Bayesianas en Juegos
    
    Parte 3
  ],
  author: (
    "Pablo Santana González",
    "Pablo Hernández Jiménez",
    "Álvaro Fontenla León"
  ),
  affiliation: "Universidad de La Laguna",
  date: datetime.today().display(),
  Licence: "Curso 2023-2024",
  UE: "Inteligencia Artificial Avanzada",
  logo: "images/ull-logo.png",
  main_color: "#5c068c",
  toc_title: "Índice",
)

= Introducción

En este seminario se va a realizar el diseño y análisis de una red bayesiana que modela el comportamiento de un bot en un videojuego.

La implementación de la red bayesiana se ha realizado con el software `GeNIe` y se ha exportado a un archivo `.xdsl`.
Y está basada en la publicación "Teaching Bayesian Behaviours to Video Game Characters". @article

En esta tercera parte se expande sobre el programa
implementado en la segunda parte, para implementar
la funcionalidad de aprendizaje usando una red que ha
sido exportada a un archivo `.xdsl` y otra generada por python.

Todos los archivos necesarios para la realización de este
seminario se encuentran en el repositorio de GitHub del
grupo. #footnote([
  Enlace al repositorio de Github
  #link("https://github.com/Hadronomy/IAA-Seminario1")
])

== Porcentaje de Participación

#tablex(
  columns: (1fr, 1fr, 1fr, auto),
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

= Descripción del funcionamiento del programa

El programa de `SMILE` que hemos implementado, usa
la red bayesiana exportada a un archivo `.xdsl` para
tomar decisiones en función de las observaciones que recibe.

#figure(
  image(
    "images/help.png",
  ),
  caption: "Ayuda del programa",
)

Existen tres subcomandos que se pueden ejecutar:

#par(first-line-indent: 0em)[

/ probabilities: Lee el modelo del bot y pide la evidencia de cada nodo y luego calcula la probabilidad del siguiente estado del bot.

/ tendencies: Lee el modelo del bot y calcula el siguiente estado del bot. Si el siguiente estado es el mismo que el estado anterior, contará como una repetición, si hay 20 repeticiones el bucle se detendrá.

/ learn: Lee un fichero de datos sobre los distintos estados del bot en cada momento y calcula las probabilidades de los nodos de la red bayesiana.

]

#pagebreak()

= Ejemplo de uso

== Probabilidades

#figure(
  image(
    "images/prob-usage-1.png",
    width: 90%
  ),
  caption: [Ejemplo de uso del subcomando `probabilities`],
) <probability-usage-1>

En el ejemplo de @probability-usage-1, se muestra el uso del
subcomando `probabilities` del programa `iaa-seminario1`.
Se pregunta al usuario por la evidencia de cada nodo y luego
calcula la probabilidad del siguiente estado del bot,
mostrando el resultado en forma de tabla con las probabilidades
y el $S_(t+1)$.

En este caso se ha introducido la evidencia de que el bot
está en el estado `explorar`, salud `Baja`, `Desarmado`,
con armas en los oponentes, sonido, enemigos cercanos, armas cercanas
y paquetes de salud cernanos.

Resaltar que el $S_(t+1)$ es `buscar_energía`, que es el estado
obtenido a partir de un muestreo aleatorio ponderado.

Los resultados mostrados en la @probability-usage-1 
concuerdan con los obtenidos si los infiriéramos con el 
`GeNIe`, véase @genie-prob-infer.

#figure(
  image(
    "images/prob-genie.png",
  ),
  caption: [Inferencia en el `GeNIe`],
) <genie-prob-infer>

#pagebreak()

== Tendencias

En el ejemplo de @tend-usage-1, se muestra el uso del
subcomando `tendencies` del programa `iaa-seminario1`.

El bot inicia con los estados mostrados en 
@tend-values.

// Estado inicial: huir
// Salud: Alta
// Arma: Armado
// Armas de los Oponentes: Si
// Sonido: Si
// Enemigos Cercanos: Si
// Armas Cercanas: Si
// Paquete de Salud Cercano: Si
#figure(
  tablex(
    columns: (1fr, 1fr),

    auto-vlines: false,
    repeat-header: true,
    [*Nodo*], [*Valor*],
    [Estado inicial], [huir],
    [Salud], [Alta],
    [Arma], [Armado],
    [Armas de los Oponentes], [Si],
    [Sonido], [Si],
    [Enemigos Cercanos], [Si],
    [Armas Cercanas], [Si],
    [Paquete de Salud Cercano], [Si],
  ),
  kind: table,
  caption: "Valores iniciales de los nodos",
) <tend-values>

Procede a calcular las probabilidades de los siguientes estados y elige el estado de forma aleatoria con una distribución de probabilidad ponderada.

En este caso, el bot ha elegido el estado `atacar` como 
siguiente estado y se mantiene en un bucle hasta que el
estado se repita 20 veces. Esto tiene sentido, puesto que
siendo un bot de personalidad agresiva y con los estados
iniciales de la @tend-values, que presentan la mejor
situación posible para atacar, es lógico que el bot
elija el estado `atacar` como siguiente estado.


#pagebreak()

#figure(
  image(
    "images/tend-usage-1.png",
    width: 65%
  ),
  caption: [Ejemplo de uso del subcomando `tendencies`],
) <tend-usage-1>

Los resultados mostrados en la @tend-usage-1 concuerdan
con los obtenidos si los infiriéramos con el `GeNIe`, véase @genie-infer.

#figure(
  image(
    "images/tend-genie.png",
  ),
  caption: [Inferencia en el `GeNIe`],
) <genie-infer>

#pagebreak()

= Aprendizaje del bot

== Aprendizaje adoptado en el artículo

Los creadores del bot han adoptado un enfoque diferente para enseñarle comportamientos, 
buscando un mayor dinamismo en su aprendizaje. 
En lugar de especificar todas las probabilidades manualmente, 
ahora permiten que el bot aprenda observando y reaccionando a las acciones del jugador en tiempo real.

Para facilitar este proceso de aprendizaje, han desarrollado una interfaz simple que permite 
al jugador controlar directamente el comportamiento del bot durante el juego. 
Esta interfaz proporciona al jugador botones que le permiten cambiar entre diferentes acciones, 
como atacar, huir o explorar, con facilidad y en tiempo real.

Además, los creadores del bot han implementado un sistema de reconocimiento de comportamientos 
basado en heurísticas programadas de manera imperativa. 
Este sistema analiza las acciones del jugador para identificar patrones clave que indican ciertos comportamientos, 
como atacar o huir. Por ejemplo, puede detectar la distancia a los enemigos, 
la velocidad de movimiento y otras señales relevantes para determinar el comportamiento del bot.

Este proceso de reconocimiento se realiza utilizando datos recopilados durante el juego, 
lo que permite mejorar continuamente el comportamiento del bot. 
En resumen, el enfoque que han adaptado los creadores del bot le ha permitido aprender de manera 
más efectiva y adaptarse a diferentes estilos de juego, acercándolo cada vez más al nivel de habilidad de un jugador.

== Nuestro enfoque de aprendizaje

En nuestro caso, hemos adoptado un enfoque más simple para el aprendizaje del bot. Hemos implementado un programa que utiliza una red bayesiana para tomar decisiones
en función de las observaciones que recibe.

Este enfoque nos permite simular el comportamiento del bot en tiempo de juego,
sin necesidad de un sistema de reconocimiento de comportamientos basado en
heurísticas programadas de manera imperativa. En lugar de eso, nuestro bot aprende de manera más estática, basándose en las 
probabilidades de los nodos de la red bayesiana.

El aprendizaje en concreto se realiza mediante la probabilidad calculada
a partir de un fichero de datos sobre los distintos estados del bot en cada
momento.

#pagebreak()

== Comparación de las tablas

A continuación, se muestra una comparación entre las tablas de probabilidades
entre las generadas por el `GeNIe` y las generadas por nuestro programa.

#figure(
  image(
    "images/arma-aprendizaje.PNG",
  ),
  caption: [Tabla en `GeNIe`],
) <genie-learn-weapon>

#figure(
  image(
    "images/arma-aprendizaje-python.png",
    width: 50%
  ),
  caption: [Tabla en Python],
) <python-learn-weapon>

Como podemos observar en las @genie-learn-weapon y @python-learn-weapon,
las tablas generadas por el `GeNIe` y por nuestro programa son idénticas.


#figure(
  image(
    "images/estado-futuro-aprendizaje.PNG",
  ),
  caption: [Tabla en `GeNIe`],
) <genie-learn-future-state>

#figure(
  image(
    "images/estado-futuro-bot-aprendizaje-python.png",
    width: 50%
  ),
  caption: [Tabla en Python],
) <python-learn-future-state>

De igual manera que en las anteriores tablas, las tablas @genie-learn-future-state
y @python-learn-future-state son idénticas.

Esto ocurre con todas las tablas generadas por el `GeNIe` y
por nuestro programa, siendo siempre iguales.

// #figure(
//   image(
//     "images/prob-usage-1.png",
//   ),
//   caption: [Ejemplo de uso del subcomando `probabilities`],
// ) <probability-usage-1>


#pagebreak()

= Conclusión

Este seminario nos ha demostrado cómo diseñar y analizar una red bayesiana para modelar 
el comportamiento de un bot en un videojuego haciendo uso de la herramienta GeNIe.
Además, se desarrolló un programa haciendo uso de la licencia SMILE que utiliza esta red 
bayesiana para tomar decisiones basadas en observaciones recibidas durante el juego, permitiéndonos
simular el comportamiento que tendría el bot en tiempo de juego.

En la tercera parte de este seminario, se ha expandido el programa implementado en la segunda parte y hemos
aprendido a entrenar las redes bayesianas con un fichero de
datos sobre los distintos estados del bot en cada momento.
Además de cómo realizar el mismo proceso de aprendizaje usando
únicamente python.

#pagebreak()

#bibliography("bibliography.bib")
