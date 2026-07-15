<%-- 
    Document   : login
    Página de inicio de sesión para el personal de MovilBus (intranet)
    Los clientes web deben usar el modal en index.jsp
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.Usuario"%>
<%
    // Si el usuario ya está logueado como CLIENTE_WEB, redirigir a ventas.jsp
    Usuario userLogin = (Usuario) session.getAttribute("usuarioSesion");
    if (userLogin != null) {
        String rolActual = userLogin.getRol();
        if ("CLIENTE_WEB".equalsIgnoreCase(rolActual)) {
            response.sendRedirect("index.jsp");
            return;
        } else if ("ADMINISTRADOR".equalsIgnoreCase(rolActual) || "VENDEDOR".equalsIgnoreCase(rolActual)) {
            response.sendRedirect("dashboard.jsp");
            return;
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>MovilBus - Intranet de Gestión</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="css/movilbus.css">
    <style>
        .login-container { max-width: 420px; }
        .acceso-restricted {
            background: #fff3cd;
            border: 1px solid #ffc107;
            border-radius: 12px;
            padding: 1rem;
        }
    </style>
</head>
<body class="login-page">

<div class="container d-flex justify-content-center">
    <div class="card login-card shadow-lg p-0 overflow-hidden">
        <div class="card-header text-center border-0 py-4" style="background: var(--gradient-primary);">
            <i class="bi bi-shield-lock fs-1 text-white"></i>
            <h3 class="fw-bold text-white mt-2 mb-0">Intranet MovilBus</h3>
            <p class="text-white-50 small mb-0">Acceso exclusivo para administradores y vendedores</p>
        </div>
        <div class="card-body p-4">
            <%-- Alerta de cuenta creada exitosamente --%>
            <% if ("success".equals(request.getParameter("registroStatus"))) { %>
                <div class="alert alert-success py-2 text-center small" role="alert">
                    <i class="bi bi-check-circle me-1"></i> <strong>¡Cuenta creada exitosamente!</strong>
                    <br>Inicia sesión con tu DNI y contraseña para acceder.
                </div>
            <% } %>

            <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-danger py-2 text-center small" role="alert">
                    <i class="bi bi-exclamation-triangle me-1"></i> <%= request.getAttribute("error") %>
                </div>
            <% } %>

            <!-- Aviso para clientes que intentan acceder -->
            <div class="acceso-restricted mb-3 text-center">
                <i class="bi bi-info-circle text-warning me-1"></i>
                <small class="fw-semibold">¿Eres cliente?</small>
                <small class="d-block text-muted mt-1">
                    Los clientes deben iniciar sesión desde 
                    <a href="index.jsp" class="text-decoration-none fw-bold" style="color: var(--mvb-orange);">MovilBus.pe</a>
                </small>
            </div>

            <form action="LoginServlet" method="POST">
                <div class="mb-3">
                    <label class="form-label"><i class="bi bi-person me-1"></i>Usuario</label>
                    <input type="text" class="form-control" id="username" name="username" placeholder="DNI o Código" required>
                </div>
                <div class="mb-4">
                    <label class="form-label"><i class="bi bi-lock me-1"></i>Contraseña</label>
                    <input type="password" class="form-control" id="password" name="password" placeholder="Ingrese su contraseña" required>
                </div>
                <button type="submit" class="btn btn-ingresar w-100 py-2 fw-bold">
                    <i class="bi bi-box-arrow-in-right me-1"></i> Ingresar al Sistema
                </button>
                <div class="text-center mt-3">
                    <a href="index.jsp" class="text-muted small text-decoration-none">
                        <i class="bi bi-arrow-left me-1"></i> Volver a la página principal
                    </a>
                </div>
            </form>
            <hr class="my-3">
            <div class="text-center">
                <small class="text-muted">
                    <i class="bi bi-shield me-1"></i>¿Olvidaste tu contraseña? Contacta al administrador.
                </small>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
