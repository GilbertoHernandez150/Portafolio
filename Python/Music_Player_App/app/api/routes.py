"""
Rutas de la API
Endpoints RESTful para la aplicación del reproductor de música
"""

from flask import Blueprint, request, jsonify, render_template, send_file
from typing import Dict, Any
import os

from app.services.youtube_search import get_search_service
from app.services.video_stream import get_stream_service
from app.services.recommendations import get_recommendation_engine
from app.models.database import DatabaseManager
from app.core.logger import setup_logger
from app.core.cache import get_cache

logger = setup_logger(__name__)

# Inicializar servicios
search_service = get_search_service()
stream_service = get_stream_service()
recommendation_engine = get_recommendation_engine()
db_manager = DatabaseManager()
cache = get_cache()


def register_routes(app):
    """Registrar todas las rutas en la aplicación Flask"""
    
    @app.route('/')
    def index():
        """Página principal"""
        return render_template('index.html')
    
    # ==================== Rutas de Búsqueda ====================
    
    @app.route('/api/search', methods=['GET'])
    def search_videos():
        """
        Buscar videos
        Parámetros de consulta: q (búsqueda), limit (máximo de resultados)
        """
        try:
            query = request.args.get('q', '')
            limit = request.args.get('limit', 10, type=int)
            
            if not query:
                return jsonify({'error': 'El parámetro de búsqueda es obligatorio'}), 400
            
            results = search_service.search(query, max_results=limit)

            # Guardar videos en la base de datos
            for video in results:
                try:
                    db_manager.get_or_create_video(video)
                except Exception as e:
                    logger.error(f"Error guardando video en DB: {e}")

            return jsonify({
                'success': True,
                'query': query,
                'count': len(results),
                'results': results
            })
            
        except Exception as e:
            logger.error(f"Error de búsqueda: {e}")
            return jsonify({'error': str(e)}), 500
    
    @app.route('/api/search/artist', methods=['GET'])
    def search_artist():
        """
        Buscar por nombre del artista
        Parámetros de consulta: artist, limit
        """
        try:
            artist = request.args.get('artist', '')
            limit = request.args.get('limit', 10, type=int)
            
            if not artist:
                return jsonify({'error': 'El parámetro artist es obligatorio'}), 400
            
            results = search_service.search_artist(artist, max_results=limit)
            
            return jsonify({
                'success': True,
                'artist': artist,
                'count': len(results),
                'results': results
            })
            
        except Exception as e:
            logger.error(f"Error en búsqueda por artista: {e}")
            return jsonify({'error': str(e)}), 500
    
    @app.route('/api/search/song', methods=['GET'])
    def search_song():
        """
        Buscar una canción específica
        Parámetros de consulta: title, artist (opcional), limit
        """
        try:
            title = request.args.get('title', '')
            artist = request.args.get('artist', None)
            limit = request.args.get('limit', 10, type=int)
            
            if not title:
                return jsonify({'error': 'El parámetro title es obligatorio'}), 400
            
            results = search_service.search_song(title, artist, max_results=limit)
            
            return jsonify({
                'success': True,
                'title': title,
                'artist': artist,
                'count': len(results),
                'results': results
            })
            
        except Exception as e:
            logger.error(f"Error en búsqueda de canción: {e}")
            return jsonify({'error': str(e)}), 500
    
    @app.route('/api/trending', methods=['GET'])
    def get_trending():
        """Obtener videos musicales en tendencia"""
        try:
            limit = request.args.get('limit', 20, type=int)
            results = search_service.get_trending_music(max_results=limit)
            
            return jsonify({
                'success': True,
                'count': len(results),
                'results': results
            })
            
        except Exception as e:
            logger.error(f"Error al obtener tendencias: {e}")
            return jsonify({'error': str(e)}), 500
    
    # ==================== Rutas de Streaming ====================
    
    @app.route('/api/stream/<video_id>', methods=['GET'])
    def get_stream(video_id: str):
        """
        Obtener la URL de streaming de un video
        Parámetro de ruta: video_id
        Parámetro de consulta: quality (high, medium, low)
        """
        try:
            if not search_service.validate_video_id(video_id):
                return jsonify({'error': 'ID de video inválido'}), 400
            
            quality = request.args.get('quality', 'high')
            stream_data = stream_service.get_stream_url(video_id, quality)
            
            if not stream_data:
                return jsonify({'error': 'No se pudo obtener el stream'}), 404
                        
            return jsonify({
                'success': True,
                'stream': stream_data
            })
            
        except Exception as e:
            logger.error(f"Error de streaming para {video_id}: {e}")
            return jsonify({'error': str(e)}), 500
    
    @app.route('/api/video/<video_id>/info', methods=['GET'])
    def get_video_info(video_id: str):
        """Obtener información detallada de un video"""
        try:
            if not search_service.validate_video_id(video_id):
                return jsonify({'error': 'ID de video inválido'}), 400
            
            info = search_service.get_video_info(video_id)
            
            if not info:
                return jsonify({'error': 'Video no encontrado'}), 404
            
            return jsonify({
                'success': True,
                'video': info
            })
            
        except Exception as e:
            logger.error(f"Error al obtener información del video {video_id}: {e}")
            return jsonify({'error': str(e)}), 500
    
    @app.route('/api/video/<video_id>/related', methods=['GET'])
    def get_related(video_id: str):
        """Obtener videos relacionados con un video específico"""
        try:
            limit = request.args.get('limit', 10, type=int)
            related = search_service.get_related_videos(video_id, max_results=limit)
            
            return jsonify({
                'success': True,
                'video_id': video_id,
                'count': len(related),
                'results': related
            })
            
        except Exception as e:
            logger.error(f"Error al obtener videos relacionados: {e}")
            return jsonify({'error': str(e)}), 500
    
    @app.route('/api/autoplay/next/<video_id>', methods=['GET'])
    def get_autoplay_next(video_id: str):
        """Obtener el siguiente video para reproducción automática"""
        try:
            next_video = stream_service.get_autoplay_next(video_id)
            
            if not next_video:
                return jsonify({'error': 'No se encontró un siguiente video'}), 404
            
            return jsonify({
                'success': True,
                'next_video': next_video
            })
            
        except Exception as e:
            logger.error(f"Error en autoplay siguiente: {e}")
            return jsonify({'error': str(e)}), 500
    
    # ==================== Rutas de Recomendaciones ====================
    
    @app.route('/api/recommendations', methods=['GET'])
    def get_recommendations():
        """Obtener recomendaciones personalizadas"""
        try:
            limit = request.args.get('limit', 10, type=int)
            recommendations = recommendation_engine.get_recommendations(limit=limit)
            
            return jsonify({
                'success': True,
                'count': len(recommendations),
                'recommendations': recommendations
            })
            
        except Exception as e:
            logger.error(f"Error de recomendaciones: {e}")
            return jsonify({'error': str(e)}), 500
    
    @app.route('/api/recommendations/video/<video_id>', methods=['GET'])
    def get_video_recommendations(video_id: str):
        """Obtener recomendaciones basadas en un video específico"""
        try:
            limit = request.args.get('limit', 10, type=int)
            recommendations = recommendation_engine.get_recommendations_for_video(
                video_id, limit=limit
            )
            
            return jsonify({
                'success': True,
                'video_id': video_id,
                'count': len(recommendations),
                'recommendations': recommendations
            })
            
        except Exception as e:
            logger.error(f"Error en recomendaciones por video: {e}")
            return jsonify({'error': str(e)}), 500
    
    @app.route('/api/feed', methods=['GET'])
    def get_feed():
        """Obtener feed personalizado con múltiples secciones"""
        try:
            limit = request.args.get('limit', 30, type=int)
            feed = recommendation_engine.get_personalized_feed(limit=limit)
            
            return jsonify({
                'success': True,
                'feed': feed
            })
            
        except Exception as e:
            logger.error(f"Error en el feed: {e}")
            return jsonify({'error': str(e)}), 500
    
    # ==================== Rutas de Historial ====================
    
    @app.route('/api/history', methods=['GET'])
    def get_history():
        """Obtener historial de reproducciones"""
        try:
            limit = request.args.get('limit', 20, type=int)
            history = db_manager.get_recent_history(limit=limit)
            
            return jsonify({
                'success': True,
                'count': len(history),
                'history': history
            })
            
        except Exception as e:
            logger.error(f"Error al obtener historial: {e}")
            return jsonify({'error': str(e)}), 500
    
    @app.route('/api/history/record', methods=['POST'])
    def record_play():
        """Registrar la reproducción de un video"""
        try:
            data = request.get_json()
            video_id = data.get('video_id')
            duration_played = data.get('duration_played', 0)
            completed = data.get('completed', False)
            source = data.get('source', 'direct')
            
            if not video_id:
                return jsonify({'error': 'video_id es obligatorio'}), 400
            
            db_manager.record_play(
                video_id, 
                duration_played=duration_played,
                completed=completed,
                source=source
            )
            
            return jsonify({'success': True})
            
        except Exception as e:
            logger.error(f"Error al registrar reproducción: {e}")
            return jsonify({'error': str(e)}), 500
    
    # ==================== Rutas de Caché ====================
    
    @app.route('/api/cache/stats', methods=['GET'])
    def cache_stats():
        """Obtener estadísticas del caché"""
        try:
            stats = cache.get_stats()
            return jsonify({
                'success': True,
                'stats': stats
            })
        except Exception as e:
            logger.error(f"Error en estadísticas de caché: {e}")
            return jsonify({'error': str(e)}), 500
    
    @app.route('/api/cache/clear', methods=['POST'])
    def clear_cache():
        """Limpiar todo el caché"""
        try:
            cache.clear()
            return jsonify({
                'success': True,
                'message': 'Caché limpiado'
            })
        except Exception as e:
            logger.error(f"Error al limpiar caché: {e}")
            return jsonify({'error': str(e)}), 500
    
    # ==================== Verificación de Salud ====================
    
    @app.route('/api/health', methods=['GET'])
    def health_check():
        """Endpoint de verificación de estado"""
        return jsonify({
            'status': 'saludable',
            'service': 'API del Reproductor de Música',
            'version': '1.0.0'
        })
    
    logger.info("Todas las rutas fueron registradas correctamente")
