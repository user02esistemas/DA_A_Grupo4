<%-- 
    Document   : dashboard
    Created on : 12 jul. 2026, 7:40:40 p. m.
    Author     : Risco
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.Usuario"%>
<%
    // Recuperamos el objeto de la sesión para mostrar el nombre del trabajador
    Usuario user = (Usuario) session.getAttribute("usuarioSesion");
    String nombreCompleto = (user != null) ? user.getNombre() + " " + user.getApellido() : "Empleado";
    String rol = (user != null) ? user.getRol() : "S/R";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>MovilBus - Intranet Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark shadow-sm">
    <div class="container-fluid">
        <a class="navbar-brand fw-bold text-primary" href="dashboard.jsp">🚌 MovilBus Intranet</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-slide"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                <li class="nav-item">
                    <a class="nav-link active" href="dashboard.jsp">Inicio</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="buses.jsp">Módulo Buses</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="viajes.jsp">Programación de Viajes</a>
                </li>
            </ul>
            <div class="d-flex align-items-center text-light">
                <span class="me-3 badge bg-primary">Rol: <%= rol %></span>
                <span class="me-3 text-secondary">|</span>
                <span class="me-3">Bienvenido, <strong><%= nombreCompleto %></strong></span>
                <a href="login.jsp" class="btn btn-outline-danger btn-sm">Salir</a>
            </div>
        </div>
    </div>
</nav>

<div class="container mt-5">
    <div class="row">
        <div class="col-md-12">
            <div class="p-5 mb-4 bg-light rounded-3 shadow-sm border">
                <div class="container-fluid py-2">
                    <h1 class="display-5 fw-bold text-dark">Panel de Control Operativo</h1>
                    <p class="col-md-8 fs-4 text-muted">Bienvenido al núcleo de administración logística de MovilBus. Desde aquí podrás gestionar la flota de buses, asignar tripulación múltiple con control transaccional y monitorear los itinerarios.</p>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-4 mt-2">
        <div class="col-md-6">
            <div class="card h-100 shadow-sm border-start border-primary border-4">
                <div class="card-body">
                    <h5 class="card-title fw-bold">🚌 Flota de Buses</h5>
                    <p class="card-text text-muted">Registra nuevas unidades móviles y genera automáticamente su matriz estructural de asientos por pisos en la base de datos.</p>
                    <a href="buses.jsp" class="btn btn-primary btn-sm fw-bold">Gestionar Flota</a>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="card h-100 shadow-sm border-start border-success border-4">
                <div class="card-body">
                    <h5 class="card-title fw-bold">🗺️ Itinerarios y Viajes</h5>
                    <p class="card-text text-muted">Programa salidas, selecciona rutas comerciales y asigna tripulaciones con blindaje transaccional atómico.</p>
                    <a href="viajes.jsp" class="btn bg-success text-white btn-sm fw-bold">Programar Salidas</a>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 
