<%-- Modulo de Reportes con filtros y exportacion CSV --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@page import="model.Usuario, dao.RutaDAO, dao.UsuarioDAO, java.util.List, java.util.Map"%>
<%
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
    boolean esAdmin = "ADMINISTRADOR".equalsIgnoreCase(rol);
    
    // Cargar datos para filtros si no vienen del servlet
    if (request.getAttribute("listaRutas") == null) {
        RutaDAO rutaDAO = new RutaDAO();
        UsuarioDAO userDAO = new UsuarioDAO();
        request.setAttribute("listaRutas", rutaDAO.listarRutas());
        request.setAttribute("listaVendedores", userDAO.listarVendedores());
    }
    
    String tipoReporte = (String) request.getAttribute("tipoReporte");
    if (tipoReporte == null) tipoReporte = "ventas";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>MovilBus - Reportes</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="css/movilbus.css">
    <style>
        .report-tab { cursor: pointer; }
        .stat-card {
            border-radius: 12px;
            padding: 1rem;
            text-align: center;
            background: white;
            box-shadow: 0 2px 8px rgba(0,0,0,.05);
        }
        .stat-card .stat-value { font-size: 1.5rem; font-weight: 800; }
        .stat-card .stat-label { font-size: .75rem; color: var(--mvb-text-light); text-transform: uppercase; }
    </style>
</head>
<body class="admin-body">
    <div class="container-fluid">
        <div class="row">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="reportes" />
                <jsp:param name="esAdmin" value="<%= String.valueOf(esAdmin) %>" />
            </jsp:include>

            <div class="col-md-10 main-content animate-fade">
                <nav class="navbar navbar-dark bg-dark rounded-3 mb-4 d-md-none p-3">
                    <span class="navbar-brand mb-0 fw-bold"><i class="bi bi-bus-front me-2"></i>MovilBus</span>
                    <div>
                        <a href="dashboard.jsp" class="btn btn-outline-light btn-sm me-1"><i class="bi bi-speedometer2"></i></a>
                        <a href="LogoutServlet" class="btn btn-outline-danger btn-sm"><i class="bi bi-box-arrow-right"></i></a>
                    </div>
                </nav>

                <!-- Page Header -->
                <div class="d-flex justify-content-between align-items-start mb-4">
                    <div>
                        <h1 class="page-title">
                            <i class="bi bi-file-earmark-bar-graph text-success me-2"></i> Reportes
                            <small>Genera reportes exportables con filtros avanzados</small>
                        </h1>
                    </div>
                </div>

                <!-- Tabs: Ventas | Viajes | Encomiendas -->
                <ul class="nav nav-tabs mb-4" id="reportTabs">
                    <li class="nav-item">
                        <a class="nav-link ${tipoReporte == 'ventas' ? 'active' : ''}" 
                           href="ReporteServlet?accion=ventas">
                           <i class="bi bi-ticket-perforated me-1"></i> Ventas
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link ${tipoReporte == 'viajes' ? 'active' : ''}" 
                           href="ReporteServlet?accion=viajes">
                           <i class="bi bi-bus-front me-1"></i> Viajes
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link ${tipoReporte == 'encomiendas' ? 'active' : ''}" 
                           href="ReporteServlet?accion=encomiendas">
                           <i class="bi bi-box-seam me-1"></i> Encomiendas
                        </a>
                    </li>
                </ul>

                <!-- Filtros -->
                <div class="card card-custom p-4 mb-4">
                    <div class="d-flex align-items-center mb-3">
                        <i class="bi bi-funnel fs-4 text-primary me-2"></i>
                        <h5 class="fw-bold mb-0">Filtros</h5>
                    </div>
                    <form action="ReporteServlet" method="GET" class="row g-3">
                        <input type="hidden" name="accion" value="${tipoReporte}">
                        
                        <div class="col-md-3">
                            <label class="form-label">Fecha Desde</label>
                            <input type="date" class="form-control" name="fechaDesde" value="${fechaDesde}">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Fecha Hasta</label>
                            <input type="date" class="form-control" name="fechaHasta" value="${fechaHasta}">
                        </div>
                        
                        <c:if test="${tipoReporte == 'ventas' or tipoReporte == 'viajes'}">
                        <div class="col-md-3">
                            <label class="form-label">Ruta</label>
                            <select class="form-select" name="idRuta">
                                <option value="">Todas las rutas</option>
                                <c:forEach var="r" items="${listaRutas}">
                                    <option value="${r.idRuta}" ${idRutaSel == r.idRuta ? 'selected' : ''}>
                                        ${r.origen} → ${r.destino}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        </c:if>
                        
                        <c:if test="${tipoReporte == 'ventas'}">
                        <div class="col-md-3">
                            <label class="form-label">Vendedor</label>
                            <select class="form-select" name="idVendedor">
                                <option value="">Todos los vendedores</option>
                                <c:forEach var="v" items="${listaVendedores}">
                                    <option value="${v.idUsuario}" ${idVendedorSel == v.idUsuario ? 'selected' : ''}>
                                        ${v.nombre} ${v.apellido}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        </c:if>
                        
                        <c:if test="${tipoReporte == 'viajes' or tipoReporte == 'encomiendas'}">
                        <div class="col-md-3">
                            <label class="form-label">Estado</label>
                            <select class="form-select" name="estado">
                                <option value="">Todos los estados</option>
                                <c:if test="${tipoReporte == 'viajes'}">
                                    <option value="PROGRAMADO" ${estadoSel == 'PROGRAMADO' ? 'selected' : ''}>Programado</option>
                                    <option value="EN_RUTA" ${estadoSel == 'EN_RUTA' ? 'selected' : ''}>En Ruta</option>
                                    <option value="FINALIZADO" ${estadoSel == 'FINALIZADO' ? 'selected' : ''}>Finalizado</option>
                                    <option value="CANCELADO" ${estadoSel == 'CANCELADO' ? 'selected' : ''}>Cancelado</option>
                                </c:if>
                                <c:if test="${tipoReporte == 'encomiendas'}">
                                    <option value="REGISTRADO" ${estadoSel == 'REGISTRADO' ? 'selected' : ''}>Registrado</option>
                                    <option value="EN VIAJE" ${estadoSel == 'EN VIAJE' ? 'selected' : ''}>En Viaje</option>
                                    <option value="ENTREGADO" ${estadoSel == 'ENTREGADO' ? 'selected' : ''}>Entregado</option>
                                </c:if>
                            </select>
                        </div>
                        </c:if>
                        
                        <c:if test="${tipoReporte == 'encomiendas'}">
                        <div class="col-md-3">
                            <label class="form-label">&nbsp;</label>
                            <div></div>
                        </div>
                        </c:if>
                        
                        <div class="col-12 d-flex gap-2">
                            <button type="submit" class="btn btn-ingresar rounded-pill px-4">
                                <i class="bi bi-search me-1"></i> Generar Reporte
                            </button>
                            <c:if test="${not empty resultados}">
                                <a href="ReporteServlet?accion=exportarCSV&tipo=${tipoReporte}&fechaDesde=${fechaDesde}&fechaHasta=${fechaHasta}&idVendedor=${idVendedorSel}&idRuta=${idRutaSel}&estado=${estadoSel}" 
                                   class="btn btn-success rounded-pill px-4">
                                    <i class="bi bi-download me-1"></i> Exportar CSV (Excel)
                                </a>
                            </c:if>
                        </div>
                    </form>
                </div>

                <!-- Resultados -->
                <c:choose>
                    <c:when test="${empty resultados}">
                        <div class="card card-custom p-5">
                            <div class="text-center py-5">
                                <i class="bi bi-file-earmark-bar-graph text-muted" style="font-size: 4rem;"></i>
                                <h5 class="mt-3 text-muted">No hay datos para mostrar</h5>
                                <p class="text-muted">Aplica filtros y genera el reporte para ver resultados.</p>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <!-- Stats -->
                        <div class="row g-3 mb-4">
                            <div class="col-md-3">
                                <div class="stat-card">
                                    <div class="stat-value text-primary">
                                        <fmt:formatNumber value="${resultados.size()}" pattern="#,##0"/>
                                    </div>
                                    <div class="stat-label">
                                        <c:choose>
                                            <c:when test="${tipoReporte == 'ventas'}">Total Pasajes</c:when>
                                            <c:when test="${tipoReporte == 'viajes'}">Total Viajes</c:when>
                                            <c:otherwise>Total Encomiendas</c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>
                            <c:if test="${tipoReporte == 'ventas'}">
                            <div class="col-md-3">
                                <div class="stat-card">
                                    <div class="stat-value" style="color: var(--mvb-orange);">
                                        S/ <fmt:formatNumber value="${totalIngresos}" pattern="#,##0.00"/>
                                    </div>
                                    <div class="stat-label">Ingresos Totales</div>
                                </div>
                            </div>
                            </c:if>
                        </div>

                        <!-- Tabla de resultados -->
                        <div class="card card-custom">
                            <div class="card-body p-4">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <h5 class="fw-bold mb-0">
                                        <i class="bi bi-list-check me-2 text-success"></i>
                                        Resultados del Reporte
                                    </h5>
                                    <span class="badge bg-success rounded-pill">${resultados.size()} registro(s)</span>
                                </div>
                                <div class="table-responsive">
                                    <c:choose>
                                        <c:when test="${tipoReporte == 'ventas'}">
                                            <table class="table table-hover align-middle mb-0 small">
                                                <thead>
                                                    <tr>
                                                        <th>#</th>
                                                        <th>Fecha</th>
                                                        <th>Pasajero</th>
                                                        <th>DNI</th>
                                                        <th>Ruta</th>
                                                        <th>Bus</th>
                                                        <th>Servicio</th>
                                                        <th>Asiento</th>
                                                        <th class="text-end">Precio</th>
                                                        <th>Pago</th>
                                                        <th>Vendedor</th>
                                                        <th>Estado</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach var="v" items="${resultados}">
                                                        <tr>
                                                            <td><span class="badge bg-dark">#${v.idPasaje}</span></td>
                                                            <td><small>${v.fechaEmision}</small></td>
                                                            <td><span title="DNI: ${v.dniCliente}">${v.nombreCliente}</span></td>
                                                            <td><code>${v.dniCliente}</code></td>
                                                            <td>
                                                                <small>
                                                                    <i class="bi bi-geo-alt-fill text-success me-1"></i>${v.origen}
                                                                    <i class="bi bi-arrow-right mx-1"></i>
                                                                    <i class="bi bi-geo-alt-fill text-danger me-1"></i>${v.destino}
                                                                </small>
                                                            </td>
                                                            <td><span class="badge bg-dark">${v.placa}</span></td>
                                                            <td><span class="badge bg-info">${v.nombreServicio}</span></td>
                                                            <td class="text-center">
                                                                <span class="badge bg-secondary">N° ${v.numeroAsiento}</span>
                                                            </td>
                                                            <td class="text-end fw-bold" style="color: var(--mvb-orange);">
                                                                S/ <fmt:formatNumber value="${v.precioPagado}" pattern="#,##0.00"/>
                                                            </td>
                                                            <td><small>${v.metodoPago}</small></td>
                                                            <td><small class="text-muted">${v.vendedor != null ? v.vendedor : '—'}</small></td>
                                                            <td>
                                                                <span class="badge ${v.estadoPasaje == 'ACTIVO' ? 'bg-success' : 'bg-secondary'}">
                                                                    ${v.estadoPasaje}
                                                                </span>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                        </c:when>
                                        <c:when test="${tipoReporte == 'viajes'}">
                                            <table class="table table-hover align-middle mb-0 small">
                                                <thead>
                                                    <tr>
                                                        <th>#</th>
                                                        <th>Salida</th>
                                                        <th>Llegada Est.</th>
                                                        <th>Ruta</th>
                                                        <th>Bus</th>
                                                        <th>Servicio</th>
                                                        <th class="text-center">Capacidad</th>
                                                        <th class="text-center">Ocupados</th>
                                                        <th class="text-center">% Ocup.</th>
                                                        <th class="text-center">Estado</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach var="v" items="${resultados}">
                                                        <tr>
                                                            <td><span class="badge bg-dark">#${v.idViaje}</span></td>
                                                            <td><small>${v.fechaHoraSalida}</small></td>
                                                            <td><small>${v.fechaLlegada}</small></td>
                                                            <td>
                                                                <small>
                                                                    <i class="bi bi-geo-alt-fill text-success me-1"></i>${v.origen}
                                                                    <i class="bi bi-arrow-right mx-1"></i>
                                                                    <i class="bi bi-geo-alt-fill text-danger me-1"></i>${v.destino}
                                                                </small>
                                                            </td>
                                                            <td><span class="badge bg-dark">${v.placa}</span></td>
                                                            <td><span class="badge bg-info">${v.servicio}</span></td>
                                                            <td class="text-center">${v.capacidad}</td>
                                                            <td class="text-center">${v.ocupados}</td>
                                                            <td class="text-center">
                                                                <c:set var="pct" value="${v.capacidad > 0 ? (v.ocupados / v.capacidad * 100) : 0}"/>
                                                                <span class="badge ${pct >= 80 ? 'bg-success' : pct >= 50 ? 'bg-warning text-dark' : 'bg-danger'}">
                                                                    <fmt:formatNumber value="${pct}" pattern="#0.0"/>%
                                                                </span>
                                                            </td>
                                                            <td class="text-center">
                                                                <span class="badge ${v.estado == 'PROGRAMADO' ? 'bg-primary' : v.estado == 'EN_RUTA' ? 'bg-success' : v.estado == 'FINALIZADO' ? 'bg-secondary' : 'bg-danger'}">
                                                                    ${v.estado}
                                                                </span>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                        </c:when>
                                        <c:when test="${tipoReporte == 'encomiendas'}">
                                            <table class="table table-hover align-middle mb-0 small">
                                                <thead>
                                                    <tr>
                                                        <th>#</th>
                                                        <th>Fecha</th>
                                                        <th>Descripción</th>
                                                        <th>Peso</th>
                                                        <th>Ruta</th>
                                                        <th>Remitente</th>
                                                        <th>Destinatario</th>
                                                        <th class="text-end">Costo</th>
                                                        <th>Vendedor</th>
                                                        <th class="text-center">Estado</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach var="e" items="${resultados}">
                                                        <tr>
                                                            <td><span class="badge bg-dark">#${e.idEncomienda}</span></td>
                                                            <td><small>${e.fechaEnvio}</small></td>
                                                            <td><small>${e.descripcion}</small></td>
                                                            <td><span class="badge bg-secondary">${e.pesoKg} kg</span></td>
                                                            <td>
                                                                <small>
                                                                    <i class="bi bi-geo-alt-fill text-success me-1"></i>${e.origen}
                                                                    <i class="bi bi-arrow-right mx-1"></i>
                                                                    <i class="bi bi-geo-alt-fill text-danger me-1"></i>${e.destino}
                                                                </small>
                                                            </td>
                                                            <td><small>${e.nombreRemitente}</small></td>
                                                            <td><small>${e.nombreDestinatario}</small></td>
                                                            <td class="text-end fw-bold" style="color: var(--mvb-orange);">
                                                                S/ <fmt:formatNumber value="${e.precioEnvio}" pattern="#,##0.00"/>
                                                            </td>
                                                            <td><small class="text-muted">${e.vendedor != null ? e.vendedor : '—'}</small></td>
                                                            <td class="text-center">
                                                                <span class="badge ${e.estado == 'ENTREGADO' ? 'bg-success' : e.estado == 'EN VIAJE' ? 'bg-primary' : 'bg-secondary'}">
                                                                    ${e.estado}
                                                                </span>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                        </c:when>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
