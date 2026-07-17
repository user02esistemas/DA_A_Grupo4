<%-- Modulo de programacion de viajes y asignacion de tripulacion --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@page import="dao.BusDAO, dao.ViajeDAO, dao.ConductorDAO, dao.RutaDAO, model.Usuario"%>
<%
    BusDAO busDAO = new BusDAO();
    RutaDAO rutaDAO = new RutaDAO();
    ConductorDAO condDAO = new ConductorDAO();
    ViajeDAO viajeDAO = new ViajeDAO();
    
    request.setAttribute("listaBuses", busDAO.listarBuses());
    request.setAttribute("listaRutas", rutaDAO.listarRutas()); 
    
    java.util.List<model.Conductor> disponibles = condDAO.listarConductoresDisponibles();
    if (disponibles == null || disponibles.isEmpty()) {
        disponibles = condDAO.listarConductores(); 
    }
    
    request.setAttribute("listaConductores", disponibles);
    request.setAttribute("listaViajes", viajeDAO.listarViajesProgramados());
    request.setAttribute("listaViajesHistorial", viajeDAO.listarTodosLosViajes());
%>
<%
    // Control de acceso: solo ADMINISTRADOR puede gestionar viajes
    Usuario userVia = (Usuario) session.getAttribute("usuarioSesion");
    if (userVia == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String rolVia = userVia.getRol();
    if (!"ADMINISTRADOR".equalsIgnoreCase(rolVia)) {
        response.sendRedirect("ventas.jsp");
        return;
    }
    boolean esAdminVia = true;
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>MovilBus - Programación de Viajes</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="css/movilbus.css">
</head>
<body class="admin-body">
    <div class="container-fluid">
        <div class="row">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="viajes" />
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
                            <i class="bi bi-calendar-event text-primary me-2"></i> Programación de Viajes
                            <small>Programa salidas, asigna rutas y tripulación con control transaccional</small>
                        </h1>
                    </div>
                </div>

                <!-- Success/Error Messages -->
                <c:if test="${not empty sessionScope.msgExitoViaje}">
                    <div class="alert alert-success alert-dismissible fade show rounded-3 shadow-sm" role="alert">
                        <i class="bi bi-check-circle me-2"></i> ${sessionScope.msgExitoViaje}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <c:remove var="msgExitoViaje" scope="session"/>
                </c:if>
                <c:if test="${not empty sessionScope.msgErrorViaje}">
                    <div class="alert alert-danger alert-dismissible fade show rounded-3 shadow-sm" role="alert">
                        <i class="bi bi-exclamation-triangle me-2"></i> ${sessionScope.msgErrorViaje}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <c:remove var="msgErrorViaje" scope="session"/>
                </c:if>

                <div class="row g-4">
                    <!-- Formulario de Programación -->
                    <div class="col-lg-4">
                        <div class="card card-custom">
                            <div class="card-body p-4">
                                <h5 class="fw-bold mb-3"><i class="bi bi-plus-circle text-success me-2"></i>Programar Nuevo Viaje</h5>
                                <form action="ViajeServlet" method="POST">
                                    <div class="mb-3">
                                        <label class="form-label"><i class="bi bi-signpost-2 me-1"></i>Ruta Comercial</label>
                                        <select class="form-select" name="idRuta" required>
                                            <option value="">-- Seleccione Ruta --</option>
                                            <c:forEach var="r" items="${listaRutas}">
                                                <c:if test="${r.estado == 'ACTIVO'}">
                                                    <option value="${r.idRuta}">${r.origen} ➔ ${r.destino} (S/. ${r.precioBase})</option>
                                                </c:if>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label class="form-label"><i class="bi bi-truck me-1"></i>Bus Asignado</label>
                                        <select class="form-select" name="idBus" required>
                                            <option value="">-- Seleccione Unidad --</option>
                                            <c:forEach var="b" items="${listaBuses}">
                                                <c:if test="${b.estado == 'ACTIVO'}">
                                                    <option value="${b.idBus}">${b.placa} - ${b.marca} (${b.capacidadAsientos} as.)</option>
                                                </c:if>
                                            </c:forEach>
                                        </select>
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label"><i class="bi bi-clock me-1"></i>Fecha y Hora de Salida</label>
                                        <input type="datetime-local" class="form-control" name="fechaHora" required>
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label fw-bold text-primary"><i class="bi bi-people me-1"></i>Tripulación</label>
                                        <div id="contenedor-conductores">
                                            <div class="row g-2 mb-2 fila-conductor">
                                                <div class="col-10">
                                                    <select class="form-select select-conductor" name="idConductores" required onchange="validarConductoresDuplicados()">
                                                        <option value="">-- Conductor Principal --</option>
                                                        <c:forEach var="c" items="${listaConductores}">
                                                            <option value="${c.idConductor}">${c.apellido}, ${c.nombre} (${c.estado})</option>
                                                        </c:forEach>
                                                    </select>
                                                </div>
                                                <div class="col-2 d-flex align-items-center">
                                                    <span class="badge bg-primary w-100">Piloto</span>
                                                </div>
                                            </div>
                                        </div>
                                        <button type="button" class="btn btn-add-conductor w-100 mt-1 fw-bold text-muted" onclick="agregarCopiloto()">
                                            <i class="bi bi-plus-lg me-1"></i> Añadir Conductor de Relevo
                                        </button>
                                    </div>

                                    <button type="submit" class="btn btn-success w-100 fw-bold rounded-pill mt-3">
                                        <i class="bi bi-calendar-check me-1"></i> Programar Salida
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- Tabla de Viajes -->
                    <div class="col-lg-8">
                        <div class="card card-custom">
                            <div class="card-body p-4">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <h5 class="fw-bold mb-0"><i class="bi bi-list-check me-2 text-primary"></i>Itinerarios Programados</h5>
                                    <span class="badge bg-primary rounded-pill">${listaViajes.size()} viajes</span>
                                </div>
                                <!-- Toggle: Proximos vs Historial -->
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <div class="btn-group btn-group-sm" role="group">
                                        <button type="button" class="btn btn-outline-primary active" id="btnProximos" onclick="toggleTabla('proximos')">
                                            <i class="bi bi-calendar-event me-1"></i> Próximos Viajes
                                        </button>
                                        <button type="button" class="btn btn-outline-secondary" id="btnHistorial" onclick="toggleTabla('historial')">
                                            <i class="bi bi-clock-history me-1"></i> Historial Completo
                                        </button>
                                    </div>
                                    <span class="badge bg-primary rounded-pill" id="badgeCount">${listaViajes.size()} viajes</span>
                                </div>

                                <div class="table-responsive">
                                    <!-- Tabla: Proximos Viajes -->
                                    <table class="table table-hover align-middle mb-0" id="tablaProximos">
                                        <thead>
                                            <tr>
                                                <th>ID</th>
                                                <th>Ruta</th>
                                                <th>Salida</th>
                                                <th>Llegada Est.</th>
                                                <th>Bus</th>
                                                <th class="text-center">Estado</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="v" items="${listaViajes}">
                                                <tr>
                                                    <td><span class="text-muted small fw-bold">#${v.idViaje}</span></td>
                                                    <td class="fw-semibold">${v.nombreRuta}</td>
                                                    <td>
                                                        <small class="text-muted">
                                                            <i class="bi bi-calendar3 me-1"></i>${v.fechaHora}
                                                        </small>
                                                    </td>
                                                    <td>
                                                        <small class="text-muted">
                                                            <i class="bi bi-clock me-1"></i>${v.fechaHoraLlegada}
                                                        </small>
                                                    </td>
                                                    <td><span class="badge bg-dark">${v.placaBus}</span></td>
                                                    <td class="text-center">
                                                        <c:choose>
                                                            <c:when test="${v.estado == 'PROGRAMADO'}">
                                                                <span class="badge bg-primary">${v.estado}</span>
                                                            </c:when>
                                                            <c:when test="${v.estado == 'EN_RUTA'}">
                                                                <span class="badge bg-success">${v.estado}</span>
                                                            </c:when>
                                                            <c:when test="${v.estado == 'FINALIZADO'}">
                                                                <span class="badge bg-secondary">${v.estado}</span>
                                                            </c:when>
                                                            <c:when test="${v.estado == 'CANCELADO'}">
                                                                <span class="badge bg-danger">${v.estado}</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-warning text-dark">${v.estado}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                            <c:if test="${empty listaViajes}">
                                                <tr>
                                                    <td colspan="6">
                                                        <div class="empty-state">
                                                            <i class="bi bi-calendar-event text-muted"></i>
                                                            <p class="mb-0">No hay salidas programadas actualmente.</p>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:if>
                                        </tbody>
                                    </table>

                                    <!-- Tabla: Historial Completo -->
                                    <table class="table table-hover align-middle mb-0" id="tablaHistorial" style="display:none;">
                                        <thead>
                                            <tr>
                                                <th>ID</th>
                                                <th>Ruta</th>
                                                <th>Salida</th>
                                                <th>Llegada Est.</th>
                                                <th>Bus</th>
                                                <th class="text-center">Estado</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="v" items="${listaViajesHistorial}">
                                                <tr class="${v.estado == 'FINALIZADO' ? 'table-light' : v.estado == 'CANCELADO' ? 'table-danger' : ''}">
                                                    <td><span class="text-muted small fw-bold">#${v.idViaje}</span></td>
                                                    <td class="fw-semibold">${v.nombreRuta}</td>
                                                    <td>
                                                        <small class="text-muted">
                                                            <i class="bi bi-calendar3 me-1"></i>${v.fechaHora}
                                                        </small>
                                                    </td>
                                                    <td>
                                                        <small class="text-muted">
                                                            <i class="bi bi-clock me-1"></i>${v.fechaHoraLlegada}
                                                        </small>
                                                    </td>
                                                    <td><span class="badge bg-dark">${v.placaBus}</span></td>
                                                    <td class="text-center">
                                                        <c:choose>
                                                            <c:when test="${v.estado == 'PROGRAMADO'}">
                                                                <span class="badge bg-primary">${v.estado}</span>
                                                            </c:when>
                                                            <c:when test="${v.estado == 'EN_RUTA'}">
                                                                <span class="badge bg-success">${v.estado}</span>
                                                            </c:when>
                                                            <c:when test="${v.estado == 'FINALIZADO'}">
                                                                <span class="badge bg-secondary">${v.estado}</span>
                                                            </c:when>
                                                            <c:when test="${v.estado == 'CANCELADO'}">
                                                                <span class="badge bg-danger">${v.estado}</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-warning text-dark">${v.estado}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                            <c:if test="${empty listaViajesHistorial}">
                                                <tr>
                                                    <td colspan="6">
                                                        <div class="empty-state">
                                                            <i class="bi bi-calendar-event text-muted"></i>
                                                            <p class="mb-0">No hay viajes registrados.</p>
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
        function agregarCopiloto() {
            const contenedor = document.getElementById("contenedor-conductores");
            const selectOriginal = contenedor.querySelector(".fila-conductor select");
            if (!selectOriginal) return;

            const nuevaFila = document.createElement("div");
            nuevaFila.className = "row g-2 mb-2 fila-conductor";

            const nuevoSelect = selectOriginal.cloneNode(true);
            nuevoSelect.value = "";
            nuevoSelect.options[0].text = "-- Seleccione Copiloto --";
            nuevoSelect.required = false;

            const colSelect = document.createElement("div");
            colSelect.className = "col-10";
            colSelect.appendChild(nuevoSelect);

            const colBoton = document.createElement("div");
            colBoton.className = "col-2";
            colBoton.innerHTML = `<button type="button" class="btn btn-outline-danger btn-sm w-100 fw-bold" onclick="eliminarFila(this)" title="Quitar conductor"><i class="bi bi-x-lg"></i></button>`;

            nuevaFila.appendChild(colSelect);
            nuevaFila.appendChild(colBoton);
            contenedor.appendChild(nuevaFila);
        }

        function eliminarFila(boton) {
            const fila = boton.closest(".fila-conductor");
            if (fila) {
                fila.remove();
                validarConductoresDuplicados();
            }
        }

        function validarConductoresDuplicados() {
            const selects = document.querySelectorAll(".select-conductor");
            const valoresSeleccionados = [];

            selects.forEach(select => {
                select.classList.remove("is-invalid");
                if (select.value !== "") {
                    if (valoresSeleccionados.includes(select.value)) {
                        select.classList.add("is-invalid");
                        alert("⚠️ No puedes asignar al mismo conductor más de una vez.");
                        select.value = "";
                    } else {
                        valoresSeleccionados.push(select.value);
                    }
                }
            });
        }

        function toggleTabla(vista) {
            const tablaProx = document.getElementById('tablaProximos');
            const tablaHist = document.getElementById('tablaHistorial');
            const btnProx = document.getElementById('btnProximos');
            const btnHist = document.getElementById('btnHistorial');
            const badge = document.getElementById('badgeCount');

            if (vista === 'proximos') {
                tablaProx.style.display = '';
                tablaHist.style.display = 'none';
                btnProx.classList.add('active');
                btnHist.classList.remove('active');
                badge.textContent = '${listaViajes.size()} viaje(s)';
                badge.className = 'badge bg-primary rounded-pill';
            } else {
                tablaProx.style.display = 'none';
                tablaHist.style.display = '';
                btnProx.classList.remove('active');
                btnHist.classList.add('active');
                badge.textContent = '${listaViajesHistorial.size()} viaje(s)';
                badge.className = 'badge bg-secondary rounded-pill';
            }
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
