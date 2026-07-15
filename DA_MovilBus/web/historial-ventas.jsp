<%-- 
    Document   : historial-ventas
    Historial completo de ventas de pasajes realizadas
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@page import="model.Usuario"%>
<%
    // 🔒 CONTROL DE ACCESO: Solo ADMINISTRADOR y VENDEDOR pueden ver historial
    Usuario userH = (Usuario) session.getAttribute("usuarioSesion");
    if (userH == null || (!"ADMINISTRADOR".equalsIgnoreCase(userH.getRol()) && !"VENDEDOR".equalsIgnoreCase(userH.getRol()))) {
        response.sendRedirect("ventas.jsp");
        return;
    }
    String userRol = userH.getRol();
    boolean esAdmin = "ADMINISTRADOR".equalsIgnoreCase(userRol);
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>MovilBus - Historial de Ventas</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="css/movilbus.css">
    <style>
        .stat-card {
            border: none;
            border-radius: 16px;
            padding: 1.2rem;
            transition: all .3s;
        }
        .stat-card:hover { transform: translateY(-3px); box-shadow: var(--shadow-md); }
        .stat-card .stat-icon {
            width: 48px; height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.4rem;
        }
        .stat-card .stat-value { font-size: 1.6rem; font-weight: 800; }
        .stat-card .stat-label { font-size: .8rem; color: var(--mvb-text-light); }
        .filter-section {
            background: white;
            border-radius: 16px;
            padding: 1rem 1.5rem;
            box-shadow: var(--shadow-card);
        }
        .filter-section .form-label { font-size: .75rem; margin-bottom: .2rem; }
        .filter-section .form-control,
        .filter-section .form-select { padding: .4rem .7rem; font-size: .85rem; }
    </style>
</head>
<body class="admin-body">
    <div class="container-fluid">
        <div class="row">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="historial" />
                <jsp:param name="esAdmin" value="<%= String.valueOf(esAdmin) %>" />
            </jsp:include>

            <!-- Main Content -->
            <div class="col-md-10 main-content animate-fade">
                <!-- Mobile Navbar -->
                <nav class="navbar navbar-dark bg-dark rounded-3 mb-4 d-md-none p-3">
                    <span class="navbar-brand mb-0 fw-bold"><i class="bi bi-bus-front me-2"></i>MovilBus</span>
                    <div>
                        <a href="dashboard.jsp" class="btn btn-outline-light btn-sm me-1"><i class="bi bi-speedometer2"></i></a>
                        <a href="LogoutServlet" class="btn btn-outline-danger btn-sm"><i class="bi bi-box-arrow-right"></i></a>
                    </div>
                </nav>

                <!-- Alerts -->
                <c:if test="${param.status == 'success'}">
                    <div class="alert alert-success alert-dismissible fade show rounded-3 shadow-sm" role="alert">
                        <i class="bi bi-check-circle me-2"></i> <strong>¡Operación exitosa!</strong>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                <c:if test="${param.status == 'anulado'}">
                    <div class="alert alert-warning alert-dismissible fade show rounded-3 shadow-sm" role="alert">
                        <i class="bi bi-arrow-counterclockwise me-2"></i> <strong>Pasaje anulado - Reembolso procesado.</strong>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                <c:if test="${param.status == 'error'}">
                    <div class="alert alert-danger alert-dismissible fade show rounded-3 shadow-sm" role="alert">
                        <i class="bi bi-exclamation-triangle me-2"></i> <strong>Error al procesar la operación.</strong>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <!-- Page Header -->
                <div class="d-flex justify-content-between align-items-start mb-4">
                    <div>
                        <h1 class="page-title">
                            <i class="bi bi-clock-history text-primary me-2"></i> Historial de Ventas
                            <small>Consulta todas las ventas de pasajes realizadas en el sistema</small>
                        </h1>
                    </div>
                </div>

                <!-- Stats -->
                <c:set var="totalVentas" value="0"/>
                <c:set var="montoTotal" value="0"/>
                <c:set var="totalActivos" value="0"/>
                <c:set var="totalAnulados" value="0"/>
                <c:forEach var="venta" items="${listaVentas}">
                    <c:set var="totalVentas" value="${totalVentas + 1}"/>
                    <c:set var="montoTotal" value="${montoTotal + venta.precioPagado}"/>
                    <c:if test="${venta.estadoPasaje == 'ACTIVO'}"><c:set var="totalActivos" value="${totalActivos + 1}"/></c:if>
                    <c:if test="${venta.estadoPasaje != 'ACTIVO'}"><c:set var="totalAnulados" value="${totalAnulados + 1}"/></c:if>
                </c:forEach>

                <div class="row g-3 mb-4">
                    <div class="col-md-3">
                        <div class="stat-card bg-white shadow-sm">
                            <div class="d-flex align-items-center">
                                <div class="stat-icon bg-primary bg-opacity-10 text-primary me-3">
                                    <i class="bi bi-ticket-perforated"></i>
                                </div>
                                <div>
                                    <div class="stat-value">${totalVentas}</div>
                                    <div class="stat-label">Total Pasajes Vendidos</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card bg-white shadow-sm">
                            <div class="d-flex align-items-center">
                                <div class="stat-icon bg-success bg-opacity-10 text-success me-3">
                                    <i class="bi bi-currency-dollar"></i>
                                </div>
                                <div>
                                    <div class="stat-value">S/. ${montoTotal}</div>
                                    <div class="stat-label">Monto Total Recaudado</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card bg-white shadow-sm">
                            <div class="d-flex align-items-center">
                                <div class="stat-icon bg-info bg-opacity-10 text-info me-3">
                                    <i class="bi bi-check-circle"></i>
                                </div>
                                <div>
                                    <div class="stat-value">${totalActivos}</div>
                                    <div class="stat-label">Pasajes Activos</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card bg-white shadow-sm">
                            <div class="d-flex align-items-center">
                                <div class="stat-icon bg-warning bg-opacity-10 text-warning me-3">
                                    <i class="bi bi-x-circle"></i>
                                </div>
                                <div>
                                    <div class="stat-value">${totalAnulados}</div>
                                    <div class="stat-label">Anulados / Inactivos</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Filtros -->
                <div class="filter-section mb-4">
                    <div class="row g-2 align-items-end">
                        <div class="col-auto">
                            <i class="bi bi-funnel text-muted me-1"></i>
                            <span class="small fw-bold text-muted">Filtrar por:</span>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">Estado</label>
                            <select class="form-select" id="filtroEstado" onchange="filtrarTabla()">
                                <option value="">Todos</option>
                                <option value="ACTIVO">Activos</option>
                                <option value="ANULADO">Anulados</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Buscar por DNI o Nombre</label>
                            <input type="text" class="form-control" id="filtroBusqueda" placeholder="Escriba para filtrar..." onkeyup="filtrarTabla()">
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">Servicio</label>
                            <select class="form-select" id="filtroServicio" onchange="filtrarTabla()">
                                <option value="">Todos</option>
                                <option value="EJECUTIVO VIP">Ejecutivo VIP</option>
                                <option value="PRESIDENCIAL">Presidencial</option>
                                <option value="PREMIER">Premier</option>
                            </select>
                        </div>
                        <div class="col-auto">
                            <button class="btn btn-outline-secondary btn-sm rounded-pill px-3" onclick="limpiarFiltros()">
                                <i class="bi bi-arrow-counterclockwise me-1"></i> Limpiar
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Tabla de Ventas -->
                <div class="card card-custom">
                    <div class="card-body p-4">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h5 class="fw-bold mb-0"><i class="bi bi-list-check me-2 text-primary"></i>Relación de Pasajes Emitidos</h5>
                            <span class="badge bg-primary rounded-pill">${totalVentas} registros</span>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0" id="tablaVentas">
                                <thead>
                                    <tr>
                                        <th>#</th>
                                        <th>Fecha Emisión</th>
                                        <th>Pasajero</th>
                                        <th>DNI</th>
                                        <th>Ruta</th>
                                        <th>Asiento</th>
                                        <th>Servicio</th>
                                        <th>Bus</th>
                                        <th class="text-center">Precio</th>
                                        <th class="text-center">Estado</th>
                                        <th>Vendedor</th>
                                        <th class="text-center">Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="v" items="${listaVentas}">
                                        <tr>
                                            <td><span class="text-muted small fw-bold">#${v.idPasaje}</span></td>
                                            <td>
                                                <small class="text-nowrap">
                                                    <i class="bi bi-calendar3 me-1"></i>${v.fechaEmision}
                                                </small>
                                            </td>
                                            <td>
                                                <div class="d-flex align-items-center">
                                                    <i class="bi bi-person-circle text-muted me-2"></i>
                                                    <span class="fw-semibold">${v.nombreCliente} ${v.apellidoCliente}</span>
                                                </div>
                                            </td>
                                            <td><code class="text-dark">${v.dniCliente}</code></td>
                                            <td>
                                                <small>
                                                    <i class="bi bi-geo-alt-fill text-success me-1"></i>${v.origen}
                                                    <i class="bi bi-arrow-right mx-1"></i>
                                                    <i class="bi bi-geo-alt-fill text-danger me-1"></i>${v.destino}
                                                </small>
                                            </td>
                                            <td class="text-center">
                                                <span class="badge bg-secondary">N° ${v.numeroAsiento}</span>
                                                <small class="text-muted d-block">Piso ${v.piso}</small>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${v.nombreServicio == 'EJECUTIVO VIP'}">
                                                        <span class="badge bg-primary badge-servicio">${v.nombreServicio}</span>
                                                    </c:when>
                                                    <c:when test="${v.nombreServicio == 'PRESIDENCIAL'}">
                                                        <span class="badge bg-warning text-dark badge-servicio">${v.nombreServicio}</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-dark badge-servicio">${v.nombreServicio}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td><span class="badge bg-dark">${v.placa}</span></td>
                                            <td class="text-center fw-bold text-success">S/. ${v.precioPagado}</td>
                                            <td class="text-center">
                                                <span class="badge ${v.estadoPasaje == 'ACTIVO' ? 'bg-success' : 'bg-secondary'}">
                                                    ${v.estadoPasaje}
                                                </span>
                                            </td>
                                            <td>
                                                <small class="text-muted">
                                                    <i class="bi bi-person-badge me-1"></i>${v.vendedor != null ? v.vendedor : 'Cliente Web'}
                                                </small>
                                            </td>
                                            <td class="text-center">
                                                <c:if test="${v.estadoPasaje == 'ACTIVO'}">
                                                    <button type="button" class="btn btn-outline-warning btn-sm rounded-pill" 
                                                            onclick="confirmarAnulacion(${v.idPasaje}, '${v.dniCliente}', '${v.nombreCliente} ${v.apellidoCliente}')"
                                                            title="Solicitar Reembolso / Anular Pasaje">
                                                        <i class="bi bi-arrow-counterclockwise me-1"></i> Reembolsar
                                                    </button>
                                                </c:if>
                                                <c:if test="${v.estadoPasaje != 'ACTIVO'}">
                                                    <span class="text-muted small">—</span>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty listaVentas}">
                                        <tr>
                                            <td colspan="12">
                                                <div class="empty-state">
                                                    <i class="bi bi-ticket text-muted"></i>
                                                    <p class="mb-0">No se han realizado ventas aún.</p>
                                                    <a href="ventas.jsp" class="btn btn-primary btn-sm mt-2 rounded-pill">
                                                        <i class="bi bi-plus-lg me-1"></i> Realizar primera venta
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
    function filtrarTabla() {
        const estado = document.getElementById('filtroEstado').value.toUpperCase();
        const busqueda = document.getElementById('filtroBusqueda').value.toLowerCase();
        const servicio = document.getElementById('filtroServicio').value.toUpperCase();
        const filas = document.querySelectorAll('#tablaVentas tbody tr');

        filas.forEach(fila => {
            if (fila.querySelector('.empty-state')) return;
            
            const textoEstado = fila.querySelector('td:nth-child(10) .badge')?.textContent.trim().toUpperCase() || '';
            const textoNombre = fila.querySelector('td:nth-child(3)')?.textContent.toLowerCase() || '';
            const textoDni = fila.querySelector('td:nth-child(4)')?.textContent.toLowerCase() || '';
            const textoServicio = fila.querySelector('td:nth-child(7) .badge')?.textContent.trim().toUpperCase() || '';

            const cumpleEstado = !estado || textoEstado === estado;
            const cumpleBusqueda = !busqueda || textoNombre.includes(busqueda) || textoDni.includes(busqueda);
            const cumpleServicio = !servicio || textoServicio.includes(servicio);

            fila.style.display = (cumpleEstado && cumpleBusqueda && cumpleServicio) ? '' : 'none';
        });
    }

    function limpiarFiltros() {
        document.getElementById('filtroEstado').value = '';
        document.getElementById('filtroBusqueda').value = '';
        document.getElementById('filtroServicio').value = '';
        filtrarTabla();
    }

    function confirmarAnulacion(idPasaje, dni, nombre) {
        if (confirm('¿Estás seguro de anular el pasaje #' + idPasaje + ' de ' + nombre + ' (DNI: ' + dni + ')?\n\nEsta acción simulará un REEMBOLSO y cambiará el estado del pasaje a ANULADO.')) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'VentaServlet';
            const inputAccion = document.createElement('input');
            inputAccion.type = 'hidden';
            inputAccion.name = 'accion';
            inputAccion.value = 'anularPasaje';
            const inputId = document.createElement('input');
            inputId.type = 'hidden';
            inputId.name = 'idPasaje';
            inputId.value = idPasaje;
            form.appendChild(inputAccion);
            form.appendChild(inputId);
            document.body.appendChild(form);
            form.submit();
        }
    }
    </script>
</body>
</html>
