"""
Inicialización del paquete de la aplicación
Crea y configura la aplicación Flask con todos los componentes necesarios
"""

from flask import Flask
from flask_cors import CORS
import os

from app.core.config import Config
from app.core.logger import setup_logger
from app.models.database import DatabaseManager
from app.api.routes import register_routes

logger = setup_logger(__name__)

def create_app(config_name='default'):
    """
    Patrón de fábrica de la aplicación
    
    Args:
        config_name: Configuración a utilizar (default, development, production)
    
    Returns:
        Instancia de la aplicación Flask configurada
    """
    app = Flask(__name__,
                template_folder='../templates',
                static_folder='../static')
    
    # Cargar configuración
    config = Config()
    app.config.from_object(config)
    
    # Habilitar CORS
    CORS(app)
    
    # Inicializar base de datos
    db_manager = DatabaseManager()
    db_manager.init_db()
    
    # Registrar rutas de la API
    register_routes(app)
    
    # Crear directorios necesarios
    os.makedirs('cache', exist_ok=True)
    os.makedirs('logs', exist_ok=True)
    os.makedirs('data', exist_ok=True)
    
    logger.info("Aplicación inicializada correctamente")
    
    return app
