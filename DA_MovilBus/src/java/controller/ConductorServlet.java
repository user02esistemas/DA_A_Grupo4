package controller;

import dao.ConductorDAO;
import model.Conductor;
import util.ValidacionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "ConductorServlet", urlPatterns = {"/ConductorServlet"})
public class ConductorServlet extends HttpServlet {

    private final ConductorDAO conductorDAO = new ConductorDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String accion = request.getParameter("accion");
        if (accion == null) accion = "crear";

        try {
            switch (accion) {
                case "crear" -> {
                    String dni = request.getParameter("dni");
                    if (!ValidacionUtil.validarDNI(dni)) {
                        session.setAttribute("msgError", "El DNI debe tener exactamente 8 dígitos numéricos.");
                        response.sendRedirect("conductores.jsp");
                        return;
                    }
                    Conductor c = new Conductor();
                    c.setDni(dni);
                    c.setNombre(request.getParameter("nombre"));
                    c.setApellido(request.getParameter("apellido"));
                    c.setNroLicencia(request.getParameter("nroLicencia"));
                    c.setEstado("DISPONIBLE");
                    if (conductorDAO.insertar(c)) {
                        session.setAttribute("msgExito", "Conductor registrado correctamente.");
                    } else {
                        session.setAttribute("msgError", "No se pudo registrar el conductor.");
                    }
                }
                case "actualizar" -> {
                    String dni = request.getParameter("dni");
                    if (!ValidacionUtil.validarDNI(dni)) {
                        session.setAttribute("msgError", "El DNI debe tener exactamente 8 dígitos numéricos.");
                        response.sendRedirect("conductores.jsp");
                        return;
                    }
                    Conductor c = new Conductor();
                    c.setIdConductor(Integer.parseInt(request.getParameter("idConductor")));
                    c.setDni(dni);
                    c.setNombre(request.getParameter("nombre"));
                    c.setApellido(request.getParameter("apellido"));
                    c.setNroLicencia(request.getParameter("nroLicencia"));
                    c.setEstado(request.getParameter("estado"));
                    if (conductorDAO.actualizar(c)) {
                        session.setAttribute("msgExito", "Conductor actualizado correctamente.");
                    } else {
                        session.setAttribute("msgError", "No se pudo actualizar el conductor.");
                    }
                }
                case "eliminar" -> {
                    int id = Integer.parseInt(request.getParameter("idConductor"));
                    if (conductorDAO.eliminarLogico(id)) {
                        session.setAttribute("msgExito", "Conductor dado de baja correctamente.");
                    } else {
                        session.setAttribute("msgError", "No se pudo dar de baja al conductor.");
                    }
                }
                default -> session.setAttribute("msgError", "Acción no reconocida.");
            }
        } catch (Exception e) {
            session.setAttribute("msgError", "Error: " + e.getMessage());
        }

        response.sendRedirect("conductores.jsp");
    }
}
