let simulatedSales = 0;

function openPaymentModal(product) {
    const modal = document.getElementById('payment-modal');
    const paymentDetails = document.getElementById('payment-details');
    
    if (modal && paymentDetails) {
        paymentDetails.innerHTML = `
            <strong>Producto:</strong> ${product.name}<br>
            <strong>Precio:</strong> ${product.price.toFixed(2)}<br>
            <strong>Total a pagar:</strong> ${(product.price * 1.18).toFixed(2)} (incluye IVA)
        `;
        
        modal.style.display = 'block';
        setupPaymentModalEvents(product);
    }
}

function setupPaymentModalEvents(product) {
    const modal = document.getElementById('payment-modal');
    const confirmBtn = document.getElementById('confirm-payment');
    const cancelBtn = document.getElementById('cancel-payment');
    const closeBtn = document.querySelector('.close');
    
    // Confirmar pago
    confirmBtn.onclick = function() {
        processPayment(product);
        modal.style.display = 'none';
    };
    
    // Cancelar pago
    cancelBtn.onclick = function() {
        modal.style.display = 'none';
    };
    
    // Cerrar modal
    closeBtn.onclick = function() {
        modal.style.display = 'none';
    };
    
    // Cerrar al hacer clic fuera del modal
    window.onclick = function(event) {
        if (event.target === modal) {
            modal.style.display = 'none';
        }
    };
}

function processPayment(product) {
    const totalAmount = product.price * 1.18; // Incluir IVA
    simulatedSales += totalAmount;
    
    // Simular procesamiento de pago
    setTimeout(() => {
        alert(`¡Pago procesado exitosamente!\nProducto: ${product.name}\nTotal: ${totalAmount.toFixed(2)}\n\nGracias por tu compra.`);
        
        // Actualizar estadísticas de ventas
        updateSalesStats();
    }, 500);
}

function updateSalesStats() {
    const salesElement = document.getElementById('simulated-sales');
    if (salesElement) {
        salesElement.textContent = `${simulatedSales.toFixed(2)}`;
    }
}