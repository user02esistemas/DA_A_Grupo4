package controller;

import dao.BusDAO;
import model.Bus;
import util.ValidacionUtil;
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
                    String placa = request.getParameter("placa");
                    String capacidadStr = request.getParameter("capacidad");
                    String pisosStr = request.getParameter("pisos");

                    // Validar placa (formato XXX-999)
                    if (!ValidacionUtil.validarPlacaBus(placa)) {
                        session.setAttribute("msgError", "La placa debe tener formato XXX-999 (ej: ABC-123).");
                        response.sendRedirect("buses.jsp");
                        return;
                    }

                    // Validar capacidad (mínimo 10, máximo 80 asientos)
                    if (!ValidacionUtil.validarEntero(capacidadStr, 10, 80)) {
                        session.setAttribute("msgError", "La capacidad debe ser un número entre 10 y 80.");
                        response.sendRedirect("buses.jsp");
                        return;
                    }

                    // Validar pisos (1 o 2)
                    if (!ValidacionUtil.validarEntero(pisosStr, 1, 2)) {
                        session.setAttribute("msgError", "La cantidad de pisos debe ser 1 o 2.");
                        response.sendRedirect("buses.jsp");
                        return;
                    }

                    Bus nuevoBus = new Bus(
                        placa,
                        request.getParameter("marca"),
                        request.getParameter("modelo"),
                        Integer.parseInt(capacidadStr),
                        Integer.parseInt(pisosStr),
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
                    String placa = request.getParameter("placa");
                    if (!ValidacionUtil.validarPlacaBus(placa)) {
                        session.setAttribute("msgError", "La placa debe tener formato XXX-999 (ej: ABC-123).");
                        response.sendRedirect("buses.jsp");
                        return;
                    }
                    Bus bus = new Bus();
                    bus.setIdBus(Integer.parseInt(request.getParameter("idBus")));
                    bus.setPlaca(placa);
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
