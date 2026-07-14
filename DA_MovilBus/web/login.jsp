<%-- 
    Document   : login
    Created on : 12 jul. 2026, 7:40:18 p. m.
    Author     : Risco
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>MovilBus - Iniciar Sesión</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; }
        .login-container { max-width: 400px; margin-top: 10%; }
    </style>
</head>
<body>

<div class="container d-flex justify-content-center">
    <div class="card shadow login-container p-4 w-100">
        <div class="text-center mb-4">
            <h3 class="text-primary fw-bold">MovilBus</h3>
            <p class="text-muted">Gestión de Transporte Interprovincial</p>
        </div>
        
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger p-2 text-center" role="alert" style="font-size: 0.9rem;">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <form action="LoginServlet" method="POST">
            <div class="mb-3">
                <label for="username" class="form-label">Usuario (DNI o Código)</label>
                <input type="text" class="form-control" id="username" name="username" placeholder="Ej: sa" required>
            </div>
            <div class="mb-3">
                <label for="password" class="form-label">Contraseña</label>
                <input type="password" class="form-control" id="password" name="password" placeholder="Ej: dba" required>
            </div>
            <button type="submit" class="btn btn-primary w-100 fw-bold mt-2">Ingresar al Sistema</button>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>>
