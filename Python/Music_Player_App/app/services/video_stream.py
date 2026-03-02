"""
Servicio de Streaming de Video
Maneja la extracción y entrega de streams de video usando yt-dlp
"""

import yt_dlp
from typing import Dict, Any, Optional
import time

from app.core.cache import get_cache
from app.core.logger import setup_logger
from app.core.config import Config
from app.services.youtube_search import get_search_service

logger = setup_logger(__name__)


class VideoStreamService:
    """Servicio para extraer y gestionar streams de video"""
    
    def __init__(self):
        self.config = Config()
        self.cache = get_cache()
        self.search_service = get_search_service()
        self.logger = logger
        
        # 🔥 Forzamos audio compatible con navegador
        self.ydl_opts = {
            'format': 'bestvideo+bestaudio/best',
            'quiet': True,
            'no_warnings': True,
            'extract_flat': False,
            'skip_download': True,
            'nocheckcertificate': True,
            'ignoreerrors': False,
        }
    
    def get_stream_url(self, video_id: str, quality: str = 'high') -> Optional[Dict[str, Any]]:
        cache_key = f"stream:{video_id}:{quality}"
        cached_stream = self.cache.get(cache_key)

        if cached_stream and self._is_stream_valid(cached_stream):
            self.logger.info(f"Stream encontrado en caché: {video_id}")
            return cached_stream
        
        self.logger.info(f"Extrayendo stream para el video: {video_id} (calidad: {quality})")
        
        try:
            url = f"https://www.youtube.com/watch?v={video_id}"

            with yt_dlp.YoutubeDL(self.ydl_opts) as ydl:
                info = ydl.extract_info(url, download=False)

                if not info:
                    self.logger.error(f"No se pudo extraer la información para {video_id}")
                    return None

                stream_data = self._extract_stream_data(info, quality)

                self.cache.set(cache_key, stream_data, ttl=18000)

                self.logger.info(f"Stream extraído correctamente para {video_id}")
                return stream_data
                
        except Exception as e:
            self.logger.error(f"Error al extraer el stream de {video_id}: {e}")
            return None
    
    def _extract_stream_data(self, info: Dict[str, Any], quality: str) -> Dict[str, Any]:

        stream_url = ""
        selected_format = None

        if 'formats' in info:
            formats = info['formats']

            video_formats = [
                f for f in formats
                if f.get('vcodec') != 'none'
                and f.get('acodec') != 'none'
            ]

            if video_formats:
                video_formats.sort(
                    key=lambda f: f.get('height') or 0,
                    reverse=True
                )
                selected_format = video_formats[0]
                stream_url = selected_format.get('url', '')


        if not stream_url:
            self.logger.error("No se encontró formato de video compatible")
            return {}

        stream_data = {
            'video_id': info.get('id', ''),
            'title': info.get('title', ''),
            'url': stream_url,
            'duration': info.get('duration', 0),
            'quality': quality,
            'ext': selected_format.get('ext', 'mp4'),
            'vcodec': selected_format.get('vcodec', ''),
            'acodec': selected_format.get('acodec', ''),
            'resolution': selected_format.get('height', 0),
            'extracted_at': time.time(),
            'thumbnail': info.get('thumbnail', ''),
            'channel': info.get('uploader', ''),
        }

        return stream_data

    
    def _is_stream_valid(self, stream_data: Dict[str, Any]) -> bool:
        if not stream_data or 'extracted_at' not in stream_data:
            return False
        
        age = time.time() - stream_data['extracted_at']
        max_age = 18000
        return age < max_age
    
    def get_autoplay_next(self, current_video_id: str) -> Optional[Dict[str, Any]]:
        try:
            related = self.search_service.get_related_videos(current_video_id, max_results=10)
            
            if not related:
                related = self.search_service.get_trending_music(max_results=10)
            
            if related:
                return related[0]
            
            return None
            
        except Exception as e:
            self.logger.error(f"Error en autoplay: {e}")
            return None


_stream_service: Optional[VideoStreamService] = None


def get_stream_service() -> VideoStreamService:
    global _stream_service
    if _stream_service is None:
        _stream_service = VideoStreamService()
    return _stream_service
