<%-- Pagina global de errores HTTP (404, 500, etc.) configurada en web.xml --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page isErrorPage="true" %>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fn" uri="jakarta.tags.functions" %>
<%
    // Obtener codigo de error HTTP
    Integer statusCode = (Integer) request.getAttribute("jakarta.servlet.error.status_code");
    String requestUri = (String) request.getAttribute("jakarta.servlet.error.request_uri");
    String servletName = (String) request.getAttribute("jakarta.servlet.error.servlet_name");
    Throwable exc = (Throwable) request.getAttribute("jakarta.servlet.error.exception");
    String excMessage = exc != null ? exc.getMessage() : null;
    
    if (statusCode == null) statusCode = 500;
    if (requestUri == null) requestUri = request.getRequestURI();
    if (servletName == null) servletName = "Desconocido";
    
    String titulo, descripcion, icono;
    switch (statusCode) {
        case 404:
            titulo = "Pagina no encontrada";
            descripcion = "La pagina que buscas no existe o ha sido movida. Verifica la direccion o vuelve al inicio.";
            icono = "bi-emoji-frown";
            break;
        case 403:
            titulo = "Acceso denegado";
            descripcion = "No tienes permisos para acceder a este recurso. Si crees que es un error, contacta al administrador.";
            icono = "bi-shield-exclamation";
            break;
        case 401:
            titulo = "No autorizado";
            descripcion = "Debes iniciar sesion para acceder a esta pagina.";
            icono = "bi-person-lock";
            break;
        case 500:
            titulo = "Error interno del servidor";
            descripcion = "Ocurrio un error inesperado. Nuestro equipo ha sido notificado. Por favor, intenta nuevamente mas tarde.";
            icono = "bi-gear";
            break;
        case 503:
            titulo = "Servicio no disponible";
            descripcion = "El servicio esta temporalmente fuera de servicio. Intentamos restaurarlo lo antes posible.";
            icono = "bi-cloud-slash";
            break;
        default:
            titulo = "Error " + statusCode;
            descripcion = "Ocurrio un error inesperado. Por favor, intenta nuevamente.";
            icono = "bi-exclamation-triangle";
            break;
    }
    request.setAttribute("errorTitulo", titulo);
    request.setAttribute("errorDescripcion", descripcion);
    request.setAttribute("errorIcono", icono);
    request.setAttribute("errorStatusCode", statusCode);
    request.setAttribute("errorRequestUri", requestUri);
    request.setAttribute("errorServletName", servletName);
    request.setAttribute("errorExcMessage", excMessage);
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= statusCode %> - <%= titulo %> | MovilBus</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
            background: linear-gradient(135deg, #0f0c29 0%, #302b63 50%, #24243e 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
        }
        .error-container {
            text-align: center;
            padding: 2rem;
            max-width: 600px;
            width: 100%;
        }
        .error-icon {
            font-size: 6rem;
            color: rgba(255,107,0,.6);
            margin-bottom: 1rem;
            display: inline-block;
            animation: float 3s ease-in-out infinite;
        }
        @keyframes float {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-15px); }
        }
        .error-code {
            font-size: 8rem;
            font-weight: 900;
            background: linear-gradient(135deg, #FF6B00, #FFB300);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            line-height: 1;
            margin-bottom: .5rem;
        }
        .error-title {
            font-size: 1.6rem;
            font-weight: 700;
            margin-bottom: 1rem;
        }
        .error-description {
            font-size: 1rem;
            color: rgba(255,255,255,.6);
            line-height: 1.7;
            margin-bottom: 2rem;
        }
        .error-actions {
            display: flex;
            gap: 1rem;
            justify-content: center;
            flex-wrap: wrap;
        }
        .btn-error-primary {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: linear-gradient(135deg, #FF6B00, #FF8C00);
            border: none;
            color: white;
            font-weight: 700;
            padding: .8rem 2rem;
            border-radius: 50px;
            text-decoration: none;
            transition: all .3s ease;
            box-shadow: 0 4px 15px rgba(255,107,0,.3);
        }
        .btn-error-primary:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(255,107,0,.45);
            color: white;
        }
        .btn-error-secondary {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: rgba(255,255,255,.1);
            border: 2px solid rgba(255,255,255,.2);
            color: white;
            font-weight: 600;
            padding: .8rem 2rem;
            border-radius: 50px;
            text-decoration: none;
            transition: all .3s ease;
            backdrop-filter: blur(10px);
        }
        .btn-error-secondary:hover {
            background: rgba(255,255,255,.15);
            border-color: rgba(255,255,255,.3);
            color: white;
            transform: translateY(-3px);
        }
        .error-details {
            margin-top: 2.5rem;
            padding: 1rem 1.5rem;
            background: rgba(0,0,0,.2);
            border-radius: 16px;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255,255,255,.05);
        }
        .error-details summary {
            cursor: pointer;
            color: rgba(255,255,255,.5);
            font-size: .85rem;
            font-weight: 600;
            user-select: none;
        }
        .error-details summary:hover {
            color: rgba(255,255,255,.7);
        }
        .error-details-content {
            margin-top: 1rem;
            text-align: left;
            font-size: .8rem;
            color: rgba(255,255,255,.4);
            font-family: 'Consolas', 'Courier New', monospace;
            word-break: break-all;
        }
        .error-details-content p {
            margin-bottom: .3rem;
        }
        @media (max-width: 576px) {
            .error-code { font-size: 5rem; }
            .error-icon { font-size: 4rem; }
            .error-title { font-size: 1.3rem; }
        }
        .error-decoration {
            position: fixed;
            width: 300px;
            height: 300px;
            border-radius: 50%;
            background: rgba(255,107,0,.03);
            pointer-events: none;
        }
        .error-decoration:nth-child(1) {
            top: -100px;
            left: -100px;
        }
        .error-decoration:nth-child(2) {
            bottom: -150px;
            right: -100px;
            width: 400px;
            height: 400px;
            background: rgba(255,200,0,.02);
        }
    </style>
</head>
<body>
    <div class="error-decoration"></div>
    <div class="error-decoration"></div>

    <div class="error-container">
        <div class="error-icon">
            <i class="bi ${errorIcono}"></i>
        </div>                    <div class="error-code">${errorStatusCode}</div>
        <h1 class="error-title">${errorTitulo}</h1>
        <p class="error-description">${errorDescripcion}</p>
        
        <div class="error-actions">
            <a href="index.jsp" class="btn-error-primary">
                <i class="bi bi-house-door"></i> Volver al inicio
            </a>
            <button onclick="history.back()" class="btn-error-secondary">
                <i class="bi bi-arrow-left"></i> Pagina anterior
            </button>
        </div>

        <div class="error-details">
            <details>
                <summary><i class="bi bi-info-circle me-1"></i> Detalles tecnicos</summary>
                <div class="error-details-content">                    <p><strong>Codigo:</strong> ${errorStatusCode}</p>
                            <p><strong>URL:</strong> ${fn:escapeXml(errorRequestUri)}</p>
                            <p><strong>Servlet:</strong> ${fn:escapeXml(errorServletName)}</p>
                            <c:if test="${not empty errorExcMessage}">
                                <p><strong>Excepcion:</strong> ${fn:escapeXml(errorExcMessage)}</p>
                            </c:if>
                    <p class="mt-2 text-white-50"><i class="bi bi-clock me-1"></i> <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new java.util.Date()) %></p>
                </div>
            </details>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
