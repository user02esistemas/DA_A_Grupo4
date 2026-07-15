package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.Usuario;

@WebServlet(name = "LogoutServlet", urlPatterns = {"/LogoutServlet"})
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Verificar si el usuario era un cliente antes de cerrar sesión
        boolean eraCliente = false;
        HttpSession session = request.getSession(false);
        if (session != null) {
            Usuario usuario = (Usuario) session.getAttribute("usuarioSesion");
            if (usuario != null && "CLIENTE_WEB".equalsIgnoreCase(usuario.getRol())) {
                eraCliente = true;
            }
            session.invalidate();
        }
        
        // Redirigir según el rol: clientes van a la landing page, personal a la intranet
        if (eraCliente) {
            response.sendRedirect("index.jsp");
        } else {
            response.sendRedirect("login.jsp");
        }
    }
}
