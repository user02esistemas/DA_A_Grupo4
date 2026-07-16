<%-- Modulo de gestion de flota de buses MovilBus --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@page import="dao.BusDAO, model.Usuario"%>
<%
    BusDAO busDAO = new BusDAO();
    request.setAttribute("listaBuses", busDAO.listarBuses());
%>
<%
    // Control de acceso: solo ADMINISTRADOR puede gestionar buses
    Usuario userBus = (Usuario) session.getAttribute("usuarioSesion");
    if (userBus == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String rolBus = userBus.getRol();
    if (!"ADMINISTRADOR".equalsIgnoreCase(rolBus)) {
        response.sendRedirect("ventas.jsp");
        return;
    }
    boolean esAdminBus = true;
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>MovilBus - Gestión de Flota</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="css/movilbus.css">
</head>
<body class="admin-body">
    <div class="container-fluid">
        <div class="row">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="buses" />
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
                            <i class="bi bi-truck text-success me-2"></i> Buses
                            <small>Gestión de la flota vehicular y configuración de asientos</small>
                        </h1>
                    </div>
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

                <div class="row g-4">
                    <!-- Formulario de Registro -->
                    <div class="col-lg-4">
                        <div class="card card-custom h-100">
                            <div class="card-body p-4">
                                <h5 class="fw-bold mb-3"><i class="bi bi-plus-circle text-success me-2"></i>Registrar Nueva Unidad</h5>
                                <form action="BusServlet" method="POST">
                                    <div class="mb-3">
                                        <label class="form-label"><i class="bi bi-upc-scan me-1"></i>Placa</label>
                                        <input type="text" class="form-control" name="placa" placeholder="Ej: ABC-123" required>
                                    </div>
                                    <div class="row g-2 mb-3">
                                        <div class="col-6">
                                            <label class="form-label">Marca</label>
                                            <input type="text" class="form-control" name="marca" placeholder="Scania" required>
                                        </div>
                                        <div class="col-6">
                                            <label class="form-label">Modelo</label>
                                            <input type="text" class="form-control" name="modelo" placeholder="K410" required>
                                        </div>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label"><i class="bi bi-star me-1"></i>Servicio</label>
                                        <select class="form-select" name="idServicio" required>
                                            <option value="" disabled selected>-- Selecciona un Servicio --</option>
                                            <option value="1">Ejecutivo VIP (4 columnas)</option>
                                            <option value="2">Presidencial (3 columnas)</option>
                                            <option value="3">Premier (3 columnas)</option>
                                        </select>
                                    </div>
                                    <div class="row g-2 mb-3">
                                        <div class="col-6">
                                            <label class="form-label">Asientos</label>
                                            <select class="form-select" name="capacidad" required>
                                                <option value="32">32 Asientos</option>
                                                <option value="37">37 Asientos</option>
                                                <option value="40">40 Asientos</option>
                                                <option value="43">43 Asientos</option>
                                                <option value="60">60 Asientos</option>
                                            </select>
                                        </div>
                                        <div class="col-6">
                                            <label class="form-label">Pisos</label>
                                            <select class="form-select" name="pisos" required>
                                                <option value="1">1 Piso</option>
                                                <option value="2">2 Pisos</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="alert alert-primary p-2 small mb-3">
                                        <i class="bi bi-info-circle me-1"></i>
                                        La plantilla de asientos se genera automáticamente según servicio y capacidad.
                                    </div>
                                    <button type="submit" class="btn btn-success w-100 fw-bold rounded-pill">
                                        <i class="bi bi-save me-1"></i> Guardar Unidad
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- Tabla de Buses -->
                    <div class="col-lg-8">
                        <div class="card card-custom">
                            <div class="card-body p-4">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <h5 class="fw-bold mb-0"><i class="bi bi-list-check me-2 text-primary"></i>Flota Vehicular</h5>
                                    <span class="badge bg-primary rounded-pill">${listaBuses.size()} unidades</span>
                                </div>
                                <div class="table-responsive">
                                    <table class="table table-hover align-middle mb-0">
                                        <thead>
                                            <tr>
                                                <th>ID</th>
                                                <th>Placa</th>
                                                <th>Marca / Modelo</th>
                                                <th>Servicio</th>
                                                <th class="text-center">Asientos</th>
                                                <th class="text-center">Pisos</th>
                                                <th class="text-center">Estado</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="b" items="${listaBuses}">
                                                <tr>
                                                    <td><span class="text-muted small fw-bold">#${b.idBus}</span></td>
                                                    <td><strong class="text-monospace">${b.placa}</strong></td>
                                                    <td>
                                                        <div class="d-flex align-items-center">
                                                            <i class="bi bi-truck fs-4 text-muted me-2"></i>
                                                            <div>
                                                                <span class="fw-semibold">${b.marca}</span>
                                                                <small class="text-muted d-block">${b.modelo}</small>
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${b.nombreServicio == 'EJECUTIVO VIP'}">
                                                                <span class="badge badge-servicio bg-primary">${b.nombreServicio}</span>
                                                            </c:when>
                                                            <c:when test="${b.nombreServicio == 'PRESIDENCIAL'}">
                                                                <span class="badge badge-servicio bg-warning text-dark">${b.nombreServicio}</span>
                                                            </c:when>
                                                            <c:when test="${b.nombreServicio == 'PREMIER'}">
                                                                <span class="badge badge-servicio bg-dark">${b.nombreServicio}</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge badge-servicio bg-secondary">${b.nombreServicio}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td class="text-center"><span class="badge bg-secondary rounded-pill">${b.capacidadAsientos}</span></td>
                                                    <td class="text-center">
                                                        <c:if test="${b.cantidadPisos == 2}">
                                                            <i class="bi bi-layers text-primary"></i>
                                                        </c:if>
                                                        <span>${b.cantidadPisos}</span>
                                                    </td>
                                                    <td class="text-center">
                                                        <span class="badge ${b.estado == 'ACTIVO' ? 'bg-success' : 'bg-warning text-dark'}">
                                                            ${b.estado}
                                                        </span>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                            <c:if test="${empty listaBuses}">
                                                <tr>
                                                    <td colspan="7">
                                                        <div class="empty-state">
                                                            <i class="bi bi-truck text-muted"></i>
                                                            <p class="mb-0">No hay buses operativos registrados actualmente.</p>
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
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Validar formato de placa en tiempo real
        document.querySelector('input[name="placa"]').addEventListener('input', function() {
            this.value = this.value.toUpperCase().replace(/[^A-Z0-9-]/g, '');
            if (this.value.length === 3 && !this.value.includes('-')) {
                this.value = this.value + '-';
            }
            if (this.value.length > 7) {
                this.value = this.value.slice(0, 7);
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
