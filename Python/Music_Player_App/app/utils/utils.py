"""
Utilidades Generales
Funciones auxiliares y utilidades usadas en toda la aplicación
"""

import re
from typing import List, Dict, Any, Optional
from datetime import datetime, timedelta
import json

from app.core.logger import setup_logger

logger = setup_logger(__name__)


class TimeUtils:
    """Utilidades de tiempo y duración"""
    
    @staticmethod
    def format_duration(seconds: int) -> str:
        """
        Formatear duración en segundos a una cadena legible
        
        Args:
            seconds: Duración en segundos
        
        Returns:
            Cadena formateada (ej. "3:45", "1:23:45")
        """
        if seconds < 0:
            return "0:00"
        
        hours = seconds // 3600
        minutes = (seconds % 3600) // 60
        secs = seconds % 60
        
        if hours > 0:
            return f"{hours}:{minutes:02d}:{secs:02d}"
        else:
            return f"{minutes}:{secs:02d}"
    
    @staticmethod
    def parse_duration(duration_str: str) -> int:
        """
        Convertir una duración en texto a segundos
        
        Args:
            duration_str: Cadena de duración (ej. "3:45", "1:23:45")
        
        Returns:
            Duración en segundos
        """
        try:
            parts = duration_str.split(':')
            parts = [int(p) for p in parts]
            
            if len(parts) == 2:  # MM:SS
                return parts[0] * 60 + parts[1]
            elif len(parts) == 3:  # HH:MM:SS
                return parts[0] * 3600 + parts[1] * 60 + parts[2]
            else:
                return 0
        except:
            return 0
    
    @staticmethod
    def format_date(dt: datetime, format_str: str = '%Y-%m-%d') -> str:
        """
        Formatear fecha y hora a texto
        
        Args:
            dt: Objeto datetime
            format_str: Cadena de formato
        
        Returns:
            Fecha formateada
        """
        if not dt:
            return ''
        return dt.strftime(format_str)
    
    @staticmethod
    def time_ago(dt: datetime) -> str:
        """
        Obtener tiempo transcurrido en formato legible
        
        Args:
            dt: Objeto datetime
        
        Returns:
            Texto de tiempo transcurrido (ej. "hace 2 horas")
        """
        if not dt:
            return 'Desconocido'
        
        now = datetime.utcnow()
        diff = now - dt
        
        seconds = diff.total_seconds()
        
        if seconds < 60:
            return 'Justo ahora'
        elif seconds < 3600:
            minutes = int(seconds / 60)
            return f'hace {minutes} minuto{"s" if minutes != 1 else ""}'
        elif seconds < 86400:
            hours = int(seconds / 3600)
            return f'hace {hours} hora{"s" if hours != 1 else ""}'
        elif seconds < 604800:
            days = int(seconds / 86400)
            return f'hace {days} día{"s" if days != 1 else ""}'
        elif seconds < 2592000:
            weeks = int(seconds / 604800)
            return f'hace {weeks} semana{"s" if weeks != 1 else ""}'
        elif seconds < 31536000:
            months = int(seconds / 2592000)
            return f'hace {months} mes{"es" if months != 1 else ""}'
        else:
            years = int(seconds / 31536000)
            return f'hace {years} año{"s" if years != 1 else ""}'


class NumberUtils:
    """Utilidades de formato numérico"""
    
    @staticmethod
    def format_number(num: int) -> str:
        """
        Formatear número con sufijos K, M, B
        
        Args:
            num: Número a formatear
        
        Returns:
            Cadena formateada (ej. "1.2K", "3.4M")
        """
        if num >= 1_000_000_000:
            return f"{num / 1_000_000_000:.1f}B"
        elif num >= 1_000_000:
            return f"{num / 1_000_000:.1f}M"
        elif num >= 1_000:
            return f"{num / 1_000:.1f}K"
        else:
            return str(num)
    
    @staticmethod
    def format_bytes(bytes_size: int) -> str:
        """
        Formatear bytes a tamaño legible
        
        Args:
            bytes_size: Tamaño en bytes
        
        Returns:
            Cadena formateada (ej. "1.5 MB")
        """
        if bytes_size >= 1_073_741_824:  # GB
            return f"{bytes_size / 1_073_741_824:.2f} GB"
        elif bytes_size >= 1_048_576:  # MB
            return f"{bytes_size / 1_048_576:.2f} MB"
        elif bytes_size >= 1_024:  # KB
            return f"{bytes_size / 1_024:.2f} KB"
        else:
            return f"{bytes_size} B"
    
    @staticmethod
    def clamp(value: float, min_val: float, max_val: float) -> float:
        """
        Limitar un valor entre mínimo y máximo
        
        Args:
            value: Valor a limitar
            min_val: Valor mínimo
            max_val: Valor máximo
        
        Returns:
            Valor limitado
        """
        return max(min_val, min(value, max_val))


class StringUtils:
    """Utilidades de manipulación de cadenas"""
    
    @staticmethod
    def truncate(text: str, max_length: int, suffix: str = '...') -> str:
        """
        Truncar texto a una longitud máxima
        
        Args:
            text: Texto a truncar
            max_length: Longitud máxima
            suffix: Sufijo a agregar si se trunca
        
        Returns:
            Texto truncado
        """
        if not text or len(text) <= max_length:
            return text
        
        return text[:max_length - len(suffix)] + suffix
    
    @staticmethod
    def slugify(text: str) -> str:
        """
        Convertir texto en un slug seguro para URL
        
        Args:
            text: Texto a convertir
        
        Returns:
            Texto convertido
        """
        # Convertir a minúsculas
        text = text.lower()
        
        # Reemplazar espacios por guiones
        text = re.sub(r'\s+', '-', text)
        
        # Eliminar caracteres no alfanuméricos
        text = re.sub(r'[^a-z0-9\-]', '', text)
        
        # Eliminar guiones múltiples
        text = re.sub(r'-+', '-', text)
        
        # Eliminar guiones iniciales y finales
        text = text.strip('-')
        
        return text
    
    @staticmethod
    def extract_hashtags(text: str) -> List[str]:
        """
        Extraer hashtags de un texto
        
        Args:
            text: Texto a analizar
        
        Returns:
            Lista de hashtags
        """
        return re.findall(r'#(\w+)', text)
    
    @staticmethod
    def highlight_search_terms(text: str, search_terms: List[str], 
                              tag: str = 'mark') -> str:
        """
        Resaltar términos de búsqueda en un texto
        
        Args:
            text: Texto base
            search_terms: Lista de términos a resaltar
            tag: Etiqueta HTML para resaltar
        
        Returns:
            Texto con términos resaltados
        """
        for term in search_terms:
            pattern = re.compile(re.escape(term), re.IGNORECASE)
            text = pattern.sub(f'<{tag}>\\g<0></{tag}>', text)
        
        return text
    
    @staticmethod
    def clean_whitespace(text: str) -> str:
        """
        Limpiar espacios en blanco excesivos
        
        Args:
            text: Texto a limpiar
        
        Returns:
            Texto limpio
        """
        # Reemplazar múltiples espacios por uno solo
        text = re.sub(r'\s+', ' ', text)
        
        # Eliminar espacios al inicio y final
        text = text.strip()
        
        return text


class ListUtils:
    """Utilidades de manipulación de listas"""
    
    @staticmethod
    def chunk_list(lst: List[Any], chunk_size: int) -> List[List[Any]]:
        """
        Dividir una lista en bloques
        
        Args:
            lst: Lista a dividir
            chunk_size: Tamaño de cada bloque
        
        Returns:
            Lista de bloques
        """
        return [lst[i:i + chunk_size] for i in range(0, len(lst), chunk_size)]
    
    @staticmethod
    def deduplicate(lst: List[Any], key: Optional[str] = None) -> List[Any]:
        """
        Eliminar duplicados de una lista
        
        Args:
            lst: Lista a procesar
            key: Clave opcional para diccionarios
        
        Returns:
            Lista sin duplicados
        """
        if not lst:
            return []
        
        if key:
            seen = set()
            result = []
            for item in lst:
                if isinstance(item, dict):
                    val = item.get(key)
                    if val not in seen:
                        seen.add(val)
                        result.append(item)
            return result
        else:
            # Para elementos que no son diccionarios
            seen = set()
            result = []
            for item in lst:
                if item not in seen:
                    seen.add(item)
                    result.append(item)
            return result
    
    @staticmethod
    def flatten(nested_list: List[List[Any]]) -> List[Any]:
        """
        Aplanar una lista anidada
        
        Args:
            nested_list: Lista anidada
        
        Returns:
            Lista plana
        """
        return [item for sublist in nested_list for item in sublist]
    
    @staticmethod
    def batch_process(items: List[Any], batch_size: int, 
                     process_func: callable) -> List[Any]:
        """
        Procesar una lista por lotes
        
        Args:
            items: Elementos a procesar
            batch_size: Tamaño de cada lote
            process_func: Función de procesamiento
        
        Returns:
            Lista de resultados
        """
        results = []
        chunks = ListUtils.chunk_list(items, batch_size)
        
        for chunk in chunks:
            try:
                result = process_func(chunk)
                results.extend(result if isinstance(result, list) else [result])
            except Exception as e:
                logger.error(f"Error al procesar el lote: {e}")
        
        return results


class DictUtils:
    """Utilidades de manipulación de diccionarios"""
    
    @staticmethod
    def merge_dicts(*dicts: Dict) -> Dict:
        """
        Unir múltiples diccionarios
        
        Args:
            *dicts: Diccionarios a unir
        
        Returns:
            Diccionario combinado
        """
        result = {}
        for d in dicts:
            if d:
                result.update(d)
        return result
    
    @staticmethod
    def filter_dict(data: Dict, keys: List[str]) -> Dict:
        """
        Filtrar un diccionario por claves específicas
        
        Args:
            data: Diccionario original
            keys: Claves a conservar
        
        Returns:
            Diccionario filtrado
        """
        return {k: v for k, v in data.items() if k in keys}
    
    @staticmethod
    def flatten_dict(data: Dict, parent_key: str = '', sep: str = '.') -> Dict:
        """
        Aplanar un diccionario anidado
        
        Args:
            data: Diccionario a aplanar
            parent_key: Prefijo de clave padre
            sep: Separador de claves
        
        Returns:
            Diccionario plano
        """
        items = []
        for k, v in data.items():
            new_key = f"{parent_key}{sep}{k}" if parent_key else k
            if isinstance(v, dict):
                items.extend(DictUtils.flatten_dict(v, new_key, sep).items())
            else:
                items.append((new_key, v))
        return dict(items)
    
    @staticmethod
    def safe_get(data: Dict, path: str, default: Any = None) -> Any:
        """
        Obtener de forma segura un valor anidado
        
        Args:
            data: Diccionario a consultar
            path: Ruta separada por puntos (ej. "user.profile.name")
            default: Valor por defecto
        
        Returns:
            Valor encontrado o valor por defecto
        """
        keys = path.split('.')
        value = data
        
        for key in keys:
            if isinstance(value, dict) and key in value:
                value = value[key]
            else:
                return default
        
        return value


class URLUtils:
    """Utilidades de manipulación de URL"""
    
    @staticmethod
    def extract_video_id(url: str) -> Optional[str]:
        """
        Extraer ID de video de YouTube desde una URL
        
        Args:
            url: URL de YouTube
        
        Returns:
            ID del video o None
        """
        patterns = [
            r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]{11})',
            r'youtube\.com\/embed\/([a-zA-Z0-9_-]{11})',
            r'youtube\.com\/v\/([a-zA-Z0-9_-]{11})'
        ]
        
        for pattern in patterns:
            match = re.search(pattern, url)
            if match:
                return match.group(1)
        
        return None
    
    @staticmethod
    def build_query_string(params: Dict[str, Any]) -> str:
        """
        Construir una cadena de consulta URL
        
        Args:
            params: Diccionario de parámetros
        
        Returns:
            Cadena de consulta
        """
        from urllib.parse import urlencode
        return urlencode({k: v for k, v in params.items() if v is not None})


# Exportar funciones de uso común
format_duration = TimeUtils.format_duration
format_number = NumberUtils.format_number
format_bytes = NumberUtils.format_bytes
truncate = StringUtils.truncate
slugify = StringUtils.slugify
time_ago = TimeUtils.time_ago


# Ejemplo de uso
if __name__ == '__main__':
    print("Probando TimeUtils...")
    print(f"Formato de duración: {format_duration(3665)}")
    print(f"Tiempo transcurrido: {time_ago(datetime.utcnow() - timedelta(hours=2))}")
    
    print("\nProbando NumberUtils...")
    print(f"Formato de número: {format_number(1234567)}")
    print(f"Formato de bytes: {format_bytes(1234567)}")
    
    print("\nProbando StringUtils...")
    print(f"Slugify: {slugify('Hello World! Test 123')}")
    print(f"Truncar: {truncate('This is a long text', 10)}")
    
    print("\nProbando ListUtils...")
    print(f"Dividir lista: {ListUtils.chunk_list([1,2,3,4,5,6,7], 3)}")
    print(f"Eliminar duplicados: {ListUtils.deduplicate([1,2,2,3,3,3])}")
