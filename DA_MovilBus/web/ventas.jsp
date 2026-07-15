<%-- 
    Document   : ventas
    Módulo de venta de pasajes - SOLO ADMINISTRADOR Y VENDEDOR
    Los clientes realizan sus compras desde index.jsp (landing page)
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@page import="java.util.List, java.util.Map, dao.CiudadDAO, model.Ciudad, model.Usuario"%>
<%
    // 🔒 CONTROL DE ACCESO: Solo ADMINISTRADOR y VENDEDOR
    Usuario user = (Usuario) session.getAttribute("usuarioSesion");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String userRol = user.getRol();
    if ("CLIENTE_WEB".equalsIgnoreCase(userRol)) {
        response.sendRedirect("index.jsp");
        return;
    }
    boolean esAdmin = "ADMINISTRADOR".equalsIgnoreCase(userRol);
    
    CiudadDAO ciudadDAO = new CiudadDAO();
    request.setAttribute("listaCiudadesVenta", ciudadDAO.listarActivas());
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>MovilBus - Venta de Pasajes</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="css/movilbus.css">
</head>
<body class="admin-body">
    <div class="container-fluid">
        <div class="row">
            <jsp:include page="sidebar.jsp">
                <jsp:param name="activePage" value="ventas" />
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

                <!-- Page Header -->
                <div class="d-flex justify-content-between align-items-start mb-4">
                    <div>
                        <h1 class="page-title">
                            <i class="bi bi-ticket-perforated text-danger me-2"></i> Venta de Pasajes
                            <small>Sistema de emisión de boletos con selección interactiva de asientos</small>
                        </h1>
                    </div>
                </div>

                <!-- Alerts -->
                <c:if test="${param.status == 'success'}">
                    <div class="alert alert-success alert-dismissible fade show rounded-3 shadow-sm" role="alert">
                        <i class="bi bi-check-circle me-2"></i> <strong>¡Pasaje emitido con éxito!</strong>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                <c:if test="${param.status == 'error'}">
                    <div class="alert alert-danger alert-dismissible fade show rounded-3 shadow-sm" role="alert">
                        <i class="bi bi-exclamation-triangle me-2"></i> <strong>Error al emitir el pasaje.</strong> Verifique los datos e intente nuevamente.
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <!-- Buscador de Viajes -->
                <div class="card card-custom p-4 mb-4">
                    <div class="d-flex align-items-center mb-3">
                        <i class="bi bi-search fs-4 text-primary me-2"></i>
                        <h5 class="fw-bold mb-0">Buscar Viajes Disponibles</h5>
                    </div>
                    <form action="VentaServlet" method="GET" class="row g-3">
                        <input type="hidden" name="accion" value="buscar">
                        <div class="col-md-4">
                            <label class="form-label">Ciudad Origen</label>
                            <select class="form-select" name="idOrigen" required>
                                <option value="">-- Seleccione origen --</option>
                                <c:forEach var="c" items="${listaCiudadesVenta}">
                                    <option value="${c.idCiudad}" ${param.idOrigen == c.idCiudad ? 'selected' : ''}>${c.nombre}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Ciudad Destino</label>
                            <select class="form-select" name="idDestino" required>
                                <option value="">-- Seleccione destino --</option>
                                <c:forEach var="c" items="${listaCiudadesVenta}">
                                    <option value="${c.idCiudad}" ${param.idDestino == c.idCiudad ? 'selected' : ''}>${c.nombre}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Fecha de Viaje</label>
                            <input type="date" class="form-control" name="fecha" required value="${param.fecha}">
                        </div>
                        <div class="col-12 mt-2">
                            <button type="submit" class="btn btn-buscar rounded-pill">
                                <i class="bi bi-search me-1"></i> Buscar Salidas
                            </button>
                        </div>
                    </form>
                </div>

                <!-- Resultados de Búsqueda -->
                <c:if test="${not empty listaViajesBusqueda}">
                    <div class="card card-custom p-4 mb-4">
                        <div class="d-flex align-items-center mb-3">
                            <i class="bi bi-clock-history fs-4 text-success me-2"></i>
                            <h5 class="fw-bold mb-0">Horarios Encontrados</h5>
                            <span class="ms-auto badge bg-success rounded-pill">${listaViajesBusqueda.size()} viaje(s)</span>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead>
                                    <tr>
                                        <th>Salida</th>
                                        <th>Ruta</th>
                                        <th>Bus / Servicio</th>
                                        <th class="text-center">Precio Base</th>
                                        <th class="text-center">Acción</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="v" items="${listaViajesBusqueda}">
                                        <tr class="${param.idViaje == v.idViaje ? 'table-primary' : ''}">
                                            <td>
                                                <strong>${v.fechaHora}</strong>
                                            </td>
                                            <td>
                                                <i class="bi bi-geo-alt-fill text-success me-1"></i>${v.origen} 
                                                <i class="bi bi-arrow-right mx-1"></i> 
                                                <i class="bi bi-geo-alt-fill text-danger me-1"></i>${v.destino}
                                            </td>
                                            <td>
                                                <span class="badge bg-dark">${v.placa}</span>
                                                <span class="service-badge ms-1">${v.nombreServicio}</span>
                                            </td>
                                            <td class="text-center fw-bold text-success">S/. ${v.precioBase}</td>
                                            <td class="text-center">
                                                <a href="VentaServlet?accion=verAsientos&idViaje=${v.idViaje}&idOrigen=${param.idOrigen}&idDestino=${param.idDestino}&fecha=${param.fecha}" 
                                                   class="btn btn-success btn-sm fw-bold rounded-pill px-3">
                                                    <i class="bi bi-grid-3x3-gap me-1"></i> Ver Asientos
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </c:if>

                <!-- Croquis de Asientos y Venta -->
                <c:if test="${param.accion == 'verAsientos'}">
                    <c:forEach var="v" items="${listaViajesBusqueda}">
                        <c:if test="${v.idViaje == param.idViaje}">
                            <c:set var="viajeActual" value="${v}" />
                        </c:if>
                    </c:forEach>

                    <div class="row g-4">
                        <!-- Croquis -->
                        <div class="col-md-7">
                            <div class="card card-custom p-4 h-100">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <h5 class="fw-bold mb-0">
                                        <i class="bi bi-grid-3x3-gap me-2 text-primary"></i>Mapa de Asientos
                                        <small class="text-muted ms-2" style="font-size:.75rem;"><i class="bi bi-info-circle"></i> Haz clic en varios asientos</small>
                                    </h5>
                                    <span class="service-badge">${viajeActual.nombreServicio}</span>
                                </div>

                                <!-- Leyenda estilo MovilBus -->
                                <div class="leyenda-asientos mb-4">
                                    <div class="leyenda-item">
                                        <div class="leyenda-color libre"></div>
                                        <span>Libre</span>
                                    </div>
                                    <div class="leyenda-item">
                                        <div class="leyenda-color seleccionado"></div>
                                        <span>Seleccionado</span>
                                    </div>
                                    <div class="leyenda-item">
                                        <div class="leyenda-color ocupado"></div>
                                        <span>Ocupado</span>
                                    </div>
                                    <div class="leyenda-item">
                                        <div class="leyenda-color" style="border: 2px solid #FFC107; background: #FFFDE7;"></div>
                                        <span>Premium</span>
                                    </div>
                                </div>

                                <!-- Contador de asientos seleccionados -->
                                <div class="alert alert-info py-2 small mb-3 text-center" id="contadorAsientos" style="display:none;">
                                    <i class="bi bi-seat me-1"></i>
                                    <span id="numSeleccionados">0</span> asiento(s) seleccionado(s) - 
                                    Total: <strong id="totalPrecioMulti">S/. 0.00</strong>
                                </div>

                                <!-- BUS LAYOUT WRAPPER (Estilo MovilBus) -->
                                <div class="bus-layout mb-4">
                                    
                                    <!-- Indicador de cabina (volante) -->
                                    <div class="bus-front-indicator">
                                        <i class="bi bi-steering-wheel"></i>
                                        <span>— Cabina del Conductor —</span>
                                    </div>

                                    <!-- Piso 1 -->
                                    <c:set var="esEjecutivo" value="${viajeActual.nombreServicio == 'EJECUTIVO VIP'}" />
                                    <c:set var="esEjecutivo60" value="${esEjecutivo && capacidadBus == 60}" />
                                    <c:set var="gridPiso1" value="${esEjecutivo60 ? 'grid-3-columnas' : (esEjecutivo ? 'grid-4-columnas' : 'grid-3-columnas')}" />
                                    <c:set var="gridPiso2" value="${esEjecutivo ? 'grid-4-columnas' : 'grid-3-columnas'}" />
                                    <div class="piso-section">
                                        <div class="piso-title">
                                            <i class="bi bi-layers"></i> PRIMER PISO
                                            <span class="badge-tipo">${viajeActual.nombreServicio == 'EJECUTIVO VIP' ? 'Semi Cama 140° / Cama VIP 160°' : viajeActual.nombreServicio == 'PRESIDENCIAL' ? 'Cama VIP 160°' : 'Cama VIP 160°'}</span>
                                        </div>
                                        <div class="${gridPiso1}">
                                            <c:forEach var="a" items="${listaAsientosIntel}">
                                                <c:if test="${a.piso == 1}">
                                                    <button type="button" 
                                                            class="btn-asiento ${a.estadoOcupado ? 'ocupado' : 'disponible'} ${a.tipoAsiento == 'Cama Vip 160°' || a.tipoAsiento == 'Full Flat 180°' ? 'premium' : ''}"
                                                            ${a.estadoOcupado ? 'disabled' : ''}
                                                            onclick="toggleAsiento(${a.numeroAsiento}, ${a.precio}, '${a.tipoAsiento}')"
                                                            title="${a.tipoAsiento} - S/. ${a.precio}">
                                                        <span class="num-asiento">${a.numeroAsiento}</span>
                                                        <span class="precio-asiento">S/. ${a.precio}</span>
                                                    </button>
                                                    <c:if test="${a.columna == 2}">
                                                        <div class="pasillo"><span class="pasillo-label">Pasillo</span></div>
                                                    </c:if>
                                                </c:if>
                                            </c:forEach>
                                        </div>
                                    </div>

                                    <!-- Elementos del bus: SSHH y Escaleras -->
                                    <div class="grid-3-columnas mt-2" style="border-top: 1px dashed #dee2e6; padding-top: 10px;">
                                        <div class="bus-elemento baño" title="Servicios Higiénicos">
                                            <i class="bi bi-water"></i>
                                            SSHH
                                        </div>
                                        <div></div>
                                        <div class="pasillo" style="min-height: 0;"></div>
                                        <div class="bus-elemento escaleras" title="Escaleras">
                                            <i class="bi bi-stairs"></i>
                                            Escaleras
                                        </div>
                                    </div>

                                    <!-- Piso 2 -->
                                    <c:set var="hayPiso2" value="false" />
                                    <c:forEach var="a" items="${listaAsientosIntel}">
                                        <c:if test="${a.piso == 2}"><c:set var="hayPiso2" value="true" /></c:if>
                                    </c:forEach>

                                    <c:if test="${hayPiso2}">
                                        <div class="piso-section mt-3 pt-3" style="border-top: 2px dashed #dee2e6;">
                                            <div class="piso-title">
                                                <i class="bi bi-layers"></i> SEGUNDO PISO
                                                <span class="badge-tipo">${viajeActual.nombreServicio == 'EJECUTIVO VIP' ? 'Butaca 140°' : 'Full Flat 180°'}</span>
                                            </div>
                                            <div class="${gridPiso2}">
                                                <c:forEach var="a" items="${listaAsientosIntel}">
                                                    <c:if test="${a.piso == 2}">
                                                        <button type="button" 
                                                                class="btn-asiento ${a.estadoOcupado ? 'ocupado' : 'disponible'} ${a.tipoAsiento == 'Full Flat 180°' ? 'premium' : ''}"
                                                                ${a.estadoOcupado ? 'disabled' : ''}
                                                                onclick="toggleAsiento(${a.numeroAsiento}, ${a.precio}, '${a.tipoAsiento}')"
                                                                title="${a.tipoAsiento} - S/. ${a.precio}">
                                                            <span class="num-asiento">${a.numeroAsiento}</span>
                                                            <span class="precio-asiento">S/. ${a.precio}</span>
                                                        </button>
                                                        <c:if test="${a.columna == 2}">
                                                            <div class="pasillo"><span class="pasillo-label">Pasillo</span></div>
                                                        </c:if>
                                                    </c:if>
                                                </c:forEach>
                                            </div>
                                        </div>
                                    </c:if>

                                </div> <!-- /bus-layout -->
                            </div>
                        </div>

                        <!-- Resumen de Compra Multi-Asiento -->
                        <div class="col-md-5">
                            <div class="card resumen-card shadow-sm border-0 p-4 h-100 bg-white">
                                <h5 class="fw-bold mb-4">
                                    <i class="bi bi-cart-check me-2 text-primary"></i>Compra de Pasajes
                                    <small class="text-muted d-block small mt-1">Selecciona uno o varios asientos y completa los datos</small>
                                </h5>

                                <form action="VentaServlet" method="POST" id="formMultiVenta">
                                    <input type="hidden" name="accion" value="guardarVentaMulti">
                                    <input type="hidden" name="idViaje" value="${param.idViaje}">
                                    <input type="hidden" name="idOrigen" value="${param.idOrigen}">
                                    <input type="hidden" name="idDestino" value="${param.idDestino}">
                                    <input type="hidden" name="fecha" value="${param.fecha}">

                                    <!-- Info del Viaje -->
                                    <div class="bg-light rounded-3 p-3 mb-4">
                                        <div class="d-flex align-items-center mb-2">
                                            <i class="bi bi-bus-front me-2 text-primary"></i>
                                            <strong>${viajeActual.origen} → ${viajeActual.destino}</strong>
                                        </div>
                                        <div class="text-muted small">
                                            <i class="bi bi-clock me-1"></i>${viajeActual.fechaHora}
                                        </div>
                                        <div class="text-muted small">
                                            <span class="badge bg-secondary">${viajeActual.placa}</span>
                                            <span class="badge bg-info ms-1">${viajeActual.nombreServicio}</span>
                                        </div>
                                    </div>

                                    <!-- Lista de Asientos Seleccionados -->
                                    <div id="listaAsientosSeleccionados" class="mb-3">
                                        <label class="form-label fw-bold"><i class="bi bi-seat me-1"></i>Asientos seleccionados</label>
                                        <div class="text-center text-muted small py-3 bg-light rounded-3" id="placeholderAsientos">
                                            <i class="bi bi-hand-index fs-2 d-block mb-2"></i>
                                            Haz clic en los asientos del mapa para agregarlos
                                        </div>
                                    </div>

                                    <!-- Contenedor dinámico para formularios de pasajeros -->
                                    <div id="contenedorPasajeros"></div>

                                    <!-- Total -->
                                    <div class="bg-dark text-white rounded-3 p-3 mb-3 text-center" id="totalBox" style="display:none;">
                                        <small class="text-white-50">Total a Pagar</small>
                                        <div class="fs-3 fw-bold" id="totalFinal">S/. 0.00</div>
                                        <small class="text-white-50" id="totalCantidad">0 pasaje(s)</small>
                                    </div>

                                    <button type="submit" class="btn btn-primary btn-lg w-100 fw-bold rounded-pill shadow-sm" id="btnConfirmar" disabled>
                                        <i class="bi bi-ticket-check me-2"></i> Confirmar y Emitir Pasajes
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </c:if>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
    // Almacén de asientos seleccionados
    let asientosSeleccionados = [];
    const infoAsientos = {};
    <c:forEach var="a" items="${listaAsientosIntel}">
        infoAsientos[${a.numeroAsiento}] = { precio: ${a.precio}, tipo: '${a.tipoAsiento}' };
    </c:forEach>

    function toggleAsiento(numero, precio, tipoAsiento) {
        const btn = event.currentTarget;
        
        // Si está ocupado, no hacer nada
        if (btn.disabled) return;
        
        const idx = asientosSeleccionados.indexOf(numero);
        if (idx > -1) {
            // Ya seleccionado → lo quitamos
            asientosSeleccionados.splice(idx, 1);
            btn.classList.remove('seleccionado');
        } else {
            // No seleccionado → lo agregamos
            asientosSeleccionados.push(numero);
            btn.classList.add('seleccionado');
        }
        
        actualizarResumen();
    }

    function actualizarResumen() {
        const contador = document.getElementById('contadorAsientos');
        const numSel = document.getElementById('numSeleccionados');
        const totalPrecio = document.getElementById('totalPrecioMulti');
        const listaDiv = document.getElementById('listaAsientosSeleccionados');
        const placeholder = document.getElementById('placeholderAsientos');
        const contPasajeros = document.getElementById('contenedorPasajeros');
        const totalBox = document.getElementById('totalBox');
        const totalFinal = document.getElementById('totalFinal');
        const totalCantidad = document.getElementById('totalCantidad');
        const btnConfirmar = document.getElementById('btnConfirmar');
        
        if (asientosSeleccionados.length === 0) {
            contador.style.display = 'none';
            placeholder.style.display = 'block';
            contPasajeros.innerHTML = '';
            totalBox.style.display = 'none';
            btnConfirmar.disabled = true;
            return;
        }
        
        // Mostrar contador
        contador.style.display = 'block';
        numSel.textContent = asientosSeleccionados.length;
        
        // Calcular total
        let total = 0;
        asientosSeleccionados.forEach(n => {
            if (infoAsientos[n]) total += infoAsientos[n].precio;
        });
        totalPrecio.textContent = 'S/. ' + total.toFixed(2);
        totalFinal.textContent = 'S/. ' + total.toFixed(2);
        totalCantidad.textContent = asientosSeleccionados.length + ' pasaje(s)';
        
        // Ocultar placeholder
        placeholder.style.display = 'none';
        
        // Mostrar lista de asientos seleccionados
        let htmlLista = '<div class="d-flex flex-wrap gap-1 mb-3">';
        asientosSeleccionados.forEach(n => {
            const info = infoAsientos[n] || { precio: 0, tipo: '' };
            htmlLista += '<span class="badge bg-warning text-dark p-2">' +
                         '<i class="bi bi-seat me-1"></i>N° ' + n + ' <small>S/. ' + info.precio.toFixed(2) + '</small>' +
                         '</span>';
        });
        htmlLista += '</div>';
        
        // Limpiar y agregar badges
        const badgesContainer = document.createElement('div');
        badgesContainer.innerHTML = htmlLista;
        const badges = badgesContainer.firstElementChild;
        
        // Eliminar badges anteriores si existen
        const oldBadges = listaDiv.querySelector('.d-flex.flex-wrap');
        if (oldBadges) oldBadges.remove();
        
        // Insertar badges después del label
        const label = listaDiv.querySelector('.form-label');
        if (label) {
            label.after(badges);
        }
        
        // Generar formularios de pasajeros
        let htmlPasajeros = '<hr><h6 class="fw-bold mb-3"><i class="bi bi-people me-1"></i>Datos de los Pasajeros</h6>';
        
        asientosSeleccionados.forEach((n, i) => {
            const tipo = infoAsientos[n] ? infoAsientos[n].tipo : '';
            htmlPasajeros += '<div class="card bg-light border-0 rounded-3 p-3 mb-2">' +
                '<div class="d-flex justify-content-between align-items-center mb-2">' +
                    '<strong class="small"><i class="bi bi-seat text-warning me-1"></i>Pasajero ' + (i+1) + ' - Asiento N° ' + n + '</strong>' +
                    '<span class="badge bg-info small">' + tipo + '</span>' +
                '</div>' +
                '<input type="hidden" name="numAsiento" value="' + n + '">' +
                '<input type="hidden" name="precioBoleto" value="' + (infoAsientos[n] ? infoAsientos[n].precio.toFixed(2) : '0.00') + '">' +
                '<div class="row g-2">' +
                    '<div class="col-md-5">' +
                        '<label class="form-label small">DNI</label>' +
                        '<input type="text" name="dni" class="form-control form-control-sm" maxlength="8" pattern="\\d{8}" placeholder="12345678" required>' +
                    '</div>' +
                    '<div class="col-md-7">' +
                        '<label class="form-label small">Nombre Completo</label>' +
                        '<input type="text" name="nombrePasajero" class="form-control form-control-sm" placeholder="Nombres y Apellidos" required>' +
                    '</div>' +
                '</div>' +
            '</div>';
        });
        
        contPasajeros.innerHTML = htmlPasajeros;
        
        // Mostrar total y botón
        totalBox.style.display = 'block';
        btnConfirmar.disabled = false;
    }
    </script>
</body>
</html>
