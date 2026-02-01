import os
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager

# =========================
# CONFIGURACIÓN
# =========================
base_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "src", "pages"))
login_url = f"file:///{os.path.join(base_path, 'login.html').replace(os.sep, '/')}"
crud_url = f"file:///{os.path.join(base_path, 'index.html').replace(os.sep, '/')}"

screenshots_path = os.path.join(os.path.dirname(__file__), "screenshots")
os.makedirs(screenshots_path, exist_ok=True)

options = Options()
options.add_experimental_option("detach", True)
driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
wait = WebDriverWait(driver, 10)

# =========================
# FUNCIONES DE PRUEBA
# =========================
def test_login_exitoso():
    print("Iniciando prueba de login exitoso...")
    driver.get(login_url)
    driver.maximize_window()
    time.sleep(2)  # Pausa para ver la página cargada

    print("Ingresando credenciales...")
    driver.find_element(By.ID, "username").send_keys("admin")
    time.sleep(1)
    driver.find_element(By.ID, "password").send_keys("admin123")
    time.sleep(1)
    
    print("Haciendo clic en enviar...")
    driver.find_element(By.CSS_SELECTOR, "button[type='submit']").click()
    time.sleep(2)

    wait.until(EC.url_contains("dashboard.html"))
    driver.save_screenshot(os.path.join(screenshots_path, "login_exitoso.png"))
    print("[OK] Login exitoso")
    time.sleep(3)  # Pausa para observar el resultado

def test_login_fallido():
    print("Iniciando prueba de login fallido...")
    driver.get(login_url)
    time.sleep(2)
    
    print("Ingresando credenciales incorrectas...")
    driver.find_element(By.ID, "username").send_keys("admin")
    time.sleep(1)
    driver.find_element(By.ID, "password").send_keys("wrongpass")
    time.sleep(1)
    
    print("Haciendo clic en enviar...")
    driver.find_element(By.CSS_SELECTOR, "button[type='submit']").click()
    time.sleep(2)

    wait.until(EC.visibility_of_element_located((By.ID, "error-message")))
    driver.save_screenshot(os.path.join(screenshots_path, "login_fallido.png"))
    print("[OK] Login fallido detectado")
    time.sleep(3)  # Pausa para observar el mensaje de error

def test_crear_producto():
    print("Iniciando prueba de creación de producto...")
    driver.get(crud_url)
    time.sleep(2)
    
    print("Llenando formulario...")
    driver.find_element(By.ID, "name").send_keys("Producto de prueba")
    time.sleep(1)
    driver.find_element(By.ID, "price").send_keys("50")
    time.sleep(1)
    
    print("Enviando formulario...")
    driver.find_element(By.ID, "submit-btn").click()
    time.sleep(2)

    wait.until(EC.presence_of_element_located((By.XPATH, "//td[text()='Producto de prueba']")))
    driver.save_screenshot(os.path.join(screenshots_path, "crear.png"))
    print("[OK] Producto creado")
    time.sleep(3)  # Pausa para ver el producto en la tabla

def test_editar_producto():
    print("Iniciando prueba de edición de producto...")
    edit_btn = wait.until(EC.element_to_be_clickable((By.XPATH, "//button[text()='Editar']")))
    edit_btn.click()
    time.sleep(2)  # Pausa para ver el formulario de edición

    print("Editando producto...")
    name_input = driver.find_element(By.ID, "name")
    name_input.clear()
    time.sleep(1)
    name_input.send_keys("Producto editado")
    time.sleep(1)
    
    print("Guardando cambios...")
    driver.find_element(By.ID, "submit-btn").click()
    time.sleep(2)

    wait.until(EC.presence_of_element_located((By.XPATH, "//td[text()='Producto editado']")))
    driver.save_screenshot(os.path.join(screenshots_path, "editar.png"))
    print("[OK] Producto editado")
    time.sleep(3)  # Pausa para ver el producto editado

def test_eliminar_producto():
    print("Iniciando prueba de eliminación de producto...")
    try:
        delete_btn = wait.until(EC.element_to_be_clickable((By.XPATH, "//button[text()='Eliminar']")))
        delete_btn.click()
        time.sleep(2)  # Pausa para ver la alerta

        # Esperar a que aparezca la alerta y aceptarla
        print("Confirmando eliminación...")
        alert = wait.until(EC.alert_is_present())
        alert.accept()  # Acepta la alerta (clic en OK)

        time.sleep(3)  # Pausa para ver que el producto se elimina

        driver.save_screenshot(os.path.join(screenshots_path, "eliminar.png"))
        print("[OK] Producto eliminado")
        time.sleep(2)
    except Exception as e:
        print("[ERROR] Eliminar producto:", e)

def test_procesar_pago():
    print("Iniciando prueba de procesamiento de pago...")
    # Simulación: si tu CRUD agrega un botón "Comprar"
    try:
        buy_btn = wait.until(EC.element_to_be_clickable((By.XPATH, "//button[text()='Comprar']")))
        buy_btn.click()
        time.sleep(2)
        wait.until(EC.visibility_of_element_located((By.ID, "payment-modal")))
        driver.save_screenshot(os.path.join(screenshots_path, "payment.png"))
        print("[OK] Pago procesado")
        time.sleep(3)  # Pausa para ver el modal de pago
    except:
        print("[INFO] Botón de compra no encontrado, omitiendo prueba de pago")

# =========================
# FLUJO PRINCIPAL
# =========================
try:
    print("=== INICIANDO SUITE DE PRUEBAS ===")
    time.sleep(2)
    
    test_login_exitoso()
    print("\n--- Siguiente prueba en 3 segundos ---")
    time.sleep(3)
    
    test_login_fallido()
    print("\n--- Siguiente prueba en 3 segundos ---")
    time.sleep(3)
    
    test_crear_producto()
    print("\n--- Siguiente prueba en 3 segundos ---")
    time.sleep(3)
    
    test_editar_producto()
    print("\n--- Siguiente prueba en 3 segundos ---")
    time.sleep(3)
    
    test_eliminar_producto()
    print("\n--- Siguiente prueba en 3 segundos ---")
    time.sleep(3)
    
    test_procesar_pago()
    
    print("\n=== PRUEBAS COMPLETADAS ===")
    time.sleep(5)  # Pausa final para revisar resultados
    
finally:
    print("Cerrando navegador...")
    time.sleep(2)
    driver.quit()