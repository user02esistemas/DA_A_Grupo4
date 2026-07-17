<%-- Panel principal de MovilBus - Dashboard Operativo con KPIs, graficos y alertas --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="dao.DashboardDAO, java.util.Map, java.util.List, java.text.SimpleDateFormat, java.util.Date, model.Usuario"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
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
    
    // Cargar datos del Dashboard
    DashboardDAO dashDAO = new DashboardDAO();
    
    int viajesHoy = dashDAO.contarViajesHoy();
    int pasajesHoy = dashDAO.contarPasajesHoy();
    double ingresosHoy = dashDAO.sumarIngresosHoy();
    double ocupacion = dashDAO.calcularOcupacionPromedio();
    int encomiendasPend = dashDAO.contarEncomiendasPendientes();
    int conductoresDisp = dashDAO.contarConductoresDisponibles();
    int viajesMes = dashDAO.contarViajesDelMes();
    int pasajerosMes = dashDAO.contarPasajerosDelMes();
    int busesActivos = dashDAO.contarBusesActivos();
    
    List<Map<String, Object>> viajesDelDia = dashDAO.listarViajesDelDia();
    List<Map<String, Object>> ingresos30d = dashDAO.obtenerIngresosUltimos30Dias();
    List<Map<String, String>> alertas = dashDAO.obtenerAlertas();
    
    request.setAttribute("viajesHoy", viajesHoy);
    request.setAttribute("pasajesHoy", pasajesHoy);
    request.setAttribute("ingresosHoy", ingresosHoy);
    request.setAttribute("ocupacion", ocupacion);
    request.setAttribute("encomiendasPend", encomiendasPend);
    request.setAttribute("conductoresDisp", conductoresDisp);
    request.setAttribute("viajesMes", viajesMes);
    request.setAttribute("pasajerosMes", pasajerosMes);
    request.setAttribute("busesActivos", busesActivos);
    request.setAttribute("viajesDelDia", viajesDelDia);
    request.setAttribute("ingresos30d", ingresos30d);
    request.setAttribute("alertas", alertas);
    
    SimpleDateFormat sdf = new SimpleDateFormat("EEEE, d 'de' MMMM 'del' yyyy");
    String fechaHoy = sdf.format(new java.util.Date());
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>MovilBus - Dashboard Operativo</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="css/movilbus.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <style>
        /* Dashboard KPI Cards */
        .kpi-card {
            border: none;
            border-radius: 16px;
            padding: 1.2rem 1.5rem;
            transition: all .3s ease;
            position: relative;
            overflow: hidden;
            background: white;
            box-shadow: 0 2px 12px rgba(0,0,0,.06);
            height: 100%;
        }
        .kpi-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 25px rgba(0,0,0,.1);
        }
        .kpi-card .kpi-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.4rem;
            margin-bottom: .8rem;
        }
        .kpi-card .kpi-value {
            font-size: 1.8rem;
            font-weight: 800;
            line-height: 1.2;
        }
        .kpi-card .kpi-label {
            font-size: .8rem;
            color: var(--mvb-text-light);
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: .3px;
        }
        .kpi-card .kpi-trend {
            font-size: .75rem;
            font-weight: 600;
            margin-top: .3rem;
        }
        .kpi-card .kpi-bg-icon {
            position: absolute;
            right: -10px;
            bottom: -10px;
            font-size: 5rem;
            opacity: .06;
            pointer-events: none;
        }
        
        /* Viajes del dia */
        .viaje-row {
            transition: all .2s;
            border-radius: 12px;
        }
        .viaje-row:hover {
            background: var(--mvb-orange-light);
        }
        .ocupacion-bar {
            height: 6px;
            border-radius: 3px;
            background: #e9ecef;
            overflow: hidden;
        }
        .ocupacion-bar-fill {
            height: 100%;
            border-radius: 3px;
            transition: width .8s ease;
        }
        
        /* Alertas */
        .alerta-item {
            border-radius: 12px;
            padding: .8rem 1rem;
            transition: all .2s;
            border-left: 4px solid transparent;
        }
        .alerta-item:hover {
            background: #f8f9fa;
        }
        
        /* Chart container */
        .chart-container {
            position: relative;
            height: 250px;
        }
    </style>
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
                            <div class="d-flex gap-2 mb-2">
                                <span class="user-badge">
                                    <i class="bi bi-person-badge"></i> 
                                    <strong><%= rol %></strong>
                                </span>
                                <span class="user-badge">
                                    <i class="bi bi-calendar3"></i> 
                                    <%= fechaHoy.substring(0,1).toUpperCase() + fechaHoy.substring(1) %>
                                </span>
                            </div>
                            <h1>Bienvenido, <%= nombreCompleto %></h1>
                            <p><%= esAdmin ? 
                                "Panel de control operativo de MovilBus. Monitorea en tiempo real el estado de tu flota." :
                                "Panel de ventas de MovilBus. Vende pasajes y consulta el historial de forma rapida." %></p>
                        </div>
                    </div>
                </div>

                <!-- ================================================================
                     KPI CARDS ROW
                     ================================================================ -->
                <div class="row g-3 mb-4">
                    <!-- Viajes Hoy -->
                    <div class="col-xl-2 col-md-4 col-6">
                        <div class="kpi-card">
                            <div class="kpi-icon" style="background: rgba(13,110,253,.1); color: #0d6efd;">
                                <i class="bi bi-bus-front"></i>
                            </div>
                            <div class="kpi-value" style="color: #0d6efd;">${viajesHoy}</div>
                            <div class="kpi-label">Viajes Hoy</div>
                            <div class="kpi-trend" style="color: #6c757d;">
                                <i class="bi bi-calendar-week me-1"></i>${viajesMes} este mes
                            </div>
                            <div class="kpi-bg-icon"><i class="bi bi-bus-front"></i></div>
                        </div>
                    </div>
                    <!-- Pasajes Vendidos -->
                    <div class="col-xl-2 col-md-4 col-6">
                        <div class="kpi-card">
                            <div class="kpi-icon" style="background: rgba(25,135,84,.1); color: #198754;">
                                <i class="bi bi-ticket-perforated"></i>
                            </div>
                            <div class="kpi-value" style="color: #198754;">${pasajesHoy}</div>
                            <div class="kpi-label">Pasajes Hoy</div>
                            <div class="kpi-trend" style="color: #6c757d;">
                                <i class="bi bi-people me-1"></i>${pasajerosMes} pasajeros mes
                            </div>
                            <div class="kpi-bg-icon"><i class="bi bi-ticket-perforated"></i></div>
                        </div>
                    </div>
                    <!-- Ingresos -->
                    <div class="col-xl-2 col-md-4 col-6">
                        <div class="kpi-card">
                            <div class="kpi-icon" style="background: rgba(255,107,0,.1); color: var(--mvb-orange);">
                                <i class="bi bi-currency-dollar"></i>
                            </div>
                            <div class="kpi-value" style="color: var(--mvb-orange);">
                                S/ <fmt:formatNumber value="${ingresosHoy}" pattern="#,##0.00"/>
                            </div>
                            <div class="kpi-label">Ingresos Hoy</div>
                            <div class="kpi-trend" style="color: #6c757d;">
                                <i class="bi bi-graph-up me-1"></i>Ultimos 30 dias
                            </div>
                            <div class="kpi-bg-icon"><i class="bi bi-currency-dollar"></i></div>
                        </div>
                    </div>
                    <!-- Ocupacion -->
                    <div class="col-xl-2 col-md-4 col-6">
                        <div class="kpi-card">
                            <div class="kpi-icon" style="background: rgba(111,66,193,.1); color: #6f42c1;">
                                <i class="bi bi-bar-chart-fill"></i>
                            </div>
                            <div class="kpi-value" style="color: #6f42c1;">
                                <fmt:formatNumber value="${ocupacion}" pattern="#0.0"/>%
                            </div>
                            <div class="kpi-label">Ocupacion</div>
                            <div class="kpi-trend" style="color: #6c757d;">
                                <i class="bi bi-seat me-1"></i>Promedio flota
                            </div>
                            <div class="kpi-bg-icon"><i class="bi bi-bar-chart-fill"></i></div>
                        </div>
                    </div>
                    <!-- Encomiendas Pendientes -->
                    <div class="col-xl-2 col-md-4 col-6">
                        <div class="kpi-card">
                            <div class="kpi-icon" style="background: rgba(255,193,7,.15); color: #dc8a00;">
                                <i class="bi bi-box-seam"></i>
                            </div>
                            <div class="kpi-value" style="color: #dc8a00;">${encomiendasPend}</div>
                            <div class="kpi-label">Encomiendas Pend.</div>
                            <div class="kpi-trend" style="color: #6c757d;">
                                <i class="bi bi-clock me-1"></i>Por entregar
                            </div>
                            <div class="kpi-bg-icon"><i class="bi bi-box-seam"></i></div>
                        </div>
                    </div>
                    <!-- Conductores Disponibles -->
                    <div class="col-xl-2 col-md-4 col-6">
                        <div class="kpi-card">
                            <div class="kpi-icon" style="background: rgba(23,162,184,.1); color: #17a2b8;">
                                <i class="bi bi-people"></i>
                            </div>
                            <div class="kpi-value" style="color: #17a2b8;">${conductoresDisp}</div>
                            <div class="kpi-label">Conductores Disp.</div>
                            <div class="kpi-trend" style="color: #6c757d;">
                                <i class="bi bi-truck me-1"></i>${busesActivos} buses activos
                            </div>
                            <div class="kpi-bg-icon"><i class="bi bi-people"></i></div>
                        </div>
                    </div>
                </div>

                <!-- ================================================================
                     MIDDLE ROW: PROXIMOS VIAJES + GRAFICO
                     ================================================================ -->
                <div class="row g-4 mb-4">
                    <!-- Proximos Viajes -->
                    <div class="col-lg-7">
                        <div class="card card-custom h-100">
                            <div class="card-body p-4">
                                <div class="d-flex align-items-center justify-content-between mb-3">
                                    <h5 class="fw-bold mb-0">
                                        <i class="bi bi-clock-history text-primary me-2"></i>Proximos Viajes - Hoy
                                    </h5>
                                    <span class="badge bg-primary rounded-pill">${viajesDelDia.size()} viaje(s)</span>
                                </div>
                                
                                <c:choose>
                                    <c:when test="${empty viajesDelDia}">
                                        <div class="text-center py-5">
                                            <i class="bi bi-calendar-check text-muted" style="font-size: 3rem;"></i>
                                            <p class="text-muted mt-2">No hay viajes programados para hoy.</p>
                                            <a href="viajes.jsp" class="btn btn-outline-primary btn-sm rounded-pill">
                                                <i class="bi bi-plus-circle me-1"></i> Programar viaje
                                            </a>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="table-responsive">
                                            <table class="table table-hover align-middle mb-0">
                                                <thead>
                                                    <tr>
                                                        <th>Hora</th>
                                                        <th>Ruta</th>
                                                        <th>Bus</th>
                                                        <th>Servicio</th>
                                                        <th class="text-center">Ocupacion</th>
                                                        <th class="text-center">Estado</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach var="v" items="${viajesDelDia}">
                                                        <tr class="viaje-row">
                                                            <td>
                                                                <strong>${v.fechaHora}</strong>
                                                                <small class="text-muted d-block">${v.fechaLlegada}</small>
                                                            </td>
                                                            <td>
                                                                <span class="fw-semibold small">
                                                                    <i class="bi bi-geo-alt-fill text-success me-1"></i>${v.origen}
                                                                    <i class="bi bi-arrow-right mx-1"></i>
                                                                    <i class="bi bi-geo-alt-fill text-danger me-1"></i>${v.destino}
                                                                </span>
                                                            </td>
                                                            <td><span class="badge bg-dark">${v.placa}</span></td>
                                                            <td><span class="badge bg-info">${v.servicio}</span></td>
                                                            <td class="text-center" style="min-width: 120px;">
                                                                <%
                                                                    Map<String, Object> vv = (Map<String, Object>) pageContext.getAttribute("v");
                                                                    int ocup = (int) vv.get("ocupados");
                                                                    int cap = (int) vv.get("capacidad");
                                                                    double pct = cap > 0 ? (double) ocup / cap * 100 : 0;
                                                                    String color = pct >= 80 ? "#198754" : (pct >= 50 ? "#FFC107" : "#dc3545");
                                                                %>
                                                                <small><%= ocup %>/<%= cap %></small>
                                                                <div class="ocupacion-bar mt-1">
                                                                    <div class="ocupacion-bar-fill" style="width:<%= pct %>% !important; background:<%= color %>;"></div>
                                                                </div>
                                                            </td>
                                                            <td class="text-center">
                                                                <c:choose>
                                                                    <c:when test="${v.estado == 'PROGRAMADO'}">
                                                                        <span class="badge bg-primary">PROGRAMADO</span>
                                                                    </c:when>
                                                                    <c:when test="${v.estado == 'EN_RUTA'}">
                                                                        <span class="badge bg-success">EN RUTA</span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="badge bg-secondary">${v.estado}</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                                <div class="mt-3 text-end">
                                    <a href="viajes.jsp" class="btn btn-sm btn-outline-primary rounded-pill">
                                        <i class="bi bi-calendar-event me-1"></i> Gestionar Viajes
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Grafico de Ingresos -->
                    <div class="col-lg-5">
                        <div class="card card-custom h-100">
                            <div class="card-body p-4">
                                <div class="d-flex align-items-center mb-3">
                                    <i class="bi bi-graph-up-arrow text-success fs-4 me-2"></i>
                                    <h5 class="fw-bold mb-0">Ingresos Ultimos 30 Dias</h5>
                                </div>
                                <div class="chart-container">
                                    <canvas id="chartIngresos"></canvas>
                                </div>
                                <div class="text-center mt-3">
                                    <small class="text-muted">
                                        <i class="bi bi-currency-dollar me-1"></i>
                                        Total 30 dias: 
                                        <strong style="color: var(--mvb-orange);">
                                            S/ 
                                            <c:set var="total30d" value="0"/>
                                            <c:forEach var="r" items="${ingresos30d}">
                                                <c:set var="total30d" value="${total30d + r.total}"/>
                                            </c:forEach>
                                            <fmt:formatNumber value="${total30d}" pattern="#,##0.00"/>
                                        </strong>
                                    </small>
                                </div>
                                <div class="mt-3 text-end">
                                    <a href="VentaServlet?accion=historial" class="btn btn-sm btn-outline-success rounded-pill">
                                        <i class="bi bi-clock-history me-1"></i> Ver Historial
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ================================================================
                     ALERTAS OPERATIVAS
                     ================================================================ -->
                <div class="card card-custom mb-4">
                    <div class="card-body p-4">
                        <div class="d-flex align-items-center mb-3">
                            <i class="bi bi-bell fs-4 text-warning me-2"></i>
                            <h5 class="fw-bold mb-0">Alertas Operativas</h5>
                            <span class="ms-auto badge bg-warning text-dark rounded-pill">${alertas.size()}</span>
                        </div>
                        <div class="row g-2">
                            <c:forEach var="a" items="${alertas}">
                                <div class="col-md-6">
                                    <div class="alerta-item d-flex align-items-center gap-3 
                                        <c:choose>
                                            <c:when test="${a.tipo == 'danger'}">bg-danger bg-opacity-10 border-danger</c:when>
                                            <c:when test="${a.tipo == 'warning'}">bg-warning bg-opacity-10 border-warning</c:when>
                                            <c:when test="${a.tipo == 'success'}">bg-success bg-opacity-10 border-success</c:when>
                                            <c:otherwise>bg-info bg-opacity-10 border-info</c:otherwise>
                                        </c:choose>"
                                        style="border-left-color: 
                                        <c:choose>
                                            <c:when test="${a.tipo == 'danger'}">#dc3545</c:when>
                                            <c:when test="${a.tipo == 'warning'}">#ffc107</c:when>
                                            <c:when test="${a.tipo == 'success'}">#198754</c:when>
                                            <c:otherwise>#0dcaf0</c:otherwise>
                                        </c:choose> !important;">
                                        <i class="bi ${a.icono} fs-4 
                                        <c:choose>
                                            <c:when test="${a.tipo == 'danger'}">text-danger</c:when>
                                            <c:when test="${a.tipo == 'warning'}">text-warning</c:when>
                                            <c:when test="${a.tipo == 'success'}">text-success</c:when>
                                            <c:otherwise>text-info</c:otherwise>
                                        </c:choose>"></i>
                                        <div class="flex-grow-1">
                                            <div class="small fw-bold">${a.mensaje}</div>
                                            <small class="text-muted">Severidad: ${a.severidad}</small>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </div>

                <!-- ================================================================
                     MODULE NAVIGATION CARDS (seccion inferior)
                     ================================================================ -->
                <div class="row g-4">
                    <div class="col-12">
                        <div class="d-flex align-items-center mb-3">
                            <i class="bi bi-grid-3x3-gap fs-5 text-muted me-2"></i>
                            <h5 class="fw-bold mb-0">Acceso Rapido a Modulos</h5>
                        </div>
                    </div>
                    
                    <% if (esAdmin) { %>
                        <!-- Conductores -->
                        <div class="col-xl-3 col-md-6">
                            <div class="card card-modulo shadow-sm h-100 border-start border-4 border-primary">
                                <div class="card-body">
                                    <div class="icon-wrapper bg-primary bg-opacity-10 text-primary">
                                        <i class="bi bi-people"></i>
                                    </div>
                                    <h5 class="card-title">Conductores</h5>
                                    <p class="card-text">Gestion completa del personal de conduccion.</p>
                                    <a href="conductores.jsp" class="btn btn-outline-primary btn-modulo">
                                        <i class="bi bi-arrow-right me-1"></i> Ir al Modulo
                                    </a>
                                </div>
                            </div>
                        </div>

                        <!-- Vendedores -->
                        <div class="col-xl-3 col-md-6">
                            <div class="card card-modulo shadow-sm h-100 border-start border-4 border-warning">
                                <div class="card-body">
                                    <div class="icon-wrapper bg-warning bg-opacity-10 text-warning">
                                        <i class="bi bi-person-badge"></i>
                                    </div>
                                    <h5 class="card-title">Vendedores</h5>
                                    <p class="card-text">Registra y administra al personal de ventas.</p>
                                    <a href="vendedores.jsp" class="btn btn-outline-warning btn-modulo">
                                        <i class="bi bi-arrow-right me-1"></i> Ir al Modulo
                                    </a>
                                </div>
                            </div>
                        </div>

                        <!-- Buses -->
                        <div class="col-xl-3 col-md-6">
                            <div class="card card-modulo shadow-sm h-100 border-start border-4 border-success">
                                <div class="card-body">
                                    <div class="icon-wrapper bg-success bg-opacity-10 text-success">
                                        <i class="bi bi-truck"></i>
                                    </div>
                                    <h5 class="card-title">Buses</h5>
                                    <p class="card-text">Registra nuevas unidades con generacion de asientos.</p>
                                    <a href="buses.jsp" class="btn btn-outline-success btn-modulo">
                                        <i class="bi bi-arrow-right me-1"></i> Ir al Modulo
                                    </a>
                                </div>
                            </div>
                        </div>

                        <!-- Ciudades -->
                        <div class="col-xl-3 col-md-6">
                            <div class="card card-modulo shadow-sm h-100 border-start border-4 border-warning">
                                <div class="card-body">
                                    <div class="icon-wrapper bg-warning bg-opacity-10 text-warning">
                                        <i class="bi bi-geo-alt"></i>
                                    </div>
                                    <h5 class="card-title">Ciudades</h5>
                                    <p class="card-text">Administra el directorio de ciudades.</p>
                                    <a href="ciudades.jsp" class="btn btn-outline-warning btn-modulo">
                                        <i class="bi bi-arrow-right me-1"></i> Ir al Modulo
                                    </a>
                                </div>
                            </div>
                        </div>

                        <!-- Rutas -->
                        <div class="col-xl-3 col-md-6">
                            <div class="card card-modulo shadow-sm h-100 border-start border-4 border-info">
                                <div class="card-body">
                                    <div class="icon-wrapper bg-info bg-opacity-10 text-info">
                                        <i class="bi bi-signpost-2"></i>
                                    </div>
                                    <h5 class="card-title">Rutas</h5>
                                    <p class="card-text">Define rutas comerciales con tarifas base.</p>
                                    <a href="rutas.jsp" class="btn btn-outline-info btn-modulo">
                                        <i class="bi bi-arrow-right me-1"></i> Ir al Modulo
                                    </a>
                                </div>
                            </div>
                        </div>

                        <!-- Viajes -->
                        <div class="col-xl-3 col-md-6">
                            <div class="card card-modulo shadow-sm h-100 border-start border-4 border-secondary">
                                <div class="card-body">
                                    <div class="icon-wrapper bg-secondary bg-opacity-10 text-secondary">
                                        <i class="bi bi-calendar-event"></i>
                                    </div>
                                    <h5 class="card-title">Viajes</h5>
                                    <p class="card-text">Programacion de viajes con asignacion de tripulacion.</p>
                                    <a href="viajes.jsp" class="btn btn-outline-secondary btn-modulo">
                                        <i class="bi bi-arrow-right me-1"></i> Ir al Modulo
                                    </a>
                                </div>
                            </div>
                        </div>
                    <% } %>

                    <!-- Ventas -->
                    <div class="col-xl-3 col-md-6">
                        <div class="card card-modulo shadow-sm h-100 border-start border-4 border-danger">
                            <div class="card-body">
                                <div class="icon-wrapper bg-danger bg-opacity-10 text-danger">
                                    <i class="bi bi-ticket-perforated"></i>
                                </div>
                                <h5 class="card-title">Vender Pasaje</h5>
                                <p class="card-text">Venta de pasajes con seleccion interactiva de asientos.</p>
                                <a href="ventas.jsp" class="btn btn-outline-danger btn-modulo">
                                    <i class="bi bi-arrow-right me-1"></i> Ir al Modulo
                                </a>
                            </div>
                        </div>
                    </div>

                    <!-- Historial -->
                    <div class="col-xl-3 col-md-6">
                        <div class="card card-modulo shadow-sm h-100 border-start border-4 border-primary">
                            <div class="card-body">
                                <div class="icon-wrapper bg-primary bg-opacity-10 text-primary">
                                    <i class="bi bi-clock-history"></i>
                                </div>
                                <h5 class="card-title">Historial de Ventas</h5>
                                <p class="card-text">Consulta todas las ventas de pasajes realizadas.</p>
                                <a href="VentaServlet?accion=historial" class="btn btn-outline-primary btn-modulo">
                                    <i class="bi bi-arrow-right me-1"></i> Ir al Modulo
                                </a>
                            </div>
                        </div>
                    </div>

                    <!-- Encomiendas -->
                    <div class="col-xl-3 col-md-6">
                        <div class="card card-modulo shadow-sm h-100 border-start border-4 border-warning">
                            <div class="card-body">
                                <div class="icon-wrapper bg-warning bg-opacity-10 text-warning">
                                    <i class="bi bi-box-seam"></i>
                                </div>
                                <h5 class="card-title">Encomiendas</h5>
                                <p class="card-text">Registro y seguimiento de envios de paquetes.</p>
                                <a href="EncomiendaServlet?accion=listar" class="btn btn-outline-warning btn-modulo">
                                    <i class="bi bi-arrow-right me-1"></i> Ir al Modulo
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
    // ============================================================
    // GRAFICO DE INGRESOS (Chart.js)
    // ============================================================
    document.addEventListener('DOMContentLoaded', function() {
        const ctx = document.getElementById('chartIngresos');
        if (!ctx) return;
        
        const labels = [];
        const data = [];
        
        <c:forEach var="r" items="${ingresos30d}">
            labels.push('${r.fecha}');
            data.push(${r.total});
        </c:forEach>
        
        // Si no hay datos, mostrar mensaje
        if (labels.length === 0) {
            ctx.parentElement.innerHTML = '<div class="text-center py-5"><i class="bi bi-graph-up text-muted" style="font-size: 3rem;"></i><p class="text-muted mt-2">No hay datos de ingresos en los ultimos 30 dias.</p></div>';
            return;
        }
        
        // Formatear fechas a dd/MM
        const shortLabels = labels.map(function(d) {
            const parts = d.split('-');
            return parts[2] + '/' + parts[1];
        });
        
        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: shortLabels,
                datasets: [{
                    label: 'Ingresos (S/)',
                    data: data,
                    backgroundColor: 'rgba(255, 107, 0, 0.7)',
                    borderColor: 'rgba(255, 107, 0, 1)',
                    borderWidth: 2,
                    borderRadius: 4,
                    barPercentage: 0.7,
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        backgroundColor: '#1A1A2E',
                        titleColor: '#fff',
                        bodyColor: '#fff',
                        callbacks: {
                            label: function(context) {
                                return 'S/ ' + context.parsed.y.toFixed(2);
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: { color: 'rgba(0,0,0,.05)' },
                        ticks: {
                            callback: function(value) { return 'S/ ' + value.toFixed(0); }
                        }
                    },
                    x: {
                        grid: { display: false },
                        ticks: { font: { size: 10 } }
                    }
                }
            }
        });
    });
    </script>
</body>
</html>
