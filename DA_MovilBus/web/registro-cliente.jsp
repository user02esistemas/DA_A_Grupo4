<%-- 
    Document   : registro-cliente
    Página de registro de nuevo cliente con su cuenta de usuario CLIENTE_WEB
    Estilo corporativo MovilBus
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MovilBus - Crear Cuenta</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/movilbus.css">
    <style>
        body {
            background: linear-gradient(135deg, #FFF3E0 0%, #FFFFFF 50%, #FFFDE7 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            font-family: 'Inter', sans-serif;
        }
        .register-card {
            max-width: 560px;
            margin: 0 auto;
            border: none;
            border-radius: 20px;
            box-shadow: 0 8px 40px rgba(0,0,0,.10);
            overflow: hidden;
        }
        .register-header {
            background: var(--gradient-primary);
            padding: 1.8rem;
            text-align: center;
            color: white;
        }
        .register-header h3 { font-weight: 800; }
        .register-body { padding: 2rem; }
        .form-control, .form-select {
            border-radius: 10px;
            padding: .65rem 1rem;
            border: 1.5px solid #e0e0e0;
            transition: all .2s;
        }
        .form-control:focus, .form-select:focus {
            border-color: var(--mvb-orange);
            box-shadow: 0 0 0 3px rgba(255,107,0,.15);
        }
        .form-label { font-weight: 600; font-size: .85rem; color: #444; }
        .btn-registrar {
            background: var(--gradient-primary);
            border: none;
            border-radius: 12px;
            padding: .75rem;
            font-weight: 700;
            color: white;
            transition: all .3s;
        }
        .btn-registrar:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(255,107,0,.35);
        }
        .brand-top {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: .5rem;
            font-size: 1.2rem;
            font-weight: 800;
            color: var(--mvb-orange);
            margin-bottom: 1.5rem;
        }
        .brand-top i { font-size: 1.5rem; }
    </style>
</head>
<body>
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-6 col-md-8">
                <div class="brand-top">
                    <i class="bi bi-bus-front"></i> MovilBus
                </div>
                <div class="register-card">
                    <div class="register-header">
                        <i class="bi bi-person-plus fs-1"></i>
                        <h3 class="fw-bold mt-2 mb-1">Crear tu Cuenta</h3>
                        <p class="mb-0 opacity-75 small">Únete a MovilBus y compra pasajes online</p>
                    </div>
                    <div class="register-body">
                        <c:if test="${param.status == 'error'}">
                            <div class="alert alert-danger text-center small rounded-3" role="alert">
                                <i class="bi bi-exclamation-triangle me-1"></i>
                                Ocurrió un error al procesar el registro. Es posible que el DNI ya esté registrado.
                            </div>
                        </c:if>

                        <form action="ClienteServlet" method="POST" onsubmit="return validarFormulario()">
                            <input type="hidden" name="accion" value="registrar">
                            
                            <div class="mb-3">
                                <label class="form-label"><i class="bi bi-card-text me-1 text-muted"></i>DNI <span class="text-danger">*</span></label>
                                <input type="text" name="dni" class="form-control" maxlength="8" pattern="\d{8}" placeholder="12345678" required>
                                <div class="form-text small">Tu DNI será tu nombre de usuario para iniciar sesión.</div>
                            </div>
                            
                            <div class="row g-2">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label"><i class="bi bi-person me-1 text-muted"></i>Nombres <span class="text-danger">*</span></label>
                                    <input type="text" name="nombre" class="form-control" placeholder="Tus nombres" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label"><i class="bi bi-person me-1 text-muted"></i>Apellidos <span class="text-danger">*</span></label>
                                    <input type="text" name="apellido" class="form-control" placeholder="Tus apellidos" required>
                                </div>
                            </div>
                            
                            <div class="row g-2">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label"><i class="bi bi-telephone me-1 text-muted"></i>Teléfono</label>
                                    <input type="tel" name="telefono" class="form-control" placeholder="999 888 777">
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label"><i class="bi bi-envelope me-1 text-muted"></i>Correo Electrónico <span class="text-danger">*</span></label>
                                    <input type="email" name="email" class="form-control" placeholder="correo@ejemplo.com" required>
                                </div>
                            </div>
                            
                            <div class="mb-4">
                                <label class="form-label"><i class="bi bi-lock me-1 text-muted"></i>Contraseña <span class="text-danger">*</span></label>
                                <input type="password" name="password" class="form-control" minlength="6" placeholder="Mínimo 6 caracteres" required>
                                <div class="form-text small">Elige una contraseña segura (mín. 6 caracteres).</div>
                            </div>

                            <button type="submit" class="btn btn-registrar w-100">
                                <i class="bi bi-check-circle me-2"></i> Crear Cuenta
                            </button>
                            
                            <div class="text-center mt-3">
                                <p class="text-muted small mb-0">
                                    ¿Ya tienes cuenta? 
                                    <a href="index.jsp" class="fw-bold text-decoration-none" style="color: var(--mvb-orange);">
                                        Iniciar Sesión
                                    </a>
                                </p>
                                <a href="index.jsp" class="text-muted small text-decoration-none mt-2 d-block">
                                    <i class="bi bi-arrow-left me-1"></i> Volver a la página principal
                                </a>
                            </div>
                        </form>
                    </div>
                </div>
                
                <!-- Beneficios -->
                <div class="row g-2 mt-4">
                    <div class="col-4">
                        <div class="text-center p-3 bg-white rounded-3 shadow-sm">
                            <i class="bi bi-shield-check fs-3" style="color: var(--mvb-orange);"></i>
                            <small class="d-block mt-1 fw-semibold">Compra Segura</small>
                        </div>
                    </div>
                    <div class="col-4">
                        <div class="text-center p-3 bg-white rounded-3 shadow-sm">
                            <i class="bi bi-clock-history fs-3" style="color: var(--mvb-orange);"></i>
                            <small class="d-block mt-1 fw-semibold">Historial de Viajes</small>
                        </div>
                    </div>
                    <div class="col-4">
                        <div class="text-center p-3 bg-white rounded-3 shadow-sm">
                            <i class="bi bi-ticket-perforated fs-3" style="color: var(--mvb-orange);"></i>
                            <small class="d-block mt-1 fw-semibold">Sin Colas</small>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function validarFormulario() {
            const dni = document.querySelector('input[name="dni"]');
            const password = document.querySelector('input[name="password"]');
            if (dni.value.length !== 8 || isNaN(dni.value)) {
                alert('El DNI debe tener 8 dígitos numéricos.');
                dni.focus();
                return false;
            }
            if (password.value.length < 6) {
                alert('La contraseña debe tener al menos 6 caracteres.');
                password.focus();
                return false;
            }
            return true;
        }
    </script>
</body>
</html>