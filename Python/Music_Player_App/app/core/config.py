"""
Sistema de Gestión de Configuración
Configuración centralizada para toda la aplicación
"""

import os
from pathlib import Path
from typing import Dict, Any
import json


class Config:
    """Clase principal de configuración para la aplicación"""
    
    # Configuración de la aplicación
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-secret-key-change-in-production'
    DEBUG = True
    TESTING = False
    
    # Rutas
    BASE_DIR = Path(__file__).parent.parent.parent
    CACHE_DIR = BASE_DIR / 'cache'
    LOGS_DIR = BASE_DIR / 'logs'
    DATA_DIR = BASE_DIR / 'data'
    DB_PATH = DATA_DIR / 'music_player.db'
    
    # Configuración de base de datos
    SQLALCHEMY_DATABASE_URI = f'sqlite:///{DB_PATH}'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    # Configuración de caché
    CACHE_TYPE = 'filesystem'
    CACHE_DEFAULT_TIMEOUT = 3600  # 1 hora
    CACHE_THRESHOLD = 500
    MAX_CACHE_SIZE_MB = 500
    
    # Configuración de YouTube
    YT_DLP_OPTIONS = {
        'format': 'bestaudio/best',
        'quiet': True,
        'no_warnings': True,
        'extract_flat': False,
        'skip_download': True,
        'youtube_include_dash_manifest': False,
        'nocheckcertificate': True,
        'ignoreerrors': True,
        'logtostderr': False,
        'no_color': True,
    }
    
    # Configuración de búsqueda
    MAX_SEARCH_RESULTS = 20
    DEFAULT_SEARCH_RESULTS = 10
    SEARCH_CACHE_TIMEOUT = 1800  # 30 minutos
    
    # Configuración de transmisión de video
    STREAM_CHUNK_SIZE = 8192
    MAX_STREAM_RETRIES = 3
    STREAM_TIMEOUT = 30
    
    # Configuración de recomendaciones
    RECOMMENDATION_COUNT = 10
    SIMILARITY_THRESHOLD = 0.3
    GENRE_WEIGHT = 0.4
    POPULARITY_WEIGHT = 0.3
    RECENCY_WEIGHT = 0.3
    
    # Configuración de rendimiento
    MAX_WORKERS = 4
    REQUEST_TIMEOUT = 30
    MAX_RETRIES = 3
    RETRY_DELAY = 1
    
    # Configuración de logging
    LOG_LEVEL = 'INFO'
    LOG_FORMAT = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    LOG_MAX_BYTES = 10485760  # 10MB
    LOG_BACKUP_COUNT = 5
    LOG_TO_FILE = True
    LOG_TO_CONSOLE = True
    
    # Configuración de seguridad
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # 16MB
    ALLOWED_VIDEO_IDS_PATTERN = r'^[a-zA-Z0-9_-]{11}$'
    RATE_LIMIT_REQUESTS = 100
    RATE_LIMIT_PERIOD = 60  # segundos
    
    # Configuración de la interfaz de usuario
    DEFAULT_VOLUME = 0.7
    AUTOPLAY_ENABLED = True
    SHUFFLE_ENABLED = False
    REPEAT_MODE = 'none'  # none, one, all
    
    @classmethod
    def load_from_file(cls, filepath: str) -> None:
        """
        Cargar configuración desde un archivo JSON
        
        Args:
            filepath: Ruta al archivo de configuración
        """
        if os.path.exists(filepath):
            with open(filepath, 'r') as f:
                config_data = json.load(f)
                for key, value in config_data.items():
                    if hasattr(cls, key):
                        setattr(cls, key, value)
    
    @classmethod
    def save_to_file(cls, filepath: str) -> None:
        """
        Guardar la configuración actual en un archivo JSON
        
        Args:
            filepath: Ruta donde se guardará la configuración
        """
        config_data = {
            key: value for key, value in cls.__dict__.items()
            if not key.startswith('_') and not callable(value)
        }
        
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        with open(filepath, 'w') as f:
            json.dump(config_data, f, indent=4, default=str)
    
    @classmethod
    def get_config_dict(cls) -> Dict[str, Any]:
        """
        Obtener la configuración como diccionario
        
        Returns:
            Diccionario con todos los valores de configuración
        """
        return {
            key: value for key, value in cls.__dict__.items()
            if not key.startswith('_') and not callable(value)
        }
    
    @classmethod
    def update_config(cls, **kwargs) -> None:
        """
        Actualizar valores de configuración
        
        Args:
            **kwargs: Pares clave-valor de configuración a actualizar
        """
        for key, value in kwargs.items():
            if hasattr(cls, key):
                setattr(cls, key, value)


class DevelopmentConfig(Config):
    """Configuración del entorno de desarrollo"""
    DEBUG = True
    TESTING = False
    LOG_LEVEL = 'DEBUG'


class ProductionConfig(Config):
    """Configuración del entorno de producción"""
    DEBUG = False
    TESTING = False
    LOG_LEVEL = 'WARNING'
    CACHE_DEFAULT_TIMEOUT = 7200  # 2 horas


class TestingConfig(Config):
    """Configuración del entorno de pruebas"""
    DEBUG = True
    TESTING = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'
    LOG_LEVEL = 'DEBUG'


# Diccionario de configuraciones para cambio sencillo
config_by_name = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'testing': TestingConfig,
    'default': DevelopmentConfig
}


def get_config(config_name: str = 'default') -> Config:
    """
    Obtener el objeto de configuración por nombre
    
    Args:
        config_name: Nombre de la configuración (development, production, testing, default)
    
    Returns:
        Objeto de configuración
    """
    return config_by_name.get(config_name, DevelopmentConfig)
