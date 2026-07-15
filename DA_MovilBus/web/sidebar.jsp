<%-- 
    Document   : sidebar
    Sidebar reutilizable para el panel de administración de MovilBus.
    Se incluye solo en páginas para ADMINISTRADOR y VENDEDOR.

    Parámetros esperados (request attributes o pageContext):
      - activePage: String (dashboard, conductores, buses, ciudades, rutas, viajes, ventas, historial)
      - esAdmin: boolean (true si el usuario es ADMINISTRADOR)
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String active = request.getParameter("activePage");
    if (active == null) active = "";
    boolean isAdmin = "true".equals(request.getParameter("esAdmin"));
%>

<!-- Sidebar -->
<div class="col-md-2 sidebar d-none d-md-block">
    <div class="brand">
        <i class="bi bi-bus-front"></i> MovilBus
    </div>
    <nav class="nav flex-column">
        <a class="nav-link <%= "dashboard".equals(active) ? "active" : "" %>" href="dashboard.jsp">
            <i class="bi bi-speedometer2"></i> Dashboard
        </a>
        <% if (isAdmin) { %>
            <a class="nav-link <%= "conductores".equals(active) ? "active" : "" %>" href="conductores.jsp">
                <i class="bi bi-people"></i> Conductores
            </a>
            <a class="nav-link <%= "buses".equals(active) ? "active" : "" %>" href="buses.jsp">
                <i class="bi bi-truck"></i> Buses
            </a>
            <a class="nav-link <%= "ciudades".equals(active) ? "active" : "" %>" href="ciudades.jsp">
                <i class="bi bi-geo-alt"></i> Ciudades
            </a>
            <a class="nav-link <%= "rutas".equals(active) ? "active" : "" %>" href="rutas.jsp">
                <i class="bi bi-signpost-2"></i> Rutas
            </a>
            <a class="nav-link <%= "viajes".equals(active) ? "active" : "" %>" href="viajes.jsp">
                <i class="bi bi-calendar-event"></i> Viajes
            </a>
        <% } %>
        <a class="nav-link <%= "ventas".equals(active) ? "active" : "" %>" href="ventas.jsp">
            <i class="bi bi-ticket-perforated"></i> Vender Pasaje
        </a>
        <a class="nav-link <%= "historial".equals(active) ? "active" : "" %>" href="VentaServlet?accion=historial">
            <i class="bi bi-clock-history"></i> Historial
        </a>
        <a class="nav-link <%= "encomiendas".equals(active) ? "active" : "" %>" href="EncomiendaServlet?accion=listar">
            <i class="bi bi-box-seam"></i> Encomiendas
        </a>
        <hr class="text-white opacity-25 my-3 mx-3">
        <a class="nav-link text-danger" href="LogoutServlet">
            <i class="bi bi-box-arrow-right"></i> Salir
        </a>
    </nav>
</div>