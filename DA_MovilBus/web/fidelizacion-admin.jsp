<%-- Panel de administración del Programa de Fidelización --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@page import="model.Usuario"%>
<%
    Usuario user = (Usuario) session.getAttribute("usuarioSesion");
    if (user == null || "CLIENTE_WEB".equalsIgnoreCase(user.getRol())) {
        response.sendRedirect("login.jsp");
        return;
    }
    boolean esAdmin = "ADMINISTRADOR".equalsIgnoreCase(user.getRol());
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>MovilBus - Programa de Fidelización</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="css/movilbus.css">
    <style>
        .nivel-badge { border-radius: 50px; padding: .3rem .8rem; font-weight: 700; font-size: .75rem; }
        .stat-card-fid {
            border-radius: 16px;
            padding: 1.2rem;
            text-align: center;
            background: white;
            box-shadow: 0 2px 12px rgba(0,0,0,.05);
            transition: all .3s;
        }
        .stat-card-fid:hover { transform: translateY(-2px); box-shadow: 0 8px 25px rgba(0,0,0,.1); }
        .stat-card-fid .stat-value { font-size: 2rem; font-weight: 800; }
        .stat-card-fid .stat-label { font-size: .75rem; text-transform: uppercase; letter-spacing: .3px; }
    </style>
</head>
<body class="admin-body">
    <div class="container-fluid">
        <div class="row">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="fidelizacion" />
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

                <!-- Header -->
                <div class="d-flex justify-content-between align-items-start mb-4">
                    <div>
                        <h1 class="page-title">
                            <i class="bi bi-star text-warning me-2"></i> Programa de Fidelización
                            <small>Gestiona los puntos y niveles de tus clientes frecuentes</small>
                        </h1>
                    </div>
                </div>

                <!-- Estadísticas -->
                <div class="row g-3 mb-4">
                    <div class="col-md-3">
                        <div class="stat-card-fid">
                            <div class="stat-value text-primary">${estadisticasFidelidad.totalClientes}</div>
                            <div class="stat-label">Clientes en Programa</div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card-fid">
                            <div class="stat-value" style="color:var(--mvb-orange);"><fmt:formatNumber value="${estadisticasFidelidad.totalPuntos}" pattern="#,##0"/></div>
                            <div class="stat-label">Puntos Totales</div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card-fid">
                            <div class="stat-value text-success">${estadisticasFidelidad.totalCanjes}</div>
                            <div class="stat-label">Canjes Realizados</div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card-fid">
                            <div class="stat-value text-info"><fmt:formatNumber value="${estadisticasFidelidad.totalPuntos - estadisticasFidelidad.totalCanjeados}" pattern="#,##0"/></div>
                            <div class="stat-label">Puntos Vigentes</div>
                        </div>
                    </div>
                </div>

                <!-- Distribución por nivel -->
                <div class="row g-3 mb-4">
                    <div class="col-md-3 col-6">
                        <div class="stat-card-fid" style="border-left:4px solid #CD7F32;">
                            <div class="stat-value" style="color:#CD7F32;">${estadisticasFidelidad.bronce}</div>
                            <div class="stat-label">🥉 Bronce</div>
                        </div>
                    </div>
                    <div class="col-md-3 col-6">
                        <div class="stat-card-fid" style="border-left:4px solid #C0C0C0;">
                            <div class="stat-value" style="color:#6c757d;">${estadisticasFidelidad.plata}</div>
                            <div class="stat-label">🥈 Plata</div>
                        </div>
                    </div>
                    <div class="col-md-3 col-6">
                        <div class="stat-card-fid" style="border-left:4px solid #FFD700;">
                            <div class="stat-value" style="color:#FFD700;">${estadisticasFidelidad.oro}</div>
                            <div class="stat-label">🥇 Oro</div>
                        </div>
                    </div>
                    <div class="col-md-3 col-6">
                        <div class="stat-card-fid" style="border-left:4px solid #E5E4E2;">
                            <div class="stat-value" style="color:#212529;">${estadisticasFidelidad.platino}</div>
                            <div class="stat-label">🏆 Platino</div>
                        </div>
                    </div>
                </div>

                <!-- Tabla de clientes -->
                <div class="card card-custom p-4 mb-4">
                    <div class="d-flex align-items-center mb-3">
                        <i class="bi bi-people fs-4 text-primary me-2"></i>
                        <h5 class="fw-bold mb-0">Clientes Registrados</h5>
                        <span class="ms-auto badge bg-primary rounded-pill">${listaClientesFidelidad.size()} cliente(s)</span>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0 small">
                            <thead>
                                <tr>
                                    <th>Cliente</th>
                                    <th>DNI</th>
                                    <th class="text-center">Puntos Acum.</th>
                                    <th class="text-center">Puntos Canj.</th>
                                    <th class="text-center">Disponibles</th>
                                    <th class="text-center">Nivel</th>
                                    <th>Descuento</th>
                                    <th>Última Actualización</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty listaClientesFidelidad}">
                                        <tr>
                                            <td colspan="8" class="text-center text-muted py-4">
                                                <i class="bi bi-inbox fs-2 d-block mb-2"></i>
                                                No hay clientes registrados en el programa
                                            </td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="pc" items="${listaClientesFidelidad}">
                                            <tr>
                                                <td class="fw-semibold">${pc.nombreCliente}</td>
                                                <td><span class="badge bg-dark">${pc.dniCliente}</span></td>
                                                <td class="text-center fw-bold"><fmt:formatNumber value="${pc.puntosAcumulados}" pattern="#,##0"/></td>
                                                <td class="text-center">${pc.puntosCanjeados}</td>
                                                <td class="text-center fw-bold" style="color:var(--mvb-orange);">${pc.puntosDisponibles}</td>
                                                <td class="text-center">
                                                    <span class="nivel-badge" style="background:${pc.nivelColor}; color:${pc.nombreNivel == 'PLATA' ? '#212529' : '#fff'};">
                                                        <i class="${pc.nivelIcono} me-1"></i>${pc.nombreNivel}
                                                    </span>
                                                </td>
                                                <td class="text-center text-success fw-bold">${pc.descuentoNivel}%</td>
                                                <td><small class="text-muted">${pc.fechaUltimaActualizacion}</small></td>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Transacciones Recientes -->
                <div class="card card-custom p-4">
                    <div class="d-flex align-items-center mb-3">
                        <i class="bi bi-clock-history fs-4 text-info me-2"></i>
                        <h5 class="fw-bold mb-0">Transacciones Recientes</h5>
                        <span class="ms-auto badge bg-info rounded-pill">${transaccionesRecientesFidelidad.size()} transacción(es)</span>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0 small">
                            <thead>
                                <tr>
                                    <th>Fecha</th>
                                    <th>Cliente</th>
                                    <th>Tipo</th>
                                    <th class="text-center">Puntos</th>
                                    <th>Monto Ref.</th>
                                    <th>Descripción</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="t" items="${transaccionesRecientesFidelidad}">
                                    <tr>
                                        <td><small>${t.fecha}</small></td>
                                        <td><small class="fw-semibold">#${t.idCliente}</small></td>
                                        <td>
                                            <span class="badge ${t.tipo == 'ACUMULACION' ? 'bg-success' : 'bg-warning text-dark'}">
                                                ${t.tipo}
                                            </span>
                                        </td>
                                        <td class="text-center fw-bold ${t.tipo == 'ACUMULACION' ? 'text-success' : 'text-danger'}">
                                            ${t.tipo == 'ACUMULACION' ? '+' : '-'}${t.puntos}
                                        </td>
                                        <td>S/ ${t.montoReferencia}</td>
                                        <td><small class="text-muted">${t.descripcion}</small></td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
