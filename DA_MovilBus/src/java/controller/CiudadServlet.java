package controller;

import dao.CiudadDAO;
import model.Ciudad;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "CiudadServlet", urlPatterns = {"/CiudadServlet"})
public class CiudadServlet extends HttpServlet {

    private final CiudadDAO ciudadDAO = new CiudadDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String accion = request.getParameter("accion");
        if (accion == null) accion = "crear";

        try {
            switch (accion) {
                case "crear" -> {
                    Ciudad c = new Ciudad(
                        request.getParameter("nombre"),
                        request.getParameter("departamento"),
                        "ACTIVO"
                    );
                    if (ciudadDAO.insertar(c)) {
                        session.setAttribute("msgExito", "Ciudad registrada correctamente.");
                    } else {
                        session.setAttribute("msgError", "No se pudo registrar la ciudad.");
                    }
                }
                case "actualizar" -> {
                    Ciudad c = new Ciudad(
                        request.getParameter("nombre"),
                        request.getParameter("departamento"),
                        request.getParameter("estado")
                    );
                    c.setIdCiudad(Integer.parseInt(request.getParameter("idCiudad")));
                    if (ciudadDAO.actualizar(c)) {
                        session.setAttribute("msgExito", "Ciudad actualizada correctamente.");
                    } else {
                        session.setAttribute("msgError", "No se pudo actualizar la ciudad.");
                    }
                }
                case "eliminar" -> {
                    int id = Integer.parseInt(request.getParameter("idCiudad"));
                    if (ciudadDAO.eliminarLogico(id)) {
                        session.setAttribute("msgExito", "Ciudad desactivada correctamente.");
                    } else {
                        session.setAttribute("msgError", "No se pudo desactivar la ciudad.");
                    }
                }
                default -> session.setAttribute("msgError", "Acción no reconocida.");
            }
        } catch (Exception e) {
            session.setAttribute("msgError", "Error: " + e.getMessage());
        }

        response.sendRedirect("ciudades.jsp");
    }
}
