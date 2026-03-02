"""
Servicio de Monitoreo de Rendimiento
Seguimiento y análisis de métricas de rendimiento de la aplicación
"""

import time
from typing import Dict, List, Optional, Any
from collections import defaultdict
from datetime import datetime
import threading

from app.core.logger import setup_logger

logger = setup_logger(__name__)


class PerformanceMetric:
    """Métrica individual de rendimiento"""
    
    def __init__(self, name: str):
        self.name = name
        self.count = 0
        self.total_time = 0.0
        self.min_time = float('inf')
        self.max_time = 0.0
        self.errors = 0
        self.last_execution = None
    
    def record(self, duration: float, error: bool = False) -> None:
        """Registrar la ejecución de una métrica"""
        self.count += 1
        self.total_time += duration
        self.min_time = min(self.min_time, duration)
        self.max_time = max(self.max_time, duration)
        self.last_execution = datetime.utcnow()
        
        if error:
            self.errors += 1
    
    def get_average(self) -> float:
        """Obtener el tiempo promedio de ejecución"""
        return self.total_time / self.count if self.count > 0 else 0.0
    
    def get_stats(self) -> Dict[str, Any]:
        """Obtener estadísticas de la métrica"""
        return {
            'name': self.name,
            'count': self.count,
            'total_time': round(self.total_time, 3),
            'average_time': round(self.get_average(), 3),
            'min_time': round(self.min_time, 3) if self.min_time != float('inf') else 0,
            'max_time': round(self.max_time, 3),
            'errors': self.errors,
            'error_rate': round(self.errors / self.count * 100, 2) if self.count > 0 else 0,
            'last_execution': self.last_execution.isoformat() if self.last_execution else None
        }


class PerformanceMonitor:
    """Monitor de rendimiento de la aplicación"""
    
    def __init__(self):
        self.metrics: Dict[str, PerformanceMetric] = defaultdict(lambda: PerformanceMetric('unknown'))
        self.lock = threading.RLock()
        self.start_time = time.time()
    
    def start_operation(self, operation_name: str) -> float:
        """
        Iniciar la medición de una operación
        
        Args:
            operation_name: Nombre de la operación
        
        Returns:
            Marca de tiempo de inicio
        """
        return time.time()
    
    def end_operation(self, operation_name: str, start_time: float, 
                     error: bool = False) -> float:
        """
        Finalizar la medición de una operación y registrar la métrica
        
        Args:
            operation_name: Nombre de la operación
            start_time: Marca de tiempo de inicio obtenida con start_operation
            error: Indica si la operación terminó con error
        
        Returns:
            Duración en segundos
        """
        duration = time.time() - start_time
        
        with self.lock:
            self.metrics[operation_name].record(duration, error)
        
        return duration
    
    def get_metric(self, operation_name: str) -> Optional[Dict[str, Any]]:
        """
        Obtener estadísticas de una métrica específica
        
        Args:
            operation_name: Nombre de la operación
        
        Returns:
            Estadísticas de la métrica o None
        """
        with self.lock:
            if operation_name in self.metrics:
                return self.metrics[operation_name].get_stats()
            return None
    
    def get_all_metrics(self) -> Dict[str, Dict[str, Any]]:
        """
        Obtener estadísticas de todas las métricas
        
        Returns:
            Diccionario con todas las métricas
        """
        with self.lock:
            return {
                name: metric.get_stats()
                for name, metric in self.metrics.items()
            }
    
    def get_slowest_operations(self, limit: int = 10) -> List[Dict[str, Any]]:
        """
        Obtener las operaciones más lentas según el tiempo promedio
        
        Args:
            limit: Número de operaciones a devolver
        
        Returns:
            Lista de operaciones más lentas
        """
        with self.lock:
            sorted_metrics = sorted(
                self.metrics.values(),
                key=lambda m: m.get_average(),
                reverse=True
            )
            return [m.get_stats() for m in sorted_metrics[:limit]]
    
    def get_most_frequent_operations(self, limit: int = 10) -> List[Dict[str, Any]]:
        """
        Obtener las operaciones más ejecutadas
        
        Args:
            limit: Número de operaciones a devolver
        
        Returns:
            Lista de operaciones más frecuentes
        """
        with self.lock:
            sorted_metrics = sorted(
                self.metrics.values(),
                key=lambda m: m.count,
                reverse=True
            )
            return [m.get_stats() for m in sorted_metrics[:limit]]
    
    def get_error_prone_operations(self, limit: int = 10) -> List[Dict[str, Any]]:
        """
        Obtener las operaciones con mayor tasa de errores
        
        Args:
            limit: Número de operaciones a devolver
        
        Returns:
            Lista de operaciones con más errores
        """
        with self.lock:
            sorted_metrics = sorted(
                [m for m in self.metrics.values() if m.errors > 0],
                key=lambda m: m.errors / m.count if m.count > 0 else 0,
                reverse=True
            )
            return [m.get_stats() for m in sorted_metrics[:limit]]
    
    def get_summary(self) -> Dict[str, Any]:
        """
        Obtener un resumen general del rendimiento
        
        Returns:
            Estadísticas resumidas
        """
        with self.lock:
            total_operations = sum(m.count for m in self.metrics.values())
            total_errors = sum(m.errors for m in self.metrics.values())
            uptime = time.time() - self.start_time
            
            return {
                'uptime_seconds': round(uptime, 2),
                'total_operations': total_operations,
                'total_errors': total_errors,
                'error_rate': round(total_errors / total_operations * 100, 2) if total_operations > 0 else 0,
                'unique_operations': len(self.metrics),
                'slowest_operation': self.get_slowest_operations(1)[0] if self.metrics else None,
                'most_frequent_operation': self.get_most_frequent_operations(1)[0] if self.metrics else None
            }
    
    def reset(self) -> None:
        """Reiniciar todas las métricas"""
        with self.lock:
            self.metrics.clear()
            self.start_time = time.time()
    
    def reset_metric(self, operation_name: str) -> bool:
        """
        Reiniciar una métrica específica
        
        Args:
            operation_name: Nombre de la operación
        
        Returns:
            True si la métrica fue reiniciada, False si no existe
        """
        with self.lock:
            if operation_name in self.metrics:
                del self.metrics[operation_name]
                return True
            return False


class PerformanceDecorator:
    """Decorador para monitoreo automático de rendimiento"""
    
    def __init__(self, monitor: PerformanceMonitor):
        self.monitor = monitor
    
    def track(self, operation_name: Optional[str] = None):
        """
        Decorador para rastrear el rendimiento de una función
        
        Args:
            operation_name: Nombre personalizado opcional de la operación
        
        Uso:
            @perf_decorator.track('mi_operacion')
            def mi_funcion():
                pass
        """
        def decorator(func):
            def wrapper(*args, **kwargs):
                op_name = operation_name or f"{func.__module__}.{func.__name__}"
                start = self.monitor.start_operation(op_name)
                
                try:
                    result = func(*args, **kwargs)
                    self.monitor.end_operation(op_name, start, error=False)
                    return result
                except Exception as e:
                    self.monitor.end_operation(op_name, start, error=True)
                    raise
            
            return wrapper
        return decorator


class RequestMetrics:
    """Seguimiento de métricas de solicitudes HTTP"""
    
    def __init__(self):
        self.requests_by_endpoint: Dict[str, int] = defaultdict(int)
        self.requests_by_status: Dict[int, int] = defaultdict(int)
        self.total_requests = 0
        self.lock = threading.RLock()
    
    def record_request(self, endpoint: str, status_code: int) -> None:
        """
        Registrar una solicitud HTTP
        
        Args:
            endpoint: Endpoint solicitado
            status_code: Código de estado HTTP
        """
        with self.lock:
            self.requests_by_endpoint[endpoint] += 1
            self.requests_by_status[status_code] += 1
            self.total_requests += 1
    
    def get_stats(self) -> Dict[str, Any]:
        """Obtener estadísticas de las solicitudes"""
        with self.lock:
            return {
                'total_requests': self.total_requests,
                'requests_by_endpoint': dict(self.requests_by_endpoint),
                'requests_by_status': dict(self.requests_by_status),
                'success_rate': round(
                    sum(count for status, count in self.requests_by_status.items() if 200 <= status < 300) 
                    / self.total_requests * 100, 2
                ) if self.total_requests > 0 else 0
            }
    
    def get_top_endpoints(self, limit: int = 10) -> List[tuple]:
        """Obtener los endpoints más utilizados"""
        with self.lock:
            sorted_endpoints = sorted(
                self.requests_by_endpoint.items(),
                key=lambda x: x[1],
                reverse=True
            )
            return sorted_endpoints[:limit]


# Instancias singleton
_performance_monitor = PerformanceMonitor()
_request_metrics = RequestMetrics()
_perf_decorator = PerformanceDecorator(_performance_monitor)


def get_performance_monitor() -> PerformanceMonitor:
    """Obtener la instancia singleton del monitor de rendimiento"""
    return _performance_monitor


def get_request_metrics() -> RequestMetrics:
    """Obtener la instancia singleton de métricas de solicitudes"""
    return _request_metrics


def get_perf_decorator() -> PerformanceDecorator:
    """Obtener la instancia del decorador de rendimiento"""
    return _perf_decorator


# Context manager para seguimiento sencillo de rendimiento
class track_performance:
    """Administrador de contexto para rastrear rendimiento"""
    
    def __init__(self, operation_name: str, monitor: Optional[PerformanceMonitor] = None):
        self.operation_name = operation_name
        self.monitor = monitor or _performance_monitor
        self.start_time = None
    
    def __enter__(self):
        self.start_time = self.monitor.start_operation(self.operation_name)
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        error = exc_type is not None
        self.monitor.end_operation(self.operation_name, self.start_time, error)
        return False  # No suprimir excepciones


# Ejemplo de uso
if __name__ == '__main__':
    monitor = get_performance_monitor()
    
    # Ejemplo 1: Seguimiento manual
    start = monitor.start_operation('test_operation')
    time.sleep(0.1)
    monitor.end_operation('test_operation', start)
    
    # Ejemplo 2: Administrador de contexto
    with track_performance('context_test'):
        time.sleep(0.1)
    
    # Ejemplo 3: Decorador
    perf_decorator = get_perf_decorator()
    
    @perf_decorator.track('decorated_function')
    def test_function():
        time.sleep(0.1)
        return "Done"
    
    test_function()
    
    # Obtener estadísticas
    print("Todas las métricas:", monitor.get_all_metrics())
    print("\nResumen:", monitor.get_summary())
    print("\nOperaciones más lentas:", monitor.get_slowest_operations(5))
