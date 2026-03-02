"""
Sistema de Recomendación
Recomendaciones musicales impulsadas por IA usando filtrado colaborativo y algoritmos basados en contenido
"""

from typing import List, Dict, Any, Optional, Set
from collections import defaultdict, Counter
import math
from datetime import datetime, timedelta

from app.core.logger import setup_logger
from app.core.config import Config
from app.models.database import DatabaseManager, Video, PlayHistory

logger = setup_logger(__name__)


class RecommendationEngine:
    """Motor para generar recomendaciones musicales personalizadas"""
    
    def __init__(self):
        self.config = Config()
        self.db = DatabaseManager()
        self.db.init_db()
        self.logger = logger
    
    def get_recommendations(self, limit: int = None) -> List[Dict[str, Any]]:
        """
        Obtener recomendaciones personalizadas basadas en el historial de reproducción
        
        Args:
            limit: Número máximo de recomendaciones
        
        Returns:
            Lista de videos recomendados
        """
        if limit is None:
            limit = self.config.RECOMMENDATION_COUNT
        
        self.logger.info(f"Generando {limit} recomendaciones")
        
        try:
            session = self.db.get_session()
            
            # Obtener el historial de reproducción del usuario
            history = session.query(PlayHistory).order_by(
                PlayHistory.played_at.desc()
            ).limit(100).all()
            
            if not history:
                # Sin historial, devolver tendencias
                self.logger.info("No se encontró historial, devolviendo tendencias")
                return self._get_trending_recommendations(session, limit)
            
            # Extraer patrones del historial
            patterns = self._analyze_listening_patterns(session, history)
            
            # Generar recomendaciones basadas en los patrones
            recommendations = []
            
            # 1. Artistas similares (40%)
            similar_artist_recs = self._get_similar_artist_recommendations(
                session, patterns, int(limit * 0.4)
            )
            recommendations.extend(similar_artist_recs)
            
            # 2. Basadas en género (30%)
            genre_recs = self._get_genre_based_recommendations(
                session, patterns, int(limit * 0.3)
            )
            recommendations.extend(genre_recs)
            
            # 3. Descubrimiento (30%) - nuevos artistas/canciones
            discovery_recs = self._get_discovery_recommendations(
                session, patterns, int(limit * 0.3)
            )
            recommendations.extend(discovery_recs)
            
            # Eliminar duplicados y videos ya escuchados
            listened_ids = {h.video.video_id for h in history}
            unique_recs = []
            seen = set()
            
            for rec in recommendations:
                vid_id = rec['video_id']
                if vid_id not in seen and vid_id not in listened_ids:
                    seen.add(vid_id)
                    unique_recs.append(rec)
            
            # Mezclar y limitar
            import random
            random.shuffle(unique_recs)
            final_recs = unique_recs[:limit]
            
            self.logger.info(f"Se generaron {len(final_recs)} recomendaciones")
            return final_recs
            
        except Exception as e:
            self.logger.error(f"Error al generar recomendaciones: {e}")
            return []
        finally:
            session.close()
    
    def get_recommendations_for_video(self, video_id: str, limit: int = 10) -> List[Dict[str, Any]]:
        """
        Obtener recomendaciones basadas en un video específico
        
        Args:
            video_id: ID del video base para la recomendación
            limit: Máximo de recomendaciones
        
        Returns:
            Lista de videos recomendados
        """
        try:
            session = self.db.get_session()
            
            # Obtener el video fuente
            source_video = session.query(Video).filter_by(video_id=video_id).first()
            
            if not source_video:
                return []
            
            # Encontrar videos similares basados en:
            # 1. Mismo canal
            same_channel = session.query(Video).filter(
                Video.channel == source_video.channel,
                Video.video_id != video_id
            ).limit(limit // 2).all()
            
            recommendations = [v.to_dict() for v in same_channel]
            
            # 2. Mismo género
            if source_video.genre:
                same_genre = session.query(Video).filter(
                    Video.genre == source_video.genre,
                    Video.video_id != video_id,
                    Video.channel != source_video.channel
                ).limit(limit // 2).all()
                
                recommendations.extend([v.to_dict() for v in same_genre])
            
            # Eliminar duplicados
            seen = set()
            unique_recs = []
            for rec in recommendations:
                if rec['video_id'] not in seen:
                    seen.add(rec['video_id'])
                    unique_recs.append(rec)
            
            return unique_recs[:limit]
            
        except Exception as e:
            self.logger.error(f"Error al obtener recomendaciones para el video {video_id}: {e}")
            return []
        finally:
            session.close()
    
    def _analyze_listening_patterns(self, session, history: List[PlayHistory]) -> Dict[str, Any]:
        """
        Analizar los patrones de escucha del usuario
        
        Returns:
            Diccionario con los patrones analizados
        """
        patterns = {
            'favorite_artists': Counter(),
            'favorite_genres': Counter(),
            'total_plays': len(history),
            'unique_videos': len(set(h.video.video_id for h in history)),
            'completion_rate': 0.0,
            'recent_trends': [],
        }
        
        completed_plays = 0
        
        for entry in history:
            video = entry.video
            
            # Contar reproducciones por artista
            if video.channel:
                patterns['favorite_artists'][video.channel] += 1
            
            # Contar reproducciones por género
            if video.genre:
                patterns['favorite_genres'][video.genre] += 1
            
            # Calcular tasa de finalización
            if entry.completed:
                completed_plays += 1
        
        # Calcular tasa de finalización
        if patterns['total_plays'] > 0:
            patterns['completion_rate'] = completed_plays / patterns['total_plays']
        
        # Obtener tendencias recientes (últimas 20 reproducciones)
        recent_history = history[:20]
        recent_artists = [h.video.channel for h in recent_history if h.video.channel]
        patterns['recent_trends'] = list(set(recent_artists))
        
        return patterns
    
    def _get_similar_artist_recommendations(self, session, patterns: Dict[str, Any], 
                                           limit: int) -> List[Dict[str, Any]]:
        """Obtener recomendaciones de artistas favoritos"""
        recommendations = []
        
        # Obtener los artistas principales
        top_artists = patterns['favorite_artists'].most_common(5)
        
        for artist, _ in top_artists:
            # Obtener videos de este artista que no estén en el historial
            videos = session.query(Video).filter(
                Video.channel == artist
            ).order_by(Video.view_count.desc()).limit(limit // len(top_artists)).all()
            
            recommendations.extend([v.to_dict() for v in videos])
        
        return recommendations
    
    def _get_genre_based_recommendations(self, session, patterns: Dict[str, Any], 
                                        limit: int) -> List[Dict[str, Any]]:
        """Obtener recomendaciones basadas en géneros favoritos"""
        recommendations = []
        
        # Obtener los géneros principales
        top_genres = patterns['favorite_genres'].most_common(3)
        
        for genre, _ in top_genres:
            # Obtener videos populares de este género
            videos = session.query(Video).filter(
                Video.genre == genre
            ).order_by(Video.view_count.desc()).limit(limit // len(top_genres)).all()
            
            recommendations.extend([v.to_dict() for v in videos])
        
        return recommendations
    
    def _get_discovery_recommendations(self, session, patterns: Dict[str, Any], 
                                      limit: int) -> List[Dict[str, Any]]:
        """Obtener recomendaciones de descubrimiento (nuevos artistas/canciones)"""
        recommendations = []
        
        # Obtener artistas que el usuario aún no ha escuchado
        listened_artists = set(patterns['favorite_artists'].keys())
        
        # Obtener videos populares de nuevos artistas
        if patterns['favorite_genres']:
            # Usar géneros favoritos para guiar el descubrimiento
            for genre, _ in patterns['favorite_genres'].most_common(2):
                videos = session.query(Video).filter(
                    Video.genre == genre,
                    ~Video.channel.in_(listened_artists)
                ).order_by(Video.view_count.desc()).limit(limit // 2).all()
                
                recommendations.extend([v.to_dict() for v in videos])
        else:
            # Obtener videos populares recientes
            cutoff_date = (datetime.utcnow() - timedelta(days=30)).strftime('%Y%m%d')
            videos = session.query(Video).filter(
                Video.upload_date >= cutoff_date,
                ~Video.channel.in_(listened_artists)
            ).order_by(Video.view_count.desc()).limit(limit).all()
            
            recommendations.extend([v.to_dict() for v in videos])
        
        return recommendations
    
    def _get_trending_recommendations(self, session, limit: int) -> List[Dict[str, Any]]:
        """Obtener recomendaciones en tendencia cuando no existe historial"""
        # Obtener los videos más reproducidos globalmente
        videos = session.query(Video).order_by(
            Video.play_count.desc(),
            Video.view_count.desc()
        ).limit(limit).all()
        
        return [v.to_dict() for v in videos]
    
    def calculate_similarity(self, video1_id: str, video2_id: str) -> float:
        """
        Calcular la similitud entre dos videos
        
        Args:
            video1_id: ID del primer video
            video2_id: ID del segundo video
        
        Returns:
            Puntaje de similitud (0.0 a 1.0)
        """
        try:
            session = self.db.get_session()
            
            video1 = session.query(Video).filter_by(video_id=video1_id).first()
            video2 = session.query(Video).filter_by(video_id=video2_id).first()
            
            if not video1 or not video2:
                return 0.0
            
            similarity = 0.0
            
            # Mismo canal = alta similitud
            if video1.channel == video2.channel:
                similarity += 0.5
            
            # Mismo género = similitud media
            if video1.genre and video2.genre and video1.genre == video2.genre:
                similarity += 0.3
            
            # Etiquetas similares = baja similitud
            if video1.tags and video2.tags:
                import json
                tags1 = set(json.loads(video1.tags) if isinstance(video1.tags, str) else video1.tags)
                tags2 = set(json.loads(video2.tags) if isinstance(video2.tags, str) else video2.tags)
                
                if tags1 and tags2:
                    tag_similarity = len(tags1 & tags2) / len(tags1 | tags2)
                    similarity += tag_similarity * 0.2
            
            return min(similarity, 1.0)
            
        except Exception as e:
            self.logger.error(f"Error al calcular similitud: {e}")
            return 0.0
        finally:
            session.close()
    
    def get_personalized_feed(self, limit: int = 50) -> Dict[str, List[Dict[str, Any]]]:
        """
        Obtener un feed personalizado con múltiples secciones
        
        Args:
            limit: Total de elementos a devolver
        
        Returns:
            Diccionario con diferentes secciones del feed
        """
        feed = {
            'for_you': self.get_recommendations(limit=limit // 3),
            'trending': self._get_trending_feed(limit // 3),
            'discover': self._get_discovery_feed(limit // 3),
        }
        
        return feed
    
    def _get_trending_feed(self, limit: int) -> List[Dict[str, Any]]:
        """Obtener videos en tendencia"""
        try:
            session = self.db.get_session()
            
            # Obtener videos populares añadidos recientemente
            cutoff_date = (datetime.utcnow() - timedelta(days=7)).strftime('%Y%m%d')
            videos = session.query(Video).filter(
                Video.upload_date >= cutoff_date
            ).order_by(Video.view_count.desc()).limit(limit).all()
            
            return [v.to_dict() for v in videos]
        finally:
            session.close()
    
    def _get_discovery_feed(self, limit: int) -> List[Dict[str, Any]]:
        """Obtener videos de descubrimiento (nuevos artistas/géneros)"""
        try:
            session = self.db.get_session()
            
            # Obtener historial de reproducción del usuario
            history = session.query(PlayHistory).limit(50).all()
            listened_artists = {h.video.channel for h in history}
            
            # Obtener videos de nuevos artistas
            videos = session.query(Video).filter(
                ~Video.channel.in_(listened_artists)
            ).order_by(Video.view_count.desc()).limit(limit).all()
            
            return [v.to_dict() for v in videos]
        finally:
            session.close()


# Instancia singleton
_recommendation_engine: Optional[RecommendationEngine] = None


def get_recommendation_engine() -> RecommendationEngine:
    """Obtener la instancia singleton del motor de recomendaciones"""
    global _recommendation_engine
    if _recommendation_engine is None:
        _recommendation_engine = RecommendationEngine()
    return _recommendation_engine
