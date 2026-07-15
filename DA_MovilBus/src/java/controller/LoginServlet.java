package controller;

import dao.UsuarioDAO;
import model.Usuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Capturar parámetros del formulario web
        String txtUser = request.getParameter("username");
        String txtPass = request.getParameter("password");
        
        UsuarioDAO usuarioDAO = new UsuarioDAO();
        
        // 2. Validar credenciales contra el DAO
        Usuario usuarioLogueado = usuarioDAO.validarLogin(txtUser, txtPass);
        
        if (usuarioLogueado != null) {
            // 3. Crear o recuperar la sesión HTTP activa
            HttpSession session = request.getSession(true);
            session.setAttribute("usuarioSesion", usuarioLogueado);
            
            // 4. Control de Acceso por Roles (Bloque 4)
            String rol = usuarioLogueado.getRol();
            
            if ("ADMINISTRADOR".equalsIgnoreCase(rol) || "VENDEDOR".equalsIgnoreCase(rol)) {
                // Redirigir al panel administrativo interno de la empresa
                response.sendRedirect("dashboard.jsp");
            } else {
                // Redirigir a la landing page principal para clientes (con su nombre)
                response.sendRedirect("index.jsp");
            }
        } else {
            // Si falla, lo devolvemos al login enviando un mensaje de error legible
            request.setAttribute("error", "Usuario o contraseña incorrectos, o cuenta inactiva.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}