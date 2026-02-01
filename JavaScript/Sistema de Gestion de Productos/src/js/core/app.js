let products = [];
let editingIndex = null;
let productIdCounter = 1;

const form = document.getElementById("product-form");
const nameInput = document.getElementById("name");
const priceInput = document.getElementById("price");
const productList = document.getElementById("product-list");
const submitBtn = document.getElementById("submit-btn");

// Cargar productos del localStorage al iniciar
document.addEventListener('DOMContentLoaded', function() {
    loadProducts();
    renderProducts();
});

form.addEventListener("submit", function (e) {
    e.preventDefault();
    
    const name = nameInput.value.trim();
    const price = parseFloat(priceInput.value);
    
    if (name === "" || isNaN(price) || price <= 0) {
        alert("Por favor ingresa datos válidos");
        return;
    }
    
    if (editingIndex === null) {
        // Crear producto nuevo
        const newProduct = {
            id: productIdCounter++,
            name: name,
            price: price,
            dateAdded: formatDate(new Date())
        };
        products.push(newProduct);
    } else {
        // Actualizar producto existente
        products[editingIndex].name = name;
        products[editingIndex].price = price;
        editingIndex = null;
        submitBtn.textContent = "Agregar Producto";
    }
    
    saveProducts();
    renderProducts();
    form.reset();
});

function renderProducts() {
    productList.innerHTML = "";
    
    products.forEach((product, index) => {
        const row = document.createElement("tr");
        row.innerHTML = `
            <td>${product.id}</td>
            <td>${product.name}</td>
            <td>${product.price.toFixed(2)}</td>
            <td>${product.dateAdded}</td>
            <td>
                <button class="btn-edit" onclick="editProduct(${index})">Editar</button>
                <button class="btn-delete" onclick="deleteProduct(${index})">Eliminar</button>
                <button class="btn-buy" onclick="buyProduct(${index})">Comprar</button>
            </td>
        `;
        productList.appendChild(row);
    });
    
    updateDashboardStats();
}

function editProduct(index) {
    const product = products[index];
    nameInput.value = product.name;
    priceInput.value = product.price;
    editingIndex = index;
    submitBtn.textContent = "Actualizar Producto";
    nameInput.focus();
}

function deleteProduct(index) {
    if (confirm("¿Estás seguro de que quieres eliminar este producto?")) {
        products.splice(index, 1);
        saveProducts();
        renderProducts();
    }
}

function buyProduct(index) {
    const product = products[index];
    openPaymentModal(product);
}

function saveProducts() {
    try {
        const productsData = JSON.stringify(products);
        // Simular guardado (no usar localStorage por restricciones)
        console.log("Productos guardados:", productsData);
    } catch (error) {
        console.error("Error guardando productos:", error);
    }
}

function loadProducts() {
    // Simular carga de datos iniciales
    if (products.length === 0) {
        products = [
            {
                id: 1,
                name: "Laptop Dell",
                price: 850.00,
                dateAdded: formatDate(new Date())
            },
            {
                id: 2,
                name: "Mouse Inalámbrico",
                price: 25.99,
                dateAdded: formatDate(new Date())
            }
        ];
        productIdCounter = 3;
    }
}

function formatDate(date) {
    const options = {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
    };
    return date.toLocaleDateString('es-ES', options);
}

function updateDashboardStats() {
    // Actualizar estadísticas para el dashboard
    const totalProducts = document.getElementById('total-products');
    if (totalProducts) {
        totalProducts.textContent = products.length;
    }
}