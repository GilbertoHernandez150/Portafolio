"""
Validadores y Sanitizadores de Entrada
Utilidades de seguridad y validación de datos
"""

import re
from typing import Any, Optional, Dict
from urllib.parse import urlparse, parse_qs
import html

from app.core.logger import setup_logger

logger = setup_logger(__name__)


class Validator:
    """Utilidades de validación de entrada"""
    
    # Patrones regex
    VIDEO_ID_PATTERN = r'^[a-zA-Z0-9_-]{11}$'
    URL_PATTERN = r'^https?://[^\s<>"{}|\\^`\[\]]+$'
    SAFE_STRING_PATTERN = r'^[a-zA-Z0-9\s\-_.,!?\'\"]+$'
    
    @staticmethod
    def validate_video_id(video_id: str) -> bool:
        """
        Validar el formato del ID de video de YouTube
        
        Args:
            video_id: ID del video a validar
        
        Returns:
            True si es válido, False en caso contrario
        """
        if not video_id or not isinstance(video_id, str):
            return False
        
        return bool(re.match(Validator.VIDEO_ID_PATTERN, video_id))
    
    @staticmethod
    def validate_url(url: str) -> bool:
        """
        Validar el formato de una URL
        
        Args:
            url: URL a validar
        
        Returns:
            True si es válida, False en caso contrario
        """
        if not url or not isinstance(url, str):
            return False
        
        try:
            result = urlparse(url)
            return all([result.scheme, result.netloc]) and result.scheme in ['http', 'https']
        except:
            return False
    
    @staticmethod
    def validate_search_query(query: str, max_length: int = 200) -> bool:
        """
        Validar una consulta de búsqueda
        
        Args:
            query: Texto de búsqueda
            max_length: Longitud máxima permitida
        
        Returns:
            True si es válida, False en caso contrario
        """
        if not query or not isinstance(query, str):
            return False
        
        # Verificar longitud
        if len(query) > max_length:
            return False
        
        # Verificar caracteres peligrosos
        dangerous_chars = ['<', '>', '{', '}', '|', '\\', '^', '`', '[', ']']
        if any(char in query for char in dangerous_chars):
            return False
        
        return True
    
    @staticmethod
    def validate_integer(value: Any, min_val: Optional[int] = None, 
                        max_val: Optional[int] = None) -> bool:
        """
        Validar un valor entero
        
        Args:
            value: Valor a validar
            min_val: Valor mínimo permitido
            max_val: Valor máximo permitido
        
        Returns:
            True si es válido, False en caso contrario
        """
        try:
            int_val = int(value)
            
            if min_val is not None and int_val < min_val:
                return False
            
            if max_val is not None and int_val > max_val:
                return False
            
            return True
        except (ValueError, TypeError):
            return False
    
    @staticmethod
    def validate_string_length(text: str, min_length: int = 0, 
                              max_length: int = 1000) -> bool:
        """
        Validar la longitud de una cadena
        
        Args:
            text: Cadena a validar
            min_length: Longitud mínima
            max_length: Longitud máxima
        
        Returns:
            True si es válida, False en caso contrario
        """
        if not isinstance(text, str):
            return False
        
        length = len(text)
        return min_length <= length <= max_length
    
    @staticmethod
    def validate_quality(quality: str) -> bool:
        """
        Validar el parámetro de calidad
        
        Args:
            quality: Cadena de calidad
        
        Returns:
            True si es válida, False en caso contrario
        """
        valid_qualities = ['high', 'medium', 'low']
        return quality in valid_qualities


class Sanitizer:
    """Utilidades de sanitización de entrada"""
    
    @staticmethod
    def sanitize_html(text: str) -> str:
        """
        Eliminar o escapar HTML de un texto
        
        Args:
            text: Texto a sanitizar
        
        Returns:
            Texto sanitizado
        """
        if not text:
            return ''
        
        # Escapar caracteres especiales HTML
        return html.escape(str(text))
    
    @staticmethod
    def sanitize_search_query(query: str) -> str:
        """
        Sanitizar una consulta de búsqueda
        
        Args:
            query: Texto de búsqueda
        
        Returns:
            Consulta sanitizada
        """
        if not query:
            return ''
        
        # Convertir a string y limpiar espacios
        query = str(query).strip()
        
        # Eliminar caracteres peligrosos
        query = re.sub(r'[<>{}|\\^`\[\]]', '', query)
        
        # Limitar longitud
        query = query[:200]
        
        return query
    
    @staticmethod
    def sanitize_filename(filename: str) -> str:
        """
        Sanitizar nombre de archivo para operaciones seguras
        
        Args:
            filename: Nombre de archivo a sanitizar
        
        Returns:
            Nombre de archivo seguro
        """
        if not filename:
            return 'untitled'
        
        # Eliminar separadores de ruta
        filename = filename.replace('/', '_').replace('\\', '_')
        
        # Eliminar caracteres peligrosos
        filename = re.sub(r'[^\w\s\-.]', '', filename)
        
        # Limitar longitud
        filename = filename[:255]
        
        return filename or 'untitled'
    
    @staticmethod
    def sanitize_sql_like(text: str) -> str:
        """
        Escapar comodines de SQL LIKE
        
        Args:
            text: Texto a escapar
        
        Returns:
            Texto escapado
        """
        if not text:
            return ''
        
        # Escapar caracteres especiales de LIKE
        text = text.replace('%', '\\%').replace('_', '\\_')
        
        return text
    
    @staticmethod
    def sanitize_dict(data: Dict[str, Any], allowed_keys: list) -> Dict[str, Any]:
        """
        Filtrar un diccionario solo con claves permitidas
        
        Args:
            data: Diccionario a filtrar
            allowed_keys: Lista de claves permitidas
        
        Returns:
            Diccionario filtrado
        """
        if not isinstance(data, dict):
            return {}
        
        return {k: v for k, v in data.items() if k in allowed_keys}


class RateLimiter:
    """Utilidad simple de limitación de solicitudes"""
    
    def __init__(self):
        self.requests = {}  # {identificador: [timestamps]}
        self.max_requests = 100
        self.time_window = 60  # segundos
    
    def is_allowed(self, identifier: str) -> bool:
        """
        Verificar si una solicitud está permitida
        
        Args:
            identifier: Identificador único (IP, ID de usuario, etc.)
        
        Returns:
            True si está permitida, False si se excede el límite
        """
        import time
        current_time = time.time()
        
        if identifier not in self.requests:
            self.requests[identifier] = []
        
        # Eliminar marcas de tiempo antiguas
        self.requests[identifier] = [
            ts for ts in self.requests[identifier]
            if current_time - ts < self.time_window
        ]
        
        # Verificar si supera el límite
        if len(self.requests[identifier]) >= self.max_requests:
            logger.warning(f"Límite de solicitudes excedido para {identifier}")
            return False
        
        # Agregar marca de tiempo actual
        self.requests[identifier].append(current_time)
        return True
    
    def reset(self, identifier: str) -> None:
        """Reiniciar el límite de solicitudes para un identificador"""
        if identifier in self.requests:
            del self.requests[identifier]


class SecurityUtils:
    """Utilidades relacionadas con seguridad"""
    
    @staticmethod
    def is_safe_redirect(url: str, allowed_domains: list = None) -> bool:
        """
        Verificar si una URL de redirección es segura
        
        Args:
            url: URL a verificar
            allowed_domains: Lista de dominios permitidos
        
        Returns:
            True si es segura, False en caso contrario
        """
        if not url:
            return False
        
        try:
            parsed = urlparse(url)
            
            # No permitir redirecciones externas por defecto
            if allowed_domains is None:
                return not parsed.netloc or parsed.netloc in ['localhost', '127.0.0.1']
            
            # Verificar contra dominios permitidos
            return parsed.netloc in allowed_domains
        except:
            return False
    
    @staticmethod
    def generate_cache_key(*args, **kwargs) -> str:
        """
        Generar una clave de caché segura a partir de argumentos
        
        Args:
            *args: Argumentos posicionales
            **kwargs: Argumentos nombrados
        
        Returns:
            Cadena de clave de caché
        """
        import hashlib
        
        # Combinar todos los argumentos
        key_parts = [str(arg) for arg in args]
        key_parts.extend(f"{k}={v}" for k, v in sorted(kwargs.items()))
        
        # Crear hash
        key_string = ':'.join(key_parts)
        return hashlib.md5(key_string.encode()).hexdigest()
    
    @staticmethod
    def sanitize_error_message(error: Exception) -> str:
        """
        Sanitizar mensaje de error para el cliente
        
        Args:
            error: Objeto de excepción
        
        Returns:
            Mensaje de error seguro
        """
        # No exponer detalles internos
        error_type = type(error).__name__
        
        safe_messages = {
            'ValueError': 'Entrada inválida proporcionada',
            'TypeError': 'Tipo de dato inválido',
            'KeyError': 'Falta un campo requerido',
            'FileNotFoundError': 'Recurso no encontrado',
            'PermissionError': 'Acceso denegado',
            'TimeoutError': 'Tiempo de espera agotado',
        }
        
        return safe_messages.get(error_type, 'Ocurrió un error')


# Instancia singleton
_rate_limiter = RateLimiter()


def get_rate_limiter() -> RateLimiter:
    """Obtener la instancia singleton del limitador de solicitudes"""
    return _rate_limiter


# Ejemplo de uso
if __name__ == '__main__':
    # Probar validadores
    print("Probando validadores...")
    print(f"ID de video válido: {Validator.validate_video_id('dQw4w9WgXcQ')}")
    print(f"ID de video inválido: {Validator.validate_video_id('invalid!')}")
    print(f"URL válida: {Validator.validate_url('https://youtube.com')}")
    print(f"URL inválida: {Validator.validate_url('not-a-url')}")
    
    # Probar sanitizadores
    print("\nProbando sanitizadores...")
    print(f"HTML sanitizado: {Sanitizer.sanitize_html('<script>alert(1)</script>')}")
    print(f"Consulta sanitizada: {Sanitizer.sanitize_search_query('test<script>')}")
    print(f"Nombre de archivo sanitizado: {Sanitizer.sanitize_filename('../../etc/passwd')}")
    
    # Probar limitador de solicitudes
    print("\nProbando limitador de solicitudes...")
    limiter = get_rate_limiter()
    for i in range(5):
        print(f"Solicitud {i+1}: {limiter.is_allowed('test-user')}")
