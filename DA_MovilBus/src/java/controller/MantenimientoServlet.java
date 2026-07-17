package controller;

import config.ConexionBD;
import dao.BusDAO;
import dao.MantenimientoDAO;
import model.Mantenimiento;
import model.Usuario;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.*;
import java.util.List;

@WebServlet(name = "MantenimientoServlet", urlPatterns = {"/MantenimientoServlet"})
public class MantenimientoServlet extends HttpServlet {

    private MantenimientoDAO mantenimientoDAO = new MantenimientoDAO();
    private BusDAO busDAO = new BusDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Usuario user = (Usuario) session.getAttribute("usuarioSesion");
        if (user == null || "CLIENTE_WEB".equalsIgnoreCase(user.getRol())) {
            response.sendRedirect("login.jsp");
            return;
        }

        String accion = request.getParameter("accion");
        if (accion == null) accion = "listar";

        switch (accion) {
            case "nuevo":
                request.setAttribute("buses", busDAO.listarBuses());
                request.getRequestDispatcher("mantenimiento.jsp?form=nuevo").forward(request, response);
                break;
            case "editar":
                int idEditar = Integer.parseInt(request.getParameter("id"));
                request.setAttribute("editarMantenimiento", mantenimientoDAO.obtenerPorId(idEditar));
                request.setAttribute("buses", busDAO.listarBuses());
                request.getRequestDispatcher("mantenimiento.jsp?form=editar").forward(request, response);
                break;
            case "completar":
                int idCompletar = Integer.parseInt(request.getParameter("id"));
                Mantenimiento m = mantenimientoDAO.obtenerPorId(idCompletar);
                if (m != null) {
                    m.setEstado("COMPLETADO");
                    m.setFechaFin(new Timestamp(System.currentTimeMillis()));
                    mantenimientoDAO.actualizar(m);
                    // Cambiar estado del bus a ACTIVO si estaba en MANTENIMIENTO
                    actualizarEstadoBus(m.getIdBus(), "ACTIVO");
                }
                response.sendRedirect("MantenimientoServlet?status=completado");
                break;
            case "cancelar":
                int idCancelar = Integer.parseInt(request.getParameter("id"));
                Mantenimiento mc = mantenimientoDAO.obtenerPorId(idCancelar);
                if (mc != null) {
                    mc.setEstado("CANCELADO");
                    mantenimientoDAO.actualizar(mc);
                    // Al cancelar el mantenimiento, restaurar el bus a ACTIVO
                    actualizarEstadoBus(mc.getIdBus(), "ACTIVO");
                }
                response.sendRedirect("MantenimientoServlet?status=cancelado");
                break;
            default:
                listar(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Usuario user = (Usuario) session.getAttribute("usuarioSesion");
        if (user == null || "CLIENTE_WEB".equalsIgnoreCase(user.getRol())) {
            response.sendRedirect("login.jsp");
            return;
        }

        String accion = request.getParameter("accion");

        if ("guardar".equals(accion)) {
            int idBus = Integer.parseInt(request.getParameter("idBus"));
            String tipo = request.getParameter("tipoMantenimiento");
            String fechaInicioStr = request.getParameter("fechaInicio");
            String fechaFinStr = request.getParameter("fechaFin");
            String descripcion = request.getParameter("descripcion");
            int kilometraje = Integer.parseInt(request.getParameter("kilometraje"));
            double costo = Double.parseDouble(request.getParameter("costo"));
            String estado = request.getParameter("estado");

            try {
                Mantenimiento m = new Mantenimiento();
                m.setIdBus(idBus);
                m.setTipoMantenimiento(tipo);
                m.setFechaInicio(Timestamp.valueOf(fechaInicioStr.replace("T", " ") + ":00"));
                if (fechaFinStr != null && !fechaFinStr.isEmpty()) {
                    m.setFechaFin(Timestamp.valueOf(fechaFinStr.replace("T", " ") + ":00"));
                }
                m.setDescripcion(descripcion);
                m.setKilometrajeActual(kilometraje);
                m.setCosto(costo);
                m.setEstado(estado);

                String idParam = request.getParameter("idMantenimiento");
                boolean ok;
                if (idParam != null && !idParam.isEmpty()) {
                    m.setIdMantenimiento(Integer.parseInt(idParam));
                    ok = mantenimientoDAO.actualizar(m);
                } else {
                    ok = mantenimientoDAO.insertar(m);
                }

                if (ok && (estado.equals("EN_PROCESO") || estado.equals("PROGRAMADO"))) {
                    actualizarEstadoBus(idBus, "MANTENIMIENTO");
                }

                response.sendRedirect("MantenimientoServlet?status=" + (ok ? "success" : "error"));
            } catch (Exception e) {
                System.err.println("Error guardar mantenimiento: " + e.getMessage());
                response.sendRedirect("MantenimientoServlet?status=error");
            }
        }
    }

    private void listar(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("listaMantenimientos", mantenimientoDAO.listarTodos());
        request.setAttribute("mantenimientosActivos", mantenimientoDAO.listarMantenimientosActivos());
        request.setAttribute("mantenimientosVencidos", mantenimientoDAO.listarMantenimientosVencidos());
        request.setAttribute("busesSinMantenimiento", mantenimientoDAO.listarBusesSinMantenimientoReciente());
        request.getRequestDispatcher("mantenimiento.jsp").forward(request, response);
    }

    private void actualizarEstadoBus(int idBus, String nuevoEstado) {
        try (Connection con = ConexionBD.getConexion();
             PreparedStatement ps = con.prepareStatement("UPDATE Bus SET estado = ? WHERE id_bus = ?")) {
            ps.setString(1, nuevoEstado);
            ps.setInt(2, idBus);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Error actualizar estado bus: " + e.getMessage());
        }
    }
}
