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

@WebServlet(name = "VendedorServlet", urlPatterns = {"/VendedorServlet"})
public class VendedorServlet extends HttpServlet {

    private final UsuarioDAO usuarioDAO = new UsuarioDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String accion = request.getParameter("accion");
        if (accion == null) accion = "registrar";

        try {
            switch (accion) {
                case "registrar" -> {
                    String username = request.getParameter("username");
                    String password = request.getParameter("password");
                    String nombre = request.getParameter("nombre");
                    String apellido = request.getParameter("apellido");

                    // Validar que el username no esté vacío
                    if (username == null || username.trim().isEmpty()) {
                        session.setAttribute("msgError", "El nombre de usuario es obligatorio.");
                        response.sendRedirect("vendedores.jsp");
                        return;
                    }

                    Usuario vendedor = new Usuario();
                    vendedor.setUsername(username.trim());
                    vendedor.setPassword(password);
                    vendedor.setNombre(nombre.trim());
                    vendedor.setApellido(apellido.trim());

                    if (usuarioDAO.insertarVendedor(vendedor)) {
                        session.setAttribute("msgExito", "Vendedor registrado correctamente.");
                    } else {
                        session.setAttribute("msgError", "No se pudo registrar el vendedor. Es posible que el nombre de usuario ya exista.");
                    }
                }
                case "actualizar" -> {
                    int id = Integer.parseInt(request.getParameter("idUsuario"));
                    String nombre = request.getParameter("nombre");
                    String apellido = request.getParameter("apellido");
                    String estado = request.getParameter("estado");

                    Usuario vendedor = new Usuario();
                    vendedor.setIdUsuario(id);
                    vendedor.setNombre(nombre.trim());
                    vendedor.setApellido(apellido.trim());
                    vendedor.setEstado(estado);

                    if (usuarioDAO.actualizarVendedor(vendedor)) {
                        session.setAttribute("msgExito", "Vendedor actualizado correctamente.");
                    } else {
                        session.setAttribute("msgError", "No se pudo actualizar el vendedor.");
                    }
                }
                case "eliminar" -> {
                    int id = Integer.parseInt(request.getParameter("idUsuario"));
                    if (usuarioDAO.eliminarVendedor(id)) {
                        session.setAttribute("msgExito", "Vendedor dado de baja correctamente.");
                    } else {
                        session.setAttribute("msgError", "No se pudo dar de baja al vendedor.");
                    }
                }
                default -> session.setAttribute("msgError", "Acción no reconocida.");
            }
        } catch (Exception e) {
            session.setAttribute("msgError", "Error: " + e.getMessage());
        }

        response.sendRedirect("vendedores.jsp");
    }
}
