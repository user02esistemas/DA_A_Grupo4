package controller;

import dao.ViajeDAO;
import dao.RutaDAO;
import model.Viaje;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@WebServlet(name = "ViajeServlet", urlPatterns = {"/ViajeServlet"})
public class ViajeServlet extends HttpServlet {

    private final ViajeDAO viajeDAO = new ViajeDAO();
    private final RutaDAO rutaDAO = new RutaDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String accion = request.getParameter("accion");
        if (accion == null) accion = "crear";

        try {
            switch (accion) {
                case "crear" -> programarViaje(request, session);
                case "cancelar" -> {
                    int idViaje = Integer.parseInt(request.getParameter("idViaje"));
                    if (viajeDAO.cancelarViaje(idViaje)) {
                        session.setAttribute("msgExitoViaje", "Viaje cancelado correctamente.");
                    } else {
                        session.setAttribute("msgErrorViaje", "No se pudo cancelar el viaje.");
                    }
                }
                default -> session.setAttribute("msgErrorViaje", "Acción no reconocida.");
            }
        } catch (Exception e) {
            session.setAttribute("msgErrorViaje", "Error en el procesamiento: " + e.getMessage());
        }

        response.sendRedirect("viajes.jsp");
    }

    private void programarViaje(HttpServletRequest request, HttpSession session) throws Exception {
        int idRuta = Integer.parseInt(request.getParameter("idRuta"));
        int idBus = Integer.parseInt(request.getParameter("idBus"));
        String fechaHoraStr = request.getParameter("fechaHora");

        String[] idConductoresArr = request.getParameterValues("idConductores");
        List<Integer> conductores = new ArrayList<>();

        if (idConductoresArr != null && idConductoresArr.length > 0) {
            Set<Integer> duplicadosCheck = new HashSet<>();
            for (String idStr : idConductoresArr) {
                if (idStr != null && !idStr.isEmpty()) {
                    int idCond = Integer.parseInt(idStr);
                    if (!duplicadosCheck.add(idCond)) {
                        session.setAttribute("msgErrorViaje", "No puedes asignar al mismo conductor más de una vez.");
                        return;
                    }
                    conductores.add(idCond);
                }
            }
        } else {
            session.setAttribute("msgErrorViaje", "Debe asignar al menos al Conductor Principal.");
            return;
        }

        fechaHoraStr = fechaHoraStr.replace("T", " ") + ":00";
        Timestamp fechaHoraSalida = Timestamp.valueOf(fechaHoraStr);

        double duracionHoras = rutaDAO.obtenerDuracionRuta(idRuta);
        long minutosAdicionales = (long) (duracionHoras * 60);
        Timestamp fechaHoraLlegadaEstimada = new Timestamp(
            fechaHoraSalida.getTime() + (minutosAdicionales * 60 * 1000));

        Viaje nuevoViaje = new Viaje();
        nuevoViaje.setIdRuta(idRuta);
        nuevoViaje.setIdBus(idBus);
        nuevoViaje.setFechaHora(fechaHoraSalida);
        nuevoViaje.setFechaHoraLlegadaEstimada(fechaHoraLlegadaEstimada);
        nuevoViaje.setEstado("PROGRAMADO");

        if (viajeDAO.programarViajeConTripulacion(nuevoViaje, conductores)) {
            session.setAttribute("msgExitoViaje", "Viaje programado con éxito.");
        } else {
            session.setAttribute("msgErrorViaje", "Error al programar el viaje en la base de datos.");
        }
    }
}
