responses = [
    # 1. Saludos
    {
        "bot_response": "¡Hola! ¿Cómo puedo ayudarte hoy?", 
        "list_of_words": ["hola"], 
        "single_response": True, 
        "required_words": []
    },
    {
        "bot_response": "¡Buenas! Estoy aquí para ayudarte con cualquier consulta sobre el ITLA.", 
        "list_of_words": ["buenas", "buenos dias", "buenas tardes", "buenas noches"], 
        "single_response": True, 
        "required_words": []
    },
    {
        "bot_response": "¡Muy bien, gracias por preguntar! ¿En qué puedo asistirte sobre el ITLA?", 
        "list_of_words": ["como estas"], 
        "single_response": True, 
        "required_words": []
    },
    {
        "bot_response": "¡Saludos! Soy el asistente del ITLA. Estoy listo para responder tus preguntas.", 
        "list_of_words": ["saludos"], 
        "single_response": True, 
        "required_words": []
    },

    # 2. Historia del ITLA
    {
        "bot_response": "El ITLA fue fundado en el año 2000 y se especializa en educación tecnológica.", 
        "list_of_words": ["cuando", "fundado", "año"], 
        "single_response": False, 
        "required_words": []
    },
    {
        "bot_response": "Nuestro instituto comenzó su misión educativa en el año 2000, enfocándose en formar profesionales en tecnología.", 
        "list_of_words": ["cuando", "mision", "año"], 
        "single_response": False, 
        "required_words": []
    },
    {
        "bot_response": "El ITLA nació en el año 2000 con el objetivo de ser un referente en educación tecnológica en República Dominicana.", 
        "list_of_words": ["año", "nacio"], 
        "single_response": False, 
        "required_words": []
    },
    {
        "bot_response": "Fundado en el año 2000, el ITLA ha sido pionero en la formación de profesionales tecnológicos en el país.", 
        "list_of_words": ["historia"], 
        "single_response": False, 
        "required_words": []
    },

    # 3. Carreras
    {
        "bot_response": "Ofrecemos carreras en Desarrollo de Software, Redes de Información, Seguridad Informática, y más.", 
        "list_of_words": ["carreras", "ofrecen", "estudiar"], 
        "single_response": False, 
        "required_words": []
    },
    {
        "bot_response": "Nuestras carreras incluyen Desarrollo de Software, Redes, Ciberseguridad, Multimedia y Sistemas de Información.", 
        "list_of_words": ["carreras", "incluyen", "estudiar"], 
        "single_response": False, 
        "required_words": []
    },
    {
        "bot_response": "Tenemos programas académicos en áreas como Tecnología de Software, Infraestructura Tecnológica y Diseño Digital.", 
        "list_of_words": ["carreras", "programas", "estudiar"], 
        "single_response": False, 
        "required_words": []
    },
    {
        "bot_response": "Puedes estudiar carreras de alta demanda como Desarrollo Web, Redes Computacionales, Seguridad Digital y Multimedia.", 
        "list_of_words": ["carreras", "estudiar"], 
        "single_response": False, 
        "required_words": []
    },

    # 4. Contacto
    {
        "bot_response": "Puedes contactarnos al (809) 738-4852, atravez de nuestro instagram o por email a educapermanente@itla.edu.do.", 
        "list_of_words": ["contacto", "teléfono", "email","itla", "disponibles", "redes sociales", "contactarlos"], 
        "single_response": False, 
        "required_words": []
    },
    {
        "bot_response": "Nuestros canales de contacto son: Teléfono (809) 738-4852, Instagram @itla.edu.do, y email institucional.", 
        "list_of_words": ["contacto", "teléfono", "email","itla", "disponibles", "redes sociales", "contactarlos"], 
        "single_response": False, 
        "required_words": []
    },
    {
        "bot_response": "Puedes comunicarte con nosotros por teléfono, email o redes sociales. Estamos disponibles para resolver tus dudas.", 
        "list_of_words": ["contacto", "teléfono", "email","itla", "disponibles", "redes sociales", "contactarlos"], 
        "single_response": False, 
        "required_words": []
    },
    {
        "bot_response": "Contáctanos al (809) 738-4852, escríbenos a educapermanente@itla.edu.do o síguenos en nuestras redes sociales.", 
        "list_of_words": ["contacto", "teléfono", "email","itla", "disponibles", "redes sociales", "puedo", "contactarlos"], 
        "single_response": False, 
        "required_words": []
    },

    # 5. Agradecimiento
    {
        "bot_response": "Gracias por tu interés en el ITLA.", 
        "list_of_words": ["gracias", "thank you"], 
        "single_response": True, 
        "required_words": []
    },
    {
        "bot_response": "Estamos encantados de poder ayudarte. ¡Que tengas un excelente día!", 
        "list_of_words": ["gracias", "thank you"], 
        "single_response": True, 
        "required_words": []
    },
    {
        "bot_response": "Ha sido un placer poder asistirte. ¡Que tengas éxito!", 
        "list_of_words": ["gracias", "thank you"], 
        "single_response": True, 
        "required_words": []
    },
    {
        "bot_response": "Gracias por elegir el ITLA. Esperamos poder seguir ayudándote.", 
        "list_of_words": ["gracias", "thank you"], 
        "single_response": True, 
        "required_words": []
    },

    # 6. Despedida
    {
        "bot_response": "¡Hasta luego! Si necesitas más información, no dudes en preguntar.", 
        "list_of_words": ["hasta luego"], 
        "single_response": True, 
        "required_words": []
    },
    {
        "bot_response": "Fue un gusto atenderte. Que tengas un excelente día.", 
        "list_of_words": ["adios"], 
        "single_response": True, 
        "required_words": []
    },
    {
        "bot_response": "¡Cuídate! Esperamos verte pronto en el ITLA.", 
        "list_of_words": ["me voy"], 
        "single_response": True, 
        "required_words": []
    },
    {
        "bot_response": "Gracias por tu tiempo. Estaremos aquí cuando me necesites.", 
        "list_of_words": ["eso", "fue", "todo"], 
        "single_response": True, 
        "required_words": []
    },

    # 7. No entendido
    {
        "bot_response": "Lo siento, no entiendo tu pregunta. ¿Podrías reformularla?", 
        "list_of_words": ["no", "entender", "perdón"], 
        "single_response": True, 
        "required_words": []
    },
    {
        "bot_response": "Disculpa, ¿podrías ser más específico? No logro comprender completamente tu pregunta.", 
        "list_of_words": ["no", "entender", "perdón"], 
        "single_response": True, 
        "required_words": []
    },
    {
        "bot_response": "Necesito más contexto para poder ayudarte. ¿Podrías explicar tu duda con más detalle?", 
        "list_of_words": ["no", "entender", "perdón"], 
        "single_response": True, 
        "required_words": []
    },
    {
        "bot_response": "Parece que hay algo que no quedó claro. ¿Quieres intentar preguntar de otra manera?", 
        "list_of_words": ["no", "entender", "perdón"], 
        "single_response": True, 
        "required_words": []
    },

    # 8. Ubicación
    {
        "bot_response": "Esta ubicado en Las Américas, Km. 27, Santo Domingo", 
        "list_of_words": ["ubicacion", "dónde", "localización", "encontrar", "llegar", "ubicado", "itla"], 
        "single_response": False, 
        "required_words": []
    },
    {
        "bot_response": "Nuestro campus principal se encuentra en la Autopista Las Américas, Kilómetro 27, Santo Domingo.", 
        "list_of_words": ["ubicacion", "dónde", "campus", "localización", "encontrar", "llegar", "ubicado", "itla"], 
        "single_response": False, 
        "required_words": []
    },
    {
        "bot_response": "Estamos ubicados en la zona de Las Américas, específicamente en el Kilómetro 27 de la autopista.", 
        "list_of_words": ["dónde", "campus", "localización", "encontrar", "llegar", "ubicado", "itla"], 
        "single_response": False, 
        "required_words": []
    },
    {
        "bot_response": "Puedes encontrarnos en Autopista Las Américas, Km. 27, Santo Domingo. Estamos bien comunicados y con fácil acceso.", 
        "list_of_words": ["ubicacion", "dónde", "campus", "localización", "encontrar", "llegar", "itla", "como"], 
        "single_response": False, 
        "required_words": []
    },

    # 9. Educación Continua
    {
        "bot_response": "El ITLA ofrece educación continua en cursos y talleres de tecnología, entre ellos estan: Desarrollo de Software, Robotica, Ciber Seguridad, Multimedia, Etc... .", 
        "list_of_words": ["educación", "continua", "cursos", "talleres", "itla", "ofrece"], 
        "single_response": False, 
        "required_words": []
    },
    {
        "bot_response": "Nuestros cursos de educación continua incluyen programación, diseño digital, seguridad informática y más.", 
        "list_of_words": ["educación", "continua", "cursos", "talleres", "itla"], 
        "single_response": False, 
        "required_words": []
    },
    {
        "bot_response": "Tenemos una amplia oferta de talleres y cursos cortos en diferentes áreas tecnológicas para tu desarrollo profesional.", 
        "list_of_words": ["educación", "continua", "cursos", "talleres", "itla", "disponibles"], 
        "single_response": False, 
        "required_words": []
    },
    {
        "bot_response": "Ofrecemos capacitación continua en tecnologías de vanguardia para que te mantengas actualizado.", 
        "list_of_words": ["educación", "continua", "cursos", "talleres", "itla", "capacitacion", "ofrecen"], 
        "single_response": False, 
        "required_words": []
    },

    # 10. Inscripciones
    {
        "bot_response": "Las inscripciones se abren varias veces al año. Puedes visitar nuestra página web o nuestro instagram para más información.", 
        "list_of_words": ["inscripciones", "cuando", "matrícula", "registrarse", "itla", "son", "las", "abren", "inscribirme", "se"], 
        "single_response": False, 
        "required_words": []
    },
    {
        "bot_response": "Abrimos periodos de inscripción trimestralmente. Te recomendamos estar pendiente de nuestras redes sociales.", 
        "list_of_words": ["inscripciones", "cuando", "matrícula", "registrarme", "itla", "inscribirme", "abren"], 
        "single_response": False, 
        "required_words": []
    },
    {
        "bot_response": "Puedes inscribirte en diferentes momentos del año. Visita nuestra web o contáctanos para conocer las próximas fechas.", 
        "list_of_words": ["inscripciones", "cuando", "matrícula", "registrarse", "itla", "inscribirse", "inscribirme", "disponibles"], 
        "single_response": False, 
        "required_words": []
    },
    {
        "bot_response": "Los procesos de inscripción son frecuentes. Te recomendamos seguir nuestras redes para no perderte ninguna convocatoria.", 
        "list_of_words": ["inscripciones", "cuando", "matrícula", "itla", "inscripcion", "inscribirme", "disponibles", "proceso", "procesos"], 
        "single_response": False, 
        "required_words": []
    }
]