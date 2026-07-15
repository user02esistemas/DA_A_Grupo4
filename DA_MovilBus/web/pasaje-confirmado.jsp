<%-- 
    Document   : pasaje-confirmado
    Pantalla de confirmación de compra - Muestra datos del pasaje y opción de descarga
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@page import="dao.ViajeDAO, java.util.Map, java.util.List, model.Usuario"%>
<%
    String idPasajeStr = request.getParameter("idPasaje");
    String multiStr = request.getParameter("multi");
    
    if (idPasajeStr == null || idPasajeStr.isEmpty()) {
        response.sendRedirect("ventas.jsp");
        return;
    }
    
    ViajeDAO viajeDAO = new ViajeDAO();
    
    // Si hay multi, cargar TODOS los pasajes de la compra
    List<Map<String, Object>> listaVentas;
    if (multiStr != null && !multiStr.isEmpty()) {
        listaVentas = viajeDAO.obtenerVentasPorIds(multiStr);
    } else {
        Map<String, Object> ventaUnica = viajeDAO.obtenerVentaPorId(Integer.parseInt(idPasajeStr));
        listaVentas = new java.util.ArrayList<>();
        if (ventaUnica != null) listaVentas.add(ventaUnica);
    }
    request.setAttribute("listaVentas", listaVentas);
    
    // Calcular total general
    double totalGeneral = 0;
    for (Map<String, Object> v : listaVentas) {
        Object precio = v.get("precioPagado");
        if (precio instanceof Number) totalGeneral += ((Number) precio).doubleValue();
    }
    request.setAttribute("totalGeneral", totalGeneral);
    
    Usuario userConf = (Usuario) session.getAttribute("usuarioSesion");
    boolean esCliente = (userConf != null && "CLIENTE_WEB".equalsIgnoreCase(userConf.getRol()));
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MovilBus - Pasaje(s) Confirmado(s)</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="css/movilbus.css">
    <style>
        @media print {
            .no-print { display: none !important; }
            .ticket-card { border: 2px solid #333 !important; box-shadow: none !important; }
            body { background: white !important; }
            .page-break { page-break-before: always; }
        }
        .ticket-card {
            max-width: 650px;
            margin: 0 auto;
            border: none;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 8px 40px rgba(0,0,0,.12);
        }
        .ticket-card + .ticket-card { margin-top: 2rem; }
        .ticket-header {
            background: var(--gradient-primary);
            padding: 1.5rem;
            text-align: center;
            color: white;
            position: relative;
        }
        .ticket-header::after {
            content: '';
            position: absolute;
            bottom: -10px;
            left: 0;
            right: 0;
            height: 20px;
            background: radial-gradient(circle at 20px 0, transparent 12px, white 13px);
            background-size: 40px 20px;
        }
        .ticket-body { padding: 2rem; background: white; }
        .ticket-divider {
            border: none;
            border-top: 2px dashed #dee2e6;
            margin: 1.5rem 0;
        }
        .ticket-row {
            display: flex;
            justify-content: space-between;
            padding: .5rem 0;
            border-bottom: 1px solid #f0f0f0;
        }
        .ticket-row:last-child { border-bottom: none; }
        .ticket-label { color: #6c757d; font-size: .85rem; font-weight: 500; }
        .ticket-value { font-weight: 700; font-size: .95rem; color: var(--mvb-dark); }
        .ticket-price {
            font-size: 2rem;
            font-weight: 900;
            color: var(--mvb-orange);
            text-align: center;
            padding: 1rem 0;
        }
        .success-check {
            width: 70px;
            height: 70px;
            border-radius: 50%;
            background: var(--gradient-primary);
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1rem;
            font-size: 2rem;
            color: white;
            animation: scaleIn .5s ease;
        }
        @keyframes scaleIn {
            0% { transform: scale(0); }
            60% { transform: scale(1.2); }
            100% { transform: scale(1); }
        }
        .barcode-decoration {
            text-align: center;
            font-family: 'Courier New', monospace;
            font-size: 1.8rem;
            letter-spacing: 4px;
            color: #ccc;
            margin: 1rem 0;
        }
        .summary-bar {
            max-width: 650px;
            margin: 0 auto 2rem;
            background: white;
            border-radius: 16px;
            padding: 1.2rem 2rem;
            box-shadow: 0 4px 20px rgba(0,0,0,.08);
            border-left: 4px solid var(--mvb-orange);
        }
    </style>
</head>
<body style="background: #f0f2f5;">
    <div class="container py-5">
        <c:if test="${empty listaVentas}">
            <div class="text-center py-5">
                <i class="bi bi-exclamation-triangle fs-1 text-warning"></i>
                <h3 class="mt-3">Pasaje(s) no encontrado(s)</h3>
                <p class="text-muted">Los pasajes que buscas no existen o han sido eliminados.</p>
                <a href="<%= esCliente ? "index.jsp" : "ventas.jsp" %>" class="btn btn-primary rounded-pill">
                    <i class="bi bi-arrow-left me-1"></i> Volver
                </a>
            </div>
        </c:if>

        <c:if test="${not empty listaVentas}">
            <!-- Barra de resumen general -->
            <div class="summary-bar no-print d-flex justify-content-between align-items-center">
                <div>
                    <span class="badge bg-success rounded-pill mb-1">
                        <i class="bi bi-check-circle me-1"></i>${listaVentas.size()} pasaje(s) emitido(s)
                    </span>
                </div>
                <div class="text-end">
                    <small class="text-muted d-block">Total pagado</small>
                    <strong class="fs-4" style="color: var(--mvb-orange);">S/. ${totalGeneral}</strong>
                </div>
            </div>

            <!-- Botones de acción (no se imprimen) -->
            <div class="text-center mb-4 no-print">
                <a href="<%= esCliente ? "index.jsp" : "ventas.jsp" %>" class="btn btn-outline-secondary rounded-pill me-2">
                    <i class="bi bi-arrow-left me-1"></i> <%= esCliente ? "Volver a Inicio" : "Nueva Venta" %>
                </a>
                <button onclick="window.print()" class="btn btn-ingresar rounded-pill">
                    <i class="bi bi-printer me-1"></i> Imprimir / Descargar
                </button>
            </div>

            <!-- Tickets -->
            <c:forEach var="venta" items="${listaVentas}" varStatus="loop">
                <c:if test="${loop.index > 0}"><div class="page-break"></div></c:if>
                <div class="ticket-card">
                    <div class="ticket-header">
                        <div class="success-check">
                            <i class="bi bi-check-lg"></i>
                        </div>
                        <h4 class="fw-bold mb-1">
                            <c:if test="${listaVentas.size() > 1}">Pasaje #${loop.index + 1} de ${listaVentas.size()}</c:if>
                            <c:if test="${listaVentas.size() == 1}">¡Pasaje Confirmado!</c:if>
                        </h4>
                        <p class="mb-0 opacity-75">
                            <c:if test="${listaVentas.size() > 1}">${venta.nombreCliente} ${venta.apellidoCliente} - Asiento N° ${venta.numeroAsiento}</c:if>
                            <c:if test="${listaVentas.size() == 1}">Tu boleto ha sido emitido exitosamente</c:if>
                        </p>
                    </div>

                    <div class="ticket-body">
                        <!-- Número de pasaje -->
                        <div class="text-center mb-3">
                            <small class="text-muted">N° de Pasaje</small>
                            <h4 class="fw-bold" style="color: var(--mvb-orange);">#${venta.idPasaje}</h4>
                        </div>

                        <div class="barcode-decoration">||||||||||||||||||||</div>

                        <!-- Datos del Pasajero -->
                        <h6 class="fw-bold mb-3" style="color: var(--mvb-orange);">
                            <i class="bi bi-person me-1"></i>DATOS DEL PASAJERO
                        </h6>
                        <div class="ticket-row">
                            <span class="ticket-label">Nombre Completo</span>
                            <span class="ticket-value">${venta.nombreCliente} ${venta.apellidoCliente}</span>
                        </div>
                        <div class="ticket-row">
                            <span class="ticket-label">DNI</span>
                            <span class="ticket-value">${venta.dniCliente}</span>
                        </div>

                        <hr class="ticket-divider">

                        <!-- Datos del Viaje -->
                        <h6 class="fw-bold mb-3" style="color: var(--mvb-orange);">
                            <i class="bi bi-bus-front me-1"></i>DATOS DEL VIAJE
                        </h6>
                        <div class="ticket-row">
                            <span class="ticket-label">Ruta</span>
                            <span class="ticket-value">${venta.origen} → ${venta.destino}</span>
                        </div>
                        <div class="ticket-row">
                            <span class="ticket-label">Fecha de Salida</span>
                            <span class="ticket-value">${venta.fechaHoraSalida}</span>
                        </div>
                        <div class="ticket-row">
                            <span class="ticket-label">Llegada Estimada</span>
                            <span class="ticket-value">${venta.fechaHoraLlegada}</span>
                        </div>
                        <div class="ticket-row">
                            <span class="ticket-label">Servicio</span>
                            <span class="ticket-value">${venta.nombreServicio}</span>
                        </div>
                        <div class="ticket-row">
                            <span class="ticket-label">Bus</span>
                            <span class="ticket-value">${venta.marca} ${venta.modelo} - ${venta.placa}</span>
                        </div>

                        <hr class="ticket-divider">

                        <!-- Datos del Asiento -->
                        <h6 class="fw-bold mb-3" style="color: var(--mvb-orange);">
                            <i class="bi bi-seat me-1"></i>DATOS DEL ASIENTO
                        </h6>
                        <div class="ticket-row">
                            <span class="ticket-label">N° Asiento</span>
                            <span class="ticket-value" style="font-size: 1.2rem;">${venta.numeroAsiento}</span>
                        </div>
                        <div class="ticket-row">
                            <span class="ticket-label">Piso</span>
                            <span class="ticket-value">${venta.piso}</span>
                        </div>
                        <div class="ticket-row">
                            <span class="ticket-label">Tipo de Asiento</span>
                            <span class="ticket-value">${venta.tipoAsiento}</span>
                        </div>

                        <hr class="ticket-divider">

                        <!-- Precio -->
                        <div class="ticket-price">
                            S/. ${venta.precioPagado}
                        </div>

                        <div class="text-center text-muted small mt-3">
                            <i class="bi bi-shield-check me-1"></i>
                            Pasaje emitido el ${venta.fechaEmision}
                            <br>
                            <strong>MovilBus</strong> - Viaja seguro, viaja en bus
                        </div>
                    </div>
                </div>
            </c:forEach>

            <!-- Botones inferiores (no se imprimen) -->
            <div class="text-center mt-4 no-print">
                <a href="<%= esCliente ? "index.jsp" : "ventas.jsp" %>" class="btn btn-primary rounded-pill px-4">
                    <i class="bi bi-ticket-perforated me-1"></i> <%= esCliente ? "Comprar Otro Pasaje" : "Nueva Venta" %>
                </a>
                <% if (esCliente) { %>
                    <a href="index.jsp" class="btn btn-outline-secondary rounded-pill px-4 ms-2">
                        <i class="bi bi-house me-1"></i> Volver a Inicio
                    </a>
                <% } %>
            </div>
        </c:if>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
