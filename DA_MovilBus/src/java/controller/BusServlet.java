package controller;

import dao.BusDAO;
import model.Bus;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "BusServlet", urlPatterns = {"/BusServlet"})
public class BusServlet extends HttpServlet {

    private final BusDAO busDAO = new BusDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String accion = request.getParameter("accion");
        if (accion == null) accion = "crear";

        try {
            switch (accion) {
                case "crear" -> {
                    Bus nuevoBus = new Bus(
                        request.getParameter("placa"),
                        request.getParameter("marca"),
                        request.getParameter("modelo"),
                        Integer.parseInt(request.getParameter("capacidad")),
                        Integer.parseInt(request.getParameter("pisos")),
                        "ACTIVO",
                        Integer.parseInt(request.getParameter("idServicio"))
                    );
                    if (busDAO.insertarBusConAsientos(nuevoBus)) {
                        session.setAttribute("msgExito", "Bus registrado con éxito. Plantilla de asientos generada.");
                    } else {
                        session.setAttribute("msgError", "No se pudo registrar el bus. Verifique que la placa no esté duplicada.");
                    }
                }
                case "actualizar" -> {
                    Bus bus = new Bus();
                    bus.setIdBus(Integer.parseInt(request.getParameter("idBus")));
                    bus.setPlaca(request.getParameter("placa"));
                    bus.setMarca(request.getParameter("marca"));
                    bus.setModelo(request.getParameter("modelo"));
                    bus.setEstado(request.getParameter("estado"));
                    if (busDAO.actualizar(bus)) {
                        session.setAttribute("msgExito", "Bus actualizado correctamente.");
                    } else {
                        session.setAttribute("msgError", "No se pudo actualizar el bus.");
                    }
                }
                case "eliminar" -> {
                    int idBus = Integer.parseInt(request.getParameter("idBus"));
                    if (busDAO.eliminarLogico(idBus)) {
                        session.setAttribute("msgExito", "Bus dado de baja correctamente.");
                    } else {
                        session.setAttribute("msgError", "No se pudo dar de baja el bus.");
                    }
                }
                default -> session.setAttribute("msgError", "Acción no reconocida.");
            }
        } catch (NumberFormatException e) {
            session.setAttribute("msgError", "Error en el formato de números ingresados.");
        } catch (Exception e) {
            session.setAttribute("msgError", "Error inesperado: " + e.getMessage());
        }

        response.sendRedirect("buses.jsp");
    }
}
