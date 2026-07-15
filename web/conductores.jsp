<%-- 
    Document   : conductores
    CRUD completo para gestionar conductores de MovilBus
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@page import="dao.ConductorDAO, model.Conductor, model.Usuario, java.util.List"%>
<%
    ConductorDAO condDAO = new ConductorDAO();
    request.setAttribute("listaConductores", condDAO.listarConductores());
%>
<%
    // 🔒 CONTROL DE ACCESO: Solo ADMINISTRADOR puede gestionar conductores
    Usuario userCond = (Usuario) session.getAttribute("usuarioSesion");
    if (userCond == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String rolCond = userCond.getRol();
    if (!"ADMINISTRADOR".equalsIgnoreCase(rolCond)) {
        response.sendRedirect("ventas.jsp");
        return;
    }
    boolean esAdminCond = true;
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>MovilBus - Gestión de Conductores</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="css/movilbus.css">
</head>
<body class="admin-body">
    <div class="toast-container" id="toastContainer"></div>

    <div class="container-fluid">
        <div class="row">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="conductores" />
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
                            <i class="bi bi-people text-primary me-2"></i> Conductores
                            <small>Gestión del personal de conducción de la flota</small>
                        </h1>
                    </div>
                    <button class="btn btn-primary rounded-pill px-4 shadow-sm" data-bs-toggle="modal" data-bs-target="#modalConductor" onclick="limpiarModal()">
                        <i class="bi bi-plus-lg me-1"></i> Nuevo Conductor
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

                <!-- Conductores Table -->
                <div class="card card-custom">
                    <div class="card-body p-4">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h5 class="fw-bold mb-0"><i class="bi bi-list-check me-2 text-primary"></i>Listado de Conductores</h5>
                            <span class="badge bg-primary rounded-pill">${listaConductores.size()} registros</span>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>DNI</th>
                                        <th>Nombre Completo</th>
                                        <th>N° Licencia</th>
                                        <th class="text-center">Estado</th>
                                        <th class="text-center">Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="c" items="${listaConductores}">
                                        <tr>
                                            <td><span class="text-muted small fw-bold">#${c.idConductor}</span></td>
                                            <td><span class="fw-semibold">${c.dni}</span></td>
                                            <td>
                                                <div class="d-flex align-items-center">
                                                    <div class="rounded-circle bg-primary bg-opacity-10 p-2 me-2 d-flex align-items-center justify-content-center" style="width: 36px; height: 36px;">
                                                        <i class="bi bi-person text-primary"></i>
                                                    </div>
                                                    <div>
                                                        <span class="fw-semibold">${c.nombre} ${c.apellido}</span>
                                                    </div>
                                                </div>
                                            </td>
                                            <td><code class="text-dark">${c.nroLicencia}</code></td>
                                            <td class="text-center">
                                                <c:choose>
                                                    <c:when test="${c.estado == 'DISPONIBLE'}">
                                                        <span class="badge badge-estado bg-success"><i class="bi bi-check-circle me-1"></i>${c.estado}</span>
                                                    </c:when>
                                                    <c:when test="${c.estado == 'ASIGNADO'}">
                                                        <span class="badge badge-estado bg-warning text-dark"><i class="bi bi-clock me-1"></i>${c.estado}</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-estado bg-secondary"><i class="bi bi-x-circle me-1"></i>${c.estado}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center">
                                                <button class="btn btn-outline-primary btn-action me-1" title="Editar" 
                                                        onclick="editarConductor(${c.idConductor}, '${c.dni}', '${c.nombre}', '${c.apellido}', '${c.nroLicencia}', '${c.estado}')">
                                                    <i class="bi bi-pencil"></i>
                                                </button>
                                                <c:if test="${c.estado != 'INACTIVO'}">
                                                    <form action="ConductorServlet" method="POST" class="d-inline" onsubmit="return confirm('¿Dar de baja al conductor ${c.nombre} ${c.apellido}?')">
                                                        <input type="hidden" name="accion" value="eliminar">
                                                        <input type="hidden" name="idConductor" value="${c.idConductor}">
                                                        <button class="btn btn-outline-danger btn-action" title="Dar de Baja">
                                                            <i class="bi bi-trash"></i>
                                                        </button>
                                                    </form>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty listaConductores}">
                                        <tr>
                                            <td colspan="6">
                                                <div class="empty-state">
                                                    <i class="bi bi-people text-muted"></i>
                                                    <p class="mb-0">No hay conductores registrados en el sistema.</p>
                                                    <button class="btn btn-primary btn-sm mt-2" data-bs-toggle="modal" data-bs-target="#modalConductor">
                                                        <i class="bi bi-plus-lg"></i> Registrar primer conductor
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

    <!-- Modal Crear/Editar Conductor -->
    <div class="modal fade" id="modalConductor" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header border-0">
                    <h5 class="modal-title fw-bold" id="modalTitle"><i class="bi bi-person-plus me-2 text-primary"></i>Registrar Conductor</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form action="ConductorServlet" method="POST" id="formConductor">
                    <div class="modal-body pt-0">
                        <input type="hidden" name="accion" id="accion" value="crear">
                        <input type="hidden" name="idConductor" id="idConductor">
                        
                        <div class="mb-3">
                            <label class="form-label"><i class="bi bi-card-text me-1"></i>DNI</label>
                            <input type="text" class="form-control" name="dni" id="dni" maxlength="8" pattern="\d{8}" placeholder="12345678" required>
                        </div>
                        <div class="row g-3 mb-3">
                            <div class="col-6">
                                <label class="form-label"><i class="bi bi-person me-1"></i>Nombres</label>
                                <input type="text" class="form-control" name="nombre" id="nombre" placeholder="Ej: Carlos" required>
                            </div>
                            <div class="col-6">
                                <label class="form-label"><i class="bi bi-person me-1"></i>Apellidos</label>
                                <input type="text" class="form-control" name="apellido" id="apellido" placeholder="Ej: Ramírez" required>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label"><i class="bi bi-file-earmark-text me-1"></i>N° Licencia de Conducir</label>
                            <input type="text" class="form-control" name="nroLicencia" id="nroLicencia" placeholder="Ej: Q-12345678" required>
                        </div>
                        <div class="mb-3" id="campoEstado" style="display:none;">
                            <label class="form-label"><i class="bi bi-toggle-on me-1"></i>Estado</label>
                            <select class="form-select" name="estado" id="estado">
                                <option value="DISPONIBLE">DISPONIBLE</option>
                                <option value="ASIGNADO">ASIGNADO</option>
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
            document.getElementById('idConductor').value = '';
            document.getElementById('formConductor').reset();
            document.getElementById('modalTitle').innerHTML = '<i class="bi bi-person-plus me-2 text-primary"></i>Registrar Conductor';
            document.getElementById('btnSubmit').innerHTML = '<i class="bi bi-save me-1"></i> Guardar';
            document.getElementById('campoEstado').style.display = 'none';
        }

        function editarConductor(id, dni, nombre, apellido, licencia, estado) {
            document.getElementById('accion').value = 'actualizar';
            document.getElementById('idConductor').value = id;
            document.getElementById('dni').value = dni;
            document.getElementById('nombre').value = nombre;
            document.getElementById('apellido').value = apellido;
            document.getElementById('nroLicencia').value = licencia;
            document.getElementById('estado').value = estado;
            document.getElementById('modalTitle').innerHTML = '<i class="bi bi-pencil me-2 text-warning"></i>Editar Conductor #' + id;
            document.getElementById('btnSubmit').innerHTML = '<i class="bi bi-arrow-repeat me-1"></i> Actualizar';
            document.getElementById('campoEstado').style.display = 'block';
            
            var modal = new bootstrap.Modal(document.getElementById('modalConductor'));
            modal.show();
        }

        // Auto-dismiss alerts after 5 seconds
        setTimeout(function() {
            document.querySelectorAll('.alert').forEach(a => {
                var bsAlert = new bootstrap.Alert(a);
                setTimeout(() => bsAlert.close(), 4000);
            });
        }, 5000);
    </script>
</body>
</html>
