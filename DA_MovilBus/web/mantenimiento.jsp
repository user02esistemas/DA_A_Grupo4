<%-- Modulo de Mantenimiento de Buses - solo ADMINISTRADOR --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@page import="java.util.List, model.Mantenimiento, model.Bus, model.Usuario, dao.BusDAO"%>
<%
    Usuario user = (Usuario) session.getAttribute("usuarioSesion");
    if (user == null || "CLIENTE_WEB".equalsIgnoreCase(user.getRol())) {
        response.sendRedirect("login.jsp");
        return;
    }
    boolean esAdmin = "ADMINISTRADOR".equalsIgnoreCase(user.getRol());
    boolean esVendedor = "VENDEDOR".equalsIgnoreCase(user.getRol());

    // Cargar buses solo si se muestra el formulario
    String formMode = request.getParameter("form");
    if (formMode != null) {
        BusDAO busDAO = new BusDAO();
        request.setAttribute("listaBusesMant", busDAO.listarBuses());
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>MovilBus - Mantenimiento de Buses</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="css/movilbus.css">
    <style>
        .mtto-alerta-card {
            border-left: 4px solid var(--mvb-orange);
            border-radius: var(--radius-md);
            transition: all .2s;
        }
        .mtto-alerta-card:hover {
            transform: translateX(4px);
            box-shadow: var(--shadow-sm);
        }
        .mtto-alerta-card.danger { border-left-color: var(--mvb-danger); }
        .mtto-alerta-card.success { border-left-color: var(--mvb-success); }
        .mtto-alerta-card.info { border-left-color: #0dcaf0; }
        .mtto-status-badge {
            font-size: .7rem;
            padding: .25em .6em;
            border-radius: var(--radius-pill);
            font-weight: 600;
        }
        .mtto-info-icon {
            width: 40px; height: 40px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.1rem;
            flex-shrink: 0;
        }
    </style>
</head>
<body class="admin-body">
    <div class="container-fluid">
        <div class="row">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="mantenimiento" />
                <jsp:param name="esAdmin" value="<%= String.valueOf(esAdmin) %>" />
            </jsp:include>

            <div class="col-md-10 main-content animate-fade">
                <!-- Mobile Navbar -->
                <nav class="navbar navbar-dark bg-dark rounded-3 mb-4 d-md-none p-3">
                    <span class="navbar-brand mb-0 fw-bold"><i class="bi bi-bus-front me-2"></i>MovilBus</span>
                    <div>
                        <a href="dashboard.jsp" class="btn btn-outline-light btn-sm me-1"><i class="bi bi-speedometer2"></i></a>
                        <a href="LogoutServlet" class="btn btn-outline-danger btn-sm"><i class="bi bi-box-arrow-right"></i></a>
                    </div>
                </nav>

                <!-- Page Header -->
                <div class="d-flex justify-content-between align-items-start mb-4 flex-wrap gap-2">
                    <div>
                        <h1 class="page-title">
                            <i class="bi bi-tools text-danger me-2"></i> Mantenimiento de Buses
                            <small>Gestión de mantenimientos preventivos y correctivos de la flota</small>
                        </h1>
                    </div>
                    <% if (esAdmin) { %>
                    <a href="mantenimiento.jsp?form=nuevo" class="btn btn-ingresar rounded-pill">
                        <i class="bi bi-plus-circle me-1"></i> Nuevo Mantenimiento
                    </a>
                    <% } %>
                </div>

                <!-- Status Alerts -->
                <c:if test="${param.status == 'success'}">
                    <div class="alert alert-success alert-dismissible fade show rounded-3 shadow-sm">
                        <i class="bi bi-check-circle me-2"></i> <strong>Mantenimiento registrado exitosamente.</strong>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                <c:if test="${param.status == 'completado'}">
                    <div class="alert alert-info alert-dismissible fade show rounded-3 shadow-sm">
                        <i class="bi bi-check2-circle me-2"></i> <strong>Mantenimiento marcado como completado.</strong>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                <c:if test="${param.status == 'cancelado'}">
                    <div class="alert alert-warning alert-dismissible fade show rounded-3 shadow-sm">
                        <i class="bi bi-x-circle me-2"></i> <strong>Mantenimiento cancelado.</strong>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                <c:if test="${param.status == 'error'}">
                    <div class="alert alert-danger alert-dismissible fade show rounded-3 shadow-sm">
                        <i class="bi bi-exclamation-triangle me-2"></i> <strong>Error al procesar la solicitud.</strong>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <!-- ============================================================
                     FORMULARIO (cuando hay ?form=nuevo o ?form=editar)
                     ============================================================ -->
                <c:if test="${param.form == 'nuevo' || param.form == 'editar'}">
                <div class="card card-custom p-4 mb-4">
                    <div class="d-flex align-items-center mb-3">
                        <i class="bi bi-plus-circle fs-4 text-primary me-2"></i>
                        <h5 class="fw-bold mb-0">Registrar Nuevo Mantenimiento</h5>
                    </div>
                    <form action="MantenimientoServlet" method="POST" class="row g-3">
                        <input type="hidden" name="accion" value="guardar">
                        <c:if test="${param.form == 'editar' && not empty editarMantenimiento}">
                            <input type="hidden" name="idMantenimiento" value="${editarMantenimiento.idMantenimiento}">
                        </c:if>

                        <div class="col-md-4">
                            <label class="form-label">Bus <span class="text-danger">*</span></label>
                            <select class="form-select" name="idBus" required>
                                <option value="">-- Seleccione Bus --</option>
                                <c:forEach var="b" items="${listaBusesMant}">
                                    <option value="${b.idBus}" ${editarMantenimiento.idBus == b.idBus ? 'selected' : ''}>${b.placa} - ${b.marca} ${b.modelo} (${b.nombreServicio})</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Tipo <span class="text-danger">*</span></label>
                            <select class="form-select" name="tipoMantenimiento" required>
                                <option value="">-- Seleccione --</option>
                                <option value="PREVENTIVO" ${editarMantenimiento.tipoMantenimiento == 'PREVENTIVO' ? 'selected' : ''}>Preventivo</option>
                                <option value="CORRECTIVO" ${editarMantenimiento.tipoMantenimiento == 'CORRECTIVO' ? 'selected' : ''}>Correctivo</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Estado <span class="text-danger">*</span></label>
                            <select class="form-select" name="estado" required>
                                <option value="PROGRAMADO" ${editarMantenimiento.estado == 'PROGRAMADO' ? 'selected' : ''}>Programado</option>
                                <option value="EN_PROCESO" ${editarMantenimiento.estado == 'EN_PROCESO' ? 'selected' : ''}>En Proceso</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Fecha Inicio <span class="text-danger">*</span></label>
                            <input type="datetime-local" class="form-control" name="fechaInicio" required
                                   value="${editarMantenimiento.fechaInicio != null ? editarMantenimiento.fechaInicio.toString().replace(' ', 'T').substring(0, 16) : ''}">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Fecha Fin</label>
                            <input type="datetime-local" class="form-control" name="fechaFin"
                                   value="${editarMantenimiento.fechaFin != null ? editarMantenimiento.fechaFin.toString().replace(' ', 'T').substring(0, 16) : ''}">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Kilometraje Actual</label>
                            <input type="number" class="form-control" name="kilometraje" min="0" value="${editarMantenimiento.kilometrajeActual}">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Costo Estimado (S/)</label>
                            <input type="number" class="form-control" name="costo" step="0.01" min="0" value="${editarMantenimiento.costo}">
                        </div>
                        <div class="col-12">
                            <label class="form-label">Descripcion / Observaciones</label>
                            <textarea class="form-control" name="descripcion" rows="2" placeholder="Describa el trabajo a realizar...">${editarMantenimiento.descripcion}</textarea>
                        </div>
                        <div class="col-12">
                            <button type="submit" class="btn btn-ingresar rounded-pill">
                                <i class="bi bi-save me-1"></i> ${param.form == 'editar' ? 'Actualizar' : 'Guardar'} Mantenimiento
                            </button>
                            <a href="MantenimientoServlet" class="btn btn-secondary rounded-pill ms-2">
                                <i class="bi bi-x-circle me-1"></i> Cancelar
                            </a>
                        </div>
                    </form>
                </div>
                </c:if>

                <!-- ============================================================
                     ALERTAS / TARJETAS DE AVISOS
                     ============================================================ -->
                <div class="row g-3 mb-4">
                    <!-- Mantenimientos activos -->
                    <c:set var="activosCount" value="0" />
                    <c:if test="${not empty mantenimientosActivos}">
                        <c:set var="activosCount" value="${mantenimientosActivos.size()}" />
                    </c:if>
                    <div class="col-md-4">
                        <div class="card border-0 shadow-sm p-3 text-center">
                            <div class="mtto-info-icon mx-auto mb-2" style="background:#FFF3E0;color:var(--mvb-orange);">
                                <i class="bi bi-gear"></i>
                            </div>
                            <div class="fs-3 fw-bold" style="color:var(--mvb-orange);">${activosCount}</div>
                            <small class="text-muted">Mantenimiento(s) Activo(s)</small>
                        </div>
                    </div>
                    <!-- Vencidos -->
                    <c:set var="vencidosCount" value="0" />
                    <c:if test="${not empty mantenimientosVencidos}">
                        <c:set var="vencidosCount" value="${mantenimientosVencidos.size()}" />
                    </c:if>
                    <div class="col-md-4">
                        <div class="card border-0 shadow-sm p-3 text-center">
                            <div class="mtto-info-icon mx-auto mb-2" style="background:#FEE2E2;color:#DC3545;">
                                <i class="bi bi-exclamation-triangle"></i>
                            </div>
                            <div class="fs-3 fw-bold text-danger">${vencidosCount}</div>
                            <small class="text-muted">Vencido(s) sin Completar</small>
                        </div>
                    </div>
                    <!-- Buses sin mantenimiento reciente -->
                    <c:set var="sinMantCount" value="0" />
                    <c:if test="${not empty busesSinMantenimiento}">
                        <c:set var="sinMantCount" value="${busesSinMantenimiento.size()}" />
                    </c:if>
                    <div class="col-md-4">
                        <div class="card border-0 shadow-sm p-3 text-center">
                            <div class="mtto-info-icon mx-auto mb-2" style="background:#E0F2FE;color:#0284C7;">
                                <i class="bi bi-clock-history"></i>
                            </div>
                            <div class="fs-3 fw-bold text-info">${sinMantCount}</div>
                            <small class="text-muted">Buses sin Mtto >60 días</small>
                        </div>
                    </div>
                </div>

                <!-- Alertas de mantenimientos vencidos -->
                <c:if test="${not empty mantenimientosVencidos}">
                <div class="card border-0 shadow-sm p-3 mb-4" style="border-left:4px solid #DC3545;">
                    <h6 class="fw-bold text-danger mb-3">
                        <i class="bi bi-exclamation-triangle-fill me-1"></i> Mantenimientos Vencidos
                    </h6>
                    <div class="row g-2">
                        <c:forEach var="mv" items="${mantenimientosVencidos}">
                            <div class="col-md-4">
                                <div class="mtto-alerta-card danger p-3 bg-light rounded-3">
                                    <div class="fw-bold">${mv.placa}</div>
                                    <small class="text-muted">
                                        <i class="bi bi-calendar me-1"></i>${mv.tipo} - Debía completarse: ${mv.fechaFin}
                                    </small>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
                </c:if>

                <!-- Alertas de buses sin mantenimiento reciente -->
                <c:if test="${not empty busesSinMantenimiento}">
                <div class="card border-0 shadow-sm p-3 mb-4" style="border-left:4px solid #0dcaf0;">
                    <h6 class="fw-bold text-info mb-3">
                        <i class="bi bi-clock-history me-1"></i> Buses sin Mantenimiento Reciente (+60 días)
                    </h6>
                    <div class="row g-2">
                        <c:forEach var="bs" items="${busesSinMantenimiento}">
                            <div class="col-md-4">
                                <div class="mtto-alerta-card info p-3 bg-light rounded-3">
                                    <div class="fw-bold">${bs.placa}</div>
                                    <small class="text-muted">${bs.marca} ${bs.modelo}</small>
                                    <small class="d-block text-muted">
                                        <i class="bi bi-calendar me-1"></i>Último: ${bs.ultimoMantenimiento}
                                    </small>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
                </c:if>

                <!-- ============================================================
                     TABLA DE MANTENIMIENTOS
                     ============================================================ -->
                <div class="card card-custom p-4">
                    <div class="d-flex align-items-center mb-3">
                        <i class="bi bi-list-check fs-4 text-success me-2"></i>
                        <h5 class="fw-bold mb-0">Historial de Mantenimientos</h5>
                        <span class="ms-auto badge bg-secondary rounded-pill">
                            ${not empty listaMantenimientos ? listaMantenimientos.size() : 0} registro(s)
                        </span>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0 small">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Bus</th>
                                    <th>Tipo</th>
                                    <th>Fecha Inicio</th>
                                    <th>Fecha Fin</th>
                                    <th>Kilometraje</th>
                                    <th class="text-end">Costo</th>
                                    <th class="text-center">Estado</th>
                                    <th class="text-center">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty listaMantenimientos}">
                                        <tr>
                                            <td colspan="9" class="text-center text-muted py-4">
                                                <i class="bi bi-inbox fs-2 d-block mb-2"></i>
                                                No hay mantenimientos registrados
                                            </td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="m" items="${listaMantenimientos}">
                                            <tr>
                                                <td><span class="badge bg-dark">#${m.idMantenimiento}</span></td>
                                                <td><strong>${m.placaBus}</strong></td>
                                                <td>
                                                    <span class="badge ${m.tipoMantenimiento == 'PREVENTIVO' ? 'bg-success' : 'bg-warning text-dark'}">
                                                        ${m.tipoMantenimiento}
                                                    </span>
                                                </td>
                                                <td><small>${m.fechaInicio}</small></td>
                                                <td><small>${m.fechaFin != null ? m.fechaFin : '—'}</small></td>
                                                <td><fmt:formatNumber value="${m.kilometrajeActual}" groupingUsed="true"/> km</td>
                                                <td class="text-end fw-bold">S/. <fmt:formatNumber value="${m.costo}" minFractionDigits="2" maxFractionDigits="2"/></td>
                                                <td class="text-center">
                                                    <span class="mtto-status-badge 
                                                        ${m.estado == 'COMPLETADO' ? 'bg-success' : 
                                                          m.estado == 'EN_PROCESO' ? 'bg-primary' : 
                                                          m.estado == 'PROGRAMADO' ? 'bg-warning text-dark' : 
                                                          m.estado == 'CANCELADO' ? 'bg-secondary' : 'bg-info'}">
                                                        ${m.estado}
                                                    </span>
                                                </td>
                                                <td class="text-center">
                                                    <div class="d-flex gap-1 justify-content-center">
                                                        <% if (esAdmin) { %>
                                                            <c:if test="${m.estado != 'COMPLETADO' && m.estado != 'CANCELADO'}">
                                                                <a href="MantenimientoServlet?accion=completar&id=${m.idMantenimiento}" 
                                                                   class="btn btn-success btn-sm btn-action" 
                                                                   onclick="return confirm('¿Completar este mantenimiento?')"
                                                                   title="Completar">
                                                                    <i class="bi bi-check-lg"></i>
                                                                </a>
                                                                <a href="MantenimientoServlet?accion=cancelar&id=${m.idMantenimiento}" 
                                                                   class="btn btn-secondary btn-sm btn-action"
                                                                   onclick="return confirm('¿Cancelar este mantenimiento?')"
                                                                   title="Cancelar">
                                                                    <i class="bi bi-x-lg"></i>
                                                                </a>
                                                            </c:if>
                                                        <% } %>
                                                        <button class="btn btn-info btn-sm btn-action" 
                                                                onclick="verDetalle(${m.idMantenimiento}, '${m.placaBus}', '${m.tipoMantenimiento}', '${m.descripcion}', '${m.kilometrajeActual}', '${m.costo}', '${m.estado}')"
                                                                title="Ver detalle">
                                                            <i class="bi bi-eye"></i>
                                                        </button>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </div>
    </div>

    <!-- Modal Detalle -->
    <div class="modal fade" id="modalDetalleMtto" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-sm">
            <div class="modal-content" style="border-radius:var(--radius-lg);">
                <div class="modal-header" style="background:var(--gradient-primary);color:white;">
                    <h6 class="modal-title fw-bold"><i class="bi bi-info-circle me-1"></i> Detalle del Mantenimiento</h6>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="mb-2"><strong>Bus:</strong> <span id="detPlaca"></span></div>
                    <div class="mb-2"><strong>Tipo:</strong> <span id="detTipo"></span></div>
                    <div class="mb-2"><strong>Descripción:</strong> <span id="detDesc"></span></div>
                    <div class="mb-2"><strong>Kilometraje:</strong> <span id="detKm"></span> km</div>
                    <div class="mb-2"><strong>Costo:</strong> S/. <span id="detCosto"></span></div>
                    <div class="mb-0"><strong>Estado:</strong> <span id="detEstado"></span></div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
    function verDetalle(id, placa, tipo, desc, km, costo, estado) {
        document.getElementById('detPlaca').textContent = placa;
        document.getElementById('detTipo').textContent = tipo;
        document.getElementById('detDesc').textContent = desc || '—';
        document.getElementById('detKm').textContent = parseInt(km).toLocaleString();
        document.getElementById('detCosto').textContent = parseFloat(costo).toFixed(2);
        document.getElementById('detEstado').textContent = estado;

        const modal = new bootstrap.Modal(document.getElementById('modalDetalleMtto'));
        modal.show();
    }
    </script>
</body>
</html>
