package controller;

import dao.ClienteDAO;
import dao.UsuarioDAO;
import model.Cliente;
import model.Usuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "ClienteServlet", urlPatterns = {"/ClienteServlet"})
public class ClienteServlet extends HttpServlet {

    private ClienteDAO clienteDAO = new ClienteDAO();
    private UsuarioDAO usuarioDAO = new UsuarioDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String accion = request.getParameter("accion");
        
        if ("registrar".equals(accion)) {
            String dni = request.getParameter("dni");
            String nombre = request.getParameter("nombre");
            String apellido = request.getParameter("apellido");
            String telefono = request.getParameter("telefono");
            String email = request.getParameter("email");
            String password = request.getParameter("password");

            // Instanciar modelos
            Usuario nuevoUsuario = new Usuario();
            nuevoUsuario.setUsername(dni); // DNI como username por defecto
            nuevoUsuario.setPassword(password);
            nuevoUsuario.setNombre(nombre);
            nuevoUsuario.setApellido(apellido);

            Cliente nuevoCliente = new Cliente();
            nuevoCliente.setDni(dni);
            nuevoCliente.setNombre(nombre);
            nuevoCliente.setApellido(apellido);
            nuevoCliente.setTelefono(telefono);
            nuevoCliente.setEmail(email);

            boolean exito = clienteDAO.registrarClienteConUsuario(nuevoCliente, nuevoUsuario);

            if (exito) {
                // ✅ Auto-login: crear sesión y redirigir a index.jsp
                Usuario usuarioLogueado = usuarioDAO.validarLogin(dni, password);
                if (usuarioLogueado != null) {
                    HttpSession session = request.getSession(true);
                    session.setAttribute("usuarioSesion", usuarioLogueado);
                    response.sendRedirect("index.jsp?registro=success");
                } else {
                    // Fallback: enviar al login manual
                    response.sendRedirect("login.jsp?registroStatus=success");
                }
            } else {
                // Redirige de vuelta al registro con mensaje de error
                response.sendRedirect("registro-cliente.jsp?status=error");
            }
        }
    }
}