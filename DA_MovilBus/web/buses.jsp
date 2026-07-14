<%-- 
    Document   : buses
    Created on : 12 jul. 2026, 7:44:44 p. m.
    Author     : Risco
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@page import="dao.BusDAO"%>
<%
    // Instanciamos el DAO e inyectamos la lista directo al alcance de la página (request scope)
    BusDAO busDAO = new BusDAO();
    request.setAttribute("listaBuses", busDAO.listarBuses());
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>MovilBus - Gestión de Flota</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<nav class="navbar navbar-expand-lg navbar-dark bg-dark shadow-sm">
    <div class="container-fluid">
        <a class="navbar-brand fw-bold text-primary" href="dashboard.jsp">🚌 MovilBus Intranet</a>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav me-auto">
                <li class="nav-item"><a class="nav-link" href="dashboard.jsp">Inicio</a></li>
                <li class="nav-item"><a class="nav-link active" href="buses.jsp">Módulo Buses</a></li>
                <li class="nav-item"><a class="nav-link" href="viajes.jsp">Programación de Viajes</a></li>
            </ul>
            <a href="login.jsp" class="btn btn-outline-danger btn-sm">Salir</a>
        </div>
    </div>
</nav>

<div class="container mt-5">
    <div class="row">
        <div class="col-md-4">
            <div class="card shadow-sm border-0 p-4 mb-4">
                <h4 class="fw-bold text-dark mb-3">Registrar Nuevo Bus</h4>
                
                <c:if test="${not empty sessionScope.msgExito}">
                    <div class="alert alert-success p-2 text-center small">${sessionScope.msgExito}</div>
                    <c:remove var="msgExito" scope="session"/>
                </c:if>
                <c:if test="${not empty sessionScope.msgError}">
                    <div class="alert alert-danger p-2 text-center small">${sessionScope.msgError}</div>
                    <c:remove var="msgError" scope="session"/>
                </c:if>

                <form action="BusServlet" method="POST">
                    <div class="mb-3">
                        <label class="form-label font-monospace small">Placa de Rodaje</label>
                        <input type="text" class="form-control" name="placa" placeholder="Ej: ABC-123" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label font-monospace small">Marca</label>
                        <input type="text" class="form-control" name="marca" placeholder="Ej: Scania, Mercedes-Benz" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label font-monospace small">Modelo</label>
                        <input type="text" class="form-control" name="modelo" placeholder="Ej: Marcopolo G8" required>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label font-monospace small">Servicio</label>
                        <select class="form-select" name="idServicio" required>
                            <option value="" disabled selected>-- Selecciona un Servicio --</option>
                            <option value="1">Ejecutivo VIP (4 columnas)</option>
                            <option value="2">Presidencial (3 columnas)</option>
                            <option value="3">Premier (3 columnas)</option>
                        </select>
                    </div>

                    <div class="row">
                        <div class="col-6 mb-3">
                            <label class="form-label font-monospace small">Asientos</label>
                            <select class="form-select" name="capacidad" required>
                                <option value="32">32 Asientos (Especial)</option>
                                <option value="37">37 Asientos (Especial)</option>
                                <option value="40">40 Asientos (Estándar)</option>
                                <option value="60">60 Asientos (Doble Piso)</option>
                            </select>
                        </div>
                        <div class="col-6 mb-3">
                            <label class="form-label font-monospace small">Pisos</label>
                            <select class="form-select" name="pisos" required>
                                <option value="1">1 Piso</option>
                                <option value="2">2 Pisos</option>
                            </select>
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary w-100 fw-bold mt-2">Guardar Unidad</button>
                </form>
            </div>
        </div>

        <div class="col-md-8">
            <div class="card shadow-sm border-0 p-4">
                <h4 class="fw-bold text-dark mb-3">Flota Vehicular Activa</h4>
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-light">
                            <tr>
                                <th>ID</th>
                                <th>Placa</th>
                                <th>Marca / Modelo</th>
                                <th>Servicio</th>
                                <th class="text-center">Capacidad</th>
                                <th class="text-center">Pisos</th>
                                <th class="text-center">Estado</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="b" items="${listaBuses}">
                                <tr>
                                    <td><span class="text-muted small">#${b.idBus}</span></td>
                                    <td><strong class="text-monospace">${b.placa}</strong></td>
                                    <td>${b.marca} <span class="text-secondary small">(${b.modelo})</span></td>
                                    <td>
                                        <span class="badge bg-light text-dark border">
                                            ${b.nombreServicio != null ? b.nombreServicio : 'Sin asignar'}
                                        </span>
                                    </td>
                                    <td class="text-center"><span class="badge bg-secondary">${b.capacidadAsientos}</span></td>
                                    <td class="text-center">${b.cantidadPisos}</td>
                                    <td class="text-center">
                                        <span class="badge ${b.estado == 'ACTIVO' ? 'bg-success' : 'bg-warning'}">
                                            ${b.estado}
                                        </span>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty listaBuses}">
                                <tr>
                                    <td colspan="7" class="text-center text-muted py-3">No hay buses operativos registrados actualmente.</td>
                                </tr>
                            </c:if>
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