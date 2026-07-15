<%-- 
    Document   : ventas
    Created on : 13 jul. 2026, 3:27:50 a. m.
    Author     : Risco
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@page import="java.util.List, java.util.Map"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>MovilBus - Taquilla de Ventas</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
    /* =========================================================================
       PLANTILLA 1: EJECUTIVO VIP (4 columnas + Pasillo Central)
       Distribución: [Asiento] [Asiento] [Pasillo] [Asiento] [Asiento]
       ========================================================================= */
    .grid-4-columnas {
        display: grid;
        grid-template-columns: 1fr 1fr 0.4fr 1fr 1fr;
        gap: 12px;
        align-items: center;
        background-color: #f8f9fa;
        padding: 20px;
        border-radius: 12px;
        border: 2px dashed #dee2e6;
    }
    
    /* Espaciador del pasillo para 4 columnas */
    .grid-4-columnas .pasillo {
        grid-column: 3;
        height: 20px;
        background: transparent;
    }

    /* =========================================================================
       PLANTILLA 2: PRESIDENCIAL / PREMIER (3 columnas de Lujo + Pasillo Derecho)
       Distribución: [Asiento] [Asiento] [Pasillo] [Asiento Individual]
       ========================================================================= */
    .grid-3-columnas {
        display: grid;
        grid-template-columns: 1.1fr 1.1fr 0.4fr 1.1fr;
        gap: 12px;
        align-items: center;
        background-color: #f4f6f9;
        padding: 20px;
        border-radius: 12px;
        border: 2px dashed #0d6efd;
    }

    /* Espaciador del pasillo para 3 columnas */
    .grid-3-columnas .pasillo {
        grid-column: 3;
        height: 20px;
        background: transparent;
    }

    /* Estilos Estándar de Asientos */
    .btn-asiento {
        height: 50px;
        border: 2px solid transparent;
        border-radius: 8px;
        font-weight: bold;
        font-size: 15px;
        cursor: pointer;
        transition: all 0.2s ease-in-out;
    }

    .btn-asiento.disponible { 
        background-color: #198754; 
        color: white; 
        border-color: #157347; 
    }
    .btn-asiento.disponible:hover { 
        background-color: #157347; 
        transform: translateY(-2px); 
        box-shadow: 0 4px 8px rgba(0,0,0,0.15); 
    }
    .btn-asiento.ocupado { 
        background-color: #dc3545; 
        color: white; 
        border-color: #b02a37; 
        cursor: not-allowed; 
        opacity: 0.55; 
    }
    .btn-asiento.seleccionado { 
        background-color: #ffc107; 
        color: #212529; 
        border-color: #ffca2c; 
        animation: pulse 0.8s infinite alternate; 
    }

    @keyframes pulse { 
        from { transform: scale(1); } 
        to { transform: scale(1.04); box-shadow: 0 0 12px rgba(255,193,7,0.6); } 
    }
    </style>
</head>
<body class="bg-light">

<nav class="navbar navbar-expand-lg navbar-dark bg-dark shadow-sm">
    <div class="container-fluid">
        <a class="navbar-brand fw-bold text-primary" href="dashboard.jsp">🚌 MovilBus Intranet</a>
    </div>
</nav>

<div class="container mt-4">
    
    <c:if test="${param.status == 'success'}">
        <div class="alert alert-success text-center fw-bold shadow-sm">¡Pasaje emitido con éxito!</div>
    </c:if>
    <c:if test="${param.status == 'error'}">
        <div class="alert alert-danger text-center fw-bold shadow-sm">Error al emitir el pasaje. Verifique los datos.</div>
    </c:if>

    <div class="row justify-content-center">
        <div class="col-md-11">
            
            <div class="card shadow-sm border-0 p-4 mb-4">
                <h4 class="fw-bold text-dark mb-3">Buscar Viajes Disponibles</h4>
                <form action="VentaServlet" method="GET" class="row g-3">
                    <input type="hidden" name="accion" value="buscar">
                    <div class="col-md-4">
                        <label class="form-label font-monospace small">Ciudad Origen</label>
                        <select class="form-select" name="idOrigen" required>
                            <option value="1" ${param.idOrigen == '1' ? 'selected' : ''}>Chiclayo</option>
                            <option value="2" ${param.idOrigen == '2' ? 'selected' : ''}>Lima</option>
                            <option value="3" ${param.idOrigen == '3' ? 'selected' : ''}>Trujillo</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label font-monospace small">Ciudad Destino</label>
                        <select class="form-select" name="idDestino" required>
                            <option value="2" ${param.idDestino == '2' ? 'selected' : ''}>Lima</option>
                            <option value="1" ${param.idDestino == '1' ? 'selected' : ''}>Chiclayo</option>
                            <option value="3" ${param.idDestino == '3' ? 'selected' : ''}>Trujillo</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label font-monospace small">Fecha de Viaje</label>
                        <input type="date" class="form-control" name="fecha" required value="${param.fecha}">
                    </div>
                    <div class="col-12 mt-3">
                        <button type="submit" class="btn btn-primary w-100 fw-bold">Buscar Salidas</button>
                    </div>
                </form>
            </div>

            <c:if test="${not empty listaViajesBusqueda}">
                <div class="card shadow-sm border-0 p-4 mb-4">
                    <h5 class="fw-bold text-dark mb-3">Horarios Encontrados</h5>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Salida</th>
                                    <th>Ruta</th>
                                    <th>Bus / Servicio</th>
                                    <th>Precio Base</th>
                                    <th class="text-center">Acción</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="v" items="${listaViajesBusqueda}">
                                    <tr class="${param.idViaje == v.idViaje ? 'table-primary' : ''}">
                                        <td><strong>${v.fechaHora}</strong></td>
                                        <td>${v.origen} ➔ ${v.destino}</td>
                                        <td>
                                            <span class="badge bg-dark">${v.placa}</span> 
                                            <span class="text-secondary small">(${v.marca} - ${v.nombreServicio})</span>
                                        </td>
                                        <td class="text-success fw-bold">S/. ${v.precioBase}</td>
                                        <td class="text-center">
                                            <a href="VentaServlet?accion=verAsientos&idViaje=${v.idViaje}&idOrigen=${param.idOrigen}&idDestino=${param.idDestino}&fecha=${param.fecha}" 
                                               class="btn btn-success btn-sm fw-bold">
                                                Seleccionar Asientos
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </c:if>

            <c:if test="${param.accion == 'verAsientos'}">
                
                <c:forEach var="v" items="${listaViajesBusqueda}">
                    <c:if test="${v.idViaje == param.idViaje}">
                        <c:set var="viajeActual" value="${v}" />
                    </c:if>
                </c:forEach>

                <div class="row g-4">
                    
                    <div class="col-md-7">
                        <div class="card shadow-sm border-0 p-4 h-100">
                            <h5 class="fw-bold text-dark text-center mb-1">Mapa de Distribución</h5>
                            <p class="text-muted text-center small mb-4">
                                Servicio: <strong class="text-primary">${viajeActual.nombreServicio}</strong>
                            </p>

                            <div class="piso-contenedor mb-4">
                                <h6 class="fw-bold text-primary border-bottom pb-2">PRIMER PISO</h6>
                                
                                <div class="${viajeActual.nombreServicio == 'EJECUTIVO VIP' ? 'grid-4-columnas' : 'grid-3-columnas'}">
                                    
                                    <c:forEach var="a" items="${listaAsientosIntel}">
                                        <c:if test="${a.piso == 1}">
                                            <button type="button" 
                                                    class="btn-asiento ${a.estadoOcupado ? 'ocupado' : 'disponible'}"
                                                    ${a.estadoOcupado ? 'disabled' : ''}
                                                    onclick="seleccionarAsiento(${a.numeroAsiento}, ${a.precio})">
                                                ${a.numeroAsiento}
                                            </button>
                                            <c:if test="${a.columna == 2}">
                                                <div class="pasillo"></div>
                                            </c:if>
                                        </c:if>
                                    </c:forEach>
                                </div>
                            </div>

                            <c:set var="hayPiso2" value="false" />
                            <c:forEach var="a" items="${listaAsientosIntel}">
                                <c:if test="${a.piso == 2}"><c:set var="hayPiso2" value="true" /></c:if>
                            </c:forEach>

                            <c:if test="${hayPiso2}">
                                <div class="piso-contenedor">
                                    <h6 class="fw-bold text-success border-bottom pb-2">SEGUNDO PISO</h6>
                                    <div class="${viajeActual.nombreServicio == 'EJECUTIVO VIP' ? 'grid-4-columnas' : 'grid-3-columnas'}">
                                        <c:forEach var="a" items="${listaAsientosIntel}">
                                            <c:if test="${a.piso == 2}">
                                                <button type="button" 
                                                        class="btn-asiento ${a.estadoOcupado ? 'ocupado' : 'disponible'}"
                                                        ${a.estadoOcupado ? 'disabled' : ''}
                                                        onclick="seleccionarAsiento(${a.numeroAsiento}, ${a.precio})">
                                                    ${a.numeroAsiento}
                                                </button>
                                                <c:if test="${a.columna == 2}">
                                                    <div class="pasillo"></div>
                                                </c:if>
                                            </c:if>
                                        </c:forEach>
                                    </div>
                                </div>
                            </c:if>
                        </div>
                    </div>

                    <div class="col-md-5">
                        <div class="card shadow-sm border-0 p-4 h-100 bg-white border-top border-primary border-4">
                            <h5 class="fw-bold text-dark mb-4">Resumen de Compra</h5>
                            
                            <form action="VentaServlet" method="POST">
                                <input type="hidden" name="accion" value="guardarVenta">
                                <input type="hidden" name="idViaje" value="${param.idViaje}">
                                <input type="hidden" name="idOrigen" value="${param.idOrigen}">
                                <input type="hidden" name="idDestino" value="${param.idDestino}">
                                <input type="hidden" name="fecha" value="${param.fecha}">
                                
                                <input type="hidden" id="numAsiento" name="numAsiento" required>
                                <input type="hidden" id="precioBoleto" name="precioBoleto" required>

                                <div class="mb-3">
                                    <label class="form-label text-muted small fw-bold">Asiento Seleccionado</label>
                                    <input type="text" id="asientoElegidoDisplay" class="form-control form-control-lg bg-light text-center fw-bold text-primary" placeholder="Seleccione en el mapa" readonly required>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label text-muted small fw-bold">Precio (S/.)</label>
                                    <input type="text" id="precioDisplay" class="form-control form-control-lg bg-light text-center fw-bold text-success" placeholder="0.00" readonly>
                                </div>

                                <hr class="my-4">

                                <div class="mb-3">
                                    <label class="form-label text-muted small fw-bold">DNI del Pasajero</label>
                                    <input type="text" name="dni" class="form-control" maxlength="8" pattern="\d{8}" placeholder="Ingrese DNI" required>
                                </div>

                                <div class="mb-4">
                                    <label class="form-label text-muted small fw-bold">Nombre Completo</label>
                                    <input type="text" name="nombrePasajero" class="form-control" placeholder="Nombres y Apellidos" required>
                                </div>

                                <button type="submit" class="btn btn-primary btn-lg w-100 fw-bold shadow-sm">
                                    Confirmar y Emitir Pasaje
                                </button>
                            </form>
                        </div>
                    </div>

                </div>
            </c:if>
        </div>
    </div>
</div>

<script>
function seleccionarAsiento(numero, precio) {
    // 1. Limpiar clase 'seleccionado' de todos los botones
    document.querySelectorAll('.btn-asiento').forEach(btn => btn.classList.remove('seleccionado'));
    
    // 2. Marcar el clickeado
    event.target.classList.add('seleccionado');
    
    // 3. Setear valores en el formulario derecho
    document.getElementById('asientoElegidoDisplay').value = "N° " + numero;
    document.getElementById('numAsiento').value = numero; // Este viaja al Servlet
    
    document.getElementById('precioDisplay').value = "S/. " + precio.toFixed(2);
    document.getElementById('precioBoleto').value = precio.toFixed(2); // Este viaja al Servlet
}
</script>

</body>
</html>