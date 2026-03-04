"""
Modelos y Gestor de Base de Datos
Modelos ORM de SQLAlchemy para videos, listas de reproducción, historial y configuraciones
"""

from sqlalchemy import create_engine, Column, Integer, String, Float, Boolean, DateTime, Table, ForeignKey, Text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship, scoped_session
from datetime import datetime
from typing import List, Optional, Dict, Any
import json

from app.core.config import Config
from app.core.logger import setup_logger

logger = setup_logger(__name__)

Base = declarative_base()

# Tabla de asociación para la relación muchos-a-muchos entre Playlist y Video
playlist_videos = Table(
    'playlist_videos',
    Base.metadata,
    Column('playlist_id', Integer, ForeignKey('playlists.id'), primary_key=True),
    Column('video_id', Integer, ForeignKey('videos.id'), primary_key=True),
    Column('position', Integer, default=0),
    Column('added_at', DateTime, default=datetime.utcnow)
)


class Video(Base):
    """Modelo de video que representa un video de YouTube"""
    
    __tablename__ = 'videos'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    video_id = Column(String(20), unique=True, nullable=False, index=True)
    title = Column(String(500), nullable=False)
    channel = Column(String(200))
    duration = Column(Integer)  # Duración en segundos
    thumbnail_url = Column(String(500))
    view_count = Column(Integer, default=0)
    like_count = Column(Integer, default=0)
    upload_date = Column(String(20))
    description = Column(Text)
    
    # Metadatos
    play_count = Column(Integer, default=0)
    last_played = Column(DateTime)
    added_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Metadatos de calidad de audio
    audio_quality = Column(String(20))  # 'high', 'medium', 'low'
    file_size = Column(Integer)  # Tamaño en bytes
    
    # Género/categoría (puede inferirse o configurarse manualmente)
    genre = Column(String(100))
    tags = Column(Text)  # Arreglo JSON de etiquetas
    
    # Relaciones
    playlists = relationship('Playlist', secondary=playlist_videos, back_populates='videos')
    play_history = relationship('PlayHistory', back_populates='video', cascade='all, delete-orphan')
    
    def to_dict(self) -> Dict[str, Any]:
        """Convertir el modelo a diccionario"""
        return {
            'id': self.id,
            'video_id': self.video_id,
            'title': self.title,
            'channel': self.channel,
            'duration': self.duration,
            'thumbnail_url': self.thumbnail_url,
            'view_count': self.view_count,
            'like_count': self.like_count,
            'upload_date': self.upload_date,
            'description': self.description,
            'play_count': self.play_count,
            'last_played': self.last_played.isoformat() if self.last_played else None,
            'added_at': self.added_at.isoformat() if self.added_at else None,
            'audio_quality': self.audio_quality,
            'genre': self.genre,
            'tags': json.loads(self.tags) if self.tags else []
        }
    
    def __repr__(self):
        return f"<Video(video_id='{self.video_id}', title='{self.title[:50]}')>"


class Playlist(Base):
    """Modelo de lista de reproducción para organizar videos"""
    
    __tablename__ = 'playlists'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(200), nullable=False)
    description = Column(Text)
    thumbnail_url = Column(String(500))
    
    # Metadatos
    is_favorite = Column(Boolean, default=False)
    play_count = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Preferencias del usuario para esta lista
    shuffle = Column(Boolean, default=False)
    repeat_mode = Column(String(20), default='none')  # 'none', 'one', 'all'
    
    # Relaciones
    videos = relationship('Video', secondary=playlist_videos, back_populates='playlists')
    
    def to_dict(self, include_videos: bool = False) -> Dict[str, Any]:
        """Convertir el modelo a diccionario"""
        data = {
            'id': self.id,
            'name': self.name,
            'description': self.description,
            'thumbnail_url': self.thumbnail_url,
            'is_favorite': self.is_favorite,
            'play_count': self.play_count,
            'video_count': len(self.videos),
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
            'shuffle': self.shuffle,
            'repeat_mode': self.repeat_mode
        }
        
        if include_videos:
            data['videos'] = [video.to_dict() for video in self.videos]
        
        return data
    
    def __repr__(self):
        return f"<Playlist(id={self.id}, name='{self.name}', videos={len(self.videos)})>"


class PlayHistory(Base):
    """Modelo de historial de reproducción para rastrear qué se reprodujo y cuándo"""
    
    __tablename__ = 'play_history'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    video_id_fk = Column(Integer, ForeignKey('videos.id'), nullable=False)
    
    # Información de la sesión de reproducción
    played_at = Column(DateTime, default=datetime.utcnow, index=True)
    duration_played = Column(Integer)  # Cuánto tiempo se reprodujo (segundos)
    completed = Column(Boolean, default=False)  # ¿El usuario lo escuchó completo?
    
    # Contexto
    source = Column(String(50))  # 'search', 'playlist', 'recommendation', 'autoplay'
    playlist_id = Column(Integer, ForeignKey('playlists.id'), nullable=True)
    
    # Relaciones
    video = relationship('Video', back_populates='play_history')
    
    def to_dict(self) -> Dict[str, Any]:
        """Convertir el modelo a diccionario"""
        return {
            'id': self.id,
            'video': self.video.to_dict() if self.video else None,
            'played_at': self.played_at.isoformat() if self.played_at else None,
            'duration_played': self.duration_played,
            'completed': self.completed,
            'source': self.source
        }
    
    def __repr__(self):
        return f"<PlayHistory(id={self.id}, video_id={self.video_id_fk}, played_at={self.played_at})>"


class Settings(Base):
    """Modelo de configuraciones de la aplicación"""
    
    __tablename__ = 'settings'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    key = Column(String(100), unique=True, nullable=False, index=True)
    value = Column(Text)
    value_type = Column(String(20))  # 'string', 'int', 'float', 'bool', 'json'
    description = Column(String(500))
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def get_value(self) -> Any:
        """Obtener el valor con su tipo correspondiente"""
        if self.value_type == 'int':
            return int(self.value)
        elif self.value_type == 'float':
            return float(self.value)
        elif self.value_type == 'bool':
            return self.value.lower() == 'true'
        elif self.value_type == 'json':
            return json.loads(self.value)
        else:
            return self.value
    
    def set_value(self, value: Any) -> None:
        """Asignar el valor con su tipo correspondiente"""
        if isinstance(value, bool):
            self.value = 'true' if value else 'false'
            self.value_type = 'bool'
        elif isinstance(value, int):
            self.value = str(value)
            self.value_type = 'int'
        elif isinstance(value, float):
            self.value = str(value)
            self.value_type = 'float'
        elif isinstance(value, (dict, list)):
            self.value = json.dumps(value)
            self.value_type = 'json'
        else:
            self.value = str(value)
            self.value_type = 'string'
    
    def to_dict(self) -> Dict[str, Any]:
        """Convertir el modelo a diccionario"""
        return {
            'id': self.id,
            'key': self.key,
            'value': self.get_value(),
            'value_type': self.value_type,
            'description': self.description,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
    
    def __repr__(self):
        return f"<Settings(key='{self.key}', value='{self.value}')>"


class DatabaseManager:
    """Gestor de base de datos para manejar todas las operaciones"""
    
    def __init__(self):
        self.config = Config()
        self.engine = None
        self.Session = None
        self.logger = setup_logger(self.__class__.__name__)
    
    def init_db(self) -> None:
        """Inicializar la conexión a la base de datos y crear las tablas"""
        try:
            # Crear el directorio de datos si no existe
            self.config.DATA_DIR.mkdir(parents=True, exist_ok=True)
            
            # Crear el engine
            self.engine = create_engine(
                self.config.SQLALCHEMY_DATABASE_URI,
                echo=False,
                pool_pre_ping=True,
                pool_recycle=3600
            )
            
            # Crear todas las tablas
            Base.metadata.create_all(self.engine)
            
            # Crear la fábrica de sesiones
            self.Session = scoped_session(sessionmaker(bind=self.engine))
            
            self.logger.info(f"Base de datos inicializada en {self.config.DB_PATH}")
            
            # Inicializar configuraciones por defecto
            self._init_default_settings()
            
        except Exception as e:
            self.logger.error(f"Error al inicializar la base de datos: {e}")
            raise
    
    def _init_default_settings(self) -> None:
        """Inicializar las configuraciones por defecto de la aplicación"""
        default_settings = {
            'volume': (0.7, 'float', 'Nivel de volumen por defecto'),
            'autoplay': (True, 'bool', 'Habilitar reproducción automática'),
            'shuffle': (False, 'bool', 'Habilitar modo aleatorio'),
            'repeat_mode': ('none', 'string', 'Modo de repetición: none, one, all'),
            'quality': ('high', 'string', 'Preferencia de calidad de audio'),
            'theme': ('dark', 'string', 'Tema de la interfaz'),
            'search_history_limit': (50, 'int', 'Máximo de entradas en el historial de búsqueda')
        }
        
        session = self.Session()
        try:
            for key, (value, value_type, description) in default_settings.items():
                existing = session.query(Settings).filter_by(key=key).first()
                if not existing:
                    setting = Settings(key=key, description=description)
                    setting.set_value(value)
                    session.add(setting)
            
            session.commit()
            self.logger.info("Configuraciones por defecto inicializadas")
        except Exception as e:
            session.rollback()
            self.logger.error(f"Error al inicializar configuraciones por defecto: {e}")
        finally:
            session.close()
    
    def get_session(self):
        """Obtener una nueva sesión de base de datos"""
        if self.Session is None:
            self.init_db()
        return self.Session()
    
    def close(self) -> None:
        """Cerrar la conexión a la base de datos"""
        if self.Session:
            self.Session.remove()
        if self.engine:
            self.engine.dispose()
        self.logger.info("Conexión a la base de datos cerrada")
    
    # Operaciones de video
    def get_or_create_video(self, video_data: Dict[str, Any]) -> Video:
        """Obtener un video existente o crear uno nuevo"""
        session = self.get_session()
        try:
            video = session.query(Video).filter_by(video_id=video_data['video_id']).first()
            
            if video:
                # Actualizar video existente
                for key, value in video_data.items():
                    if hasattr(video, key):
                        setattr(video, key, value)
            else:
                # Crear nuevo video
                video = Video(**video_data)
                session.add(video)
            
            session.commit()
            session.refresh(video)
            return video
        except Exception as e:
            session.rollback()
            self.logger.error(f"Error al obtener/crear el video: {e}")
            raise
        finally:
            session.close()
    
    def record_play(self, video_id: str, duration_played: int = 0, 
               completed: bool = False, source: str = 'direct') -> None:
        session = self.get_session()
        try:
            video = session.query(Video).filter_by(video_id=video_id).first()

            # Si no existe, lo creamos mínimo
            if not video:
                video = Video(
                    video_id=video_id,
                    title="Unknown",
                    channel="Unknown"
                )
                session.add(video)
                session.commit()
                session.refresh(video)

            # Actualizar contador
            video.play_count += 1
            video.last_played = datetime.utcnow()

            history = PlayHistory(
                video_id_fk=video.id,
                duration_played=duration_played,
                completed=completed,
                source=source
            )

            session.add(history)
            session.commit()

            self.logger.info(f"Reproducción registrada para el video: {video_id}")

        except Exception as e:
            session.rollback()
            self.logger.error(f"Error al registrar la reproducción: {e}")
        finally:
            session.close()
    
    def get_recent_history(self, limit: int = 20) -> List[Dict[str, Any]]:
        """Obtener el historial de reproducciones recientes"""
        session = self.get_session()
        try:
            history = session.query(PlayHistory).order_by(
                PlayHistory.played_at.desc()
            ).limit(limit).all()
            
            return [h.to_dict() for h in history]
        finally:
            session.close()
