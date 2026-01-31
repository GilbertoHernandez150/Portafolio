import pymongo
import redis
import json

# Conectar a MongoDB
mongo_client = pymongo.MongoClient('mongodb://localhost:27017/')
mongo_db = mongo_client['SistemaReservaViajes']
mongo_collection = mongo_db['Usuarios']

# Conectar a Redis
redis_client = redis.Redis(host='127.0.0.1', port=6379, db=0)

# Obtener documentos de MongoDB
documents = mongo_collection.find()

# Transferir documentos a Redis
for doc in documents:
   
    key = str(doc.get('UsuarioID'))
    
    
    json_data = json.dumps(doc, default=str)
    
    # Usar el UsuarioID del documento como clave en Redis
    redis_client.set(key, json_data)

print("Transferencia completada.")