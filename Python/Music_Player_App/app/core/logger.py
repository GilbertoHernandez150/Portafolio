"""
Sistema Profesional de Logging
Logging multinivel con rotación, colores y monitoreo de rendimiento
"""

import logging
import logging.handlers
import os
import sys
from pathlib import Path
from typing import Optional
from datetime import datetime
import json
import traceback


class ColoredFormatter(logging.Formatter):
    """Formateador personalizado con colores para salida en consola"""
    
    COLORS = {
        'DEBUG': '\033[36m',     # Cian
        'INFO': '\033[32m',      # Verde
        'WARNING': '\033[33m',   # Amarillo
        'ERROR': '\033[31m',     # Rojo
        'CRITICAL': '\033[35m',  # Magenta
        'RESET': '\033[0m'       # Reiniciar
    }
    
    def format(self, record):
        """Formatear el registro de log con colores"""
        log_color = self.COLORS.get(record.levelname, self.COLORS['RESET'])
        record.levelname = f"{log_color}{record.levelname}{self.COLORS['RESET']}"
        return super().format(record)


class JSONFormatter(logging.Formatter):
    """Formatea los logs en JSON para logging estructurado"""
    
    def format(self, record):
        """Formatear el registro de log como JSON"""
        log_data = {
            'timestamp': datetime.fromtimestamp(record.created).isoformat(),
            'level': record.levelname,
            'logger': record.name,
            'message': record.getMessage(),
            'module': record.module,
            'function': record.funcName,
            'line': record.lineno
        }
        
        if record.exc_info:
            log_data['exception'] = traceback.format_exception(*record.exc_info)
        
        if hasattr(record, 'extra_data'):
            log_data['extra'] = record.extra_data
        
        return json.dumps(log_data)


class PerformanceLogger:
    """Logger para métricas de rendimiento"""
    
    def __init__(self, logger: logging.Logger):
        self.logger = logger
        self.metrics = {}
    
    def start_timer(self, operation: str) -> None:
        """Iniciar medición de tiempo de una operación"""
        self.metrics[operation] = {
            'start': datetime.now(),
            'end': None,
            'duration': None
        }
    
    def end_timer(self, operation: str) -> float:
        """
        Finalizar medición de tiempo de una operación y registrar la duración
        
        Returns:
            Duración en segundos
        """
        if operation in self.metrics:
            self.metrics[operation]['end'] = datetime.now()
            duration = (
                self.metrics[operation]['end'] -
                self.metrics[operation]['start']
            ).total_seconds()
            self.metrics[operation]['duration'] = duration
            
            self.logger.info(f"Rendimiento: {operation} tomó {duration:.3f}s")
            return duration
        return 0.0
    
    def log_metric(self, metric_name: str, value: float, unit: str = '') -> None:
        """Registrar una métrica personalizada"""
        self.logger.info(f"Métrica: {metric_name} = {value}{unit}")
    
    def get_metrics(self) -> dict:
        """Obtener todas las métricas recopiladas"""
        return self.metrics


class LoggerManager:
    """Gestor singleton de logging para toda la aplicación"""
    
    _instance = None
    _loggers = {}
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(LoggerManager, cls).__new__(cls)
            cls._instance._initialized = False
        return cls._instance
    
    def __init__(self):
        if self._initialized:
            return
        
        self._initialized = True
        self.log_dir = Path('logs')
        self.log_dir.mkdir(exist_ok=True)
        
        # Crear archivos principales de log
        self.app_log_file = self.log_dir / 'app.log'
        self.error_log_file = self.log_dir / 'error.log'
        self.performance_log_file = self.log_dir / 'performance.log'
        self.json_log_file = self.log_dir / 'app.json.log'
    
    def get_logger(self, name: str, level: str = 'INFO') -> logging.Logger:
        """
        Obtener o crear un logger con el nombre indicado
        
        Args:
            name: Nombre del logger (usualmente __name__)
            level: Nivel de logging (DEBUG, INFO, WARNING, ERROR, CRITICAL)
        
        Returns:
            Instancia de logger configurada
        """
        if name in self._loggers:
            return self._loggers[name]
        
        logger = logging.getLogger(name)
        logger.setLevel(getattr(logging, level.upper()))
        logger.handlers.clear()
        
        # Handler de consola con colores
        console_handler = logging.StreamHandler(sys.stdout)
        console_handler.setLevel(logging.DEBUG)
        console_formatter = ColoredFormatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
        console_handler.setFormatter(console_formatter)
        logger.addHandler(console_handler)
        
        # Handler de archivo con rotación (log principal)
        file_handler = logging.handlers.RotatingFileHandler(
            self.app_log_file,
            maxBytes=10485760,  # 10MB
            backupCount=5,
            encoding='utf-8'
        )
        file_handler.setLevel(logging.DEBUG)
        file_formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
        file_handler.setFormatter(file_formatter)
        logger.addHandler(file_handler)
        
        # Handler de errores (solo errores)
        error_handler = logging.handlers.RotatingFileHandler(
            self.error_log_file,
            maxBytes=10485760,
            backupCount=5,
            encoding='utf-8'
        )
        error_handler.setLevel(logging.ERROR)
        error_handler.setFormatter(file_formatter)
        logger.addHandler(error_handler)
        
        # Handler JSON para logging estructurado
        json_handler = logging.handlers.RotatingFileHandler(
            self.json_log_file,
            maxBytes=10485760,
            backupCount=5,
            encoding='utf-8'
        )
        json_handler.setLevel(logging.INFO)
        json_handler.setFormatter(JSONFormatter())
        logger.addHandler(json_handler)
        
        self._loggers[name] = logger
        return logger
    
    def get_performance_logger(self, name: str) -> PerformanceLogger:
        """
        Obtener un logger de rendimiento
        
        Args:
            name: Nombre del logger
        
        Returns:
            Instancia de PerformanceLogger
        """
        logger = self.get_logger(name)
        return PerformanceLogger(logger)
    
    def clear_old_logs(self, days: int = 7) -> None:
        """
        Eliminar archivos de log más antiguos que los días indicados
        
        Args:
            days: Cantidad de días a conservar
        """
        import time
        cutoff_time = time.time() - (days * 86400)
        
        for log_file in self.log_dir.glob('*.log*'):
            if log_file.stat().st_mtime < cutoff_time:
                log_file.unlink()
                print(f"Archivo de log antiguo eliminado: {log_file}")


def setup_logger(name: str, level: str = 'INFO') -> logging.Logger:
    """
    Función rápida para obtener un logger
    
    Args:
        name: Nombre del logger (usualmente __name__)
        level: Nivel de logging
    
    Returns:
        Logger configurado
    """
    manager = LoggerManager()
    return manager.get_logger(name, level)


def setup_performance_logger(name: str) -> PerformanceLogger:
    """
    Función rápida para obtener un logger de rendimiento
    
    Args:
        name: Nombre del logger
    
    Returns:
        Instancia de PerformanceLogger
    """
    manager = LoggerManager()
    return manager.get_performance_logger(name)


# Ejemplo de uso y pruebas
if __name__ == '__main__':
    # Probar logging básico
    logger = setup_logger(__name__, 'DEBUG')
    
    logger.debug("Este es un mensaje de depuración")
    logger.info("Este es un mensaje informativo")
    logger.warning("Este es un mensaje de advertencia")
    logger.error("Este es un mensaje de error")
    logger.critical("Este es un mensaje crítico")
    
    # Probar logging de rendimiento
    perf_logger = setup_performance_logger(__name__)
    
    perf_logger.start_timer('operacion_prueba')
    import time
    time.sleep(0.1)
    duration = perf_logger.end_timer('operacion_prueba')
    
    perf_logger.log_metric('metrica_prueba', 42.5, 'ms')
    
    print("\nMétricas de rendimiento:")
    print(perf_logger.get_metrics())
