<%-- 
    Document   : encomiendas
    Módulo de Encomiendas - Registro y seguimiento de envíos de paquetes
    Solo accesible para ADMINISTRADOR y VENDEDOR
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@page import="java.util.List, java.util.Map, dao.CiudadDAO, model.Ciudad, model.Usuario"%>
<%
    // 🔒 CONTROL DE ACCESO
    Usuario user = (Usuario) session.getAttribute("usuarioSesion");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String userRol = user.getRol();
    if (!"ADMINISTRADOR".equalsIgnoreCase(userRol) && !"VENDEDOR".equalsIgnoreCase(userRol)) {
        response.sendRedirect("index.jsp");
        return;
    }
    boolean esAdmin = "ADMINISTRADOR".equalsIgnoreCase(userRol);
    
    // Cargar ciudades para el módulo (si es necesario)
    CiudadDAO ciudadDAO = new CiudadDAO();
    request.setAttribute("listaCiudadesEnc", ciudadDAO.listarActivas());
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MovilBus - Encomiendas</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="css/movilbus.css">
    <style>
        .enc-stat-card {
            border: none;
            border-radius: 16px;
            padding: 1.2rem;
            transition: all .3s;
            background: white;
        }
        .enc-stat-card:hover { transform: translateY(-3px); box-shadow: var(--shadow-md); }
        .enc-stat-card .stat-icon {
            width: 48px; height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.4rem;
        }
        .enc-stat-card .stat-value { font-size: 1.6rem; font-weight: 800; }
        .enc-stat-card .stat-label { font-size: .8rem; color: var(--mvb-text-light); }
        .enc-form-card {
            border: none;
            border-radius: 20px;
            box-shadow: var(--shadow-card);
        }
        .enc-form-card .card-header {
            background: var(--gradient-primary);
            color: white;
            border-radius: 20px 20px 0 0;
            padding: 1.2rem 1.8rem;
        }
        .enc-form-card .card-body { padding: 1.8rem; }
        .badge-estado {
            font-size: .75rem;
            padding: .35rem .7rem;
            border-radius: 50px;
        }
        .table-enc > :not(caption) > * > * {
            vertical-align: middle;
            font-size: .875rem;
        }
    </style>
</head>
<body class="admin-body">
    <div class="container-fluid">
        <div class="row">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="encomiendas" />
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
                        <i class="bi bi-check-circle me-2"></i> <strong>¡Encomienda registrada con éxito!</strong>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                <c:if test="${param.status == 'error'}">
                    <div class="alert alert-danger alert-dismissible fade show rounded-3 shadow-sm" role="alert">
                        <i class="bi bi-exclamation-triangle me-2"></i> <strong>Error al procesar la encomienda.</strong> Verifique los datos.
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <!-- Page Header -->
                <div class="d-flex justify-content-between align-items-start mb-4">
                    <div>
                        <h1 class="page-title">
                            <i class="bi bi-box-seam text-warning me-2"></i> Encomiendas y Citas
                            <small>Gestión de envíos de paquetes y citas agendadas</small>
                        </h1>
                    </div>
                    <button class="btn btn-ingresar rounded-pill px-4" onclick="mostrarFormulario()" 
                            style="${not empty param.mostrarForm or param.accion == 'nuevo' ? 'display:none' : ''}">
                        <i class="bi bi-plus-lg me-1"></i> Nueva Encomienda
                    </button>
                </div>

                <!-- Stats Encomiendas -->
                <c:set var="totalEnc" value="0"/>
                <c:set var="totalIngresos" value="0"/>
                <c:set var="pendientes" value="0"/>
                <c:set var="entregados" value="0"/>
                <c:forEach var="e" items="${listaEncomiendas}">
                    <c:set var="totalEnc" value="${totalEnc + 1}"/>
                    <c:set var="totalIngresos" value="${totalIngresos + e.precioEnvio}"/>
                    <c:if test="${e.estado == 'REGISTRADO' or e.estado == 'EN VIAJE'}"><c:set var="pendientes" value="${pendientes + 1}"/></c:if>
                    <c:if test="${e.estado == 'ENTREGADO'}"><c:set var="entregados" value="${entregados + 1}"/></c:if>
                </c:forEach>
                <!-- Stats Citas -->
                <c:set var="totalCitas" value="0"/>
                <c:set var="citasPendientes" value="0"/>
                <c:set var="citasConfirmadas" value="0"/>
                <c:forEach var="c" items="${listaCitas}">
                    <c:set var="totalCitas" value="${totalCitas + 1}"/>
                    <c:if test="${c.estado == 'PENDIENTE'}"><c:set var="citasPendientes" value="${citasPendientes + 1}"/></c:if>
                    <c:if test="${c.estado == 'CONFIRMADA'}"><c:set var="citasConfirmadas" value="${citasConfirmadas + 1}"/></c:if>
                </c:forEach>

                <div class="row g-3 mb-4">
                    <div class="col">
                        <div class="enc-stat-card shadow-sm">
                            <div class="d-flex align-items-center">
                                <div class="stat-icon bg-warning bg-opacity-10 text-warning me-3">
                                    <i class="bi bi-box-seam"></i>
                                </div>
                                <div>
                                    <div class="stat-value">${totalEnc}</div>
                                    <div class="stat-label">Total Encomiendas</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col">
                        <div class="enc-stat-card shadow-sm">
                            <div class="d-flex align-items-center">
                                <div class="stat-icon bg-success bg-opacity-10 text-success me-3">
                                    <i class="bi bi-currency-dollar"></i>
                                </div>
                                <div>
                                    <div class="stat-value">S/. ${totalIngresos}</div>
                                    <div class="stat-label">Ingresos por Envíos</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col">
                        <div class="enc-stat-card shadow-sm">
                            <div class="d-flex align-items-center">
                                <div class="stat-icon bg-info bg-opacity-10 text-info me-3">
                                    <i class="bi bi-clock"></i>
                                </div>
                                <div>
                                    <div class="stat-value">${pendientes}</div>
                                    <div class="stat-label">Encomiendas Pendientes</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col">
                        <div class="enc-stat-card shadow-sm">
                            <div class="d-flex align-items-center">
                                <div class="stat-icon bg-primary bg-opacity-10 text-primary me-3">
                                    <i class="bi bi-check-circle"></i>
                                </div>
                                <div>
                                    <div class="stat-value">${entregados}</div>
                                    <div class="stat-label">Entregados</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col">
                        <div class="enc-stat-card shadow-sm">
                            <div class="d-flex align-items-center">
                                <div class="stat-icon bg-warning bg-opacity-10 text-warning me-3">
                                    <i class="bi bi-calendar-check"></i>
                                </div>
                                <div>
                                    <div class="stat-value">${totalCitas} <small class="text-muted" style="font-size:.7rem;">(${citasPendientes} pend.)</small></div>
                                    <div class="stat-label">Citas Agendadas</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Tabs: Encomiendas | Citas -->
                <ul class="nav nav-tabs mb-4" id="encTabs" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link active" id="tab-encomiendas" data-bs-toggle="tab" data-bs-target="#encomiendas-tab" type="button" role="tab">
                            <i class="bi bi-box-seam me-1"></i> Encomiendas 
                            <span class="badge bg-warning text-dark rounded-pill ms-1">${totalEnc}</span>
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="tab-citas" data-bs-toggle="tab" data-bs-target="#citas-tab" type="button" role="tab">
                            <i class="bi bi-calendar-check me-1"></i> Citas Agendadas
                            <span class="badge bg-warning text-dark rounded-pill ms-1">${totalCitas}</span>
                        </button>
                    </li>
                </ul>

                <div class="tab-content" id="encTabsContent">

                <!-- ==================== TAB: ENCOMIENDAS ==================== -->
                <div class="tab-pane fade show active" id="encomiendas-tab" role="tabpanel">

                <!-- Formulario de Registro -->
                <div class="enc-form-card mb-4" id="formEncomienda" 
                     style="display:${param.accion == 'nuevo' or not empty param.mostrarForm ? 'block' : 'none'}">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="fw-bold mb-0"><i class="bi bi-plus-circle me-2"></i>Registrar Nueva Encomienda</h5>
                        <button type="button" class="btn-close btn-close-white" onclick="ocultarFormulario()"></button>
                    </div>
                    <div class="card-body">
                        <form action="EncomiendaServlet" method="POST">
                            <input type="hidden" name="accion" value="registrar">
                            <div class="mb-4">
                                <label class="form-label fw-bold"><i class="bi bi-bus-front me-1"></i>Viaje de Transporte</label>
                                <select class="form-select" name="idViaje" required>
                                    <option value="">-- Seleccione un viaje --</option>
                                    <c:forEach var="v" items="${listaViajes}">
                                        <option value="${v.idViaje}" ${param.idViaje == v.idViaje ? 'selected' : ''}>
                                            ${v.nombreRuta} | ${v.fechaHora} | ${v.placaBus}
                                        </option>
                                    </c:forEach>
                                </select>
                                <c:if test="${empty listaViajes}">
                                    <div class="text-warning small mt-1">
                                        <i class="bi bi-exclamation-triangle me-1"></i>No hay viajes programados disponibles.
                                    </div>
                                </c:if>
                            </div>
                            <div class="border rounded-3 p-3 mb-4 bg-light">
                                <h6 class="fw-bold mb-3" style="color: var(--mvb-orange);">
                                    <i class="bi bi-person-up me-1"></i>Remitente (Quién envía)
                                </h6>
                                <div class="row g-3">
                                    <div class="col-md-4">
                                        <label class="form-label small">DNI <span class="text-danger">*</span></label>
                                        <input type="text" name="dniRemitente" class="form-control" maxlength="8" pattern="\d{8}" placeholder="12345678" required>
                                    </div>
                                    <div class="col-md-8">
                                        <label class="form-label small">Nombre Completo <span class="text-danger">*</span></label>
                                        <input type="text" name="nombreRemitente" class="form-control" placeholder="Nombres y Apellidos" required>
                                    </div>
                                </div>
                            </div>
                            <div class="border rounded-3 p-3 mb-4 bg-light">
                                <h6 class="fw-bold mb-3" style="color: var(--mvb-orange);">
                                    <i class="bi bi-person-down me-1"></i>Destinatario (Quién recibe)
                                </h6>
                                <div class="row g-3">
                                    <div class="col-md-4">
                                        <label class="form-label small">DNI <span class="text-danger">*</span></label>
                                        <input type="text" name="dniDestinatario" class="form-control" maxlength="8" pattern="\d{8}" placeholder="12345678" required>
                                    </div>
                                    <div class="col-md-8">
                                        <label class="form-label small">Nombre Completo <span class="text-danger">*</span></label>
                                        <input type="text" name="nombreDestinatario" class="form-control" placeholder="Nombres y Apellidos" required>
                                    </div>
                                </div>
                            </div>
                            <div class="border rounded-3 p-3 mb-4 bg-light">
                                <h6 class="fw-bold mb-3" style="color: var(--mvb-orange);">
                                    <i class="bi bi-box me-1"></i>Detalles del Paquete
                                </h6>
                                <div class="row g-3">
                                    <div class="col-md-12">
                                        <label class="form-label small">Descripción del Contenido <span class="text-danger">*</span></label>
                                        <input type="text" name="descripcion" class="form-control" placeholder="Ej: Caja de repuestos, Documentos legales, Ropa..." required>
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label small">Peso (Kg) <span class="text-danger">*</span></label>
                                        <input type="number" name="pesoKg" class="form-control" step="0.1" min="0.1" placeholder="0.0" required>
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label small">Precio de Envío (S/.) <span class="text-danger">*</span></label>
                                        <input type="number" name="precioEnvio" class="form-control" step="0.5" min="1" placeholder="0.00" required>
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label small">Método de Pago</label>
                                        <select class="form-select" name="metodoPago">
                                            <option value="EFECTIVO">Efectivo</option>
                                            <option value="TARJETA">Tarjeta</option>
                                            <option value="TRANSFERENCIA">Transferencia</option>
                                            <option value="YAPE">Yape</option>
                                            <option value="PLIN">Plin</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                            <div class="d-flex gap-2 justify-content-end">
                                <button type="button" class="btn btn-outline-secondary rounded-pill px-4" onclick="ocultarFormulario()">
                                    <i class="bi bi-x-lg me-1"></i> Cancelar
                                </button>
                                <button type="submit" class="btn btn-ingresar rounded-pill px-4">
                                    <i class="bi bi-check-lg me-1"></i> Registrar Encomienda
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Tabla Encomiendas -->
                <div class="card card-custom">
                    <div class="card-body p-4">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h5 class="fw-bold mb-0"><i class="bi bi-list-check me-2 text-warning"></i>Relación de Encomiendas</h5>
                            <span class="badge bg-warning text-dark rounded-pill">${totalEnc} registro(s)</span>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle table-enc mb-0" id="tablaEncomiendas">
                                <thead>
                                    <tr>
                                        <th>#</th>
                                        <th>Fecha</th>
                                        <th>Descripción</th>
                                        <th>Peso</th>
                                        <th>Remitente</th>
                                        <th>Destinatario</th>
                                        <th>Ruta / Bus</th>
                                        <th class="text-center">Costo</th>
                                        <th class="text-center">Estado</th>
                                        <th>Vendedor</th>
                                        <th class="text-center">Acción</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="e" items="${listaEncomiendas}">
                                        <tr>
                                            <td><span class="fw-bold text-muted small">#${e.idEncomienda}</span></td>
                                            <td><small>${e.fechaEnvio}</small></td>
                                            <td><span class="fw-semibold small">${e.descripcion}</span></td>
                                            <td><span class="badge bg-secondary">${e.pesoKg} kg</span></td>
                                            <td><small><i class="bi bi-person-up text-success me-1"></i><span title="DNI: ${e.dniRemitente}">${e.nombreRemitente}</span></small></td>
                                            <td><small><i class="bi bi-person-down text-info me-1"></i><span title="DNI: ${e.dniDestinatario}">${e.nombreDestinatario}</span></small></td>
                                            <td><small><i class="bi bi-geo-alt-fill text-success me-1"></i>${e.origen} <i class="bi bi-arrow-right mx-1"></i> <i class="bi bi-geo-alt-fill text-danger me-1"></i>${e.destino}<br><span class="badge bg-dark mt-1">${e.placa}</span></small></td>
                                            <td class="text-center fw-bold" style="color: var(--mvb-orange);">S/. ${e.precioEnvio}</td>
                                            <td class="text-center">
                                                <span class="badge ${e.estado == 'ENTREGADO' ? 'bg-success' : e.estado == 'EN VIAJE' ? 'bg-primary' : e.estado == 'ANULADO' ? 'bg-danger' : 'bg-secondary'} badge-estado">${e.estado}</span>
                                            </td>
                                            <td><small class="text-muted">${e.vendedor != null ? e.vendedor : '—'}</small></td>
                                            <td class="text-center">
                                                <div class="dropdown">
                                                    <button class="btn btn-outline-secondary btn-sm dropdown-toggle rounded-pill" type="button" data-bs-toggle="dropdown">
                                                        <i class="bi bi-gear me-1"></i>
                                                    </button>
                                                    <ul class="dropdown-menu dropdown-menu-end shadow-sm">
                                                        <c:if test="${e.estado == 'REGISTRADO'}"><li><a class="dropdown-item" href="EncomiendaServlet?accion=actualizarEstado&idEncomienda=${e.idEncomienda}&estado=EN VIAJE"><i class="bi bi-truck text-primary me-2"></i>Marcar En Viaje</a></li></c:if>
                                                        <c:if test="${e.estado == 'EN VIAJE' or e.estado == 'REGISTRADO'}"><li><a class="dropdown-item" href="EncomiendaServlet?accion=actualizarEstado&idEncomienda=${e.idEncomienda}&estado=ENTREGADO"><i class="bi bi-check-circle text-success me-2"></i>Marcar Entregado</a></li></c:if>
                                                        <c:if test="${e.estado != 'ENTREGADO' and e.estado != 'ANULADO'}"><li><hr class="dropdown-divider"></li><li><a class="dropdown-item text-danger" href="EncomiendaServlet?accion=actualizarEstado&idEncomienda=${e.idEncomienda}&estado=ANULADO" onclick="return confirm('¿Anular encomienda #${e.idEncomienda}?')"><i class="bi bi-x-circle text-danger me-2"></i>Anular</a></li></c:if>
                                                    </ul>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty listaEncomiendas}">
                                        <tr><td colspan="11"><div class="empty-state"><i class="bi bi-box-seam text-muted fs-1"></i><p class="mb-0">No se han registrado encomiendas aún.</p><button class="btn btn-warning btn-sm mt-2 rounded-pill" onclick="mostrarFormulario()"><i class="bi bi-plus-lg me-1"></i> Registrar primera encomienda</button></div></td></tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                </div> <!-- /tab encomiendas -->

                <!-- ==================== TAB: CITAS ==================== -->
                <div class="tab-pane fade" id="citas-tab" role="tabpanel">
                <div class="card card-custom">
                    <div class="card-body p-4">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h5 class="fw-bold mb-0"><i class="bi bi-calendar-check me-2 text-warning"></i>Citas Agendadas por Clientes</h5>
                            <span class="badge bg-warning text-dark rounded-pill">${totalCitas} cita(s)</span>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle table-enc mb-0">
                                <thead>
                                    <tr>
                                        <th>#</th>
                                        <th>Registro</th>
                                        <th>Cliente</th>
                                        <th>DNI</th>
                                        <th>Teléfono</th>
                                        <th>Descripción</th>
                                        <th>Ruta</th>
                                        <th>Fecha/Hora Pref.</th>
                                        <th class="text-center">Estado</th>
                                        <th class="text-center">Acción</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="c" items="${listaCitas}">
                                        <tr>
                                            <td><span class="fw-bold text-muted small">#${c.idCita}</span></td>
                                            <td><small>${c.fechaRegistro}</small></td>
                                            <td><small><i class="bi bi-person-circle me-1"></i>${c.nombreCliente}</small></td>
                                            <td><code>${c.dniCliente}</code></td>
                                            <td><small>${c.telefonoCliente}</small></td>
                                            <td><small>${c.descripcion}</small></td>
                                            <td><small>${c.nombreOrigen} → ${c.nombreDestino}</small></td>
                                            <td><small>${c.fechaPreferida} ${c.horaPreferida}</small></td>
                                            <td class="text-center">
                                                <span class="badge ${c.estado == 'CONFIRMADA' ? 'bg-success' : c.estado == 'PENDIENTE' ? 'bg-warning text-dark' : c.estado == 'CANCELADA' ? 'bg-danger' : 'bg-secondary'} badge-estado">${c.estado}</span>
                                            </td>
                                            <td class="text-center">
                                                <div class="dropdown">
                                                    <button class="btn btn-outline-secondary btn-sm dropdown-toggle rounded-pill" type="button" data-bs-toggle="dropdown">
                                                        <i class="bi bi-gear me-1"></i>
                                                    </button>
                                                    <ul class="dropdown-menu dropdown-menu-end shadow-sm">
                                                        <c:if test="${c.estado == 'PENDIENTE'}"><li><a class="dropdown-item" href="EncomiendaServlet?accion=actualizarEstadoCita&idCita=${c.idCita}&estado=CONFIRMADA"><i class="bi bi-check-circle text-success me-2"></i>Confirmar</a></li></c:if>
                                                        <c:if test="${c.estado == 'CONFIRMADA'}"><li><a class="dropdown-item" href="EncomiendaServlet?accion=actualizarEstadoCita&idCita=${c.idCita}&estado=COMPLETADA"><i class="bi bi-check-all text-primary me-2"></i>Marcar Completada</a></li></c:if>
                                                        <c:if test="${c.estado != 'CANCELADA' and c.estado != 'COMPLETADA'}"><li><hr class="dropdown-divider"></li><li><a class="dropdown-item text-danger" href="EncomiendaServlet?accion=actualizarEstadoCita&idCita=${c.idCita}&estado=CANCELADA" onclick="return confirm('¿Cancelar cita #${c.idCita}?')"><i class="bi bi-x-circle text-danger me-2"></i>Cancelar</a></li></c:if>
                                                    </ul>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty listaCitas}">
                                        <tr><td colspan="10"><div class="empty-state"><i class="bi bi-calendar-check text-muted fs-1"></i><p class="mb-0">No hay citas agendadas.</p></div></td></tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                </div> <!-- /tab citas -->

                </div> <!-- /tab-content -->
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function mostrarFormulario() {
            document.getElementById('formEncomienda').style.display = 'block';
            window.scrollTo({ top: document.getElementById('formEncomienda').offsetTop - 100, behavior: 'smooth' });
        }
        function ocultarFormulario() {
            document.getElementById('formEncomienda').style.display = 'none';
        }
    </script>
</body>
</html>
