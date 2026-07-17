package controller;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.Usuario;

@WebFilter(filterName = "AuthFilter", urlPatterns = {
    "/dashboard.jsp", "/buses.jsp", "/viajes.jsp", "/historial-ventas.jsp",
    "/conductores.jsp", "/ciudades.jsp", "/rutas.jsp",
    "/encomiendas.jsp", "/ventas.jsp", "/vendedores.jsp", "/reportes.jsp",
    "/mantenimiento.jsp", "/fidelizacion-admin.jsp"
})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);
        Usuario usuario = (session != null) ? (Usuario) session.getAttribute("usuarioSesion") : null;

        if (usuario == null) {
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login.jsp");
            return;
        }

        String rol = usuario.getRol();

        // CLIENTE_WEB no accede a páginas admin
        if ("CLIENTE_WEB".equalsIgnoreCase(rol)) {
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/index.jsp");
            return;
        }

        // VENDEDOR y ADMINISTRADOR tienen acceso
        if ("VENDEDOR".equalsIgnoreCase(rol) || "ADMINISTRADOR".equalsIgnoreCase(rol)) {
            chain.doFilter(request, response);
            return;
        }

        httpResponse.sendRedirect(httpRequest.getContextPath() + "/login.jsp");
    }

    @Override
    public void destroy() {}
}
