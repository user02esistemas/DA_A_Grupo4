<%-- Pagina publica de seguimiento de encomiendas con timeline --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@page import="java.util.List, java.util.Map, java.text.SimpleDateFormat"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MovilBus - Seguimiento de Encomienda</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="css/movilbus.css">
    <style>
        :root {
            --track-bg: #f8f9fc;
            --track-primary: #FF6B00;
            --track-success: #10b981;
            --track-pending: #f59e0b;
            --track-muted: #9ca3af;
        }
        body { background: var(--track-bg); min-height: 100vh; }
        
        .track-header {
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
            padding: 2rem 0;
            color: white;
        }
        .track-header h1 { font-weight: 800; font-size: 1.8rem; letter-spacing: -.5px; }
        .track-header h1 i { color: var(--track-primary); }
        .track-header p { opacity: .7; font-size: .9rem; }
        
        .track-search-card {
            border: none;
            border-radius: 20px;
            box-shadow: 0 4px 25px rgba(0,0,0,.08);
            overflow: hidden;
            margin-top: -1.5rem;
            position: relative;
            z-index: 10;
        }
        .track-search-card .card-body { padding: 1.5rem 2rem; }
        .track-input-group {
            position: relative;
        }
        .track-input-group .form-control {
            height: 56px;
            border-radius: 50px;
            border: 2px solid #e5e7eb;
            padding-left: 3rem;
            font-size: 1.05rem;
            font-weight: 600;
            letter-spacing: 2px;
            text-transform: uppercase;
            transition: all .3s;
        }
        .track-input-group .form-control:focus {
            border-color: var(--track-primary);
            box-shadow: 0 0 0 4px rgba(255,107,0,.12);
        }
        .track-input-group .input-icon {
            position: absolute;
            left: 1.2rem;
            top: 50%;
            transform: translateY(-50%);
            color: var(--track-muted);
            font-size: 1.3rem;
            z-index: 5;
        }
        .track-input-group .btn-track {
            position: absolute;
            right: 6px;
            top: 6px;
            height: 44px;
            border-radius: 50px;
            background: var(--track-primary);
            border: none;
            color: white;
            font-weight: 700;
            padding: 0 1.8rem;
            transition: all .3s;
        }
        .track-input-group .btn-track:hover {
            background: #e06000;
            transform: scale(1.02);
        }
        
        .track-result-card {
            border: none;
            border-radius: 20px;
            box-shadow: 0 4px 25px rgba(0,0,0,.08);
            overflow: hidden;
        }
        .track-result-card .card-header {
            background: linear-gradient(135deg, var(--track-primary), #FFB300);
            color: white;
            border: none;
            padding: 1.2rem 2rem;
        }
        .track-result-card .card-body { padding: 2rem; }
        
        .track-code-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: rgba(255,255,255,.2);
            border-radius: 50px;
            padding: .4rem 1.2rem;
            font-size: 1.2rem;
            font-weight: 800;
            letter-spacing: 2px;
        }
        
        .estado-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: .4rem 1.2rem;
            border-radius: 50px;
            font-weight: 700;
            font-size: .85rem;
        }
        .estado-badge.REGISTRADO { background: #e5e7eb; color: #374151; }
        .estado-badge.EN_VIAJE { background: #dbeafe; color: #1d4ed8; }
        .estado-badge.ENTREGADO { background: #d1fae5; color: #065f46; }
        .estado-badge.ANULADO { background: #fee2e2; color: #991b1b; }
        .estado-badge.EN_ORIGEN { background: #fef3c7; color: #92400e; }
        .estado-badge.EN_TRANSITO { background: #ede9fe; color: #5b21b6; }
        .estado-badge.EN_DESTINO { background: #e0e7ff; color: #3730a3; }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1.2rem;
        }
        .info-item { }
        .info-item .info-label { font-size: .75rem; color: var(--track-muted); font-weight: 600; text-transform: uppercase; letter-spacing: .5px; }
        .info-item .info-value { font-size: .95rem; font-weight: 600; color: #1f2937; margin-top: 2px; }
        
        .timeline-container {
            position: relative;
            padding: 0;
        }
        .timeline-container::before {
            content: '';
            position: absolute;
            left: 16px;
            top: 0;
            bottom: 0;
            width: 3px;
            background: #e5e7eb;
            border-radius: 3px;
        }
        .timeline-item {
            position: relative;
            padding-left: 48px;
            padding-bottom: 1.5rem;
        }
        .timeline-item:last-child { padding-bottom: 0; }
        .timeline-item .timeline-dot {
            position: absolute;
            left: 8px;
            width: 20px;
            height: 20px;
            border-radius: 50%;
            border: 3px solid #e5e7eb;
            background: white;
            z-index: 2;
        }
        .timeline-item.active .timeline-dot {
            border-color: var(--track-primary);
            background: var(--track-primary);
            box-shadow: 0 0 0 4px rgba(255,107,0,.15);
        }
        .timeline-item.active .timeline-dot::after {
            content: '';
            position: absolute;
            top: 4px;
            left: 4px;
            width: 6px;
            height: 6px;
            border-radius: 50%;
            background: white;
        }
        .timeline-item.completed .timeline-dot {
            border-color: var(--track-success);
            background: var(--track-success);
        }
        .timeline-item.pending .timeline-dot {
            border-color: var(--track-muted);
            background: #f3f4f6;
        }
        .timeline-item .timeline-content {
            background: #f9fafb;
            border-radius: 12px;
            padding: .8rem 1.2rem;
            transition: all .2s;
        }
        .timeline-item.active .timeline-content {
            background: rgba(255,107,0,.06);
            border-left: 3px solid var(--track-primary);
        }
        .timeline-item .timeline-content .tl-title {
            font-weight: 700;
            font-size: .9rem;
            color: #1f2937;
        }
        .timeline-item .timeline-content .tl-desc {
            font-size: .8rem;
            color: #6b7280;
            margin-top: 2px;
        }
        .timeline-item .timeline-content .tl-time {
            font-size: .75rem;
            color: var(--track-muted);
            margin-top: 4px;
        }
        
        .not-found-card {
            border: none;
            border-radius: 20px;
            box-shadow: 0 4px 25px rgba(0,0,0,.08);
            text-align: center;
            padding: 3rem;
        }
        .not-found-card i { font-size: 4rem; color: var(--track-muted); }
        .not-found-card h4 { font-weight: 700; margin-top: 1rem; }
        .not-found-card p { color: #6b7280; }
        
        .back-link {
            color: rgba(255,255,255,.7);
            text-decoration: none;
            font-size: .9rem;
            transition: all .2s;
        }
        .back-link:hover { color: white; }
        
        .progress-bar-container {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin: 1.5rem 0;
            position: relative;
        }
        .progress-bar-container::before {
            content: '';
            position: absolute;
            left: 30px;
            right: 30px;
            top: 50%;
            height: 4px;
            background: #e5e7eb;
            border-radius: 4px;
            transform: translateY(-50%);
            z-index: 0;
        }
        .progress-step {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 6px;
            position: relative;
            z-index: 1;
        }
        .progress-step .step-dot {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: .9rem;
            font-weight: 800;
            border: 3px solid #e5e7eb;
            background: white;
            color: var(--track-muted);
        }
        .progress-step.completed .step-dot {
            border-color: var(--track-success);
            background: var(--track-success);
            color: white;
        }
        .progress-step.active .step-dot {
            border-color: var(--track-primary);
            background: var(--track-primary);
            color: white;
            box-shadow: 0 0 0 4px rgba(255,107,0,.15);
        }
        .progress-step .step-label {
            font-size: .65rem;
            font-weight: 600;
            color: var(--track-muted);
            text-align: center;
            text-transform: uppercase;
            letter-spacing: .5px;
        }
        .progress-step.completed .step-label { color: var(--track-success); }
        .progress-step.active .step-label { color: var(--track-primary); font-weight: 700; }
        
        footer {
            margin-top: 3rem;
            padding: 1.5rem 0;
            text-align: center;
            color: var(--track-muted);
            font-size: .85rem;
        }
        footer a { color: var(--track-primary); text-decoration: none; }
        
        @media (max-width: 576px) {
            .track-search-card .card-body { padding: 1rem; }
            .track-result-card .card-body { padding: 1rem; }
            .info-grid { grid-template-columns: 1fr 1fr; gap: .8rem; }
        }
    </style>
</head>
<body>
    <div class="track-header">
        <div class="container">
            <a href="index.jsp" class="back-link">
                <i class="bi bi-arrow-left me-1"></i> Volver a MovilBus
            </a>
            <h1 class="mt-2"><i class="bi bi-box-seam me-2"></i> Seguimiento de Encomienda</h1>
            <p>Ingresa tu codigo de seguimiento para conocer el estado de tu envio</p>
        </div>
    </div>

    <div class="container py-4">
        <div class="row justify-content-center">
            <div class="col-lg-8 col-xl-7">
                <!-- Search Card -->
                <div class="track-search-card">
                    <div class="card-body">
                        <form action="EncomiendaServlet" method="GET" class="track-input-group">
                            <input type="hidden" name="accion" value="tracking">
                            <i class="bi bi-search input-icon"></i>
                            <input type="text" name="codigo" class="form-control" 
                                   placeholder="MOV-XXXXXXXX" 
                                   value="${param.codigo}"
                                   maxlength="20" 
                                   style="text-transform:uppercase"
                                   autofocus>
                            <button type="submit" class="btn-track">
                                <i class="bi bi-arrow-right me-1"></i> Buscar
                            </button>
                        </form>
                        <div class="text-center mt-2">
                            <small class="text-muted">Ejemplo: MOV-AB12CD34</small>
                        </div>
                    </div>
                </div>

                <!-- Not Found Alert -->
                <c:if test="${param.notfound == '1'}">
                    <div class="not-found-card mt-4">
                        <i class="bi bi-search-heart"></i>
                        <h4>Encomienda no encontrada</h4>
                        <p>No pudimos encontrar un envio con el codigo <strong>${param.codigo}</strong>. Verifica el codigo e intenta nuevamente.</p>
                        <button class="btn btn-outline-primary rounded-pill px-4 mt-2" onclick="document.querySelector('input[name=codigo]').focus()">
                            <i class="bi bi-arrow-clockwise me-1"></i> Intentar de nuevo
                        </button>
                    </div>
                </c:if>

                <!-- Result Card -->
                <c:if test="${not empty encomiendaTracking}">
                    <%
                        Map<String, Object> enc = (Map<String, Object>) request.getAttribute("encomiendaTracking");
                        String estado = (String) enc.get("estado");
                        pageContext.setAttribute("estadoActual", estado);
                    %>
                    <div class="track-result-card mt-4 animate-fade">
                        <div class="card-header d-flex flex-wrap align-items-center justify-content-between gap-2">
                            <div>
                                <small class="text-white-50">Codigo de Seguimiento</small>
                                <div class="track-code-badge">
                                    <i class="bi bi-upc-scan"></i>
                                    ${encomiendaTracking.codigoSeguimiento}
                                </div>
                            </div>
                            <div>
                                <span class="estado-badge ${fn:replace(estadoActual, ' ', '_')}">
                                    <c:choose>
                                        <c:when test="${estadoActual == 'REGISTRADO'}"><i class="bi bi-clipboard-check"></i></c:when>
                                        <c:when test="${estadoActual == 'EN VIAJE'}"><i class="bi bi-truck"></i></c:when>
                                        <c:when test="${estadoActual == 'ENTREGADO'}"><i class="bi bi-check-circle"></i></c:when>
                                        <c:when test="${estadoActual == 'ANULADO'}"><i class="bi bi-x-circle"></i></c:when>
                                        <c:otherwise><i class="bi bi-clock"></i></c:otherwise>
                                    </c:choose>
                                    ${estadoActual}
                                </span>
                            </div>
                        </div>
                        <div class="card-body">
                            <!-- Info Grid -->
                            <div class="info-grid mb-4">
                                <div class="info-item">
                                    <div class="info-label"><i class="bi bi-person-up me-1"></i>Remitente</div>
                                    <div class="info-value">${encomiendaTracking.nombreRemitente}</div>
                                    <small class="text-muted">DNI: ${encomiendaTracking.dniRemitente}</small>
                                </div>
                                <div class="info-item">
                                    <div class="info-label"><i class="bi bi-person-down me-1"></i>Destinatario</div>
                                    <div class="info-value">${encomiendaTracking.nombreDestinatario}</div>
                                    <small class="text-muted">DNI: ${encomiendaTracking.dniDestinatario}</small>
                                </div>
                                <div class="info-item">
                                    <div class="info-label"><i class="bi bi-geo-alt me-1"></i>Ruta</div>
                                    <div class="info-value">${encomiendaTracking.origen} <i class="bi bi-arrow-right mx-1"></i> ${encomiendaTracking.destino}</div>
                                </div>
                                <div class="info-item">
                                    <div class="info-label"><i class="bi bi-box me-1"></i>Descripcion / Peso</div>
                                    <div class="info-value">${encomiendaTracking.descripcion}</div>
                                    <small class="text-muted">${encomiendaTracking.pesoKg} kg</small>
                                </div>
                                <div class="info-item">
                                    <div class="info-label"><i class="bi bi-bus-front me-1"></i>Bus</div>
                                    <div class="info-value">${encomiendaTracking.placa}</div>
                                    <small class="text-muted">${encomiendaTracking.marca}</small>
                                </div>
                                <div class="info-item">
                                    <div class="info-label"><i class="bi bi-cash me-1"></i>Pago</div>
                                    <div class="info-value">S/. ${encomiendaTracking.montoPago}</div>
                                    <small class="text-muted">${encomiendaTracking.metodoPago}</small>
                                </div>
                            </div>

                            <!-- Progress Steps (visual) -->
                            <c:if test="${estadoActual != 'ANULADO'}">
                            <%
                                String estadoActual = (String) ((Map) request.getAttribute("encomiendaTracking")).get("estado");
                                String[] pasos = {"REGISTRADO", "EN VIAJE", "ENTREGADO"};
                                boolean encontrado = false;
                                request.setAttribute("pasos", pasos);
                            %>
                            <div class="progress-bar-container">
                                <c:forEach var="estadoStep" items="${pasos}" varStatus="vs">
                                    <%
                                        String paso = (String) pageContext.getAttribute("estadoStep");
                                        String estadoActual2 = (String) ((Map) request.getAttribute("encomiendaTracking")).get("estado");
                                        String[] pasosArr = (String[]) request.getAttribute("pasos");
                                        int idxPaso = java.util.Arrays.asList(pasosArr).indexOf(paso);
                                        int idxActual = java.util.Arrays.asList(pasosArr).indexOf(estadoActual2);
                                        String clase;
                                        if (paso.equals(estadoActual2)) {
                                            clase = "active";
                                        } else if (idxPaso < idxActual) {
                                            clase = "completed";
                                        } else {
                                            clase = "";
                                        }
                                        pageContext.setAttribute("stepClass", clase);
                                    %>
                                    <div class="progress-step ${stepClass}">
                                        <div class="step-dot">
                                            <c:choose>
                                                <c:when test="${stepClass == 'completed'}"><i class="bi bi-check-lg"></i></c:when>
                                                <c:when test="${stepClass == 'active'}"><i class="bi bi-chevron-right"></i></c:when>
                                                <c:otherwise>${vs.count}</c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div class="step-label">${estadoStep}</div>
                                    </div>
                                </c:forEach>
                            </div>
                            </c:if>
                            <c:if test="${estadoActual == 'ANULADO'}">
                                <div class="alert alert-danger text-center rounded-3 mt-3">
                                    <i class="bi bi-x-circle me-2"></i> Esta encomienda fue <strong>ANULADA</strong> y no continuara su proceso de envio.
                                </div>
                            </c:if>

                            <hr class="my-4">
                            
                            <!-- Timeline -->
                            <h6 class="fw-bold mb-3">
                                <i class="bi bi-clock-history me-2"></i> Historial del Envio
                            </h6>
                            <div class="timeline-container">
                                <c:forEach var="ev" items="${historialEstados}" varStatus="vs">
                                    <c:set var="esUltimo" value="${vs.last}"/>
                                    <c:set var="itemClass" value=""/>
                                    <c:if test="${esUltimo and estadoActual != 'ANULADO'}">
                                        <c:set var="itemClass" value="active"/>
                                    </c:if>
                                    <c:if test="${not esUltimo or estadoActual == 'ENTREGADO'}">
                                        <c:set var="itemClass" value="completed"/>
                                    </c:if>
                                    <c:if test="${estadoActual == 'ANULADO' and esUltimo}">
                                        <c:set var="itemClass" value="active"/>
                                    </c:if>
                                    <div class="timeline-item ${itemClass}">
                                        <div class="timeline-dot"></div>
                                        <div class="timeline-content">
                                            <div class="tl-title">
                                                <c:choose>
                                                    <c:when test="${empty ev.estadoAnterior}">Encomienda registrada</c:when>
                                                    <c:otherwise>${ev.observacion}</c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div class="tl-desc">
                                                <c:if test="${not empty ev.usuarioCambio}">
                                                    <i class="bi bi-person me-1"></i>${ev.usuarioCambio}
                                                </c:if>
                                                <c:if test="${not empty ev.estadoAnterior and not empty ev.estadoNuevo}">
                                                    <span class="badge bg-light text-dark ms-2">${ev.estadoAnterior} <i class="bi bi-arrow-right"></i> ${ev.estadoNuevo}</span>
                                                </c:if>
                                            </div>
                                            <div class="tl-time">
                                                <i class="bi bi-clock me-1"></i>${ev.fechaCambio}
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </div>
                </c:if>

                <!-- Initial state: no search yet -->
                <c:if test="${empty encomiendaTracking and empty param.notfound and empty param.codigo}">
                    <div class="text-center py-5">
                        <i class="bi bi-box-seam text-muted" style="font-size: 4rem;"></i>
                        <h5 class="fw-bold mt-3">Rastrea tu Envio</h5>
                        <p class="text-muted">Ingresa el codigo de seguimiento que recibiste al registrar tu encomienda para conocer su ubicacion y estado actual.</p>
                        <div class="row justify-content-center mt-4">
                            <div class="col-md-4 col-6 text-center p-3">
                                <div class="rounded-circle bg-light d-inline-flex align-items-center justify-content-center mb-2" style="width: 50px; height: 50px;">
                                    <i class="bi bi-upc-scan text-primary fs-4"></i>
                                </div>
                                <h6 class="small fw-bold">1. Ingresa el codigo</h6>
                                <small class="text-muted">El codigo MOV-XXXXXXX</small>
                            </div>
                            <div class="col-md-4 col-6 text-center p-3">
                                <div class="rounded-circle bg-light d-inline-flex align-items-center justify-content-center mb-2" style="width: 50px; height: 50px;">
                                    <i class="bi bi-eye text-primary fs-4"></i>
                                </div>
                                <h6 class="small fw-bold">2. Revisa el estado</h6>
                                <small class="text-muted">Ubicacion actual del paquete</small>
                            </div>
                            <div class="col-md-4 col-6 text-center p-3">
                                <div class="rounded-circle bg-light d-inline-flex align-items-center justify-content-center mb-2" style="width: 50px; height: 50px;">
                                    <i class="bi bi-clock-history text-primary fs-4"></i>
                                </div>
                                <h6 class="small fw-bold">3. Sigue el progreso</h6>
                                <small class="text-muted">Historial completo del envio</small>
                            </div>
                        </div>
                    </div>
                </c:if>

            </div>
        </div>
    </div>

    <footer>
        <div class="container">
            <p class="mb-0">
                <i class="bi bi-bus-front me-1"></i> <strong>MovilBus</strong> — Servicio de transporte de pasajeros y encomiendas.
                <br>
                <a href="index.jsp">Volver al inicio</a>
            </p>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Auto-uppercase tracking code
        document.addEventListener('DOMContentLoaded', function() {
            const input = document.querySelector('input[name=codigo]');
            if (input) {
                input.addEventListener('input', function() {
                    this.value = this.value.toUpperCase();
                });
                // Focus if empty
                if (!input.value) input.focus();
            }
        });
    </script>
</body>
</html>
