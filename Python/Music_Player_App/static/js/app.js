// Reproductor de Música - JavaScript Principal

class MusicPlayer {
    constructor() {
        this.currentVideo = null;
        this.queue = [];
        this.queueIndex = -1;
        this.autoplayEnabled = true;
        this.shuffleEnabled = false;
        this.repeatMode = 'none'; // 'none', 'one', 'all'
        this.volume = 0.7;
        this.isSeeking = false; // CONTROL DE SEEK
        
        this.initializeElements();
        this.attachEventListeners();
        this.loadTrending();
    }

    initializeElements() {
        // Vistas
        this.views = {
            home: document.getElementById('home-view'),
            search: document.getElementById('search-view'),
            history: document.getElementById('history-view'),
            recommendations: document.getElementById('recommendations-view')
        };

        // Elementos del reproductor
        this.videoPlayer = document.getElementById('video-player');
        this.videoPlaceholder = document.getElementById('video-placeholder');
        this.trackTitle = document.getElementById('track-title');
        this.trackArtist = document.getElementById('track-artist');
        this.playPauseBtn = document.getElementById('play-pause-btn');

        // Barra de progreso
        this.progressBar = document.getElementById('progress-bar');
        this.currentTimeEl = document.getElementById('current-time');
        this.durationEl = document.getElementById('duration');

        // Cuadrículas
        this.trendingGrid = document.getElementById('trending-grid');
        this.searchResults = document.getElementById('search-results');
        this.historyList = document.getElementById('history-list');
        this.recommendationsGrid = document.getElementById('recommendations-grid');

        // Otros elementos
        this.searchInput = document.getElementById('search-input');
        this.loadingSpinner = document.getElementById('loading-spinner');
        this.notification = document.getElementById('notification');
    
        this.progressBar.disabled = true;
    }

    attachEventListeners() {
        // Navegación
        document.querySelectorAll('.nav-item').forEach(item => {
            item.addEventListener('click', (e) => this.switchView(e.target.closest('.nav-item').dataset.view));
        });

        // Búsqueda
        document.getElementById('search-btn').addEventListener('click', () => this.search());
        this.searchInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') this.search();
        });

        // Controles del reproductor
        this.playPauseBtn.addEventListener('click', () => this.togglePlayPause());
        document.getElementById('next-btn').addEventListener('click', () => this.playNext());
        document.getElementById('prev-btn').addEventListener('click', () => this.playPrevious());
        document.getElementById('shuffle-btn').addEventListener('click', () => this.toggleShuffle());
        document.getElementById('repeat-btn').addEventListener('click', () => this.toggleRepeat());
        document.getElementById('autoplay-btn').addEventListener('click', () => this.toggleAutoplay());

        // Volumen
        document.getElementById('volume-slider').addEventListener('input', (e) => {
            this.volume = e.target.value / 100;
            this.videoPlayer.volume = this.volume;
            
        });

        // Cuando se carga metadata (duración total)
        this.videoPlayer.addEventListener('loadedmetadata', () => {
            if (!isNaN(this.videoPlayer.duration)) {

                this.progressBar.max = 100; 
                this.progressBar.disabled = false; 

                this.durationEl.textContent = this.formatDuration(
                    Math.floor(this.videoPlayer.duration)
                );
            }
        });

        // Mientras se reproduce
        this.videoPlayer.addEventListener('timeupdate', () => {

            if (this.isSeeking) return; // EVITA CONFLICTO

            if (!isNaN(this.videoPlayer.duration) && this.videoPlayer.duration > 0) {

                const percent = (this.videoPlayer.currentTime / this.videoPlayer.duration) * 100;

                this.progressBar.value = percent;

                document.getElementById('progress-fill').style.width = percent + '%';

                this.currentTimeEl.textContent = this.formatDuration(
                    Math.floor(this.videoPlayer.currentTime)
                );
            }
        });


        // Cuando empieza a arrastrar
        this.progressBar.addEventListener('pointerdown', () => {
            this.isSeeking = true;
        });

        // Mientras arrastra (visual solamente)
        this.progressBar.addEventListener('input', (e) => {
            const percent = e.target.value;
            document.getElementById('progress-fill').style.width = percent + '%';
        });

        // Cuando suelta
        this.progressBar.addEventListener('pointerup', (e) => {

            if (!isNaN(this.videoPlayer.duration) && this.videoPlayer.duration > 0) {

                const percent = e.target.value;
                const newTime = (percent / 100) * this.videoPlayer.duration;

                this.videoPlayer.currentTime = newTime;
            }

            this.isSeeking = false;
        });

    }

    switchView(viewName) {
        // Ocultar todas las vistas
        Object.values(this.views).forEach(view => view.classList.add('hidden'));
        
        // Mostrar la vista seleccionada
        this.views[viewName].classList.remove('hidden');

        // Actualizar ítem activo del menú
        document.querySelectorAll('.nav-item').forEach(item => {
            item.classList.remove('active');
            if (item.dataset.view === viewName) {
                item.classList.add('active');
            }
        });

        // Cargar datos según la vista
        switch(viewName) {
            case 'home':
                this.loadTrending();
                break;
            case 'history':
                this.loadHistory();
                break;
            case 'recommendations':
                this.loadRecommendations();
                break;
        }
    }

    async loadTrending() {
        this.showLoading(true);
        try {
            const response = await fetch('/api/trending?limit=20');
            const data = await response.json();
            
            if (data.success) {
                this.renderVideoGrid(data.results, this.trendingGrid);
            }
        } catch (error) {
            this.showNotification('Error al cargar los videos en tendencia');
            console.error(error);
        }
        this.showLoading(false);
    }

    async search() {
        const query = this.searchInput.value.trim();
        if (!query) return;

        this.showLoading(true);
        this.switchView('search');
        
        try {
            const response = await fetch(`/api/search?q=${encodeURIComponent(query)}&limit=20`);
            const data = await response.json();
            
            if (data.success) {
                document.getElementById('search-title').textContent = `Resultados para "${query}"`;
                this.renderVideoGrid(data.results, this.searchResults);
            }
        } catch (error) {
            this.showNotification('La búsqueda falló');
            console.error(error);
        }
        this.showLoading(false);
    }

    async loadHistory() {
        this.showLoading(true);
        try {
            const response = await fetch('/api/history?limit=20');
            const data = await response.json();
            
            if (data.success) {
                const videos = data.history.map(h => h.video);
                this.renderVideoGrid(videos, this.historyList);
            }
        } catch (error) {
            this.showNotification('Error al cargar el historial');
            console.error(error);
        }
        this.showLoading(false);
    }

    async loadRecommendations() {
        this.showLoading(true);
        try {
            const response = await fetch('/api/recommendations?limit=20');
            const data = await response.json();
            
            if (data.success) {
                this.renderVideoGrid(data.recommendations, this.recommendationsGrid);
            }
        } catch (error) {
            this.showNotification('Error al cargar recomendaciones');
            console.error(error);
        }
        this.showLoading(false);
    }

    renderVideoGrid(videos, container) {
        container.innerHTML = '';
        
        videos.forEach(video => {
            const card = this.createVideoCard(video);
            container.appendChild(card);
        });
    }

    createVideoCard(video) {
        const card = document.createElement('div');
        card.className = 'video-card';
        
        const duration = this.formatDuration(video.duration || 0);
        const views = this.formatNumber(video.view_count || 0);
        
        card.innerHTML = `
            <img src="${video.thumbnail_url || '/static/images/placeholder.jpg'}" 
                 alt="${video.title}" 
                 onerror="this.src='/static/images/placeholder.jpg'">
            <div class="video-card-title">${this.escapeHtml(video.title)}</div>
            <div class="video-card-channel">${this.escapeHtml(video.channel || 'Desconocido')}</div>
            <div class="video-card-stats">${views} vistas • ${duration}</div>
        `;
        
        card.addEventListener('click', () => this.playVideo(video));
        
        return card;
    }

    async playVideo(video) {
        this.showLoading(true);

        try {
            // Obtener ID correctamente (soporta video_id o id)
            const videoId = video.video_id || video.id;

            if (!videoId) {
                this.showNotification("Video inválido");
                this.showLoading(false);
                return;
            }

            const response = await fetch(`/api/stream/${videoId}?quality=high`);
            const data = await response.json();

            if (data.success && data.stream && data.stream.url) {

                this.currentVideo = video;

                this.trackTitle.textContent = video.title;
                this.trackArtist.textContent = video.channel || 'Artista desconocido';

                this.videoPlayer.src = data.stream.url;
                this.videoPlayer.load();
                await this.videoPlayer.play();

                // Resetear barra
                this.progressBar.value = 0;
                this.currentTimeEl.textContent = "0:00";

                this.videoPlayer.classList.add('active');
                this.videoPlaceholder.classList.add('hidden');

                this.playPauseBtn.textContent = '⏸';

                this.showNotification(`Reproduciendo ahora: ${video.title}`);

                this.recordPlay(videoId);

                if (this.autoplayEnabled) {
                    await this.loadRelatedVideos(videoId);
                }

            } else {
                this.showNotification("No se pudo obtener el stream");
            }

        } catch (error) {
            this.showNotification('Error al reproducir el video');
            console.error(error);
        }

        this.showLoading(false);
    }

    async loadRelatedVideos(videoId) {
        try {
            const response = await fetch(`/api/video/${videoId}/related?limit=10`);
            const data = await response.json();
            
            if (data.success) {
                this.queue = data.results;
                this.queueIndex = -1;
            }
        } catch (error) {
            console.error('Error al cargar videos relacionados:', error);
        }
    }

    async recordPlay(videoId) {
        try {
            await fetch('/api/history/record', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    video_id: videoId,
                    source: 'direct'
                })
            });
        } catch (error) {
            console.error('Error al registrar la reproducción:', error);
        }
    }

    togglePlayPause() {
        if (this.videoPlayer.paused) {
            this.videoPlayer.play();
            this.playPauseBtn.textContent = '⏸';
        } else {
            this.videoPlayer.pause();
            this.playPauseBtn.textContent = '▶';
        }
    }

    async playNext() {
        if (this.queue.length === 0) {
            // Intentar obtener el siguiente por autoplay
            if (this.currentVideo && this.autoplayEnabled) {
                try {
                    const response = await fetch(`/api/autoplay/next/${this.currentVideo.video_id}`);
                    const data = await response.json();
                    
                    if (data.success) {
                        await this.playVideo(data.next_video);
                    }
                } catch (error) {
                    this.showNotification('No hay más videos en la cola');
                }
            }
            return;
        }

        this.queueIndex = (this.queueIndex + 1) % this.queue.length;
        const nextVideo = this.queue[this.queueIndex];
        await this.playVideo(nextVideo);
    }

    async playPrevious() {
        if (this.queue.length === 0) return;

        this.queueIndex = this.queueIndex <= 0 ? this.queue.length - 1 : this.queueIndex - 1;
        const prevVideo = this.queue[this.queueIndex];
        await this.playVideo(prevVideo);
    }

    toggleShuffle() {
        this.shuffleEnabled = !this.shuffleEnabled;
        const btn = document.getElementById('shuffle-btn');
        btn.classList.toggle('active');
        
        if (this.shuffleEnabled && this.queue.length > 0) {
            // Mezclar cola
            for (let i = this.queue.length - 1; i > 0; i--) {
                const j = Math.floor(Math.random() * (i + 1));
                [this.queue[i], this.queue[j]] = [this.queue[j], this.queue[i]];
            }
        }
        
        this.showNotification(`Aleatorio ${this.shuffleEnabled ? 'activado' : 'desactivado'}`);
    }

    toggleRepeat() {
        const modes = ['none', 'one', 'all'];
        const currentIndex = modes.indexOf(this.repeatMode);
        this.repeatMode = modes[(currentIndex + 1) % modes.length];
        
        const btn = document.getElementById('repeat-btn');
        btn.classList.toggle('active', this.repeatMode !== 'none');
        
        const modeText = {
            'none': 'Repetición desactivada',
            'one': 'Repetir una',
            'all': 'Repetir todas'
        };
        
        this.showNotification(modeText[this.repeatMode]);
    }

    toggleAutoplay() {
        this.autoplayEnabled = !this.autoplayEnabled;
        const btn = document.getElementById('autoplay-btn');
        btn.classList.toggle('active');
        
        this.showNotification(`Autoplay ${this.autoplayEnabled ? 'activado' : 'desactivado'}`);
    }

    // Funciones utilitarias
    formatDuration(seconds) {
        const mins = Math.floor(seconds / 60);
        const secs = seconds % 60;
        return `${mins}:${secs.toString().padStart(2, '0')}`;
    }

    formatNumber(num) {
        if (num >= 1000000) return (num / 1000000).toFixed(1) + 'M';
        if (num >= 1000) return (num / 1000).toFixed(1) + 'K';
        return num.toString();
    }

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    showLoading(show) {
        this.loadingSpinner.classList.toggle('hidden', !show);
    }

    showNotification(message) {
        this.notification.textContent = message;
        this.notification.classList.remove('hidden');
        
        setTimeout(() => {
            this.notification.classList.add('hidden');
        }, 3000);
    }
}

// Inicializar la app cuando el DOM esté cargado
document.addEventListener('DOMContentLoaded', () => {
    window.musicPlayer = new MusicPlayer();
});

