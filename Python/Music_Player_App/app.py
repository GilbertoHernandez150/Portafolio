"""
Reproductor de Música - Punto de Entrada Principal
Un reproductor profesional de música de YouTube con interfaz estilo Spotify
"""

from app import create_app
from app.core.logger import setup_logger

# Configuración del sistema de logging
logger = setup_logger(__name__)

def main():
    """Punto de entrada principal de la aplicación"""
    try:
        logger.info("Iniciando la aplicación del Reproductor de Música...")
        app = create_app()
        
        # Ejecutar la aplicación Flask
        app.run(
            host='0.0.0.0',
            port=5000,
            debug=True,
            threaded=True
        )
    except Exception as e:
        logger.error(f"Error al iniciar la aplicación: {e}")
        raise

if __name__ == '__main__':
    main()
