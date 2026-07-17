<%-- Landing page principal de MovilBus, acceso publico para busqueda y compra de pasajes --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@page import="dao.CiudadDAO, model.Ciudad, model.Usuario, java.util.List, util.EscapeUtil"%>
<%
    CiudadDAO ciudadDAO = new CiudadDAO();
    List<Ciudad> ciudadesActivas = ciudadDAO.listarActivas();
    request.setAttribute("ciudadesIndex", ciudadesActivas);
    
    // Verificar si hay cliente logueado
    Usuario userIdx = (Usuario) session.getAttribute("usuarioSesion");
    String nombreCliente = "";
    String rolCliente = "";
    if (userIdx != null) {
        nombreCliente = userIdx.getNombre() + " " + userIdx.getApellido();
        rolCliente = userIdx.getRol();
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MovilBus - Viaja seguro, viaja en bus</title>
    <meta name="description" content="MovilBus - Transporte interprovincial de pasajeros. Compra pasajes online, encomiendas y más. Viaja cómodo y seguro.">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/movilbus.css">
    <style>
        .pago-option {
            border: 2px solid #e0e0e0;
            border-radius: 12px;
            padding: .6rem .3rem;
            text-align: center;
            cursor: pointer;
            transition: all .2s;
            background: white;
        }
        .pago-option:hover {
            border-color: var(--mvb-orange);
            background: #FFF8E1;
        }
        .pago-option.active {
            border-color: var(--mvb-orange);
            background: #FFF3E0;
            box-shadow: 0 0 0 3px rgba(255,107,0,.15);
        }
        .pago-option i {
            font-size: 1.4rem;
            display: block;
            margin-bottom: 2px;
            color: var(--mvb-orange);
        }
        .pago-option small {
            font-size: .65rem;
            font-weight: 600;
            color: #495057;
            text-transform: uppercase;
            letter-spacing: .3px;
        }
    </style>
</head>
<body>

    <!-- ============================================================
         HEADER / NAVBAR (sin Intranet, solo para clientes)
         Diseno estable: 3 particiones fijas (Brand | NavLinks | UserArea)
         ============================================================ -->
    <nav class="navbar navbar-expand-lg navbar-movilbus sticky-top">
        <div class="container">
            <!-- Particion 1: Brand (tamano fijo) -->
            <a class="navbar-brand flex-shrink-0" href="index.jsp">
                <i class="bi bi-bus-front me-2"></i>MovilBus
            </a>

            <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#navbarMain">
                <span class="navbar-toggler-icon"></span>
            </button>

            <div class="collapse navbar-collapse" id="navbarMain">
                <!-- Particion 2: NavLinks (ocupa el espacio restante, flex-nowrap para no romper) -->
                <ul class="navbar-nav mx-auto mb-2 mb-lg-0" style="flex-wrap:nowrap;">
                    <li class="nav-item"><a class="nav-link active" href="index.jsp">Inicio</a></li>
                    <!-- Items de cliente SIEMPRE en el DOM, se ocultan/muestran sin afectar layout -->
                    <li class="nav-item" id="navItemPuntos" style="<%= nombreCliente.isEmpty() ? "display:none;" : "" %>">
                        <a class="nav-link" href="FidelizacionServlet?accion=misPuntos"><i class="bi bi-star me-1"></i>Mis Puntos</a>
                    </li>
                    <li class="nav-item" id="navItemViajes" style="<%= nombreCliente.isEmpty() ? "display:none;" : "" %>">
                        <a class="nav-link" href="VentaServlet?accion=historial"><i class="bi bi-clock-history me-1"></i>Mis Viajes</a>
                    </li>
                    <li class="nav-item" id="navItemEnvios" style="<%= nombreCliente.isEmpty() ? "display:none;" : "" %>">
                        <a class="nav-link" href="EncomiendaServlet?accion=historialEncomienda"><i class="bi bi-box-seam me-1"></i>Mis Envios</a>
                    </li>
                    <li class="nav-item"><a class="nav-link" href="#servicios">Servicios</a></li>
                    <li class="nav-item"><a class="nav-link" href="#encomiendas"><i class="bi bi-box-seam me-1"></i>Encomiendas</a></li>
                    <li class="nav-item"><a class="nav-link" href="tracking.jsp"><i class="bi bi-upc-scan me-1"></i>Rastrear</a></li>
                    <li class="nav-item"><a class="nav-link" href="#destinos">Destinos</a></li>
                    <li class="nav-item"><a class="nav-link" href="#contacto">Contacto</a></li>
                </ul>

                <!-- Particion 3: UserArea (ancho fijo exacto, no se expande/contrae al loguearse) -->
                <div class="user-area-partition flex-shrink-0" style="width:210px; text-align:right;">
                    <% if (nombreCliente.isEmpty()) { %>
                        <button class="btn btn-ingresar-cliente" data-bs-toggle="modal" data-bs-target="#modalLoginCliente" style="width:100%;">
                            <i class="bi bi-person me-1"></i> Mi Cuenta
                        </button>
                    <% } else { %>
                        <div class="d-flex align-items-center justify-content-end gap-2" style="flex-wrap:nowrap;">
                            <span class="badge bg-light text-dark py-2 px-3 rounded-pill d-inline-flex align-items-center gap-1 text-truncate"
                                  style="font-size:.8rem; max-width:160px;">
                                <i class="bi bi-person-check text-success flex-shrink-0"></i>
                                <span class="text-truncate"><%= nombreCliente %></span>
                            </span>
                            <a href="LogoutServlet" class="btn btn-outline-danger btn-sm rounded-pill flex-shrink-0">
                                <i class="bi bi-box-arrow-right"></i>
                            </a>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
    </nav>

    <!-- Alertas globales -->
    <% if ("success".equals(request.getParameter("registro"))) { %>
    <div class="container mt-3">
        <div class="alert alert-success alert-dismissible fade show rounded-4 shadow-sm" role="alert">
            <div class="d-flex align-items-center gap-2">
                <i class="bi bi-check-circle-fill fs-4"></i>
                <div>
                    <strong>¡Bienvenido a MovilBus!</strong><br>
                    <span>Tu cuenta ha sido creada exitosamente. Ahora puedes comprar pasajes online.</span>
                </div>
            </div>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </div>
    <% } %>
    <% if ("success".equals(request.getParameter("cita"))) { %>
    <div class="container mt-3">
        <div class="alert alert-success alert-dismissible fade show rounded-4 shadow-sm" role="alert">
            <div class="d-flex align-items-center gap-2">
                <i class="bi bi-check-circle-fill fs-4" style="color: var(--mvb-orange);"></i>
                <div>
                    <strong>¡Cita agendada exitosamente!</strong><br>
                    <span>Nos pondremos en contacto contigo para confirmar el envío de tu encomienda.</span>
                </div>
            </div>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </div>
    <% } %>
    <% if ("error".equals(request.getParameter("cita"))) { %>
    <div class="container mt-3">
        <div class="alert alert-danger alert-dismissible fade show rounded-4 shadow-sm" role="alert">
            <div class="d-flex align-items-center gap-2">
                <i class="bi bi-exclamation-triangle-fill fs-4"></i>
                <div>
                    <strong>Error al agendar la cita.</strong><br>
                    <span>Verifica tus datos e inténtalo nuevamente.</span>
                </div>
            </div>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </div>
    <% } %>
    
    <!-- Alertas de canje de puntos -->
    <% if ("exito".equals(request.getParameter("canje"))) { %>
    <div class="container mt-3">
        <div class="alert alert-success alert-dismissible fade show rounded-4 shadow-sm" role="alert">
            <div class="d-flex align-items-center gap-2">
                <i class="bi bi-gift-fill fs-4" style="color: var(--mvb-orange);"></i>
                <div>
                    <strong>¡Canje exitoso!</strong><br>
                    <span>Obtuviste S/ <%= EscapeUtil.escHtml(request.getParameter("descuento")) %> de descuento en tu próxima compra.</span>
                </div>
            </div>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </div>
    <% } %>
    <% if ("error".equals(request.getParameter("canje"))) { %>
    <div class="container mt-3">
        <div class="alert alert-warning alert-dismissible fade show rounded-4 shadow-sm" role="alert">
            <div class="d-flex align-items-center gap-2">
                <i class="bi bi-exclamation-triangle-fill fs-4 text-warning"></i>
                <div>
                    <strong>Canje no procesado.</strong><br>
                    <span><%= EscapeUtil.escHtml(request.getParameter("msg") != null ? request.getParameter("msg") : "Verifica tus puntos e inténtalo nuevamente.") %></span>
                </div>
            </div>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </div>
    <% } %>

    <!-- ============================================================
         HERO SECTION
         ============================================================ -->
    <section class="hero-section">
        <div class="container">
            <div class="row align-items-center g-5">
                <div class="col-lg-7">
                    <div class="hero-badge animate-up">
                        <i class="bi bi-shield-check"></i>
                        Viaja con confianza y seguridad
                    </div>
                    <h1 class="hero-title animate-up animate-up-delay-1">
                        Descubre nuevos<br>
                        <span class="highlight">horizontes</span> con<br>
                        MovilBus
                    </h1>
                    <p class="hero-subtitle animate-up animate-up-delay-2">
                        Transformamos tus viajes en experiencias inolvidables. 
                        Disfruta del mejor servicio de transporte interprovincial 
                        con los más altos estándares de comodidad y puntualidad.
                    </p>
                    <div class="d-flex gap-3 flex-wrap animate-up animate-up-delay-3">
                        <a href="#buscador" class="btn btn-ingresar btn-lg px-4 py-3">
                            <i class="bi bi-ticket-perforated me-2"></i>Comprar Pasaje
                        </a>
                        <a href="#servicios" class="btn btn-outline-light btn-lg px-4 py-3 rounded-pill">
                            <i class="bi bi-info-circle me-2"></i>Ver Servicios
                        </a>
                    </div>
                </div>
                <div class="col-lg-5 d-none d-lg-block">
                    <div class="hero-image-wrapper animate-up animate-up-delay-4">
                        <i class="bi bi-bus-front float-animation" style="font-size: 16rem; color: rgba(255,107,0,.08);"></i>
                        <div class="hero-floating-card text-center">
                            <div class="display-1 mb-2">800+</div>
                            <p class="mb-0 text-white-50">Pasajeros satisfechos<br>cada mes</p>
                            <hr class="text-white-25 my-3">
                            <div class="d-flex justify-content-around">
                                <div>
                                    <div class="fw-bold text-warning">12</div>
                                    <small class="text-white-50">Destinos</small>
                                </div>
                                <div>
                                    <div class="fw-bold text-warning">50+</div>
                                    <small class="text-white-50">Agencias</small>
                                </div>
                                <div>
                                    <div class="fw-bold text-warning">10</div>
                                    <small class="text-white-50">Años</small>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- ============================================================
         SEARCH FORM - BUSCADOR DE PASAJES
         ============================================================ -->
    <section class="search-section" id="buscador">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-10">
                    <div class="search-card animate-up">
                        <div class="d-flex align-items-center mb-3">
                            <i class="bi bi-search fs-4 text-primary me-2"></i>
                            <h5 class="fw-bold mb-0">Busca tu viaje</h5>
                        </div>
                        <form action="VentaServlet" method="GET" class="row g-3 align-items-end">
                            <input type="hidden" name="accion" value="buscar">
                            
                            <!-- Origen -->
                            <div class="col-md-4">
                                <label class="form-label"><i class="bi bi-geo-alt me-1"></i>Origen</label>
                                <div class="search-field-wrapper">
                                    <select class="form-select" name="idOrigen" required>
                                        <option value="">¿De dónde viajas?</option>
                                        <c:forEach var="c" items="${ciudadesIndex}">
                                            <option value="${c.idCiudad}" ${param.idOrigen == c.idCiudad ? 'selected' : ''}>${c.nombre}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>

                            <!-- Destino -->
                            <div class="col-md-4 position-relative">
                                <label class="form-label"><i class="bi bi-geo-alt me-1"></i>Destino</label>
                                <div class="search-field-wrapper">
                                    <select class="form-select" name="idDestino" required>
                                        <option value="">¿A dónde vas?</option>
                                        <c:forEach var="c" items="${ciudadesIndex}">
                                            <option value="${c.idCiudad}" ${param.idDestino == c.idCiudad ? 'selected' : ''}>${c.nombre}</option>
                                        </c:forEach>
                                    </select>
                                    <button type="button" class="search-swap-btn" onclick="intercambiarDestinos()" title="Intercambiar">
                                        <i class="bi bi-arrow-left-right"></i>
                                    </button>
                                </div>
                            </div>

                            <!-- Fecha (default: maniana) -->
                            <div class="col-md-2">
                                <label class="form-label"><i class="bi bi-calendar me-1"></i>Fecha</label>
                                <input type="date" class="form-control" name="fecha" id="inputFechaBusqueda"
                                       value="<%= request.getParameter("fecha") != null ? request.getParameter("fecha") : "" %>" required>
                                <script>
                                    // Fijar fecha por defecto a maniana solo si no hay fecha en la URL
                                    (function() {
                                        var input = document.getElementById('inputFechaBusqueda');
                                        if (input && !input.value) {
                                            var maniana = new Date();
                                            maniana.setDate(maniana.getDate() + 1);
                                            var dd = String(maniana.getDate()).padStart(2,'0');
                                            var mm = String(maniana.getMonth()+1).padStart(2,'0');
                                            var yyyy = maniana.getFullYear();
                                            input.value = yyyy+'-'+mm+'-'+dd;
                                        }
                                    })();
                                </script>
                            </div>

                            <!-- Botón -->
                            <div class="col-md-2">
                                <button type="submit" class="btn btn-buscar">
                                    <i class="bi bi-search me-1"></i> Buscar
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- ============================================================
         RESULTADOS DE BÚSQUEDA (desde VentaServlet)
         ============================================================ -->
    <c:if test="${not empty listaViajesBusqueda}">
    <section class="py-4" id="resultados">
        <div class="container">
            <div class="card shadow-sm border-0 rounded-4 p-4 animate-up">
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
                                    <td><strong>${v.fechaHora}</strong></td>
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
        </div>
    </section>
    </c:if>

    <!-- Mensaje cuando no hay resultados de busqueda -->
    <c:if test="${param.accion == 'buscar' and empty listaViajesBusqueda}">
    <section class="py-4" id="sin-resultados">
        <div class="container">
            <div class="card shadow-sm border-0 rounded-4 p-4 animate-up">
                <div class="text-center py-4">
                    <i class="bi bi-search-heart" style="font-size:3rem; color:var(--mvb-orange); opacity:.4;"></i>
                    <h5 class="fw-bold mt-3 mb-1">No se encontraron viajes</h5>
                    <p class="text-muted mb-0">
                        No hay viajes programados para la ruta y fecha seleccionadas.
                        Prueba con otra fecha o cambia el origen/destino.
                    </p>
                    <small class="text-muted">
                        <i class="bi bi-info-circle me-1"></i>
                        Los viajes disponibles se muestran a partir de maniana.
                    </small>
                </div>
            </div>
        </div>
    </section>
    </c:if>

    <!-- ============================================================
         CROQUIS DE ASIENTOS Y COMPRA (desde VentaServlet)
         ============================================================ -->
    <c:if test="${param.accion == 'verAsientos'}">
    <c:forEach var="v" items="${listaViajesBusqueda}">
        <c:if test="${v.idViaje == param.idViaje}">
            <c:set var="viajeActual" value="${v}" />
        </c:if>
    </c:forEach>

    <c:if test="${not empty viajeActual}">
    <section class="py-4" id="seleccion-asientos">
        <div class="container">
            <div class="row g-4">
                <!-- Croquis -->
                <div class="col-lg-7">
                    <div class="card shadow-sm border-0 rounded-4 p-4 animate-up">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h5 class="fw-bold mb-0">
                                <i class="bi bi-grid-3x3-gap me-2 text-primary"></i>Selecciona tus Asientos
                                <small class="text-muted ms-2" style="font-size:.75rem;"><i class="bi bi-info-circle"></i> Haz clic en los asientos</small>
                            </h5>
                            <span class="service-badge">${viajeActual.nombreServicio}</span>
                        </div>

                        <!-- Leyenda -->
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

                        <!-- Contador -->
                        <div class="alert alert-info py-2 small mb-3 text-center" id="contadorAsientosIdx" style="display:none;">
                            <i class="bi bi-seat me-1"></i>
                            <span id="numSeleccionadosIdx">0</span> asiento(s) seleccionado(s) - 
                            Total: <strong id="totalPrecioMultiIdx">S/. 0.00</strong>
                        </div>

                        <!-- Bus Layout -->
                        <div class="bus-layout mb-4">
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
                                                    onclick="toggleAsientoIdx(${a.numeroAsiento}, ${a.precio}, '${a.tipoAsiento}')"
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

                            <!-- SSHH y Escaleras -->
                            <div class="grid-3-columnas mt-2" style="border-top: 1px dashed #dee2e6; padding-top: 10px;">
                                <div class="bus-elemento baño" title="Servicios Higiénicos">
                                    <i class="bi bi-water"></i> SSHH
                                </div>
                                <div></div>
                                <div class="pasillo" style="min-height: 0;"></div>
                                <div class="bus-elemento escaleras" title="Escaleras">
                                    <i class="bi bi-stairs"></i> Escaleras
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
                                                        onclick="toggleAsientoIdx(${a.numeroAsiento}, ${a.precio}, '${a.tipoAsiento}')"
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
                        </div><!-- /bus-layout -->
                    </div>
                </div>

                <!-- Resumen de Compra -->
                <div class="col-lg-5">
                    <div class="card shadow-sm border-0 rounded-4 p-4 h-100 animate-up" style="border-top: 4px solid var(--mvb-orange) !important;">
                        <h5 class="fw-bold mb-4">
                            <i class="bi bi-cart-check me-2 text-primary"></i>Compra de Pasajes
                            <small class="text-muted d-block small mt-1">Selecciona uno o varios asientos</small>
                        </h5>

                        <form action="VentaServlet" method="POST" id="formMultiVentaIdx">
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

                            <!-- Asientos Seleccionados -->
                            <div id="listaAsientosSelIdx" class="mb-3">
                                <label class="form-label fw-bold"><i class="bi bi-seat me-1"></i>Asientos seleccionados</label>
                                <div class="text-center text-muted small py-3 bg-light rounded-3" id="placeholderAsientosIdx">
                                    <i class="bi bi-hand-index fs-2 d-block mb-2"></i>
                                    Haz clic en los asientos del mapa
                                </div>
                            </div>

                            <!-- Pasajeros -->
                            <div id="contenedorPasajerosIdx"></div>

                            <!-- Total -->
                            <div class="bg-dark text-white rounded-3 p-3 mb-3 text-center" id="totalBoxIdx" style="display:none;">
                                <small class="text-white-50">Total a Pagar</small>
                                <div class="fs-3 fw-bold" id="totalFinalIdx">S/. 0.00</div>
                                <small class="text-white-50" id="totalCantidadIdx">0 pasaje(s)</small>
                            </div>

                            <!-- Metodo de Pago -->
                            <div class="mb-3" id="metodoPagoGroupIdx" style="display:none;">
                                <label class="form-label fw-bold"><i class="bi bi-credit-card me-1"></i>Metodo de Pago</label>
                                <input type="hidden" name="metodoPago" id="metodoPagoInputIdx" value="EFECTIVO">
                                <div class="row g-2">
                                    <div class="col-4">
                                        <div class="pago-option active" data-metodo="EFECTIVO" onclick="seleccionarPagoIdx(this)">
                                            <i class="bi bi-cash"></i>
                                            <small>Efectivo</small>
                                        </div>
                                    </div>
                                    <div class="col-4">
                                        <div class="pago-option" data-metodo="YAPE" onclick="seleccionarPagoIdx(this)">
                                            <i class="bi bi-phone"></i>
                                            <small>Yape</small>
                                        </div>
                                    </div>
                                    <div class="col-4">
                                        <div class="pago-option" data-metodo="PLIN" onclick="seleccionarPagoIdx(this)">
                                            <i class="bi bi-phone"></i>
                                            <small>Plin</small>
                                        </div>
                                    </div>
                                    <div class="col-4">
                                        <div class="pago-option" data-metodo="TARJETA" onclick="seleccionarPagoIdx(this)">
                                            <i class="bi bi-credit-card-2-front"></i>
                                            <small>Tarjeta</small>
                                        </div>
                                    </div>
                                    <div class="col-4">
                                        <div class="pago-option" data-metodo="TRANSFERENCIA" onclick="seleccionarPagoIdx(this)">
                                            <i class="bi bi-bank"></i>
                                            <small>Transferencia</small>
                                        </div>
                                    </div>
                                </div>

                                <!-- QR Yape/Plin (dinamico) -->
                                <div id="qrPagoMovilIdx" style="display:none;" class="text-center mt-3 p-3 bg-light rounded-3">
                                    <img id="qrImgIdx" src="" alt="QR de pago" style="width:130px;height:130px;border-radius:12px;">
                                    <div class="small text-muted mt-2">
                                        <i class="bi bi-phone me-1"></i>
                                        Escanea con tu app <strong id="qrLabelIdx">Yape</strong> para pagar
                                    </div>
                                </div>

                                <!-- Formulario Tarjeta (simulado) -->
                                <div id="formTarjetaIdx" style="display:none;" class="mt-3 p-3 bg-light rounded-3">
                                    <div class="row g-2">
                                        <div class="col-12">
                                            <label class="small">Numero de Tarjeta</label>
                                            <input type="text" class="form-control form-control-sm" placeholder="1234 5678 9012 3456" maxlength="19">
                                        </div>
                                        <div class="col-6">
                                            <label class="small">Vencimiento</label>
                                            <input type="text" class="form-control form-control-sm" placeholder="MM/AA">
                                        </div>
                                        <div class="col-6">
                                            <label class="small">CVV</label>
                                            <input type="text" class="form-control form-control-sm" placeholder="123" maxlength="4">
                                        </div>
                                    </div>
                                    <div class="small text-muted mt-2">
                                        <i class="bi bi-shield-lock me-1"></i>Pago seguro - Datos encriptados
                                    </div>
                                </div>

                                <!-- Transferencia -->
                                <div id="infoTransferenciaIdx" style="display:none;" class="mt-3 p-3 bg-light rounded-3 text-center small">
                                    <i class="bi bi-bank2 me-1"></i>
                                    <strong>Banco de la Nacion</strong><br>
                                    Cuenta Corriente: <strong>123-456789-0-00</strong><br>
                                    Titular: <strong>MovilBus S.A.C.</strong>
                                </div>
                            </div>

                            <button type="submit" class="btn btn-ingresar btn-lg w-100 fw-bold rounded-pill shadow-sm" id="btnConfirmarIdx" disabled>
                                <i class="bi bi-ticket-check me-2"></i> Confirmar y Emitir Pasajes
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </section>
    </c:if>
    </c:if>

    <!-- ============================================================
         MIS VIAJES / HISTORIAL DEL CLIENTE
         (visible solo cuando CLIENTE_WEB está logueado y hay listaVentas)
         ============================================================ -->
    <c:if test="${not empty listaVentas and esHistorialCliente}">
    <section class="py-4" id="mis-viajes">
        <div class="container">
            <div class="card shadow-sm border-0 rounded-4 p-4 animate-up">
                <div class="d-flex align-items-center mb-3">
                    <i class="bi bi-clock-history fs-4 text-primary me-2"></i>
                    <h5 class="fw-bold mb-0">Mis Viajes</h5>
                    <span class="ms-auto badge bg-primary rounded-pill">${listaVentas.size()} pasaje(s)</span>
                </div>
                
                <!-- Stats rápidos -->
                <c:set var="totalGastado" value="0"/>
                <c:set var="totalActivos" value="0"/>
                <c:forEach var="v" items="${listaVentas}">
                    <c:set var="totalGastado" value="${totalGastado + v.precioPagado}"/>
                    <c:if test="${v.estadoPasaje == 'ACTIVO'}"><c:set var="totalActivos" value="${totalActivos + 1}"/></c:if>
                </c:forEach>
                <div class="row g-2 mb-3">
                    <div class="col-md-6">
                        <div class="bg-light rounded-3 p-3 text-center">
                            <small class="text-muted">Total Gastado</small>
                            <div class="fw-bold fs-5" style="color: var(--mvb-orange);">S/. ${totalGastado}</div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="bg-light rounded-3 p-3 text-center">
                            <small class="text-muted">Pasajes Activos</small>
                            <div class="fw-bold fs-5 text-success">${totalActivos}</div>
                        </div>
                    </div>
                </div>

                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0 small">
                        <thead>
                            <tr>
                                <th># Pasaje</th>
                                <th>Fecha</th>
                                <th>Ruta</th>
                                <th>Asiento</th>
                                <th>Servicio</th>
                                <th class="text-center">Precio</th>
                                <th class="text-center">Estado</th>
                                <th>Vendido por</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="v" items="${listaVentas}">
                                <tr>
                                    <td><span class="badge bg-dark">#${v.idPasaje}</span></td>
                                    <td><small>${v.fechaEmision}</small></td>
                                    <td>
                                        <small>
                                            <i class="bi bi-geo-alt-fill text-success me-1"></i>${v.origen}
                                            <i class="bi bi-arrow-right mx-1"></i>
                                            <i class="bi bi-geo-alt-fill text-danger me-1"></i>${v.destino}
                                        </small>
                                    </td>
                                    <td class="text-center">
                                        <span class="badge bg-secondary">N° ${v.numeroAsiento}</span>
                                        <small class="text-muted d-block">Piso ${v.piso}</small>
                                    </td>
                                    <td>
                                        <span class="badge ${v.nombreServicio == 'EJECUTIVO VIP' ? 'bg-primary' : v.nombreServicio == 'PRESIDENCIAL' ? 'bg-warning text-dark' : 'bg-dark'} badge-servicio">${v.nombreServicio}</span>
                                    </td>
                                    <td class="text-center fw-bold text-success">S/. ${v.precioPagado}</td>
                                    <td class="text-center">
                                        <span class="badge ${v.estadoPasaje == 'ACTIVO' ? 'bg-success' : 'bg-secondary'}">${v.estadoPasaje}</span>
                                    </td>
                                    <td>
                                        <small class="text-muted">
                                            <i class="bi bi-person-badge me-1"></i>${v.vendedor != null ? v.vendedor : 'Online (Cliente Web)'}
                                        </small>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
                
                <div class="mt-3 text-center">
                    <a href="#buscador" class="btn btn-ingresar rounded-pill btn-sm">
                        <i class="bi bi-ticket-perforated me-1"></i> Comprar nuevo pasaje
                    </a>
                </div>
            </div>
        </div>
    </section>
    </c:if>

    <!-- ============================================================
         MIS PUNTOS DE FIDELIZACIÓN
         (visible solo cuando CLIENTE_WEB está logueado y hay datos)
         ============================================================ -->
    <c:if test="${not empty puntosCliente}">
    <section class="py-4" id="mis-puntos">
        <div class="container">
            <div class="card shadow-sm border-0 rounded-4 p-4 animate-up">
                <div class="d-flex align-items-center mb-3">
                    <i class="bi bi-star fs-4 text-warning me-2"></i>
                    <h5 class="fw-bold mb-0">Mis Puntos de Fidelización</h5>
                    <span class="ms-auto">
                        <span class="badge" 
                              style="background:${puntosCliente.nivelColor}; color:#fff; font-size:.8rem; padding:.4rem .8rem;">
                            <i class="${puntosCliente.nivelIcono} me-1"></i>${puntosCliente.nombreNivel}
                        </span>
                    </span>
                </div>

                <!-- Tarjeta principal de puntos -->
                <div class="row g-3">
                    <div class="col-md-4">
                        <div class="bg-light rounded-3 p-4 text-center">
                            <small class="text-muted text-uppercase fw-bold" style="font-size:.7rem;">Puntos Disponibles</small>
                            <div class="display-5 fw-bold" style="color: var(--mvb-orange);">${puntosCliente.puntosDisponibles}</div>
                            <small class="text-muted">Acumulados: ${puntosCliente.puntosAcumulados} · Canjeados: ${puntosCliente.puntosCanjeados}</small>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="bg-light rounded-3 p-4 text-center">
                            <small class="text-muted text-uppercase fw-bold" style="font-size:.7rem;">Nivel Actual</small>
                            <div class="d-flex align-items-center justify-content-center gap-2">
                                <i class="${puntosCliente.nivelIcono}" style="font-size:2rem; color:${puntosCliente.nivelColor};"></i>
                                <span class="fs-3 fw-bold" style="color:${puntosCliente.nivelColor};">${puntosCliente.nombreNivel}</span>
                            </div>
                            <small class="text-muted">${puntosCliente.descuentoNivel}% de descuento en tu nivel</small>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="bg-light rounded-3 p-4 text-center">
                            <small class="text-muted text-uppercase fw-bold" style="font-size:.7rem;">Próximo Nivel</small>
                            <div class="fs-5 fw-bold text-dark">${puntosCliente.siguienteNivel}</div>
                            <small class="text-muted">Faltan ${puntosCliente.puntosFaltantesSiguienteNivel} puntos</small>
                            <div class="progress mt-2" style="height:6px;">
                                <div class="progress-bar bg-warning" style="width:${puntosCliente.progresoSiguienteNivel}%;"></div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Canje de puntos -->
                <c:if test="${puntosCliente.puntosDisponibles >= 100}">
                <div class="mt-3 p-3 bg-white rounded-3 border">
                    <h6 class="fw-bold mb-2"><i class="bi bi-gift me-1 text-success"></i>Canjear Puntos por Descuento</h6>
                    <p class="small text-muted mb-2">
                        Cada 100 puntos = S/ 1 de descuento en tu próximo pasaje. 
                        Tienes <strong>${puntosCliente.puntosDisponibles} puntos</strong> 
                        = <strong>S/ ${puntosCliente.puntosDisponibles / 100}</strong> de descuento potencial.
                    </p>
                    <form action="FidelizacionServlet" method="POST" class="row g-2 align-items-end">
                        <input type="hidden" name="accion" value="canjear">
                        <div class="col-md-4">
                            <label class="form-label small">Puntos a canjear</label>
                            <input type="number" class="form-control form-control-sm" name="puntosCanje" 
                                   min="100" max="${puntosCliente.puntosDisponibles}" 
                                   step="100" value="${puntosCliente.puntosDisponibles - (puntosCliente.puntosDisponibles % 100)}" required>
                        </div>
                        <div class="col-md-4">
                            <button type="submit" class="btn btn-success btn-sm rounded-pill">
                                <i class="bi bi-gift me-1"></i> Canjear Ahora
                            </button>
                        </div>
                        <div class="col-md-4">
                            <small class="text-muted d-block mt-1">
                                <i class="bi bi-info-circle me-1"></i>100 pts = S/ 1
                            </small>
                        </div>
                    </form>
                </div>
                </c:if>

                <!-- Historial de transacciones -->
                <c:if test="${not empty transaccionesPuntos}">
                <div class="mt-3">
                    <h6 class="fw-bold mb-2"><i class="bi bi-clock-history me-1"></i>Últimas Transacciones</h6>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0 small">
                            <thead>
                                <tr>
                                    <th>Fecha</th>
                                    <th>Tipo</th>
                                    <th>Puntos</th>
                                    <th>Descripción</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="t" items="${transaccionesPuntos}">
                                    <tr>
                                        <td><small>${t.fecha}</small></td>
                                        <td>
                                            <span class="badge ${t.tipo == 'ACUMULACION' ? 'bg-success' : 'bg-warning text-dark'}">
                                                ${t.tipo == 'ACUMULACION' ? '+' : '-'}${t.tipo}
                                            </span>
                                        </td>
                                        <td class="fw-bold ${t.tipo == 'ACUMULACION' ? 'text-success' : 'text-danger'}">
                                            ${t.tipo == 'ACUMULACION' ? '+' : '-'}${t.puntos}
                                        </td>
                                        <td><small>${t.descripcion}</small></td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
                </c:if>

                <div class="mt-3 text-center">
                    <small class="text-muted">
                        <i class="bi bi-info-circle me-1"></i>
                        Ganas 1 punto por cada S/ 10 en pasajes. Canjea desde 100 puntos.
                    </small>
                </div>
            </div>
        </div>
    </section>
    </c:if>

    <!-- ============================================================
         MIS ENCOMIENDAS Y CITAS DEL CLIENTE
         (visible solo cuando CLIENTE_WEB está logueado y hay datos)
         ============================================================ -->
    <c:if test="${not empty listaEncomiendasCliente or not empty listaCitasCliente}">
    <section class="py-4" id="mis-envios">
        <div class="container">
            <div class="card shadow-sm border-0 rounded-4 p-4 animate-up">
                <div class="d-flex align-items-center mb-3">
                    <i class="bi bi-box-seam fs-4 text-warning me-2"></i>
                    <h5 class="fw-bold mb-0">Mis Envíos y Citas</h5>
                    <span class="ms-auto badge bg-warning text-dark rounded-pill">
                        ${not empty listaEncomiendasCliente ? listaEncomiendasCliente.size() : 0} encomienda(s)
                    </span>
                </div>

                <!-- Stats rápidos -->
                <c:set var="totalEncCliente" value="0"/>
                <c:set var="totalCitasCliente" value="0"/>
                <c:set var="encEntregadas" value="0"/>
                <c:set var="citasPendientes" value="0"/>
                <c:forEach var="e" items="${listaEncomiendasCliente}">
                    <c:set var="totalEncCliente" value="${totalEncCliente + 1}"/>
                    <c:if test="${e.estado == 'ENTREGADO'}"><c:set var="encEntregadas" value="${encEntregadas + 1}"/></c:if>
                </c:forEach>
                <c:forEach var="c" items="${listaCitasCliente}">
                    <c:set var="totalCitasCliente" value="${totalCitasCliente + 1}"/>
                    <c:if test="${c.estado == 'PENDIENTE'}"><c:set var="citasPendientes" value="${citasPendientes + 1}"/></c:if>
                </c:forEach>

                <div class="row g-2 mb-3">
                    <div class="col-md-4">
                        <div class="bg-light rounded-3 p-3 text-center">
                            <small class="text-muted">Total Encomiendas</small>
                            <div class="fw-bold fs-5" style="color: var(--mvb-orange);">${totalEncCliente}</div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="bg-light rounded-3 p-3 text-center">
                            <small class="text-muted">Entregadas</small>
                            <div class="fw-bold fs-5 text-success">${encEntregadas}</div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="bg-light rounded-3 p-3 text-center">
                            <small class="text-muted">Citas Pendientes</small>
                            <div class="fw-bold fs-5 text-warning">${citasPendientes}</div>
                        </div>
                    </div>
                </div>

                <!-- Tab de Encomiendas -->
                <c:if test="${not empty listaEncomiendasCliente}">
                <h6 class="fw-bold mt-3 mb-2"><i class="bi bi-box-seam me-1"></i>Mis Encomiendas</h6>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0 small">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Fecha</th>
                                <th>Descripción</th>
                                <th>Peso</th>
                                <th>Ruta</th>
                                <th class="text-center">Costo</th>
                                <th class="text-center">Estado</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="e" items="${listaEncomiendasCliente}">
                                <tr>
                                    <td><span class="badge bg-dark">#${e.idEncomienda}</span></td>
                                    <td><small>${e.fechaEnvio}</small></td>
                                    <td><small>${e.descripcion}</small></td>
                                    <td><span class="badge bg-secondary">${e.pesoKg} kg</span></td>
                                    <td>
                                        <small>
                                            <i class="bi bi-geo-alt-fill text-success me-1"></i>${e.origen}
                                            <i class="bi bi-arrow-right mx-1"></i>
                                            <i class="bi bi-geo-alt-fill text-danger me-1"></i>${e.destino}
                                        </small>
                                    </td>
                                    <td class="text-center fw-bold" style="color: var(--mvb-orange);">S/. ${e.precioEnvio}</td>
                                    <td class="text-center">
                                        <span class="badge ${e.estado == 'ENTREGADO' ? 'bg-success' : e.estado == 'EN VIAJE' ? 'bg-primary' : 'bg-secondary'}">
                                            ${e.estado}
                                        </span>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
                <hr>
                </c:if>

                <!-- Tab de Citas -->
                <c:if test="${not empty listaCitasCliente}">
                <h6 class="fw-bold mt-2 mb-2"><i class="bi bi-calendar-check me-1"></i>Mis Citas Agendadas</h6>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0 small">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Registro</th>
                                <th>Descripción</th>
                                <th>Ruta</th>
                                <th>Fecha Preferida</th>
                                <th class="text-center">Estado</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="c" items="${listaCitasCliente}">
                                <tr>
                                    <td><span class="badge bg-dark">#${c.idCita}</span></td>
                                    <td><small>${c.fechaRegistro}</small></td>
                                    <td><small>${c.descripcion}</small></td>
                                    <td>
                                        <small>
                                            <i class="bi bi-geo-alt-fill text-success me-1"></i>${c.nombreOrigen}
                                            <i class="bi bi-arrow-right mx-1"></i>
                                            <i class="bi bi-geo-alt-fill text-danger me-1"></i>${c.nombreDestino}
                                        </small>
                                    </td>
                                    <td><small>${c.fechaPreferida} - ${c.horaPreferida}</small></td>
                                    <td class="text-center">
                                        <span class="badge ${c.estado == 'CONFIRMADA' ? 'bg-success' : c.estado == 'PENDIENTE' ? 'bg-warning text-dark' : 'bg-secondary'}">
                                            ${c.estado}
                                        </span>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
                </c:if>
                
                <div class="mt-3 text-center">
                    <button class="btn btn-ingresar rounded-pill btn-sm" data-bs-toggle="modal" data-bs-target="#modalCitaEncomienda">
                        <i class="bi bi-calendar-plus me-1"></i> Agendar nueva cita
                    </button>
                </div>
            </div>
        </div>
    </section>
    </c:if>

    <!-- ============================================================
         SERVICES SECTION
         ============================================================ -->
    <section class="py-5" id="servicios" style="padding-top: 4rem !important;">
        <div class="container">
            <div class="text-center mb-5">
                <h2 class="section-title">Nuestros Servicios</h2>
                <p class="section-subtitle">Elige el nivel de confort que mejor se adapte a tu viaje</p>
            </div>
            <div class="row g-4">
                <!-- Ejecutivo VIP -->
                <div class="col-md-4">
                    <div class="card service-card">
                        <div class="card-img-top ejecutivo-bg">
                            <i class="bi bi-star"></i>
                        </div>
                        <div class="card-body">
                            <div class="d-flex justify-content-between align-items-start mb-2">
                                <h5 class="card-title">Ejecutivo VIP</h5>
                                <span class="service-badge-price">Desde S/ 80</span>
                            </div>
                            <p class="card-text">
                                Asientos reclinables Semi Cama 140° y Cama VIP 160°. 
                                Ideal para viajes de negocios con la mejor relación calidad-precio.
                            </p>
                            <ul class="list-unstyled small text-muted mb-0">
                                <li><i class="bi bi-check-circle text-success me-1"></i> Aire acondicionado</li>
                                <li><i class="bi bi-check-circle text-success me-1"></i> Asientos reclinables</li>
                                <li><i class="bi bi-check-circle text-success me-1"></i> Puerto USB</li>
                            </ul>
                        </div>
                    </div>
                </div>

                <!-- Presidencial -->
                <div class="col-md-4">
                    <div class="card service-card">
                        <div class="card-img-top presidencial-bg">
                            <i class="bi bi-gem"></i>
                        </div>
                        <div class="card-body">
                            <div class="d-flex justify-content-between align-items-start mb-2">
                                <h5 class="card-title">Presidencial</h5>
                                <span class="service-badge-price">Desde S/ 100</span>
                            </div>
                            <p class="card-text">
                                Asientos Cama VIP 160° y Full Flat 180° en distribución 
                                de lujo de 3 columnas. Experiencia premium de viaje.
                            </p>
                            <ul class="list-unstyled small text-muted mb-0">
                                <li><i class="bi bi-check-circle text-success me-1"></i> Asientos cama 160°</li>
                                <li><i class="bi bi-check-circle text-success me-1"></i> Pantalla individual</li>
                                <li><i class="bi bi-check-circle text-success me-1"></i> Snack y bebida</li>
                            </ul>
                        </div>
                    </div>
                </div>

                <!-- Premier -->
                <div class="col-md-4">
                    <div class="card service-card">
                        <div class="card-img-top premier-bg">
                            <i class="bi bi-crown"></i>
                        </div>
                        <div class="card-body">
                            <div class="d-flex justify-content-between align-items-start mb-2">
                                <h5 class="card-title">Premier</h5>
                                <span class="service-badge-price">Desde S/ 135</span>
                            </div>
                            <p class="card-text">
                                La máxima expresión de lujo en carretera. Asientos 
                                Full Flat 180° con la más alta privacidad y confort.
                            </p>
                            <ul class="list-unstyled small text-muted mb-0">
                                <li><i class="bi bi-check-circle text-success me-1"></i> Asientos Full Flat 180°</li>
                                <li><i class="bi bi-check-circle text-success me-1"></i> Cena a bordo</li>
                                <li><i class="bi bi-check-circle text-success me-1"></i> Asistente personal</li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- ============================================================
         FEATURES / WHY CHOOSE US
         ============================================================ -->
    <section class="features-section py-5">
        <div class="container">
            <div class="text-center mb-5">
                <h2 class="section-title">¿Por qué elegir MovilBus?</h2>
                <p class="section-subtitle">Más de 10 años llevando a nuestros pasajeros con los más altos estándares</p>
            </div>
            <div class="row g-4">
                <div class="col-md-3">
                    <div class="feature-card">
                        <div class="feature-icon orange">
                            <i class="bi bi-shield-check"></i>
                        </div>
                        <h5>Seguridad Garantizada</h5>
                        <p>Conductores profesionales y buses con mantenimiento preventivo constante.</p>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="feature-card">
                        <div class="feature-icon yellow">
                            <i class="bi bi-clock"></i>
                        </div>
                        <h5>Puntualidad</h5>
                        <p>Salidas y llegadas en hora. Respetamos tu tiempo.</p>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="feature-card">
                        <div class="feature-icon dark">
                            <i class="bi bi-wifi"></i>
                        </div>
                        <h5>Tecnología a Bordo</h5>
                        <p>WiFi, puertos USB, pantallas individuales y más.</p>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="feature-card">
                        <div class="feature-icon orange">
                            <i class="bi bi-emoji-smile"></i>
                        </div>
                        <h5>Comodidad Superior</h5>
                        <p>Asientos reclinables con amplio espacio para las piernas.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- ============================================================
         DESTINOS SECTION (con autocomplete al hacer clic)
         ============================================================ -->
    <section class="py-5" id="destinos">
        <div class="container">
            <div class="text-center mb-5">
                <h2 class="section-title">Destinos Destacados</h2>
                <p class="section-subtitle">Descubre la magia de nuestros principales destinos</p>
            </div>
            <div class="row g-4">
                <!-- Chiclayo (ID 1): Al hacer clic va a ventas con origen preseleccionado -->
                <div class="col-md-4 col-lg-3 col-6">
                    <div class="card destino-card" onclick="buscarDestino(1)" style="cursor:pointer;">
                        <div class="destino-img chiclayo-bg">
                            <i class="bi bi-geo-alt"></i>
                        </div>
                        <div class="card-body">
                            <h6 class="destino-name">Chiclayo</h6>
                            <div class="destino-price">S/ 90 <small>desde</small></div>
                            <span class="btn btn-destino btn-sm mt-2 w-100">Ver más</span>
                        </div>
                    </div>
                </div>
                <!-- Lima (ID 2) -->
                <div class="col-md-4 col-lg-3 col-6">
                    <div class="card destino-card" onclick="buscarDestino(2)" style="cursor:pointer;">
                        <div class="destino-img lima-bg">
                            <i class="bi bi-building"></i>
                        </div>
                        <div class="card-body">
                            <h6 class="destino-name">Lima</h6>
                            <div class="destino-price">S/ 80 <small>desde</small></div>
                            <span class="btn btn-destino btn-sm mt-2 w-100">Ver más</span>
                        </div>
                    </div>
                </div>
                <!-- Trujillo (ID 3) -->
                <div class="col-md-4 col-lg-3 col-6">
                    <div class="card destino-card" onclick="buscarDestino(3)" style="cursor:pointer;">
                        <div class="destino-img trujillo-bg">
                            <i class="bi bi-compass"></i>
                        </div>
                        <div class="card-body">
                            <h6 class="destino-name">Trujillo</h6>
                            <div class="destino-price">S/ 50 <small>desde</small></div>
                            <span class="btn btn-destino btn-sm mt-2 w-100">Ver más</span>
                        </div>
                    </div>
                </div>
                <!-- Piura (ID 4) -->
                <div class="col-md-4 col-lg-3 col-6">
                    <div class="card destino-card" onclick="buscarDestino(4)" style="cursor:pointer;">
                        <div class="destino-img piura-bg">
                            <i class="bi bi-sun"></i>
                        </div>
                        <div class="card-body">
                            <h6 class="destino-name">Piura</h6>
                            <div class="destino-price">S/ 30 <small>desde</small></div>
                            <span class="btn btn-destino btn-sm mt-2 w-100">Ver más</span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="text-center mt-4">
                <a href="#buscador" class="btn btn-outline-secondary rounded-pill px-4">
                    <i class="bi bi-grid-3x3-gap me-1"></i> Buscar pasajes
                </a>
            </div>
        </div>
    </section>

    <!-- ============================================================
         ENCOMIENDAS SECTION
         ============================================================ -->
    <section class="py-5" id="encomiendas" style="background: linear-gradient(135deg, #FFF8E1 0%, #FFFFFF 50%, #FFF3E0 100%);">
        <div class="container">
            <div class="row align-items-center g-5">
                <div class="col-lg-6">
                    <div class="hero-badge animate-up" style="background: rgba(255,152,0,.12); color: #E65100;">
                        <i class="bi bi-box-seam"></i>
                        Envíos seguros y rápidos
                    </div>
                    <h2 class="section-title text-start mt-3" style="font-size: 2rem;">
                        Envía tus <span class="highlight">encomiendas</span><br>
                        con MovilBus
                    </h2>
                    <p class="text-muted mb-4" style="font-size: 1.05rem; line-height: 1.7;">
                        Aprovecha nuestros viajes interprovinciales para enviar paquetes, 
                        documentos y mercancía de forma rápida, segura y al mejor precio. 
                        Tu encomienda viaja en el mismo bus, con la misma puntualidad 
                        y cuidado que nuestros pasajeros.
                    </p>
                    
                    <div class="row g-3 mb-4">
                        <div class="col-sm-6">
                            <div class="d-flex align-items-start gap-3 p-3 bg-white rounded-3 shadow-sm">
                                <div class="feature-icon orange" style="width: 44px; height: 44px; font-size: 1.2rem; flex-shrink: 0;">
                                    <i class="bi bi-shield-check"></i>
                                </div>
                                <div>
                                    <h6 class="fw-bold mb-1 small">Seguridad Garantizada</h6>
                                    <p class="mb-0 text-muted" style="font-size: .82rem;">Tu paquete viaja protegido y monitoreado.</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-sm-6">
                            <div class="d-flex align-items-start gap-3 p-3 bg-white rounded-3 shadow-sm">
                                <div class="feature-icon yellow" style="width: 44px; height: 44px; font-size: 1.2rem; flex-shrink: 0;">
                                    <i class="bi bi-clock"></i>
                                </div>
                                <div>
                                    <h6 class="fw-bold mb-1 small">Entrega Rápida</h6>
                                    <p class="mb-0 text-muted" style="font-size: .82rem;">Llega el mismo día del viaje programado.</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-sm-6">
                            <div class="d-flex align-items-start gap-3 p-3 bg-white rounded-3 shadow-sm">
                                <div class="feature-icon dark" style="width: 44px; height: 44px; font-size: 1.2rem; flex-shrink: 0;">
                                    <i class="bi bi-currency-dollar"></i>
                                </div>
                                <div>
                                    <h6 class="fw-bold mb-1 small">Precios Justos</h6>
                                    <p class="mb-0 text-muted" style="font-size: .82rem;">Tarifas económicas según peso y destino.</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-sm-6">
                            <div class="d-flex align-items-start gap-3 p-3 bg-white rounded-3 shadow-sm">
                                <div class="feature-icon orange" style="width: 44px; height: 44px; font-size: 1.2rem; flex-shrink: 0;">
                                    <i class="bi bi-geo-alt"></i>
                                </div>
                                <div>
                                    <h6 class="fw-bold mb-1 small">Multi-destinos</h6>
                                    <p class="mb-0 text-muted" style="font-size: .82rem;">Cobertura en todas nuestras rutas activas.</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="d-flex flex-wrap gap-3">
                        <button class="btn btn-ingresar rounded-pill px-4 py-2" data-bs-toggle="modal" data-bs-target="#modalCitaEncomienda">
                            <i class="bi bi-calendar-check me-2"></i> Agendar Cita
                        </button>
                        <% if (!nombreCliente.isEmpty()) { %>
                            <a href="<%= "CLIENTE_WEB".equalsIgnoreCase(rolCliente) ? "#" : "EncomiendaServlet?accion=listar" %>" 
                               class="btn btn-outline-secondary rounded-pill px-4 py-2"
                               <%= "CLIENTE_WEB".equalsIgnoreCase(rolCliente) ? "onclick=\"alert('Para más información, visita nuestra agencia más cercana.');\"" : "" %>>
                                <i class="bi bi-box-seam me-2"></i> Ver Encomiendas
                            </a>
                        <% } %>
                    </div>
                    <p class="text-muted small mt-3 mb-0">
                        <i class="bi bi-info-circle me-1"></i>
                        Agenda una cita y te contactaremos para coordinar el recojo y envío de tu paquete.
                        También puedes visitar cualquiera de nuestras agencias.
                    </p>
                </div>
                <div class="col-lg-6 d-none d-lg-block">
                    <div class="text-center">
                        <i class="bi bi-box-seam" style="font-size: 14rem; color: rgba(255,152,0,.08);"></i>
                        <div class="card shadow-sm border-0 rounded-4 p-4 mx-auto" style="max-width: 320px; margin-top: -60px;">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <span class="badge bg-warning text-dark rounded-pill"><i class="bi bi-star-fill me-1"></i>Más usado</span>
                                <small class="text-muted">Desde S/ 15</small>
                            </div>
                            <h6 class="fw-bold">Encomienda Express</h6>
                            <p class="small text-muted mb-0">Hasta 5 kg · Documentos y paquetes pequeños · Entrega en destino + recojo en agencia.</p>
                            <hr>
                            <div class="d-flex justify-content-between small">
                                <span class="text-muted">Peso máximo</span>
                                <span class="fw-bold">50 kg</span>
                            </div>
                            <div class="d-flex justify-content-between small mt-1">
                                <span class="text-muted">Tiempo estimado</span>
                                <span class="fw-bold">Según ruta</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- ============================================================
         FOOTER (con Intranet solo aquí)
         ============================================================ -->
    <footer class="footer-movilbus" id="contacto">
        <div class="container">
            <div class="row g-4">
                <!-- Brand -->
                <div class="col-lg-4">
                    <div class="brand-footer mb-3">
                        <i class="bi bi-bus-front me-2"></i>MovilBus
                    </div>
                    <p class="text-white-50 small mb-3" style="line-height: 1.7;">
                        Transformamos tus viajes en experiencias inolvidables. 
                        Más de 10 años brindando el mejor servicio de transporte 
                        interprovincial del norte del Perú.
                    </p>
                    <div class="d-flex gap-2">
                        <a href="#" class="social-icon"><i class="bi bi-facebook"></i></a>
                        <a href="#" class="social-icon"><i class="bi bi-instagram"></i></a>
                        <a href="#" class="social-icon"><i class="bi bi-twitter-x"></i></a>
                        <a href="#" class="social-icon"><i class="bi bi-tiktok"></i></a>
                    </div>
                </div>

                <!-- Quick Links -->
                <div class="col-lg-2 col-md-4">
                    <h5>Enlaces</h5>
                    <div class="d-flex flex-column">
                        <a href="index.jsp"><i class="bi bi-chevron-right small"></i> Inicio</a>
                        <a href="#servicios"><i class="bi bi-chevron-right small"></i> Servicios</a>
                        <a href="#encomiendas"><i class="bi bi-chevron-right small"></i> Encomiendas</a>
                        <a href="#destinos"><i class="bi bi-chevron-right small"></i> Destinos</a>
                        <a href="#buscador"><i class="bi bi-chevron-right small"></i> Comprar Pasaje</a>
                    </div>
                </div>

                <!-- Contact -->
                <div class="col-lg-3 col-md-4">
                    <h5>Contacto</h5>
                    <div class="d-flex flex-column">
                        <a href="#"><i class="bi bi-telephone"></i> (074) 123-456</a>
                        <a href="#"><i class="bi bi-whatsapp"></i> +51 999 888 777</a>
                        <a href="#"><i class="bi bi-envelope"></i> info@movilbus.pe</a>
                        <a href="#"><i class="bi bi-geo-alt"></i> Chiclayo - Lambayeque</a>
                    </div>
                </div>

                <!-- Acceso Intranet (solo aquí, en el pie de página) -->
                <div class="col-lg-3 col-md-4">
                    <h5>Acceso al Sistema</h5>
                    <p class="text-white-50 small">Accede a nuestra plataforma de gestión interna.</p>
                    <div class="d-flex flex-column gap-2">
                        <a href="login.jsp" class="btn-intranet">
                            <i class="bi bi-shield-lock me-1"></i> Intranet de Gestión
                        </a>
                        <button class="btn-intranet" data-bs-toggle="modal" data-bs-target="#modalLoginCliente" style="background: var(--mvb-orange); border-color: var(--mvb-orange);">
                            <i class="bi bi-person me-1"></i> Iniciar Sesión Cliente
                        </button>
                    </div>
                </div>
            </div>

            <hr class="footer-divider">

            <div class="footer-bottom">
                <div class="row align-items-center">
                    <div class="col-md-6 text-center text-md-start">
                        © 2026 <strong>MovilBus</strong>. Todos los derechos reservados.
                    </div>
                    <div class="col-md-6 text-center text-md-end mt-2 mt-md-0">
                        <a href="#" class="me-3">Términos y condiciones</a>
                        <a href="#">Política de privacidad</a>
                    </div>
                </div>
            </div>
        </div>
    </footer>

    <!-- ============================================================
         MODAL CITA ENCOMIENDA
         ============================================================ -->
    <div class="modal fade modal-movilbus" id="modalCitaEncomienda" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content" style="border-radius: 20px; overflow: hidden;">
                <div class="modal-header text-center" style="background: linear-gradient(135deg, #FF6B00, #FF8F00); color: white; padding: 1.2rem 1.8rem;">
                    <div class="w-100">
                        <i class="bi bi-calendar-check fs-1 mb-2 d-block"></i>
                        <h5 class="modal-title fw-bold">Agendar Cita para Encomienda</h5>
                        <p class="mb-0 small opacity-75">Programa el envío de tu paquete y te contactaremos</p>
                    </div>
                    <button type="button" class="btn-close btn-close-white position-absolute top-0 end-0 m-3" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <form action="EncomiendaServlet" method="POST" id="formCitaEncomienda">
                        <input type="hidden" name="accion" value="agendarCita">

                        <!-- Datos del cliente -->
                        <div class="border rounded-3 p-3 mb-4 bg-light">
                            <h6 class="fw-bold mb-3" style="color: var(--mvb-orange);">
                                <i class="bi bi-person me-1"></i>Tus Datos
                            </h6>
                            <div class="row g-3">
                                <div class="col-md-4">
                                    <label class="form-label small">DNI <span class="text-danger">*</span></label>
                                    <input type="text" name="dni" class="form-control" maxlength="8" pattern="\d{8}" placeholder="12345678" required>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label small">Nombre Completo <span class="text-danger">*</span></label>
                                    <input type="text" name="nombre" class="form-control" placeholder="Nombres y Apellidos" required>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label small">Teléfono <span class="text-muted">(opcional)</span></label>
                                    <input type="tel" name="telefono" class="form-control" maxlength="15" pattern="[0-9\s]{7,15}" placeholder="999888777" inputmode="numeric">
                                </div>
                            </div>
                        </div>

                        <!-- Origen y Destino -->
                        <div class="border rounded-3 p-3 mb-4 bg-light">
                            <h6 class="fw-bold mb-3" style="color: var(--mvb-orange);">
                                <i class="bi bi-geo-alt me-1"></i>Ruta del Envío
                            </h6>
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label small">Origen <span class="text-danger">*</span></label>
                                    <select class="form-select" name="idOrigen" required>
                                        <option value="">¿De dónde se envía?</option>
                                        <c:forEach var="c" items="${ciudadesIndex}">
                                            <option value="${c.idCiudad}">${c.nombre}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label small">Destino <span class="text-danger">*</span></label>
                                    <select class="form-select" name="idDestino" required>
                                        <option value="">¿A dónde se envía?</option>
                                        <c:forEach var="c" items="${ciudadesIndex}">
                                            <option value="${c.idCiudad}">${c.nombre}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                        </div>

                        <!-- Detalles del paquete -->
                        <div class="border rounded-3 p-3 mb-4 bg-light">
                            <h6 class="fw-bold mb-3" style="color: var(--mvb-orange);">
                                <i class="bi bi-box me-1"></i>Detalles del Paquete
                            </h6>
                            <div class="row g-3">
                                <div class="col-md-8">
                                    <label class="form-label small">Descripción <span class="text-danger">*</span></label>
                                    <input type="text" name="descripcion" class="form-control" placeholder="Ej: Documentos, ropa, repuestos..." required>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label small">Peso aprox. (kg) <span class="text-danger">*</span></label>
                                    <input type="number" name="pesoEstimado" class="form-control" step="0.1" min="0.1" value="1.0" required>
                                </div>
                            </div>
                        </div>

                        <!-- Fecha y Hora -->
                        <div class="border rounded-3 p-3 mb-4 bg-light">
                            <h6 class="fw-bold mb-3" style="color: var(--mvb-orange);">
                                <i class="bi bi-clock me-1"></i>Preferencia de Recojo
                            </h6>
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label small">Fecha Preferida <span class="text-danger">*</span></label>
                                    <input type="date" name="fechaPreferida" class="form-control" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label small">Hora Preferida <span class="text-danger">*</span></label>
                                    <input type="time" name="horaPreferida" class="form-control" required>
                                </div>
                            </div>
                        </div>

                        <!-- Observaciones -->
                        <div class="mb-4">
                            <label class="form-label small">Observaciones (opcional)</label>
                            <textarea name="observaciones" class="form-control" rows="2" placeholder="Algún detalle adicional..."></textarea>
                        </div>

                        <button type="submit" class="btn btn-ingresar w-100 py-2 fw-bold rounded-pill">
                            <i class="bi bi-check-circle me-2"></i> Agendar Cita
                        </button>
                        <p class="text-center text-muted small mt-2 mb-0">
                            <i class="bi bi-shield-check me-1"></i>
                            Te contactaremos para confirmar el recojo y el costo del envío.
                        </p>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- ============================================================
         MODAL LOGIN CLIENTE
         ============================================================ -->
    <div class="modal fade modal-movilbus" id="modalLoginCliente" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-sm">
            <div class="modal-content">
                <div class="modal-header text-center">
                    <div class="w-100">
                        <i class="bi bi-person-circle fs-1 mb-2 d-block"></i>
                        <h5 class="modal-title fw-bold">Iniciar Sesión</h5>
                        <p class="mb-0 small opacity-75">Accede a tu cuenta de cliente MovilBus</p>
                    </div>
                    <button type="button" class="btn-close position-absolute top-0 end-0 m-3" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form action="LoginServlet" method="POST">
                        <div class="mb-3">
                            <label class="form-label fw-semibold small">Usuario (DNI o Correo)</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light"><i class="bi bi-person"></i></span>
                                <input type="text" class="form-control" name="username" placeholder="Ingresa tu usuario" required>
                            </div>
                        </div>
                        <div class="mb-4">
                            <label class="form-label fw-semibold small">Contraseña</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light"><i class="bi bi-lock"></i></span>
                                <input type="password" class="form-control" name="password" placeholder="Ingresa tu contraseña" required>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-ingresar w-100 py-2 mb-2">
                            <i class="bi bi-box-arrow-in-right me-1"></i> Ingresar
                        </button>
                        <p class="text-center text-muted small mb-0 mt-3">
                            ¿No tienes cuenta? <a href="registro-cliente.jsp" class="text-decoration-none fw-semibold" style="color: var(--mvb-orange);">Regístrate aquí</a>
                        </p>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- ============================================================
         SCRIPTS
         ============================================================ -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // === Intercambiar Origen/Destino ===
        function intercambiarDestinos() {
            const origen = document.querySelector('select[name="idOrigen"]');
            const destino = document.querySelector('select[name="idDestino"]');
            if (origen && destino) {
                const temp = origen.value;
                origen.value = destino.value;
                destino.value = temp;
            }
        }

        // === Buscar por destino (autocompletado desde cards) ===
        function buscarDestino(idDestino) {
            // Redirige a index.jsp con el destino preseleccionado
            // El usuario puede elegir el origen manualmente
            const origen = document.querySelector('select[name="idOrigen"]');
            const destino = document.querySelector('select[name="idDestino"]');
            if (destino) destino.value = idDestino;
            // Hacer scroll al buscador
            document.getElementById('buscador').scrollIntoView({ behavior: 'smooth' });
        }

        // === Navbar scroll effect ===
        document.addEventListener('scroll', function() {
            const navbar = document.querySelector('.navbar-movilbus');
            if (window.scrollY > 50) {
                navbar.classList.add('scrolled');
            } else {
                navbar.classList.remove('scrolled');
            }
        });

        // Validación de campos numéricos en el modal de cita
        document.addEventListener('DOMContentLoaded', function() {
            const dniCita = document.querySelector('#modalCitaEncomienda input[name="dni"]');
            if (dniCita) {
                dniCita.addEventListener('input', function() {
                    this.value = this.value.replace(/\D/g, '');
                });
            }

            const telCita = document.querySelector('#modalCitaEncomienda input[name="telefono"]');
            if (telCita) {
                telCita.addEventListener('input', function() {
                    this.value = this.value.replace(/[^0-9\s]/g, '');
                });
            }

            const formCita = document.getElementById('formCitaEncomienda');
            if (formCita) {
                formCita.addEventListener('submit', function(e) {
                    const dni = this.querySelector('input[name="dni"]').value.replace(/\s+/g, '');
                    if (dni.length !== 8 || isNaN(dni)) {
                        e.preventDefault();
                        alert('⚠️ El DNI debe tener exactamente 8 dígitos numéricos.');
                        return;
                    }
                    const tel = this.querySelector('input[name="telefono"]').value.trim();
                    if (tel !== '' && tel.replace(/\s+/g, '').length < 7) {
                        e.preventDefault();
                        alert('⚠️ El teléfono debe tener al menos 7 dígitos (si se ingresa).');
                        return;
                    }
                });
            }
        });

        // === Smooth scroll for anchor links ===
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function(e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({ behavior: 'smooth', block: 'start' });
                }
            });
        });

        // === Auto close alerts ===
        setTimeout(function() {
            document.querySelectorAll('.alert').forEach(a => {
                const bsAlert = bootstrap.Alert.getOrCreateInstance(a);
                setTimeout(() => bsAlert.close(), 4000);
            });
        }, 5000);
    </script>

    <!-- ============================================================
         SCRIPT DE SELECCIÓN DE ASIENTOS (Index - Clientes)
         ============================================================ -->
    <script>
    // Almacén de asientos seleccionados
    let asientosSeleccionadosIdx = [];
    const infoAsientosIdx = {};
    <c:forEach var="a" items="${listaAsientosIntel}">
        infoAsientosIdx[${a.numeroAsiento}] = { precio: ${a.precio}, tipo: '${a.tipoAsiento}' };
    </c:forEach>

    function toggleAsientoIdx(numero, precio, tipoAsiento) {
        const btn = event.currentTarget;
        if (btn.disabled) return;
        
        const idx = asientosSeleccionadosIdx.indexOf(numero);
        if (idx > -1) {
            asientosSeleccionadosIdx.splice(idx, 1);
            btn.classList.remove('seleccionado');
        } else {
            asientosSeleccionadosIdx.push(numero);
            btn.classList.add('seleccionado');
        }
        actualizarResumenIdx();
    }

    function actualizarResumenIdx() {
        const contador = document.getElementById('contadorAsientosIdx');
        const numSel = document.getElementById('numSeleccionadosIdx');
        const totalPrecio = document.getElementById('totalPrecioMultiIdx');
        const listaDiv = document.getElementById('listaAsientosSelIdx');
        const placeholder = document.getElementById('placeholderAsientosIdx');
        const contPasajeros = document.getElementById('contenedorPasajerosIdx');
        const totalBox = document.getElementById('totalBoxIdx');
        const totalFinal = document.getElementById('totalFinalIdx');
        const totalCantidad = document.getElementById('totalCantidadIdx');
        const btnConfirmar = document.getElementById('btnConfirmarIdx');
        
        if (asientosSeleccionadosIdx.length === 0) {
            if (contador) contador.style.display = 'none';
            if (placeholder) placeholder.style.display = 'block';
            if (contPasajeros) contPasajeros.innerHTML = '';
            if (totalBox) totalBox.style.display = 'none';
            const metodoPagoGroup = document.getElementById('metodoPagoGroupIdx');
            if (metodoPagoGroup) metodoPagoGroup.style.display = 'none';
            if (btnConfirmar) btnConfirmar.disabled = true;
            return;
        }
        
        if (contador) contador.style.display = 'block';
        if (numSel) numSel.textContent = asientosSeleccionadosIdx.length;
        
        let total = 0;
        asientosSeleccionadosIdx.forEach(n => {
            if (infoAsientosIdx[n]) total += infoAsientosIdx[n].precio;
        });
        if (totalPrecio) totalPrecio.textContent = 'S/. ' + total.toFixed(2);
        if (totalFinal) totalFinal.textContent = 'S/. ' + total.toFixed(2);
        if (totalCantidad) totalCantidad.textContent = asientosSeleccionadosIdx.length + ' pasaje(s)';
        
        if (placeholder) placeholder.style.display = 'none';
        
        // Mostrar badges de asientos seleccionados
        let htmlLista = '<div class="d-flex flex-wrap gap-1 mb-3">';
        asientosSeleccionadosIdx.forEach(n => {
            const info = infoAsientosIdx[n] || { precio: 0, tipo: '' };
            htmlLista += '<span class="badge bg-warning text-dark p-2">' +
                         '<i class="bi bi-seat me-1"></i>N° ' + n + ' <small>S/. ' + info.precio.toFixed(2) + '</small>' +
                         '</span>';
        });
        htmlLista += '</div>';
        
        const badgesContainer = document.createElement('div');
        badgesContainer.innerHTML = htmlLista;
        const badges = badgesContainer.firstElementChild;
        
        const oldBadges = listaDiv ? listaDiv.querySelector('.d-flex.flex-wrap') : null;
        if (oldBadges) oldBadges.remove();
        
        const label = listaDiv ? listaDiv.querySelector('.form-label') : null;
        if (label) {
            label.after(badges);
        }
        
        // Formularios de pasajeros
        let htmlPasajeros = '<hr><h6 class="fw-bold mb-3"><i class="bi bi-people me-1"></i>Datos de los Pasajeros</h6>';
        asientosSeleccionadosIdx.forEach((n, i) => {
            const tipo = infoAsientosIdx[n] ? infoAsientosIdx[n].tipo : '';
            htmlPasajeros += '<div class="card bg-light border-0 rounded-3 p-3 mb-2">' +
                '<div class="d-flex justify-content-between align-items-center mb-2">' +
                    '<strong class="small"><i class="bi bi-seat text-warning me-1"></i>Pasajero ' + (i+1) + ' - Asiento N° ' + n + '</strong>' +
                    '<span class="badge bg-info small">' + tipo + '</span>' +
                '</div>' +
                '<input type="hidden" name="numAsiento" value="' + n + '">' +
                '<input type="hidden" name="precioBoleto" value="' + (infoAsientosIdx[n] ? infoAsientosIdx[n].precio.toFixed(2) : '0.00') + '">' +
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
        if (contPasajeros) contPasajeros.innerHTML = htmlPasajeros;
        
        if (totalBox) totalBox.style.display = 'block';
        // Mostrar metodo de pago
        const metodoPagoGroup = document.getElementById('metodoPagoGroupIdx');
        if (metodoPagoGroup) metodoPagoGroup.style.display = 'block';
        if (btnConfirmar) btnConfirmar.disabled = false;
    }

    function seleccionarPagoIdx(el) {
        document.querySelectorAll('#metodoPagoGroupIdx .pago-option').forEach(function(e) {
            e.classList.remove('active');
        });
        el.classList.add('active');

        const metodo = el.getAttribute('data-metodo');
        document.getElementById('metodoPagoInputIdx').value = metodo;

        document.getElementById('qrPagoMovilIdx').style.display = 'none';
        document.getElementById('formTarjetaIdx').style.display = 'none';
        document.getElementById('infoTransferenciaIdx').style.display = 'none';

        if (metodo === 'YAPE' || metodo === 'PLIN') {
            const qrDiv = document.getElementById('qrPagoMovilIdx');
            qrDiv.style.display = 'block';
            const label = metodo === 'YAPE' ? 'Yape' : 'Plin';
            document.getElementById('qrLabelIdx').textContent = label;
            const total = document.getElementById('totalFinalIdx').textContent.trim();
            const qrImg = document.getElementById('qrImgIdx');
            qrImg.src = 'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=MovilBus%20'
                + encodeURIComponent(label) + '%20-%20S/.' + encodeURIComponent(total);
        } else if (metodo === 'TARJETA') {
            document.getElementById('formTarjetaIdx').style.display = 'block';
        } else if (metodo === 'TRANSFERENCIA') {
            document.getElementById('infoTransferenciaIdx').style.display = 'block';
        }
    }
    </script>
</body>
</html>
