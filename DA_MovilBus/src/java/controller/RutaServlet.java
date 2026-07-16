package controller;

import dao.RutaDAO;
import util.ValidacionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "RutaServlet", urlPatterns = {"/RutaServlet"})
public class RutaServlet extends HttpServlet {

    private final RutaDAO rutaDAO = new RutaDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String accion = request.getParameter("accion");
        if (accion == null) accion = "crear";

        try {
            switch (accion) {
                case "crear" -> {
                    String duracionStr = request.getParameter("duracionHoras");
                    String precioStr = request.getParameter("precioBase");

                    // Validar duración (0.5 a 48 horas)
                    if (!ValidacionUtil.validarDecimalPositivo(duracionStr, 0.5, 48)) {
                        session.setAttribute("msgError", "La duración debe estar entre 0.5 y 48 horas.");
                        response.sendRedirect("rutas.jsp");
                        return;
                    }

                    // Validar precio base (mínimo S/. 1, máximo S/. 9999)
                    if (!ValidacionUtil.validarDecimalPositivo(precioStr, 1, 9999)) {
                        session.setAttribute("msgError", "El precio base debe estar entre S/. 1 y S/. 9,999.");
                        response.sendRedirect("rutas.jsp");
                        return;
                    }

                    int idOrigen = Integer.parseInt(request.getParameter("idOrigen"));
                    int idDestino = Integer.parseInt(request.getParameter("idDestino"));
                    double duracion = Double.parseDouble(duracionStr);
                    double precioBase = Double.parseDouble(precioStr);
                    if (idOrigen == idDestino) {
                        session.setAttribute("msgError", "El origen y destino no pueden ser iguales.");
                    } else if (rutaDAO.insertar(idOrigen, idDestino, duracion, precioBase)) {
                        session.setAttribute("msgExito", "Ruta comercial registrada correctamente.");
                    } else {
                        session.setAttribute("msgError", "No se pudo registrar la ruta.");
                    }
                }
                case "actualizar" -> {
                    String duracionStr = request.getParameter("duracionHoras");
                    String precioStr = request.getParameter("precioBase");

                    if (!ValidacionUtil.validarDecimalPositivo(duracionStr, 0.5, 48)) {
                        session.setAttribute("msgError", "La duración debe estar entre 0.5 y 48 horas.");
                        response.sendRedirect("rutas.jsp");
                        return;
                    }
                    if (!ValidacionUtil.validarDecimalPositivo(precioStr, 1, 9999)) {
                        session.setAttribute("msgError", "El precio base debe estar entre S/. 1 y S/. 9,999.");
                        response.sendRedirect("rutas.jsp");
                        return;
                    }

                    int idRuta = Integer.parseInt(request.getParameter("idRuta"));
                    int idOrigen = Integer.parseInt(request.getParameter("idOrigen"));
                    int idDestino = Integer.parseInt(request.getParameter("idDestino"));
                    double duracion = Double.parseDouble(duracionStr);
                    double precioBase = Double.parseDouble(precioStr);
                    String estado = request.getParameter("estado");
                    if (rutaDAO.actualizar(idRuta, idOrigen, idDestino, duracion, precioBase, estado)) {
                        session.setAttribute("msgExito", "Ruta actualizada correctamente.");
                    } else {
                        session.setAttribute("msgError", "No se pudo actualizar la ruta.");
                    }
                }
                case "eliminar" -> {
                    int idRuta = Integer.parseInt(request.getParameter("idRuta"));
                    if (rutaDAO.eliminarLogico(idRuta)) {
                        session.setAttribute("msgExito", "Ruta desactivada correctamente.");
                    } else {
                        session.setAttribute("msgError", "No se pudo desactivar la ruta.");
                    }
                }
                default -> session.setAttribute("msgError", "Acción no reconocida.");
            }
        } catch (Exception e) {
            session.setAttribute("msgError", "Error: " + e.getMessage());
        }

        response.sendRedirect("rutas.jsp");
    }
}
