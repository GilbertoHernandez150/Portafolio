document.getElementById('loginForm').addEventListener('submit', function(e) {
    e.preventDefault();
    
    const username = document.getElementById('username').value.trim();
    const password = document.getElementById('password').value;
    const errorMessage = document.getElementById('error-message');
    
    // Validación simple (usuarios de prueba)
    const validUsers = {
        'admin': 'admin123',
        'usuario': 'pass123',
        'test': 'test'
    };
    
    if (validUsers[username] && validUsers[username] === password) {
        // Login exitoso
        const loginData = {
            username: username,
            loginTime: new Date().toISOString(),
            isLoggedIn: true
        };
        
        // Simular guardado de sesión (sin localStorage)
        console.log("Login exitoso:", loginData);
        
        // Redirigir al dashboard
        window.location.href = 'dashboard.html';
    } else {
        // Login fallido
        errorMessage.textContent = 'Usuario o contraseña incorrectos';
        errorMessage.className = 'error-visible';
        
        // Ocultar mensaje después de 3 segundos
        setTimeout(() => {
            errorMessage.className = 'error-hidden';
        }, 3000);
    }
});

// Limpiar mensaje de error cuando el usuario empiece a escribir
document.getElementById('username').addEventListener('input', clearErrorMessage);
document.getElementById('password').addEventListener('input', clearErrorMessage);

function clearErrorMessage() {
    const errorMessage = document.getElementById('error-message');
    errorMessage.className = 'error-hidden';
}