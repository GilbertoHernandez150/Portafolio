"""
Servicio de Búsqueda en YouTube
Versión corregida y estable (SSL fix + trending + mejor manejo de errores)
"""

import yt_dlp
from typing import List, Dict, Any, Optional
import re
import ssl

from app.core.cache import get_cache
from app.core.logger import setup_logger, setup_performance_logger
from app.core.config import Config

logger = setup_logger(__name__)
perf_logger = setup_performance_logger(__name__)

# SOLUCIÓN REAL PARA WINDOWS SSL
ssl._create_default_https_context = ssl._create_unverified_context


class YouTubeSearchService:
    """Servicio para buscar videos en YouTube"""

    def __init__(self):
        self.config = Config()
        self.cache = get_cache()
        self.logger = logger
        self.perf_logger = perf_logger

        self.ydl_opts = {
            "quiet": True,
            "no_warnings": True,
            "extract_flat": True,
            "skip_download": True,
            "ignoreerrors": True,
            "nocheckcertificate": True,
            "geo_bypass": True,
            "geo_bypass_country": "US",
            "noplaylist": True,
            "source_address": "0.0.0.0",
        }

    # ==========================================================
    #                    BÚSQUEDA GENERAL
    # ==========================================================

    def search(self, query: str, max_results: int = None) -> List[Dict[str, Any]]:
        if not query:
            return []

        if max_results is None:
            max_results = self.config.DEFAULT_SEARCH_RESULTS

        cache_key = f"search:{query}:{max_results}"
        cached_results = self.cache.get(cache_key)
        if cached_results:
            self.logger.info(f"Caché encontrada para: {query}")
            return cached_results

        self.logger.info(f"Buscando en YouTube: {query} (máx: {max_results})")
        self.perf_logger.start_timer(f"search_{query}")

        try:
            search_url = f"ytsearch{max_results}:{query}"

            with yt_dlp.YoutubeDL(self.ydl_opts) as ydl:
                result = ydl.extract_info(search_url, download=False)

            if not result or "entries" not in result:
                self.logger.warning(f"No se encontraron resultados para: {query}")
                return []

            videos = []
            for entry in result["entries"]:
                if entry and entry.get("id"):
                    videos.append(self._extract_video_data(entry))

            self.cache.set(
                cache_key,
                videos,
                ttl=self.config.SEARCH_CACHE_TIMEOUT,
            )

            duration = self.perf_logger.end_timer(f"search_{query}")
            self.logger.info(
                f"Se encontraron {len(videos)} videos en {duration:.2f}s"
            )

            return videos

        except Exception as e:
            self.logger.error(f"Error en búsqueda '{query}': {e}")
            return []

    # ==========================================================
    #               MÉTODOS ESPECIALIZADOS
    # ==========================================================

    def search_artist(self, artist_name: str, max_results: int = None):
        return self.search(f"{artist_name} music", max_results)

    def search_song(
        self,
        song_title: str,
        artist: Optional[str] = None,
        max_results: int = None,
    ):
        query = f"{artist} {song_title}" if artist else song_title
        return self.search(query, max_results)

    def get_trending_music(self, max_results: int = 20):
        """
        Música en tendencia (simulada por búsqueda).
        Ahora compatible con routes.py
        """
        return self.search("music trending 2026", max_results)

    # ==========================================================
    #               VIDEOS RELACIONADOS
    # ==========================================================

    def get_related_videos(
        self,
        video_id: str,
        max_results: int = 10,
    ):

        if not self.validate_video_id(video_id):
            return []

        cache_key = f"related:{video_id}:{max_results}"
        cached_results = self.cache.get(cache_key)
        if cached_results:
            return cached_results

        try:
            url = f"https://www.youtube.com/watch?v={video_id}"

            detailed_opts = {**self.ydl_opts, "extract_flat": False}

            with yt_dlp.YoutubeDL(detailed_opts) as ydl:
                result = ydl.extract_info(url, download=False)

            if not result:
                return []

            channel = result.get("uploader", "")
            related = self.search(f"{channel} music", max_results + 5)

            related = [
                v for v in related
                if v["video_id"] != video_id
            ][:max_results]

            self.cache.set(cache_key, related, ttl=3600)
            return related

        except Exception as e:
            self.logger.error(
                f"Error obteniendo relacionados {video_id}: {e}"
            )
            return []

    # ==========================================================
    #               INFO DETALLADA
    # ==========================================================

    def get_video_info(self, video_id: str):

        if not self.validate_video_id(video_id):
            return None

        cache_key = f"video_info:{video_id}"
        cached_info = self.cache.get(cache_key)
        if cached_info:
            return cached_info

        try:
            url = f"https://www.youtube.com/watch?v={video_id}"

            detailed_opts = {
                **self.ydl_opts,
                "extract_flat": False,
            }

            with yt_dlp.YoutubeDL(detailed_opts) as ydl:
                result = ydl.extract_info(url, download=False)

            if not result:
                return None

            video_data = self._extract_video_data(result, detailed=True)

            self.cache.set(cache_key, video_data, ttl=3600)

            return video_data

        except Exception as e:
            self.logger.error(
                f"Error obteniendo info {video_id}: {e}"
            )
            return None

    # ==========================================================
    #               UTILIDADES INTERNAS
    # ==========================================================

    def _extract_video_data(
    self,
    entry: Dict[str, Any],
    detailed: bool = False,
    ):

        # Obtener video_id de forma segura
        video_id = ""

        if entry.get("id"):
            video_id = entry.get("id")

        # Algunos resultados traen URL en vez de ID limpio
        elif entry.get("url"):
            video_id = entry.get("url")

        # Extraer ID desde webpage_url si existe
        elif entry.get("webpage_url"):
            match = re.search(r"v=([a-zA-Z0-9_-]{11})", entry.get("webpage_url"))
            if match:
                video_id = match.group(1)

        video_data = {
            "video_id": video_id,
            "title": entry.get("title", "Título desconocido"),
            "channel": entry.get(
                "uploader",
                entry.get("channel", "Canal desconocido"),
            ),
            "duration": entry.get("duration", 0),
            "thumbnail_url": self._get_best_thumbnail(
                entry.get("thumbnails", [])
            ),
            "view_count": entry.get("view_count", 0),
            "like_count": entry.get("like_count", 0),
            "upload_date": entry.get("upload_date", ""),
        }

        if detailed:
            video_data.update({
                "description": entry.get("description", ""),
                "tags": entry.get("tags", []),
                "categories": entry.get("categories", []),
                "webpage_url": entry.get("webpage_url", ""),
            })

        return video_data

    def _get_best_thumbnail(self, thumbnails: List[Dict[str, Any]]) -> str:
        if not thumbnails:
            return ""

        sorted_thumbnails = sorted(
            thumbnails,
            key=lambda t: t.get("width", 0),
            reverse=True,
        )

        return sorted_thumbnails[0].get("url", "") if sorted_thumbnails else ""


    def validate_video_id(self, video_id: str) -> bool:
        pattern = self.config.ALLOWED_VIDEO_IDS_PATTERN
        return bool(re.match(pattern, video_id))


_search_service: Optional[YouTubeSearchService] = None


def get_search_service() -> YouTubeSearchService:
    global _search_service
    if _search_service is None:
        _search_service = YouTubeSearchService()
    return _search_service
