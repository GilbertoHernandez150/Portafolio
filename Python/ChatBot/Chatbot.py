import re
import random
from responses import responses  # Importar las respuestas del archivo aparte

def get_response(user_input):
    split_message = re.split(r'\W+', user_input.lower())
    response = check_all_message(split_message)
    return response

def message_probability(user_message, recognized_words, single_response=False, required_words=[]): 
    message_certainty = 0
    has_required_words = True
    
    # Contar cuántas palabras reconocidas están en el mensaje del usuario
    for word in user_message:
        if word in recognized_words:
            message_certainty += 1
    
    # Calcular el porcentaje de coincidencia
    percentage = float(message_certainty) / float(len(recognized_words)) if recognized_words else 0
    
    # Verificar si las palabras requeridas están presentes
    for word in required_words:
        if word not in user_message:
            has_required_words = False
            break
    
    # Ajustar la condición para permitir coincidencias parciales con palabras requeridas
    if has_required_words and percentage > 0.2 or single_response:
        return int(percentage * 100)
    else:
        return 0

def check_all_message(message):
    highest_prob_list = {}
    
    for response in responses:
        bot_response = response["bot_response"]
        list_of_words = response["list_of_words"]
        single_response = response["single_response"]
        required_words = response["required_words"]
        
        highest_prob_list[bot_response] = message_probability(message, list_of_words, single_response, required_words)
    
    # Seleccionar la mejor coincidencia
    if not highest_prob_list:
        return unknown()
    
    best_match = max(highest_prob_list, key=highest_prob_list.get)
    return unknown() if highest_prob_list[best_match] < 20 else best_match

def unknown():
    response = ["Lo siento, no entiendo tu pregunta.", "Por favor repite eso.", "No estoy seguro de a qué te refieres."]
    return random.choice(response)

while True:
    print('Bot: ' + get_response(input('You: ')))