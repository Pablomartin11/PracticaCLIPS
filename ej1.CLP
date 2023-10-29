; Creamos la plantilla para la semantica univaluada.
(deftemplate oav-u
   (slot objeto(type SYMBOL))
   (slot atributo (type SYMBOL))
   (slot valor)
)

(deffacts hechos-supuestamente-univaluados
   (oav-u (objeto Juan) (atributo edad) (valor 35))
   (oav-u (objeto Juan) (atributo edad) (valor 41))
   (oav-u (objeto Juan) (atributo edad) (valor 48))
)

(defrule verificar-semantica-univaluada
   ?x1 <- (oav-u (objeto ?nombre) (atributo ?edad) (valor ?valor1))
   ?x2 <- (oav-u (objeto ?nombre) (atributo ?edad) (valor ?valor2&:(!= ?valor2 ?valor1)))
   =>
   (retract ?x2)
)
