<%-- CRUD completo para gestionar rutas comerciales de MovilBus --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@page import="dao.RutaDAO, dao.CiudadDAO, model.Usuario, java.util.List, java.util.Map"%>
<%
    RutaDAO rutaDAO = new RutaDAO();
    CiudadDAO ciudadDAO = new CiudadDAO();
    request.setAttribute("listaRutas", rutaDAO.listarRutas());
    request.setAttribute("listaCiudades", ciudadDAO.listarActivas());
%>
<%
    // Control de acceso: solo ADMINISTRADOR puede gestionar rutas
    Usuario userRut = (Usuario) session.getAttribute("usuarioSesion");
    if (userRut == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String rolRut = userRut.getRol();
    if (!"ADMINISTRADOR".equalsIgnoreCase(rolRut)) {
        response.sendRedirect("ventas.jsp");
        return;
    }
    boolean esAdminRut = true;
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>MovilBus - Gestión de Rutas</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="css/movilbus.css">
</head>
<body class="admin-body">
    <div class="container-fluid">
        <div class="row">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="rutas" />
                <jsp:param name="esAdmin" value="true" />
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

                <!-- Page Header -->
                <div class="d-flex justify-content-between align-items-start mb-4">
                    <div>
                        <h1 class="page-title">
                            <i class="bi bi-signpost-2 text-primary me-2"></i> Rutas Comerciales
                            <small>Definición de rutas, distancias y tarifas base</small>
                        </h1>
                    </div>
                    <button class="btn btn-primary rounded-pill px-4 shadow-sm" data-bs-toggle="modal" data-bs-target="#modalRuta" onclick="limpiarModal()">
                        <i class="bi bi-plus-lg me-1"></i> Nueva Ruta
                    </button>
                </div>

                <!-- Success/Error Messages -->
                <c:if test="${not empty sessionScope.msgExito}">
                    <div class="alert alert-success alert-dismissible fade show rounded-3 shadow-sm" role="alert">
                        <i class="bi bi-check-circle me-2"></i> ${sessionScope.msgExito}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <c:remove var="msgExito" scope="session"/>
                </c:if>
                <c:if test="${not empty sessionScope.msgError}">
                    <div class="alert alert-danger alert-dismissible fade show rounded-3 shadow-sm" role="alert">
                        <i class="bi bi-exclamation-triangle me-2"></i> ${sessionScope.msgError}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <c:remove var="msgError" scope="session"/>
                </c:if>

                <!-- Stats Row -->
                <div class="row g-3 mb-4">
                    <div class="col-md-3">
                        <div class="card card-custom p-3">
                            <div class="d-flex align-items-center">
                                <div class="rounded-circle bg-primary bg-opacity-10 p-3 me-3">
                                    <i class="bi bi-signpost-2 fs-4 text-primary"></i>
                                </div>
                                <div>
                                    <h6 class="fw-bold mb-0">${listaRutas.size()}</h6>
                                    <small class="text-muted">Rutas Totales</small>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card card-custom p-3">
                            <div class="d-flex align-items-center">
                                <div class="rounded-circle bg-success bg-opacity-10 p-3 me-3">
                                    <i class="bi bi-check-circle fs-4 text-success"></i>
                                </div>
                                <div>
                                    <h6 class="fw-bold mb-0">
                                        <c:set var="activas" value="0"/>
                                        <c:forEach var="r" items="${listaRutas}">
                                            <c:if test="${r.estado == 'ACTIVO'}"><c:set var="activas" value="${activas + 1}"/></c:if>
                                        </c:forEach>
                                        ${activas}
                                    </h6>
                                    <small class="text-muted">Rutas Activas</small>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card card-custom p-3">
                            <div class="d-flex align-items-center">
                                <div class="rounded-circle bg-warning bg-opacity-10 p-3 me-3">
                                    <i class="bi bi-clock fs-4 text-warning"></i>
                                </div>
                                <div>
                                    <c:set var="totalHoras" value="0"/>
                                    <c:forEach var="r" items="${listaRutas}">
                                        <c:set var="totalHoras" value="${totalHoras + r.duracionHoras}"/>
                                    </c:forEach>
                                    <h6 class="fw-bold mb-0">${totalHoras} hrs</h6>
                                    <small class="text-muted">Horas Acumuladas</small>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card card-custom p-3">
                            <div class="d-flex align-items-center">
                                <div class="rounded-circle bg-info bg-opacity-10 p-3 me-3">
                                    <i class="bi bi-currency-dollar fs-4 text-info"></i>
                                </div>
                                <div>
                                    <c:choose>
                                        <c:when test="${empty listaRutas}">
                                            <h6 class="fw-bold mb-0">S/. 0.00</h6>
                                        </c:when>
                                        <c:otherwise>
                                            <c:set var="precioMin" value="999999"/>
                                            <c:set var="precioMax" value="0"/>
                                            <c:forEach var="r" items="${listaRutas}">
                                                <c:if test="${r.precioBase < precioMin}"><c:set var="precioMin" value="${r.precioBase}"/></c:if>
                                                <c:if test="${r.precioBase > precioMax}"><c:set var="precioMax" value="${r.precioBase}"/></c:if>
                                            </c:forEach>
                                            <h6 class="fw-bold mb-0">S/. ${precioMin} - S/. ${precioMax}</h6>
                                        </c:otherwise>
                                    </c:choose>
                                    <small class="text-muted">Rango Tarifario</small>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Rutas Table -->
                <div class="card card-custom">
                    <div class="card-body p-4">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h5 class="fw-bold mb-0"><i class="bi bi-list-check me-2 text-primary"></i>Catálogo de Rutas</h5>
                            <span class="badge bg-primary rounded-pill">${listaRutas.size()} registros</span>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Origen</th>
                                        <th>Destino</th>
                                        <th class="text-center">Duración</th>
                                        <th class="text-center">Precio Base</th>
                                        <th class="text-center">Estado</th>
                                        <th class="text-center">Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="r" items="${listaRutas}">
                                        <tr>
                                            <td><span class="text-muted small fw-bold">#${r.idRuta}</span></td>
                                            <td>
                                                <span class="fw-semibold">
                                                    <i class="bi bi-geo-alt-fill text-success me-1"></i>${r.origen}
                                                </span>
                                            </td>
                                            <td>
                                                <span class="fw-semibold">
                                                    <i class="bi bi-geo-alt-fill text-danger me-1"></i>${r.destino}
                                                </span>
                                            </td>
                                            <td class="text-center">
                                                <span class="badge bg-light text-dark border">
                                                    <i class="bi bi-clock me-1"></i>${r.duracionHoras} hrs
                                                </span>
                                            </td>
                                            <td class="text-center">
                                                <span class="fw-bold text-success">S/. ${r.precioBase}</span>
                                            </td>
                                            <td class="text-center">
                                                <span class="badge badge-estado ${r.estado == 'ACTIVO' ? 'bg-success' : 'bg-secondary'}">
                                                    ${r.estado}
                                                </span>
                                            </td>
                                            <td class="text-center">
                                                <button class="btn btn-outline-primary btn-action me-1" title="Editar"
                                                        onclick="editarRuta(${r.idRuta}, ${r.idOrigen}, ${r.idDestino}, ${r.duracionHoras}, ${r.precioBase}, '${r.estado}')">
                                                    <i class="bi bi-pencil"></i>
                                                </button>
                                                <c:if test="${r.estado == 'ACTIVO'}">
                                                    <form action="RutaServlet" method="POST" class="d-inline" onsubmit="return confirm('¿Desactivar la ruta ${r.origen} - ${r.destino}?')">
                                                        <input type="hidden" name="accion" value="eliminar">
                                                        <input type="hidden" name="idRuta" value="${r.idRuta}">
                                                        <button class="btn btn-outline-warning btn-action" title="Desactivar">
                                                            <i class="bi bi-toggle-off"></i>
                                                        </button>
                                                    </form>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty listaRutas}">
                                        <tr>
                                            <td colspan="7">
                                                <div class="empty-state">
                                                    <i class="bi bi-signpost-2 text-muted"></i>
                                                    <p class="mb-0">No hay rutas comerciales registradas.</p>
                                                    <p class="text-muted small">Primero asegúrate de tener ciudades activas registradas.</p>
                                                    <button class="btn btn-primary btn-sm mt-2" data-bs-toggle="modal" data-bs-target="#modalRuta">
                                                        <i class="bi bi-plus-lg"></i> Crear primera ruta
                                                    </button>
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

    <!-- Modal Crear/Editar Ruta -->
    <div class="modal fade" id="modalRuta" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header border-0">
                    <h5 class="modal-title fw-bold" id="modalTitle"><i class="bi bi-signpost-2 me-2 text-primary"></i>Registrar Ruta</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form action="RutaServlet" method="POST" id="formRuta">
                    <div class="modal-body pt-0">
                        <input type="hidden" name="accion" id="accion" value="crear">
                        <input type="hidden" name="idRuta" id="idRuta">
                        <input type="hidden" name="estado" id="estadoHidden">

                        <div class="mb-3">
                            <label class="form-label"><i class="bi bi-signpost-split me-1"></i>Ciudad de Origen</label>
                            <select class="form-select" name="idOrigen" id="idOrigen" required>
                                <option value="">-- Seleccione origen --</option>
                                <c:forEach var="c" items="${listaCiudades}">
                                    <option value="${c.idCiudad}">${c.nombre}, ${c.departamento}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label"><i class="bi bi-signpost-split me-1"></i>Ciudad de Destino</label>
                            <select class="form-select" name="idDestino" id="idDestino" required>
                                <option value="">-- Seleccione destino --</option>
                                <c:forEach var="c" items="${listaCiudades}">
                                    <option value="${c.idCiudad}">${c.nombre}, ${c.departamento}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="row g-3 mb-3">
                            <div class="col-6">
                                <label class="form-label"><i class="bi bi-clock me-1"></i>Duración (horas)</label>
                                <input type="number" step="0.01" min="0.5" max="48" class="form-control" name="duracionHoras" id="duracionHoras" placeholder="Ej: 12.50" required>
                            </div>
                            <div class="col-6">
                                <label class="form-label"><i class="bi bi-currency-dollar me-1"></i>Precio Base (S/.)</label>
                                <input type="number" step="0.01" min="0" class="form-control" name="precioBase" id="precioBase" placeholder="Ej: 80.00" required>
                            </div>
                        </div>
                        <div class="alert alert-info p-2 small text-center mb-0">
                            <i class="bi bi-info-circle me-1"></i>
                            El precio final del pasaje será: Base + Tipo de Asiento + Recargo de Ubicación
                        </div>
                        <div class="mb-3" id="campoEstado" style="display:none;">
                            <label class="form-label"><i class="bi bi-toggle-on me-1"></i>Estado</label>
                            <select class="form-select" name="estadoSelect" id="estadoSelect" onchange="document.getElementById('estadoHidden').value=this.value">
                                <option value="ACTIVO">ACTIVO</option>
                                <option value="INACTIVO">INACTIVO</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer border-0 pt-0">
                        <button type="button" class="btn btn-light rounded-pill" data-bs-dismiss="modal">Cancelar</button>
                        <button type="submit" class="btn btn-primary rounded-pill px-4" id="btnSubmit">
                            <i class="bi bi-save me-1"></i> Guardar
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function limpiarModal() {
            document.getElementById('accion').value = 'crear';
            document.getElementById('idRuta').value = '';
            document.getElementById('formRuta').reset();
            document.getElementById('modalTitle').innerHTML = '<i class="bi bi-signpost-2 me-2 text-primary"></i>Registrar Ruta';
            document.getElementById('btnSubmit').innerHTML = '<i class="bi bi-save me-1"></i> Guardar';
            document.getElementById('campoEstado').style.display = 'none';
        }

        function editarRuta(id, idOrigen, idDestino, duracion, precio, estado) {
            document.getElementById('accion').value = 'actualizar';
            document.getElementById('idRuta').value = id;
            document.getElementById('idOrigen').value = idOrigen;
            document.getElementById('idDestino').value = idDestino;
            document.getElementById('duracionHoras').value = duracion;
            document.getElementById('precioBase').value = precio;
            document.getElementById('estadoHidden').value = estado;
            document.getElementById('estadoSelect').value = estado;
            document.getElementById('modalTitle').innerHTML = '<i class="bi bi-pencil me-2 text-warning"></i>Editar Ruta #' + id;
            document.getElementById('btnSubmit').innerHTML = '<i class="bi bi-arrow-repeat me-1"></i> Actualizar';
            document.getElementById('campoEstado').style.display = 'block';
            
            new bootstrap.Modal(document.getElementById('modalRuta')).show();
        }

        // Validar origen != destino
        document.getElementById('formRuta').addEventListener('submit', function(e) {
            var origen = document.getElementById('idOrigen').value;
            var destino = document.getElementById('idDestino').value;
            if (origen && destino && origen === destino) {
                e.preventDefault();
                alert('⚠️ El origen y destino no pueden ser la misma ciudad.');
            }
        });

        setTimeout(function() {
            document.querySelectorAll('.alert').forEach(a => {
                var bsAlert = new bootstrap.Alert(a);
                setTimeout(() => bsAlert.close(), 4000);
            });
        }, 5000);
    </script>
</body>
</html>
