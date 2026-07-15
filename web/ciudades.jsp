<%-- 
    Document   : ciudades
    CRUD completo para gestionar ciudades de MovilBus
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@page import="dao.CiudadDAO, model.Ciudad, model.Usuario, java.util.List"%>
<%
    CiudadDAO ciudadDAO = new CiudadDAO();
    request.setAttribute("listaCiudades", ciudadDAO.listarTodas());
%>
<%
    // 🔒 CONTROL DE ACCESO: Solo ADMINISTRADOR puede gestionar ciudades
    Usuario userCiu = (Usuario) session.getAttribute("usuarioSesion");
    if (userCiu == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String rolCiu = userCiu.getRol();
    if (!"ADMINISTRADOR".equalsIgnoreCase(rolCiu)) {
        response.sendRedirect("ventas.jsp");
        return;
    }
    boolean esAdminCiu = true;
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>MovilBus - Gestión de Ciudades</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="css/movilbus.css">
</head>
<body class="admin-body">
    <div class="container-fluid">
        <div class="row">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="ciudades" />
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
                            <i class="bi bi-geo-alt text-primary me-2"></i> Ciudades
                            <small>Gestión de ciudades y departamentos para rutas comerciales</small>
                        </h1>
                    </div>
                    <button class="btn btn-primary rounded-pill px-4 shadow-sm" data-bs-toggle="modal" data-bs-target="#modalCiudad" onclick="limpiarModal()">
                        <i class="bi bi-plus-lg me-1"></i> Nueva Ciudad
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
                    <div class="col-md-4">
                        <div class="card card-custom p-3">
                            <div class="d-flex align-items-center">
                                <div class="rounded-circle bg-primary bg-opacity-10 p-3 me-3">
                                    <i class="bi bi-building fs-4 text-primary"></i>
                                </div>
                                <div>
                                    <h6 class="fw-bold mb-0">${listaCiudades.size()}</h6>
                                    <small class="text-muted">Total Ciudades</small>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card card-custom p-3">
                            <div class="d-flex align-items-center">
                                <div class="rounded-circle bg-success bg-opacity-10 p-3 me-3">
                                    <i class="bi bi-check-circle fs-4 text-success"></i>
                                </div>
                                <div>
                                    <h6 class="fw-bold mb-0">
                                        <c:set var="activas" value="0"/>
                                        <c:forEach var="c" items="${listaCiudades}">
                                            <c:if test="${c.estado == 'ACTIVO'}"><c:set var="activas" value="${activas + 1}"/></c:if>
                                        </c:forEach>
                                        ${activas}
                                    </h6>
                                    <small class="text-muted">Ciudades Activas</small>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card card-custom p-3">
                            <div class="d-flex align-items-center">
                                <div class="rounded-circle bg-warning bg-opacity-10 p-3 me-3">
                                    <i class="bi bi-x-circle fs-4 text-warning"></i>
                                </div>
                                <div>
                                    <h6 class="fw-bold mb-0">
                                        <c:set var="inactivas" value="0"/>
                                        <c:forEach var="c" items="${listaCiudades}">
                                            <c:if test="${c.estado != 'ACTIVO'}"><c:set var="inactivas" value="${inactivas + 1}"/></c:if>
                                        </c:forEach>
                                        ${inactivas}
                                    </h6>
                                    <small class="text-muted">Inactivas</small>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Ciudades Table -->
                <div class="card card-custom">
                    <div class="card-body p-4">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h5 class="fw-bold mb-0"><i class="bi bi-list-check me-2 text-primary"></i>Directorio de Ciudades</h5>
                            <span class="badge bg-primary rounded-pill">${listaCiudades.size()} registros</span>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Nombre</th>
                                        <th>Departamento</th>
                                        <th class="text-center">Estado</th>
                                        <th class="text-center">Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="c" items="${listaCiudades}">
                                        <tr>
                                            <td><span class="text-muted small fw-bold">#${c.idCiudad}</span></td>
                                            <td>
                                                <div class="d-flex align-items-center">
                                                    <i class="bi bi-geo-alt-fill text-primary me-2"></i>
                                                    <span class="fw-semibold">${c.nombre}</span>
                                                </div>
                                            </td>
                                            <td>
                                                <span class="badge bg-light text-dark border">
                                                    <i class="bi bi-building me-1"></i>${c.departamento}
                                                </span>
                                            </td>
                                            <td class="text-center">
                                                <span class="badge badge-estado ${c.estado == 'ACTIVO' ? 'bg-success' : 'bg-secondary'}">
                                                    <i class="bi ${c.estado == 'ACTIVO' ? 'bi-check-circle' : 'bi-x-circle'} me-1"></i>${c.estado}
                                                </span>
                                            </td>
                                            <td class="text-center">
                                                <button class="btn btn-outline-primary btn-action me-1" title="Editar"
                                                        onclick="editarCiudad(${c.idCiudad}, '${c.nombre}', '${c.departamento}', '${c.estado}')">
                                                    <i class="bi bi-pencil"></i>
                                                </button>
                                                <c:if test="${c.estado == 'ACTIVO'}">
                                                    <form action="CiudadServlet" method="POST" class="d-inline" onsubmit="return confirm('¿Desactivar la ciudad ${c.nombre}?')">
                                                        <input type="hidden" name="accion" value="eliminar">
                                                        <input type="hidden" name="idCiudad" value="${c.idCiudad}">
                                                        <button class="btn btn-outline-warning btn-action" title="Desactivar">
                                                            <i class="bi bi-toggle-off"></i>
                                                        </button>
                                                    </form>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty listaCiudades}">
                                        <tr>
                                            <td colspan="5">
                                                <div class="empty-state">
                                                    <i class="bi bi-geo-alt text-muted"></i>
                                                    <p class="mb-0">No hay ciudades registradas en el sistema.</p>
                                                    <button class="btn btn-primary btn-sm mt-2" data-bs-toggle="modal" data-bs-target="#modalCiudad">
                                                        <i class="bi bi-plus-lg"></i> Registrar primera ciudad
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

    <!-- Modal Crear/Editar Ciudad -->
    <div class="modal fade" id="modalCiudad" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header border-0">
                    <h5 class="modal-title fw-bold" id="modalTitle"><i class="bi bi-geo-alt me-2 text-primary"></i>Registrar Ciudad</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form action="CiudadServlet" method="POST" id="formCiudad">
                    <div class="modal-body pt-0">
                        <input type="hidden" name="accion" id="accion" value="crear">
                        <input type="hidden" name="idCiudad" id="idCiudad">
                        
                        <div class="mb-3">
                            <label class="form-label"><i class="bi bi-building me-1"></i>Nombre de la Ciudad</label>
                            <input type="text" class="form-control" name="nombre" id="nombre" placeholder="Ej: Chiclayo" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label"><i class="bi bi-map me-1"></i>Departamento</label>
                            <input type="text" class="form-control" name="departamento" id="departamento" placeholder="Ej: Lambayeque" required>
                        </div>
                        <div class="mb-3" id="campoEstado" style="display:none;">
                            <label class="form-label"><i class="bi bi-toggle-on me-1"></i>Estado</label>
                            <select class="form-select" name="estado" id="estado">
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
            document.getElementById('idCiudad').value = '';
            document.getElementById('formCiudad').reset();
            document.getElementById('modalTitle').innerHTML = '<i class="bi bi-geo-alt me-2 text-primary"></i>Registrar Ciudad';
            document.getElementById('btnSubmit').innerHTML = '<i class="bi bi-save me-1"></i> Guardar';
            document.getElementById('campoEstado').style.display = 'none';
        }

        function editarCiudad(id, nombre, departamento, estado) {
            document.getElementById('accion').value = 'actualizar';
            document.getElementById('idCiudad').value = id;
            document.getElementById('nombre').value = nombre;
            document.getElementById('departamento').value = departamento;
            document.getElementById('estado').value = estado;
            document.getElementById('modalTitle').innerHTML = '<i class="bi bi-pencil me-2 text-warning"></i>Editar Ciudad #' + id;
            document.getElementById('btnSubmit').innerHTML = '<i class="bi bi-arrow-repeat me-1"></i> Actualizar';
            document.getElementById('campoEstado').style.display = 'block';
            
            new bootstrap.Modal(document.getElementById('modalCiudad')).show();
        }

        setTimeout(function() {
            document.querySelectorAll('.alert').forEach(a => {
                var bsAlert = new bootstrap.Alert(a);
                setTimeout(() => bsAlert.close(), 4000);
            });
        }, 5000);
    </script>
</body>
</html>
