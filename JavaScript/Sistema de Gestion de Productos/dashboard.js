document.addEventListener('DOMContentLoaded', function() {
    initializeDashboard();
});

function initializeDashboard() {
    // Mostrar fecha actual formateada
    updateCurrentDate();
    
    // Mostrar mensaje de bienvenida
    updateWelcomeMessage();
    
    // Actualizar estadísticas
    updateStats();
    
    // Configurar botones
    setupEventListeners();
}

function updateCurrentDate() {
    const dateElement = document.getElementById('current-date');
    if (dateElement) {
        const now = new Date();
        const formattedDate = now.toLocaleDateString('es-ES', {
            weekday: 'long',
            year: 'numeric',
            month: 'long',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
        dateElement.textContent = formattedDate;
    }
}

function updateWelcomeMessage() {
    const welcomeElement = document.getElementById('welcome-message');
    if (welcomeElement) {
        // Simular usuario logueado
        const currentUser = 'Usuario Admin'; // En una app real vendría de la sesión
        welcomeElement.textContent = `Bienvenido, ${currentUser}`;
    }
}

function updateStats() {
    // Simular estadísticas
    const totalProducts = document.getElementById('total-products');
    const lastLogin = document.getElementById('last-login');
    const simulatedSales = document.getElementById('simulated-sales');
    
    if (totalProducts) totalProducts.textContent = '5';
    if (lastLogin) lastLogin.textContent = formatDate(new Date());
    if (simulatedSales) simulatedSales.textContent = '$1,245.50';
}

function setupEventListeners() {
    const logoutBtn = document.getElementById('logout-btn');
    const clearDataBtn = document.getElementById('clear-data');
    
    if (logoutBtn) {
        logoutBtn.addEventListener('click', function() {
            if (confirm('¿Estás seguro de que quieres cerrar sesión?')) {
                // Limpiar datos de sesión
                console.log('Cerrando sesión...');
                window.location.href = 'login.html';
            }
        });
    }
    
    if (clearDataBtn) {
        clearDataBtn.addEventListener('click', function() {
            if (confirm('¿Estás seguro de que quieres limpiar todos los datos?')) {
                console.log('Limpiando datos...');
                alert('Datos limpiados exitosamente');
                updateStats();
            }
        });
    }
}

function formatDate(date) {
    return date.toLocaleDateString('es-ES', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
}
