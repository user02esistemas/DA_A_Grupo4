<%-- Panel principal de MovilBus con acceso a todos los modulos segun el rol del usuario --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.Usuario"%>
<%
    // Control de acceso: solo ADMIN o VENDEDOR
    Usuario user = (Usuario) session.getAttribute("usuarioSesion");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String rol = user.getRol();
    if ("CLIENTE_WEB".equalsIgnoreCase(rol)) {
        response.sendRedirect("index.jsp");
        return;
    }
    String nombreCompleto = user.getNombre() + " " + user.getApellido();
    boolean esAdmin = "ADMINISTRADOR".equalsIgnoreCase(rol);
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>MovilBus - Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="css/movilbus.css">
</head>
<body class="admin-body">
    <div class="container-fluid">
        <div class="row">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="dashboard" />
                <jsp:param name="esAdmin" value="<%= String.valueOf(esAdmin) %>" />
            </jsp:include>

            <!-- Main Content -->
            <div class="col-md-10 main-content animate-fade">
                <!-- Mobile Navbar -->
                <nav class="navbar navbar-dark bg-dark rounded-3 mb-4 d-md-none p-3">
                    <span class="navbar-brand mb-0 fw-bold"><i class="bi bi-bus-front me-2"></i>MovilBus</span>
                    <div>
                        <span class="user-badge me-2">
                            <i class="bi bi-person-circle"></i> <%= nombreCompleto %>
                        </span>
                        <a href="LogoutServlet" class="btn btn-outline-danger btn-sm"><i class="bi bi-box-arrow-right"></i></a>
                    </div>
                </nav>

                <!-- Welcome Banner -->
                <div class="welcome-banner mb-4">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="user-badge mb-3">
                                <i class="bi bi-person-badge"></i> 
                                <strong><%= rol %></strong>
                            </div>
                            <h1>Bienvenido, <%= nombreCompleto %></h1>
                            <p><%= esAdmin ? 
                                "Panel de control operativo de MovilBus. Administra tu flota de buses, conductores, rutas y programa viajes desde un solo lugar." :
                                "Panel de ventas de MovilBus. Vende pasajes y consulta el historial de ventas de forma rápida y segura." %></p>
                        </div>
                    </div>
                </div>

                <!-- Module Cards Grid -->
                <div class="row g-4">
                    <% if (esAdmin) { %>
                        <!-- Conductores -->
                        <div class="col-xl-4 col-md-6">
                            <div class="card card-modulo shadow-sm h-100 border-start border-4 border-primary">
                                <div class="card-body">
                                    <div class="icon-wrapper bg-primary bg-opacity-10 text-primary">
                                        <i class="bi bi-people"></i>
                                    </div>
                                    <h5 class="card-title">Conductores</h5>
                                    <p class="card-text">Gestión completa del personal de conducción.</p>
                                    <a href="conductores.jsp" class="btn btn-outline-primary btn-modulo">
                                        <i class="bi bi-arrow-right me-1"></i> Ir al Módulo
                                    </a>
                                </div>
                            </div>
                        </div>

                        <!-- Vendedores -->
                        <div class="col-xl-4 col-md-6">
                            <div class="card card-modulo shadow-sm h-100 border-start border-4 border-warning">
                                <div class="card-body">
                                    <div class="icon-wrapper bg-warning bg-opacity-10 text-warning">
                                        <i class="bi bi-person-badge"></i>
                                    </div>
                                    <h5 class="card-title">Vendedores</h5>
                                    <p class="card-text">Registra y administra al personal de ventas de la empresa.</p>
                                    <a href="vendedores.jsp" class="btn btn-outline-warning btn-modulo">
                                        <i class="bi bi-arrow-right me-1"></i> Ir al Módulo
                                    </a>
                                </div>
                            </div>
                        </div>

                        <!-- Buses -->
                        <div class="col-xl-4 col-md-6">
                            <div class="card card-modulo shadow-sm h-100 border-start border-4 border-success">
                                <div class="card-body">
                                    <div class="icon-wrapper bg-success bg-opacity-10 text-success">
                                        <i class="bi bi-truck"></i>
                                    </div>
                                    <h5 class="card-title">Buses</h5>
                                    <p class="card-text">Registra nuevas unidades con generación automática de asientos.</p>
                                    <a href="buses.jsp" class="btn btn-outline-success btn-modulo">
                                        <i class="bi bi-arrow-right me-1"></i> Ir al Módulo
                                    </a>
                                </div>
                            </div>
                        </div>

                        <!-- Ciudades -->
                        <div class="col-xl-4 col-md-6">
                            <div class="card card-modulo shadow-sm h-100 border-start border-4 border-warning">
                                <div class="card-body">
                                    <div class="icon-wrapper bg-warning bg-opacity-10 text-warning">
                                        <i class="bi bi-geo-alt"></i>
                                    </div>
                                    <h5 class="card-title">Ciudades</h5>
                                    <p class="card-text">Administra el directorio de ciudades y departamentos.</p>
                                    <a href="ciudades.jsp" class="btn btn-outline-warning btn-modulo">
                                        <i class="bi bi-arrow-right me-1"></i> Ir al Módulo
                                    </a>
                                </div>
                            </div>
                        </div>

                        <!-- Rutas -->
                        <div class="col-xl-4 col-md-6">
                            <div class="card card-modulo shadow-sm h-100 border-start border-4 border-info">
                                <div class="card-body">
                                    <div class="icon-wrapper bg-info bg-opacity-10 text-info">
                                        <i class="bi bi-signpost-2"></i>
                                    </div>
                                    <h5 class="card-title">Rutas</h5>
                                    <p class="card-text">Define rutas comerciales con tarifas base.</p>
                                    <a href="rutas.jsp" class="btn btn-outline-info btn-modulo">
                                        <i class="bi bi-arrow-right me-1"></i> Ir al Módulo
                                    </a>
                                </div>
                            </div>
                        </div>

                        <!-- Viajes -->
                        <div class="col-xl-4 col-md-6">
                            <div class="card card-modulo shadow-sm h-100 border-start border-4 border-secondary">
                                <div class="card-body">
                                    <div class="icon-wrapper bg-secondary bg-opacity-10 text-secondary">
                                        <i class="bi bi-calendar-event"></i>
                                    </div>
                                    <h5 class="card-title">Viajes</h5>
                                    <p class="card-text">Programación de viajes con asignación de tripulación.</p>
                                    <a href="viajes.jsp" class="btn btn-outline-secondary btn-modulo">
                                        <i class="bi bi-arrow-right me-1"></i> Ir al Módulo
                                    </a>
                                </div>
                            </div>
                        </div>
                    <% } %>

                    <!-- Ventas (visible para todos: ADMIN y VENDEDOR) -->
                    <div class="col-xl-4 col-md-6">
                        <div class="card card-modulo shadow-sm h-100 border-start border-4 border-danger">
                            <div class="card-body">
                                <div class="icon-wrapper bg-danger bg-opacity-10 text-danger">
                                    <i class="bi bi-ticket-perforated"></i>
                                </div>
                                <h5 class="card-title">Vender Pasaje</h5>
                                <p class="card-text">Venta de pasajes con selección interactiva de asientos.</p>
                                <a href="ventas.jsp" class="btn btn-outline-danger btn-modulo">
                                    <i class="bi bi-arrow-right me-1"></i> Ir al Módulo
                                </a>
                            </div>
                        </div>
                    </div>

                    <!-- Historial (visible para todos: ADMIN y VENDEDOR) -->
                    <div class="col-xl-4 col-md-6">
                        <div class="card card-modulo shadow-sm h-100 border-start border-4 border-primary">
                            <div class="card-body">
                                <div class="icon-wrapper bg-primary bg-opacity-10 text-primary">
                                    <i class="bi bi-clock-history"></i>
                                </div>
                                <h5 class="card-title">Historial de Ventas</h5>
                                <p class="card-text">Consulta todas las ventas de pasajes realizadas.</p>
                                <a href="VentaServlet?accion=historial" class="btn btn-outline-primary btn-modulo">
                                    <i class="bi bi-arrow-right me-1"></i> Ir al Módulo
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
