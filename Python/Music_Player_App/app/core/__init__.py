"""
Paquete Core
Componentes de infraestructura para la aplicación
"""

from app.core.cache import SmartCache, get_cache
from app.core.config import Config, get_config
from app.core.logger import setup_logger, setup_performance_logger, LoggerManager

__all__ = [
    'SmartCache',
    'get_cache',
    'Config',
    'get_config',
    'setup_logger',
    'setup_performance_logger',
    'LoggerManager'
]
