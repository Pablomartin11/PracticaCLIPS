; Plantilla para objetos multivaluados.
(deftemplate oav-m
   (slot objeto(type SYMBOL))
   (slot atributo (type SYMBOL))
   (slot valor)
)

; Plantilla para objetos univaluados
(deftemplate oav-u
   (slot objeto(type SYMBOL))
   (slot atributo (type SYMBOL))
   (slot valor)
)

; Definimos los hechos para los pacientes Maria y Pedro.
(deffacts hechos-sobre-pacientes
    (oav-u (objeto Maria) (atributo sexo) (valor mujer))
    (oav-u (objeto Maria) (atributo edad) (valor 10))
    (oav-u (objeto Maria) (atributo annosFumando) (valor 0))
    (oav-m (objeto Maria) (atributo sintomas) (valor dolorPecho))
    (oav-m (objeto Maria) (atributo evidencias) (valor rumorDiastolico))
    (oav-u (objeto Maria) (atributo presionSistolica) (valor 130))
    (oav-u (objeto Maria) (atributo presionDiastolica) (valor 60))

    (oav-u (objeto Pedro) (atributo sexo) (valor hombre))
    (oav-u (objeto Pedro) (atributo edad) (valor 70))
    (oav-u (objeto Pedro) (atributo annosFumando) (valor 6))
    (oav-m (objeto Pedro) (atributo sintomas) (valor calambresPiernas))
    (oav-m (objeto Pedro) (atributo evidencias) (valor rumorSistolico))
    (oav-m (objeto Pedro) (atributo evidencias) (valor dilatacionCora))
    (oav-u (objeto Pedro) (atributo presionSistolica) (valor 150))
    (oav-u (objeto Pedro) (atributo presionDiastolica) (valor 95))

)

; Definimos los hechos para las enfermedades.
(deffacts hechos-sobre-las-enfermedades
    (oav-u (objeto Aneurisma) (atributo afecta) (valor vasosSanguineos))
    (oav-m (objeto Aneurisma) (atributo sintoma) (valor dolorAbdominal))
    (oav-m (objeto Aneurisma) (atributo evidencia) (valor rumorAbdominal))
    (oav-m (objeto Aneurisma) (atributo evidencia) (valor masaPulsante))

    (oav-u (objeto EstenosisArterial) (atributo afecta) (valor vasosSanguineos))
    (oav-m (objeto EstenosisArterial) (atributo sintoma) (valor calambresPiernas))

    (oav-u (objeto Arteriosclerosis) (atributo afecta) (valor vasosSanguineos))

    (oav-u (objeto Regurgitacion) (atributo afecta) (valor corazon))
    (oav-m (objeto Regurgitacion) (atributo evidencia) (valor rumorSistolico))
    (oav-m (objeto Regurgitacion) (atributo evidencia) (valor dilatacionCorazon))
)

; Reglas
(defrule calcular-PresPul "Calcular la Presion del Pulso"
    (declare (salience 9000))
    (oav-u (objeto ?nombre) (atributo presionSistolica) (valor ?numPresSis))
    (oav-u (objeto ?nombre) (atributo presionDiastolica) (valor ?numPresDia))
    =>
    (assert (oav-u (objeto ?nombre) (atributo presionPulso) (valor (- ?numPresSis ?numPresDia))))
)

(defrule diagnostico-Aneurisma "Deteccion de aneurisma"
    (oav-m (objeto ?nombre) (atributo sintomas) (valor dolorAbdominal))
    (oav-m (objeto ?nombre) (atributo evidencias) (valor rumorAbdominal))
    (oav-m (objeto ?nombre) (atributo evidencias) (valor masaPulsante))
    =>
    (assert (oav-m (objeto ?nombre) (atributo diagnostico) (valor Aneurisma)))
)

(defrule diagnostico-EstenosisArterial "Deteccion de Estenosis Arterial"
    (declare (salience 6000))
    (oav-m (objeto ?nombre) (atributo sintomas) (valor calambresPiernas))
    =>
    (assert (oav-m (objeto ?nombre) (atributo diagnostico) (valor EstenosisArterial)))
)

(defrule diagnostico-Arteriosclerosis "Deteccion de Arteriosclerosis"
    (oav-m (objeto ?nombre) (atributo diagnostico) (valor EstenosisArterial))
    (oav-u (objeto ?nombre) (atributo annosFumando) (valor ?annos))
    (oav-u (objeto ?nombre) (atributo edad) (valor ?numeroEdad))

    (or (test (> ?annos 10)) (test (> ?numeroEdad 55)))
    =>
    (assert (oav-m (objeto ?nombre) (atributo diagnostico) (valor Arteriosclerosis)))
)

(defrule diagnostico-Regurgitacion "Deteccion de Regurgitacion Aortica"
    (oav-m (objeto ?nombre) (atributo evidencias) (valor rumorSistolico | dilatacionCorazon))
    (oav-u (objeto ?nombre) (atributo presionSistolica) (valor ?numPresSis))
    (oav-u (objeto ?nombre) (atributo presionPulso) (valor ?numPresPul))

    (test (> ?numPresSis 130))
    (test (> ?numPresPul 50))
    =>
    (assert (oav-m (objeto ?nombre) (atributo diagnostico) (valor Regurgitacion)))
)

(defrule no-diagnostico "No tiene diagnostico"
    (declare (salience -5000))
    (oav-u (objeto ?nombre) (atributo edad))
    (not (oav-m (objeto ?nombre) (atributo diagnostico)) )
    =>
    (printout t ?nombre " no tiene ninguna enfermedad registrada" crlf)
)

(defrule comunicar-diagnostico "Comunicar el diagnostico"
    (declare (salience -5000))
    (oav-m (objeto ?nombre) (atributo diagnostico) (valor ?x))
    (oav-u (objeto ?x) (atributo afecta) (valor ?y))
    =>
    (printout t ?nombre " tiene " ?x ", que es una enfermedad de tipo cardiovascular y afecta a" ?y crlf)
)

(defrule verificar-semantica-univaluada
    (declare (salience 10000))
   ?x <- (oav-u (objeto ?nombre) (atributo ?univaluado) (valor ?valor1))
   ?y <- (oav-u (objeto ?nombre) (atributo ?univaluado) (valor ?valor2))
   (test (< (fact-index ?x) (fact-index ?y)))
   =>
   (retract ?x)
)
