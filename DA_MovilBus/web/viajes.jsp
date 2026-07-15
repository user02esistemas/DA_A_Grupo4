<%-- 
    Document   : viajes
    Created on : 13 jul. 2026, 3:17:58 a. m.
    Author     : Risco
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@page import="dao.BusDAO, dao.ViajeDAO, dao.ConductorDAO, dao.RutaDAO"%>
<%
    BusDAO busDAO = new BusDAO();
    RutaDAO rutaDAO = new RutaDAO();
    ConductorDAO condDAO = new ConductorDAO();
    ViajeDAO viajeDAO = new ViajeDAO();
    
    request.setAttribute("listaBuses", busDAO.listarBuses());
    request.setAttribute("listaRutas", rutaDAO.listarRutas()); 
    
    // 🛠️ Intenta jalar los disponibles primero
    java.util.List<model.Conductor> disponibles = condDAO.listarConductoresDisponibles();
    
    // Si la base de datos no tiene a nadie como 'DISPONIBLE', jalamos todos para que no quede vacío el combobox
    if (disponibles == null || disponibles.isEmpty()) {
        disponibles = condDAO.listarConductores(); 
    }
    
    request.setAttribute("listaConductores", disponibles);
    request.setAttribute("listaViajes", viajeDAO.listarViajesProgramados());
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>MovilBus - Programación de Itinerarios</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        /* Contenedor que agrupa los asientos en 4 columnas emulando el bus */
        .grid-bus-40 {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 12px;
            max-width: 320px;
            margin: 0 auto;
        }
        .btn-asiento {
            width: 50px;
            height: 50px;
            font-weight: bold;
            border-radius: 8px;
            border: 2px solid #ccc;
        }
        .btn-asiento.disponible { background-color: #e3f2fd; color: #0d6efd; }
        .btn-asiento.ocupado { background-color: #f8d7da; color: #dc3545; cursor: not-allowed; }
        .btn-asiento.seleccionado { background-color: #2ecc71; color: white; }

        /* Espaciador para simular el pasadizo central después de la segunda columna */
        .grid-bus-40 button:nth-child(4n+2) {
            margin-right: 25px; 
        }
    </style>
</head>
<body class="bg-light">

<nav class="navbar navbar-expand-lg navbar-dark bg-dark shadow-sm">
    <div class="container-fluid">
        <a class="navbar-brand fw-bold text-primary" href="dashboard.jsp">🚌 MovilBus Intranet</a>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav me-auto">
                <li class="nav-item"><a class="nav-link" href="dashboard.jsp">Inicio</a></li>
                <li class="nav-item"><a class="nav-link" href="buses.jsp">Módulo Buses</a></li>
                <li class="nav-item"><a class="nav-link active" href="viajes.jsp">Programación de Viajes</a></li>
            </ul>
            <a href="login.jsp" class="btn btn-outline-danger btn-sm">Salir</a>
        </div>
    </div>
</nav>

<div class="container mt-5">
    <div class="row">
        <div class="col-md-4">
            <div class="card shadow-sm border-0 p-4 mb-4">
                <h4 class="fw-bold text-dark mb-3">Programar Nuevo Viaje</h4>
                
                <c:if test="${not empty sessionScope.msgExitoViaje}">
                    <div class="alert alert-success p-2 text-center small">${sessionScope.msgExitoViaje}</div>
                    <c:remove var="msgExitoViaje" scope="session"/>
                </c:if>
                <c:if test="${not empty sessionScope.msgErrorViaje}">
                    <div class="alert alert-danger p-2 text-center small">${sessionScope.msgErrorViaje}</div>
                    <c:remove var="msgErrorViaje" scope="session"/>
                </c:if>

                <form action="ViajeServlet" method="POST">
                    <div class="mb-3">
                        <label class="form-label font-monospace small">Ruta Comercial</label>
                        <select class="form-select" name="idRuta" required>
                            <option value="">-- Seleccione Ruta --</option>
                            <c:forEach var="r" items="${listaRutas}">
                                <option value="${r.idRuta}">${r.origen} ➔ ${r.destino} (S/. ${r.precioBase})</option>
                            </c:forEach>
                        </select>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label font-monospace small">Bus Asignado</label>
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
                        <label class="form-label font-monospace small">Fecha y Hora de Salida</label>
                        <input type="datetime-local" class="form-control" name="fechaHora" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label font-monospace small fw-bold text-primary">Tripulación del Viaje</label>

                        <div id="contenedor-conductores">
                            <div class="row g-2 mb-2 fila-conductor">
                                <div class="col-10">
                                    <select class="form-select select-conductor" name="idConductores" required onchange="validarConductoresDuplicados()">
                                        <option value="">-- Seleccione Conductor Principal --</option>
                                        <c:forEach var="c" items="${listaConductores}">
                                            <option value="${c.idConductor}">${c.apellido}, ${c.nombre} (${c.estado})</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-2 text-center align-self-center">
                                    <span class="badge bg-primary text-wrap small">Piloto</span>
                                </div>
                            </div>
                        </div>

                        <button type="button" class="btn btn-outline-secondary btn-sm w-100 mt-1 fw-bold" onclick="agregarCopiloto()">
                            ➕ Añadir Conductor de Relevo (Copiloto)
                        </button>
                    </div>

                    <script>
                    function agregarCopiloto() {
                        const contenedor = document.getElementById("contenedor-conductores");

                        // 1. Buscamos el PRIMER select original que renderizó JSP desde el servidor
                        const selectOriginal = contenedor.querySelector(".fila-conductor select");
                        if (!selectOriginal) return;

                        // 2. Creamos la nueva fila
                        const nuevaFila = document.createElement("div");
                        nuevaFila.className = "row g-2 mb-2 fila-conductor";

                        // 3. Clonamos estructuralmente el nodo select para arrastrar TODOS los <option> internos intactos
                        const nuevoSelect = selectOriginal.cloneNode(true);
                        nuevoSelect.value = ""; // Limpiamos cualquier selección previa que tuviera el original
                        nuevoSelect.options[0].text = "-- Seleccione Copiloto de Relevo --"; // Ajustamos el texto inicial

                        // 4. Construimos el contenedor para el botón de eliminar
                        const colSelect = document.createElement("div");
                        colSelect.className = "col-10";
                        colSelect.appendChild(nuevoSelect);

                        const colBoton = document.createElement("div");
                        colBoton.className = "col-2";
                        colBoton.innerHTML = `<button type="button" class="btn btn-danger btn-sm w-100 fw-bold" onclick="eliminarFila(this)">❌</button>`;

                        // 5. Armamos la fila y la insertamos
                        nuevaFila.appendChild(colSelect);
                        nuevaFila.appendChild(colBoton);
                        contenedor.appendChild(nuevaFila);
                    }

                    function eliminarFila(boton) {
                        const fila = boton.closest(".fila-conductor");
                        if (fila) {
                            fila.remove();
                            validarConductoresDuplicados(); // Re-evaluar tras eliminar una fila
                        }
                    }

                    // 🛠️ VALIDACIÓN EN TIEMPO REAL
                    function validarConductoresDuplicados() {
                        // Captura todos los select de conductores activos en pantalla
                        const selects = document.querySelectorAll(".select-conductor");
                        const valoresSeleccionados = [];

                        selects.forEach(select => {
                            // Limpiamos estilos de error previos
                            select.classList.remove("is-invalid");

                            if (select.value !== "") {
                                // Si el ID ya fue seleccionado antes... ¡Alerta!
                                if (valoresSeleccionados.includes(select.value)) {
                                    select.classList.add("is-invalid");
                                    alert("⚠️ Error: No puedes asignar al mismo conductor más de una vez en este viaje.");
                                    select.value = ""; // Resetea la selección duplicada
                                } else {
                                    valoresSeleccionados.push(select.value);
                                }
                            }
                        });
                    }
                    </script>

                    <button type="submit" class="btn btn-success w-100 fw-bold mt-2">Programar Salida</button>
                </form>
            </div>
        </div>

        <div class="col-md-8">
            <div class="card shadow-sm border-0 p-4">
                <h4 class="fw-bold text-dark mb-3">Itinerarios y Salidas Programadas</h4>
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-light">
                            <tr>
                                <th>ID</th>
                                <th>Origen / Destino</th>
                                <th>Fecha y Hora</th>
                                <th>Bus (Placa)</th>
                                <th class="text-center">Estado</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="v" items="${listaViajes}">
                                <tr>
                                    <td><span class="text-muted small">#${v.idViaje}</span></td>
                                    <td><strong>${v.nombreRuta}</strong></td>
                                    <td>${v.fechaHora}</td>
                                    <td><span class="badge bg-dark">${v.placaBus}</span></td>
                                    <td class="text-center">
                                        <span class="badge bg-primary">${v.estado}</span>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty listaViajes}">
                                <tr>
                                    <td colspan="5" class="text-center text-muted py-3">No hay salidas programadas en el sistema.</td>
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