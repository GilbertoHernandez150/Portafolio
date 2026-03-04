"""
Sistema Inteligente de Caché Multinivel
Caché en memoria + disco con TTL, predicción y estadísticas
"""

import os
import json
import pickle
import hashlib
import time
from pathlib import Path
from typing import Any, Optional, Dict, List
from datetime import datetime, timedelta
from collections import OrderedDict, defaultdict
import threading

from app.core.logger import setup_logger

logger = setup_logger(__name__)


class CacheEntry:
    """Representa una entrada individual de caché con metadatos"""
    
    def __init__(self, key: str, value: Any, ttl: int = 3600):
        self.key = key
        self.value = value
        self.created_at = time.time()
        self.ttl = ttl
        self.hits = 0
        self.last_accessed = time.time()
        self.size = self._calculate_size(value)
    
    def _calculate_size(self, value: Any) -> int:
        """Estimar el tamaño del valor en bytes"""
        try:
            if isinstance(value, (str, bytes)):
                return len(value)
            elif isinstance(value, (dict, list)):
                return len(json.dumps(value))
            else:
                return len(pickle.dumps(value))
        except:
            return 0
    
    def is_expired(self) -> bool:
        """Verificar si la entrada de caché ha expirado"""
        if self.ttl == 0:  # 0 significa que nunca expira
            return False
        return time.time() - self.created_at > self.ttl
    
    def touch(self) -> None:
        """Actualizar estadísticas de acceso"""
        self.hits += 1
        self.last_accessed = time.time()


class MemoryCache:
    """Caché LRU en memoria con soporte TTL"""
    
    def __init__(self, max_size: int = 1000):
        self.max_size = max_size
        self.cache: OrderedDict[str, CacheEntry] = OrderedDict()
        self.lock = threading.RLock()
    
    def get(self, key: str) -> Optional[Any]:
        """Obtener valor desde el caché"""
        with self.lock:
            if key not in self.cache:
                return None
            
            entry = self.cache[key]
            
            if entry.is_expired():
                del self.cache[key]
                return None
            
            entry.touch()
            self.cache.move_to_end(key)  # LRU: mover al final
            return entry.value
    
    def set(self, key: str, value: Any, ttl: int = 3600) -> None:
        """Guardar valor en el caché"""
        with self.lock:
            if key in self.cache:
                del self.cache[key]
            
            # Eliminar el más antiguo si se alcanza el límite
            if len(self.cache) >= self.max_size:
                self.cache.popitem(last=False)  # Eliminar el más antiguo
            
            entry = CacheEntry(key, value, ttl)
            self.cache[key] = entry
    
    def delete(self, key: str) -> bool:
        """Eliminar una clave del caché"""
        with self.lock:
            if key in self.cache:
                del self.cache[key]
                return True
            return False
    
    def clear(self) -> None:
        """Limpiar todas las entradas del caché"""
        with self.lock:
            self.cache.clear()
    
    def cleanup_expired(self) -> int:
        """Eliminar todas las entradas expiradas"""
        with self.lock:
            expired_keys = [
                key for key, entry in self.cache.items()
                if entry.is_expired()
            ]
            for key in expired_keys:
                del self.cache[key]
            return len(expired_keys)
    
    def get_stats(self) -> Dict[str, Any]:
        """Obtener estadísticas del caché"""
        with self.lock:
            total_hits = sum(entry.hits for entry in self.cache.values())
            total_size = sum(entry.size for entry in self.cache.values())
            
            return {
                'entries': len(self.cache),
                'max_size': self.max_size,
                'total_hits': total_hits,
                'total_size_bytes': total_size,
                'total_size_mb': total_size / (1024 * 1024)
            }


class DiskCache:
    """Caché persistente basado en disco"""
    
    def __init__(self, cache_dir: str = 'cache'):
        self.cache_dir = Path(cache_dir)
        self.cache_dir.mkdir(exist_ok=True, parents=True)
        self.metadata_file = self.cache_dir / 'metadata.json'
        self.metadata = self._load_metadata()
        self.lock = threading.RLock()
    
    def _load_metadata(self) -> Dict:
        """Cargar metadatos del caché desde disco"""
        if self.metadata_file.exists():
            try:
                with open(self.metadata_file, 'r') as f:
                    return json.load(f)
            except:
                return {}
        return {}
    
    def _save_metadata(self) -> None:
        """Guardar metadatos del caché en disco"""
        with open(self.metadata_file, 'w') as f:
            json.dump(self.metadata, f, indent=2)
    
    def _get_cache_path(self, key: str) -> Path:
        """Obtener la ruta del archivo para la clave de caché"""
        key_hash = hashlib.md5(key.encode()).hexdigest()
        return self.cache_dir / f"{key_hash}.cache"
    
    def get(self, key: str) -> Optional[Any]:
        """Obtener valor desde el caché en disco"""
        with self.lock:
            cache_path = self._get_cache_path(key)
            
            if not cache_path.exists():
                return None
            
            # Verificar expiración desde los metadatos
            if key in self.metadata:
                meta = self.metadata[key]
                if meta.get('ttl', 0) > 0:
                    created_at = meta.get('created_at', 0)
                    if time.time() - created_at > meta['ttl']:
                        self.delete(key)
                        return None
            
            try:
                with open(cache_path, 'rb') as f:
                    value = pickle.load(f)
                
                # Actualizar tiempo de acceso
                if key in self.metadata:
                    self.metadata[key]['last_accessed'] = time.time()
                    self.metadata[key]['hits'] = self.metadata[key].get('hits', 0) + 1
                    self._save_metadata()
                
                return value
            except Exception as e:
                logger.error(f"Error al leer el archivo de caché {cache_path}: {e}")
                self.delete(key)
                return None
    
    def set(self, key: str, value: Any, ttl: int = 3600) -> None:
        """Guardar valor en el caché de disco"""
        with self.lock:
            cache_path = self._get_cache_path(key)
            
            try:
                with open(cache_path, 'wb') as f:
                    pickle.dump(value, f)
                
                self.metadata[key] = {
                    'created_at': time.time(),
                    'last_accessed': time.time(),
                    'ttl': ttl,
                    'hits': 0,
                    'size': os.path.getsize(cache_path)
                }
                self._save_metadata()
            except Exception as e:
                logger.error(f"Error al escribir el archivo de caché {cache_path}: {e}")
    
    def delete(self, key: str) -> bool:
        """Eliminar una clave del caché en disco"""
        with self.lock:
            cache_path = self._get_cache_path(key)
            
            if cache_path.exists():
                cache_path.unlink()
            
            if key in self.metadata:
                del self.metadata[key]
                self._save_metadata()
                return True
            
            return False
    
    def clear(self) -> None:
        """Eliminar todos los archivos de caché"""
        with self.lock:
            for cache_file in self.cache_dir.glob('*.cache'):
                cache_file.unlink()
            
            self.metadata.clear()
            self._save_metadata()
    
    def cleanup_expired(self) -> int:
        """Eliminar entradas de caché expiradas"""
        with self.lock:
            current_time = time.time()
            expired_keys = []
            
            for key, meta in self.metadata.items():
                if meta.get('ttl', 0) > 0:
                    if current_time - meta['created_at'] > meta['ttl']:
                        expired_keys.append(key)
            
            for key in expired_keys:
                self.delete(key)
            
            return len(expired_keys)
    
    def get_stats(self) -> Dict[str, Any]:
        """Obtener estadísticas del caché en disco"""
        with self.lock:
            total_size = sum(meta.get('size', 0) for meta in self.metadata.values())
            total_hits = sum(meta.get('hits', 0) for meta in self.metadata.values())
            
            return {
                'entries': len(self.metadata),
                'total_hits': total_hits,
                'total_size_bytes': total_size,
                'total_size_mb': total_size / (1024 * 1024),
                'cache_dir': str(self.cache_dir)
            }


class SmartCache:
    """
    Caché inteligente multinivel con promoción y degradación automática
    Caché en memoria para datos calientes, caché en disco para datos templados
    """
    
    def __init__(self, memory_size: int = 500, cache_dir: str = 'cache'):
        self.memory_cache = MemoryCache(max_size=memory_size)
        self.disk_cache = DiskCache(cache_dir=cache_dir)
        self.access_patterns: Dict[str, List[float]] = defaultdict(list)
        self.logger = setup_logger(self.__class__.__name__)
    
    def get(self, key: str) -> Optional[Any]:
        """
        Obtener valor desde el caché (primero memoria, luego disco)
        Promueve elementos accedidos frecuentemente a memoria
        """
        # Intentar primero desde memoria
        value = self.memory_cache.get(key)
        if value is not None:
            self._record_access(key)
            return value
        
        # Intentar desde disco
        value = self.disk_cache.get(key)
        if value is not None:
            self._record_access(key)
            
            # Promover a memoria si se accede con frecuencia
            if self._should_promote(key):
                self.memory_cache.set(key, value)
                self.logger.debug(f"Clave promovida al caché en memoria: {key}")
            
            return value
        
        return None
    
    def set(self, key: str, value: Any, ttl: int = 3600, force_memory: bool = False) -> None:
        """
        Guardar valor en el caché
        Datos calientes van a memoria, datos templados a disco
        """
        if force_memory:
            self.memory_cache.set(key, value, ttl)
        else:
            # Siempre guardar en disco para persistencia
            self.disk_cache.set(key, value, ttl)
            
            # También guardar en memoria si se predice como caliente
            if self._predict_hot(key):
                self.memory_cache.set(key, value, ttl)
    
    def delete(self, key: str) -> bool:
        """Eliminar de ambos cachés"""
        mem_deleted = self.memory_cache.delete(key)
        disk_deleted = self.disk_cache.delete(key)
        return mem_deleted or disk_deleted
    
    def clear(self) -> None:
        """Limpiar ambos cachés"""
        self.memory_cache.clear()
        self.disk_cache.clear()
        self.access_patterns.clear()
    
    def _record_access(self, key: str) -> None:
        """Registrar patrón de acceso para predicción"""
        self.access_patterns[key].append(time.time())
        
        # Mantener solo los últimos 100 accesos
        if len(self.access_patterns[key]) > 100:
            self.access_patterns[key] = self.access_patterns[key][-100:]
    
    def _should_promote(self, key: str) -> bool:
        """Determinar si una clave debe promoverse al caché en memoria"""
        if key not in self.access_patterns:
            return False
        
        accesses = self.access_patterns[key]
        if len(accesses) < 3:
            return False
        
        # Promover si se accedió 3+ veces en los últimos 5 minutos
        recent_accesses = [a for a in accesses if time.time() - a < 300]
        return len(recent_accesses) >= 3
    
    def _predict_hot(self, key: str) -> bool:
        """Predecir si una clave será accedida frecuentemente"""
        # Heurística simple: claves con ciertos patrones suelen ser calientes
        hot_patterns = ['search:', 'stream:', 'video:']
        return any(pattern in key for pattern in hot_patterns)
    
    def cleanup(self) -> Dict[str, int]:
        """Limpiar entradas expiradas de ambos cachés"""
        mem_cleaned = self.memory_cache.cleanup_expired()
        disk_cleaned = self.disk_cache.cleanup_expired()
        
        return {
            'memory_cleaned': mem_cleaned,
            'disk_cleaned': disk_cleaned,
            'total_cleaned': mem_cleaned + disk_cleaned
        }
    
    def get_stats(self) -> Dict[str, Any]:
        """Obtener estadísticas completas del caché"""
        mem_stats = self.memory_cache.get_stats()
        disk_stats = self.disk_cache.get_stats()
        
        total_entries = mem_stats['entries'] + disk_stats['entries']
        total_hits = mem_stats['total_hits'] + disk_stats['total_hits']
        
        hit_rate = (total_hits / max(total_entries, 1)) if total_entries > 0 else 0
        
        return {
            'memory': mem_stats,
            'disk': disk_stats,
            'total_entries': total_entries,
            'total_hits': total_hits,
            'hit_rate': hit_rate,
            'access_patterns_tracked': len(self.access_patterns)
        }


# Instancia singleton
_cache_instance: Optional[SmartCache] = None


def get_cache() -> SmartCache:
    """Obtener la instancia singleton del caché"""
    global _cache_instance
    if _cache_instance is None:
        _cache_instance = SmartCache()
    return _cache_instance
