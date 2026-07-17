<%-- Pantalla de confirmacion de compra - Diseno profesional tipo boarding pass --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@page import="dao.ViajeDAO, dao.FidelizacionDAO, java.util.Map, java.util.List, model.Usuario"%>
<%
    String idPasajeStr = request.getParameter("idPasaje");
    String multiStr = request.getParameter("multi");
    
    if (idPasajeStr == null || idPasajeStr.isEmpty()) {
        response.sendRedirect("ventas.jsp");
        return;
    }
    
    ViajeDAO viajeDAO = new ViajeDAO();
    
    List<Map<String, Object>> listaVentas;
    if (multiStr != null && !multiStr.isEmpty()) {
        listaVentas = viajeDAO.obtenerVentasPorIds(multiStr);
    } else {
        Map<String, Object> ventaUnica = viajeDAO.obtenerVentaPorId(Integer.parseInt(idPasajeStr));
        listaVentas = new java.util.ArrayList<>();
        if (ventaUnica != null) listaVentas.add(ventaUnica);
    }
    request.setAttribute("listaVentas", listaVentas);
    
    double totalGeneral = 0;
    for (Map<String, Object> v : listaVentas) {
        Object precio = v.get("precioPagado");
        if (precio instanceof Number) totalGeneral += ((Number) precio).doubleValue();
    }
    request.setAttribute("totalGeneral", totalGeneral);
    
    // Calcular puntos de fidelización ganados (usando constante del DAO)
    int puntosGanados = (int) (totalGeneral / dao.FidelizacionDAO.getPuntosPorSol());
    request.setAttribute("puntosGanados", puntosGanados);
    
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
    <script src="https://cdn.jsdelivr.net/npm/html2canvas@1.4.1/dist/html2canvas.min.js"></script>
    <style>
        :root {
            --bp-orange: #FF6B00;
            --bp-dark: #1A1A2E;
            --bp-gray: #f5f6fa;
            --bp-border: #e8e8e8;
        }
        
        body {
            background: linear-gradient(135deg, #1A1A2E 0%, #2D2D44 100%);
            min-height: 100vh;
            font-family: 'Inter', 'Segoe UI', system-ui, sans-serif;
        }
        
        /* ============ PRINT ============ */
        @media print {
            @page { margin: 0.5cm; }
            body { background: white !important; }
            .no-print { display: none !important; }
            .bp-card { 
                box-shadow: none !important; 
                border: 2px solid #333 !important;
                break-inside: avoid;
                page-break-inside: avoid;
            }
            .bp-perforated-top::before { display: none !important; }
            .bp-back-button { display: none !important; }
        }
        
        /* ============ BOARDING PASS CARD ============ */
        .bp-card {
            max-width: 520px;
            margin: 0 auto;
            background: white;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 20px 60px rgba(0,0,0,.3);
            position: relative;
            transition: transform .3s;
        }
        .bp-card:hover { transform: translateY(-2px); }
        .bp-card + .bp-card { margin-top: 2.5rem; }
        
        /* Perforated top edge */
        .bp-card.bp-perforated-top {
            position: relative;
        }
        .bp-card.bp-perforated-top::before {
            content: '';
            position: absolute;
            top: -10px;
            left: 0;
            right: 0;
            height: 20px;
            background: radial-gradient(circle at 20px 0, transparent 10px, white 11px);
            background-size: 40px 20px;
            z-index: 2;
        }
        
        /* ============ HEADER ============ */
        .bp-header {
            background: linear-gradient(135deg, #FF6B00, #FF8C00, #FFB300);
            padding: 1.2rem 1.8rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            color: white;
            position: relative;
        }
        .bp-header::after {
            content: '';
            position: absolute;
            bottom: -8px;
            left: 0;
            right: 0;
            height: 16px;
            background: radial-gradient(circle at 12px 0, transparent 8px, white 9px);
            background-size: 24px 16px;
            z-index: 1;
        }
        .bp-brand {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .bp-brand-icon {
            width: 40px;
            height: 40px;
            background: rgba(255,255,255,.2);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.3rem;
        }
        .bp-brand h4 {
            font-weight: 800;
            font-size: 1.1rem;
            margin: 0;
            line-height: 1.1;
        }
        .bp-brand small {
            opacity: .8;
            font-size: .65rem;
            display: block;
        }
        .bp-ticket-type {
            text-align: right;
        }
        .bp-ticket-type .badge {
            background: rgba(255,255,255,.25);
            font-size: .7rem;
            padding: .3rem .8rem;
            border-radius: 50px;
        }
        .bp-ticket-type strong {
            display: block;
            font-size: 1rem;
        }
        
        /* ============ BODY ============ */
        .bp-body {
            padding: 1.5rem 1.8rem 1.2rem;
            background: white;
        }
        
        /* Success banner */
        .bp-success {
            text-align: center;
            margin-bottom: 1.2rem;
        }
        .bp-success-icon {
            width: 56px;
            height: 56px;
            border-radius: 50%;
            background: linear-gradient(135deg, #198754, #20c997);
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto .5rem;
            font-size: 1.6rem;
            color: white;
            animation: bpPulse .6s ease;
        }
        @keyframes bpPulse {
            0% { transform: scale(0); }
            60% { transform: scale(1.1); }
            100% { transform: scale(1); }
        }
        .bp-success h5 { font-weight: 800; font-size: 1.1rem; margin-bottom: .2rem; }
        .bp-success small { color: #6c757d; font-size: .75rem; }
        
        /* ID Badge */
        .bp-id-badge {
            text-align: center;
            margin-bottom: 1rem;
        }
        .bp-id-badge small {
            font-size: .65rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: #6c757d;
        }
        .bp-id-badge .id-number {
            font-size: 1.3rem;
            font-weight: 900;
            letter-spacing: 2px;
            color: var(--bp-orange);
        }
        
        /* ============ DIVIDERS ============ */
        .bp-divider {
            border: none;
            border-top: 2px dashed var(--bp-border);
            margin: 1rem 0;
            position: relative;
        }
        .bp-divider-dots {
            border: none;
            border-top: 2px dotted var(--bp-border);
            margin: .8rem 0;
        }
        
        /* ============ INFO ROWS ============ */
        .bp-section-title {
            font-size: .65rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: var(--bp-orange);
            margin-bottom: .6rem;
        }
        .bp-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: .35rem 0;
        }
        .bp-row .label {
            font-size: .75rem;
            color: #6c757d;
        }
        .bp-row .value {
            font-size: .85rem;
            font-weight: 600;
            color: var(--bp-dark);
            text-align: right;
        }
        .bp-row .value-lg {
            font-size: 1rem;
            font-weight: 700;
        }
        
        /* Route highlight */
        .bp-route {
            text-align: center;
            padding: .6rem 0;
            margin: .5rem 0;
            background: #FFF8E1;
            border-radius: 12px;
            border: 1px solid #FFE082;
        }
        .bp-route .city {
            font-weight: 800;
            font-size: 1.2rem;
            color: var(--bp-dark);
        }
        .bp-route .arrow {
            color: var(--bp-orange);
            font-size: 1.5rem;
            margin: 0 .5rem;
        }
        .bp-route .time {
            font-size: .75rem;
            color: #6c757d;
        }
        
        /* ============ SEAT HIGHLIGHT ============ */
        .bp-seat {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: .6rem 1rem;
            background: linear-gradient(135deg, #FFF3E0, #FFE0B2);
            border-radius: 12px;
            margin: .8rem 0;
        }
        .bp-seat-icon {
            width: 44px;
            height: 44px;
            background: var(--bp-orange);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.2rem;
        }
        .bp-seat-info {
            flex: 1;
        }
        .bp-seat-info .seat-number {
            font-size: 1.2rem;
            font-weight: 900;
            color: var(--bp-dark);
        }
        .bp-seat-info .seat-type {
            font-size: .7rem;
            color: #6c757d;
        }
        .bp-seat-info .seat-price {
            font-weight: 800;
            font-size: 1.1rem;
            color: var(--bp-orange);
        }
        
        /* ============ PRICE SECTION ============ */
        .bp-price {
            text-align: center;
            padding: .5rem 0;
        }
        .bp-price .amount {
            font-size: 2rem;
            font-weight: 900;
            color: var(--bp-orange);
        }
        .bp-price .label {
            font-size: .7rem;
            color: #6c757d;
            text-transform: uppercase;
            letter-spacing: .5px;
        }
        
        /* ============ FOOTER ============ */
        .bp-footer {
            padding: 1rem 1.8rem;
            background: #f8f9fa;
            border-top: 1px solid var(--bp-border);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .bp-footer small {
            font-size: .65rem;
            color: #6c757d;
        }
        .bp-footer strong {
            color: var(--bp-dark);
        }
        
        /* ============ QR ============ */
        .bp-qr {
            text-align: center;
            padding: .5rem 0;
        }
        .bp-qr img {
            width: 90px;
            height: 90px;
            border-radius: 8px;
            border: 2px solid #eee;
        }
        .bp-qr small {
            display: block;
            font-size: .6rem;
            color: #6c757d;
            margin-top: 3px;
        }
        
        /* ============ PERFORATED SIDE (barcode) ============ */
        .bp-barcode {
            text-align: center;
            padding: .3rem 0;
            font-family: 'Courier New', monospace;
            font-size: 1.3rem;
            letter-spacing: 3px;
            color: #bbb;
        }
        
        /* ============ SUMMARY BAR ============ */
        .bp-summary {
            max-width: 520px;
            margin: 0 auto 1.5rem;
            background: rgba(255,255,255,.95);
            border-radius: 16px;
            padding: 1rem 1.5rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 4px 20px rgba(0,0,0,.1);
            border-left: 4px solid var(--bp-orange);
        }
        
        /* ============ ACTION BUTTONS ============ */
        .bp-actions {
            max-width: 520px;
            margin: 1.5rem auto;
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
            justify-content: center;
        }
        .bp-actions .btn {
            border-radius: 50px;
            font-weight: 600;
            font-size: .85rem;
            padding: .6rem 1.2rem;
            transition: all .2s;
        }
        .bp-actions .btn:hover {
            transform: translateY(-2px);
        }
        
        /* Empty state */
        .bp-empty {
            max-width: 520px;
            margin: 4rem auto;
            text-align: center;
        }
        .bp-empty .card {
            border: none;
            border-radius: 20px;
            padding: 3rem;
            background: white;
        }
    </style>
</head>
<body>
    <div class="container py-4">
        
        <c:if test="${empty listaVentas}">
            <div class="bp-empty">
                <div class="card shadow-sm">
                    <i class="bi bi-exclamation-triangle fs-1 text-warning"></i>
                    <h4 class="mt-3 fw-bold">Pasaje(s) no encontrado(s)</h4>
                    <p class="text-muted">Los pasajes solicitados no existen o han sido eliminados.</p>
                    <a href="<%= esCliente ? "index.jsp" : "ventas.jsp" %>" class="btn btn-ingresar rounded-pill px-4">
                        <i class="bi bi-arrow-left me-1"></i> Volver
                    </a>
                </div>
            </div>
        </c:if>

        <c:if test="${not empty listaVentas}">
            <!-- ============ SUMMARY BAR ============ -->
            <div class="bp-summary no-print">
                <div>
                    <span class="badge bg-success rounded-pill">
                        <i class="bi bi-check-circle me-1"></i>${listaVentas.size()} pasaje(s) emitido(s)
                    </span>
                    <c:if test="${puntosGanados > 0}">
                    <div class="mt-2">
                        <span class="badge bg-warning text-dark rounded-pill">
                            <i class="bi bi-star-fill me-1"></i>+${puntosGanados} puntos de fidelización
                        </span>
                    </div>
                    </c:if>
                </div>
                <div class="text-end">
                    <small class="text-muted d-block" style="font-size:.7rem;">Total pagado</small>
                    <strong class="fs-4" style="color: var(--bp-orange);">
                        S/ <fmt:formatNumber value="${totalGeneral}" pattern="#,##0.00"/>
                    </strong>
                </div>
            </div>

            <!-- ============ TICKETS (boarding passes) ============ -->
            <c:forEach var="venta" items="${listaVentas}" varStatus="loop">
            
            <!-- Page break for multi-ticket print -->
            <c:if test="${loop.index > 0}"><div class="page-break" style="page-break-before:always;"></div></c:if>
            
            <div class="bp-card bp-perforated-top" id="ticket-${loop.index}">
                
                <!-- HEADER -->
                <div class="bp-header">
                    <div class="bp-brand">
                        <div class="bp-brand-icon">
                            <i class="bi bi-bus-front"></i>
                        </div>
                        <div>
                            <h4>MovilBus</h4>
                            <small>Viaja seguro, viaja en bus</small>
                        </div>
                    </div>
                    <div class="bp-ticket-type">
                        <strong>BOARDING PASS</strong>
                        <span class="badge">${venta.nombreServicio}</span>
                    </div>
                </div>

                <!-- BODY -->
                <div class="bp-body">
                    
                    <!-- Success + ID -->
                    <div class="bp-success">
                        <div class="bp-success-icon">
                            <i class="bi bi-check-lg"></i>
                        </div>
                        <h5>
                            <c:if test="${listaVentas.size() > 1}">
                                Pasajero ${loop.index + 1} de ${listaVentas.size()}
                            </c:if>
                            <c:if test="${listaVentas.size() == 1}">
                                ¡Pasaje Confirmado!
                            </c:if>
                        </h5>
                        <small>Tu boleto ha sido emitido exitosamente</small>
                    </div>

                    <div class="bp-id-badge">
                        <small>Numero de Pasaje</small>
                        <div class="id-number">#${venta.idPasaje}</div>
                    </div>

                    <hr class="bp-divider">

                    <!-- ROUTE HIGHLIGHT -->
                    <div class="bp-route">
                        <div class="city">${venta.origen}</div>
                        <div>
                            <span class="arrow"><i class="bi bi-arrow-right"></i></span>
                        </div>
                        <div class="city">${venta.destino}</div>
                        <div class="time">
                            <i class="bi bi-clock me-1"></i>${venta.fechaHoraSalida}
                        </div>
                    </div>

                    <hr class="bp-divider">

                    <!-- PASSENGER INFO -->
                    <div class="bp-section-title">
                        <i class="bi bi-person me-1"></i>Pasajero
                    </div>
                    <div class="bp-row">
                        <span class="label">Nombre</span>
                        <span class="value">${venta.nombreCliente} ${venta.apellidoCliente}</span>
                    </div>
                    <div class="bp-row">
                        <span class="label">DNI</span>
                        <span class="value">${venta.dniCliente}</span>
                    </div>

                    <hr class="bp-divider-dots">

                    <!-- TRIP DETAILS -->
                    <div class="bp-section-title">
                        <i class="bi bi-info-circle me-1"></i>Detalles del Viaje
                    </div>
                    <div class="bp-row">
                        <span class="label">Salida</span>
                        <span class="value">${venta.fechaHoraSalida}</span>
                    </div>
                    <div class="bp-row">
                        <span class="label">Llegada Est.</span>
                        <span class="value">${venta.fechaHoraLlegada}</span>
                    </div>
                    <div class="bp-row">
                        <span class="label">Bus</span>
                        <span class="value">${venta.marca} ${venta.modelo} - ${venta.placa}</span>
                    </div>
                    <div class="bp-row">
                        <span class="label">Servicio</span>
                        <span class="value">
                            <span class="badge bg-info">${venta.nombreServicio}</span>
                        </span>
                    </div>

                    <hr class="bp-divider-dots">

                    <!-- SEAT HIGHLIGHT -->
                    <div class="bp-section-title">
                        <i class="bi bi-seat me-1"></i>Asiento
                    </div>
                    <div class="bp-seat">
                        <div class="bp-seat-icon">
                            <i class="bi bi-seat"></i>
                        </div>
                        <div class="bp-seat-info">
                            <div class="seat-number">Asiento N° ${venta.numeroAsiento}</div>
                            <div class="seat-type">${venta.tipoAsiento} - Piso ${venta.piso}</div>
                        </div>
                        <div class="seat-price">
                            S/ <fmt:formatNumber value="${venta.precioPagado}" pattern="#,##0.00"/>
                        </div>
                    </div>

                    <!-- BARCODE DECORATION -->
                    <div class="bp-barcode">||||||||||||||||||||</div>

                    <!-- QR CODE -->
                    <div class="bp-qr">
                        <img src="https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=MovilBus%20-%20Pasaje%20%23${venta.idPasaje}%0A${venta.nombreCliente}%20${venta.apellidoCliente}%0A${venta.origen}%20%E2%86%92%20${venta.destino}%0A${venta.fechaHoraSalida}%0AAsiento%20N%C2%B0%20${venta.numeroAsiento}%0ATotal:%20S/${venta.precioPagado}"
                             alt="QR del pasaje"
                             loading="lazy"
                             onerror="this.style.display='none'">
                        <small>Escanea para ver detalles del pasaje</small>
                    </div>

                </div>

                <!-- FOOTER -->
                <div class="bp-footer">
                    <div>
                        <small>Emitido el</small><br>
                        <strong>${venta.fechaEmision}</strong>
                    </div>
                    <div class="text-end">
                        <small>Powered by</small><br>
                        <strong>MovilBus</strong>
                    </div>
                </div>
            </div>
            </c:forEach>

            <!-- ============ ACTION BUTTONS ============ -->
            <div class="bp-actions no-print">
                <a href="<%= esCliente ? "index.jsp" : "ventas.jsp" %>" class="btn btn-outline-light">
                    <i class="bi bi-arrow-left me-1"></i> 
                    <%= esCliente ? "Inicio" : "Nueva Venta" %>
                </a>
                <button onclick="window.print()" class="btn btn-ingresar">
                    <i class="bi bi-printer me-1"></i> Imprimir / PDF
                </button>
                <button onclick="descargarTicket(this, 0)" class="btn btn-outline-light">
                    <i class="bi bi-download me-1"></i> PNG
                </button>
                <a href="https://wa.me/?text=🎫%20MovilBus%20-%20Pasaje%20Confirmado%0APasajero:%20${listaVentas[0].nombreCliente}%20${listaVentas[0].apellidoCliente}%0ARuta:%20${listaVentas[0].origen}%20%E2%86%92%20${listaVentas[0].destino}%0AFecha:%20${listaVentas[0].fechaHoraSalida}%0AAsiento:%20N%C2%B0%20${listaVentas[0].numeroAsiento}%0ATotal:%20S/${totalGeneral}"
                   target="_blank" class="btn btn-success">
                    <i class="bi bi-whatsapp me-1"></i> Compartir
                </a>
            </div>
        </c:if>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
    // ================================================================
    // DESCARGAR TICKET COMO PNG (usando html2canvas)
    // ================================================================
    function descargarTicket(btn, idx) {
        const targetId = 'ticket-' + (idx || 0);
        const element = document.getElementById(targetId);
        
        if (!element) {
            alert('No se encontro el ticket para descargar.');
            return;
        }

        // Mostrar indicador
        const originalText = btn.innerHTML;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span> Generando...';
        btn.disabled = true;

        // Si hay multiples tickets, descargar todos
        const ticketsCount = ${listaVentas.size()};
        
        function descargarTicketIndividual(elemento, nombreArchivo) {
            return html2canvas(elemento, {
                scale: 2,
                backgroundColor: '#ffffff',
                useCORS: true,
                allowTaint: false,
                logging: false,
                width: elemento.scrollWidth,
                height: elemento.scrollHeight,
                windowWidth: elemento.scrollWidth,
                windowHeight: elemento.scrollHeight
            }).then(function(canvas) {
                const link = document.createElement('a');
                link.download = nombreArchivo;
                link.href = canvas.toDataURL('image/png');
                link.click();
            });
        }
        
        if (ticketsCount <= 1) {
            // Un solo ticket
            descargarTicketIndividual(element, 'MovilBus_Ticket.png').then(function() {
                btn.innerHTML = originalText;
                btn.disabled = false;
            }).catch(function(err) {
                console.error('Error:', err);
                alert('Error al generar la imagen.');
                btn.innerHTML = originalText;
                btn.disabled = false;
            });
        } else {
            // Multiples tickets - descargar todos
            const promises = [];
            for (let i = 0; i < ticketsCount; i++) {
                const el = document.getElementById('ticket-' + i);
                if (el) {
                    promises.push(
                        descargarTicketIndividual(el, 'MovilBus_Ticket_' + (i+1) + '.png')
                    );
                }
            }
            Promise.all(promises).then(function() {
                btn.innerHTML = originalText;
                btn.disabled = false;
            }).catch(function(err) {
                console.error('Error:', err);
                alert('Error al generar las imagenes.');
                btn.innerHTML = originalText;
                btn.disabled = false;
            });
        }
    }
    </script>
</body>
</html>
