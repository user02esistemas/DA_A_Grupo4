package controller;

import dao.CitaEncomiendaDAO;
import dao.EncomiendaDAO;
import dao.ViajeDAO;
import model.CitaEncomienda;
import model.Encomienda;
import model.Usuario;
import util.ValidacionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "EncomiendaServlet", urlPatterns = {"/EncomiendaServlet"})
public class EncomiendaServlet extends HttpServlet {

    private EncomiendaDAO encomiendaDAO = new EncomiendaDAO();
    private CitaEncomiendaDAO citaDAO = new CitaEncomiendaDAO();
    private ViajeDAO viajeDAO = new ViajeDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accion = request.getParameter("accion");
        if (accion == null) accion = "";

        try {
                // Accion publica para clientes: historialEncomienda
            if ("historialEncomienda".equals(accion)) {
                HttpSession sess = request.getSession(false);
                Usuario userHist = (sess != null) ? (Usuario) sess.getAttribute("usuarioSesion") : null;
                if (userHist == null || !"CLIENTE_WEB".equalsIgnoreCase(userHist.getRol())) {
                    response.sendRedirect("login.jsp");
                    return;
                }
                String dniCliente = userHist.getUsername(); // DNI del cliente
                request.setAttribute("listaEncomiendasCliente", encomiendaDAO.listarEncomiendasPorCliente(dniCliente));
                request.setAttribute("listaCitasCliente", citaDAO.listarCitasPorCliente(dniCliente));
                request.getRequestDispatcher("index.jsp").forward(request, response);
                return;
            }

                // Acciones de admin/vendedor (requieren autenticacion)
            HttpSession sess = request.getSession(false);
            Usuario user = (sess != null) ? (Usuario) sess.getAttribute("usuarioSesion") : null;
            if (user == null || (!"ADMINISTRADOR".equalsIgnoreCase(user.getRol())
                    && !"VENDEDOR".equalsIgnoreCase(user.getRol()))) {
                response.sendRedirect("login.jsp");
                return;
            }

            if ("listar".equals(accion)) {
                // Listar todas las encomiendas + citas + viajes disponibles
                request.setAttribute("listaEncomiendas", encomiendaDAO.listarEncomiendas());
                request.setAttribute("listaCitas", citaDAO.listarCitas());
                request.setAttribute("listaViajes", viajeDAO.listarViajesProgramados());
                request.getRequestDispatcher("encomiendas.jsp").forward(request, response);

            } else if ("nuevo".equals(accion)) {
                request.setAttribute("listaViajes", viajeDAO.listarViajesProgramados());
                request.getRequestDispatcher("encomiendas.jsp").forward(request, response);

            } else if ("nuevoDesdeCita".equals(accion)) {
                // Cargar datos de la cita para pre-llenar el formulario
                String idCitaStr = request.getParameter("idCita");
                if (idCitaStr != null && !idCitaStr.isEmpty()) {
                    int idCita = Integer.parseInt(idCitaStr);
                    CitaEncomienda citaData = citaDAO.obtenerCitaPorId(idCita);
                    if (citaData != null) {
                        request.setAttribute("citaData", citaData);
                    }
                }
                request.setAttribute("listaViajes", viajeDAO.listarViajesProgramados());
                request.setAttribute("mostrarForm", true);
                request.setAttribute("listaEncomiendas", encomiendaDAO.listarEncomiendas());
                request.setAttribute("listaCitas", citaDAO.listarCitas());
                request.getRequestDispatcher("encomiendas.jsp").forward(request, response);

            } else if ("actualizarEstado".equals(accion)) {
                String idStr = request.getParameter("idEncomienda");
                String nuevoEstado = request.getParameter("estado");
                java.util.Set<String> estadosValidos = java.util.Set.of("REGISTRADO", "EN VIAJE", "ENTREGADO", "ANULADO");
                if (idStr != null && nuevoEstado != null && estadosValidos.contains(nuevoEstado)) {
                    int idEnc = Integer.parseInt(idStr);
                    encomiendaDAO.actualizarEstado(idEnc, nuevoEstado);
                }
                response.sendRedirect("EncomiendaServlet?accion=listar");

            } else if ("listarCitas".equals(accion)) {
                request.setAttribute("listaCitas", citaDAO.listarCitas());
                request.getRequestDispatcher("encomiendas.jsp").forward(request, response);

            } else if ("actualizarEstadoCita".equals(accion)) {
                String idStr = request.getParameter("idCita");
                String nuevoEstado = request.getParameter("estado");
                java.util.Set<String> estadosValidos = java.util.Set.of("PENDIENTE", "CONFIRMADA", "CANCELADA", "COMPLETADA");
                if (idStr != null && nuevoEstado != null && estadosValidos.contains(nuevoEstado)) {
                    int idCita = Integer.parseInt(idStr);
                    citaDAO.actualizarEstado(idCita, nuevoEstado);
                }
                response.sendRedirect("EncomiendaServlet?accion=listar");

            } else {
                request.setAttribute("listaEncomiendas", encomiendaDAO.listarEncomiendas());
                request.setAttribute("listaCitas", citaDAO.listarCitas());
                request.setAttribute("listaViajes", viajeDAO.listarViajesProgramados());
                request.getRequestDispatcher("encomiendas.jsp").forward(request, response);
            }

        } catch (Exception e) {
            System.err.println("Error en EncomiendaServlet GET: " + e.getMessage());
            response.sendRedirect("encomiendas.jsp?status=error");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accion = request.getParameter("accion");

        // Accion publica: agendarCita (desde landing page, sin autenticacion)
        // ============================================================
        if ("agendarCita".equals(accion)) {
            String dni = request.getParameter("dni");
            String nombre = request.getParameter("nombre");
            String telefono = request.getParameter("telefono");
            String idOrigenStr = request.getParameter("idOrigen");
            String idDestinoStr = request.getParameter("idDestino");
            String descripcion = request.getParameter("descripcion");
            String pesoStr = request.getParameter("pesoEstimado");
            String fechaPref = request.getParameter("fechaPreferida");
            String horaPref = request.getParameter("horaPreferida");
            String observaciones = request.getParameter("observaciones");

            if (dni == null || nombre == null || idOrigenStr == null || idDestinoStr == null
                    || fechaPref == null || horaPref == null) {
                response.sendRedirect("index.jsp?cita=error");
                return;
            }

            // Validar DNI
            if (!ValidacionUtil.validarDNI(dni)) {
                response.sendRedirect("index.jsp?cita=error");
                return;
            }

            // Validar teléfono si se proporcionó
            if (telefono != null && !telefono.trim().isEmpty() && !ValidacionUtil.validarTelefonoFlexible(telefono)) {
                response.sendRedirect("index.jsp?cita=error");
                return;
            }

            // Validar peso
            if (pesoStr != null && !pesoStr.isEmpty() && !ValidacionUtil.validarDecimalPositivo(pesoStr)) {
                response.sendRedirect("index.jsp?cita=error");
                return;
            }

            try {
                CitaEncomienda cita = new CitaEncomienda();
                cita.setIdOrigen(Integer.parseInt(idOrigenStr));
                cita.setIdDestino(Integer.parseInt(idDestinoStr));
                cita.setDescripcion(descripcion);
                cita.setPesoEstimado(pesoStr != null && !pesoStr.isEmpty() ? Double.parseDouble(pesoStr) : 1.0);
                cita.setFechaPreferida(fechaPref);
                cita.setHoraPreferida(horaPref);
                cita.setObservaciones(observaciones);

                int idGenerado = citaDAO.insertarCita(cita, dni, nombre, telefono);

                if (idGenerado > 0) {
                    System.out.println("[OK] Cita encomienda #" + idGenerado + " agendada");
                    response.sendRedirect("index.jsp?cita=success");
                } else {
                    response.sendRedirect("index.jsp?cita=error");
                }
            } catch (NumberFormatException e) {
                System.err.println("Error de formato en cita: " + e.getMessage());
                response.sendRedirect("index.jsp?cita=error");
            }
            return;
        }

        // Acciones de admin/vendedor (requieren autenticacion)
        // ============================================================
        HttpSession sess = request.getSession(false);
        Usuario user = (sess != null) ? (Usuario) sess.getAttribute("usuarioSesion") : null;
        if (user == null || (!"ADMINISTRADOR".equalsIgnoreCase(user.getRol())
                && !"VENDEDOR".equalsIgnoreCase(user.getRol()))) {
            response.sendRedirect("login.jsp");
            return;
        }

        if ("registrar".equals(accion)) {
            String idViajeStr = request.getParameter("idViaje");
            String descripcion = request.getParameter("descripcion");
            String pesoStr = request.getParameter("pesoKg");
            String precioStr = request.getParameter("precioEnvio");
            String metodoPago = request.getParameter("metodoPago");
            String dniRemitente = request.getParameter("dniRemitente");
            String nombreRemitente = request.getParameter("nombreRemitente");
            String dniDestinatario = request.getParameter("dniDestinatario");
            String nombreDestinatario = request.getParameter("nombreDestinatario");

            if (idViajeStr == null || descripcion == null || descripcion.trim().isEmpty()
                    || dniRemitente == null || dniDestinatario == null) {
                response.sendRedirect("EncomiendaServlet?accion=nuevo&status=error");
                return;
            }

            // Validar DNIs de remitente y destinatario
            if (!ValidacionUtil.validarDNI(dniRemitente) || !ValidacionUtil.validarDNI(dniDestinatario)) {
                response.sendRedirect("EncomiendaServlet?accion=nuevo&status=error");
                return;
            }

            try {
                int idViaje = Integer.parseInt(idViajeStr);
                
                // Validar peso y precio como números positivos
                if (!ValidacionUtil.validarDecimalPositivo(pesoStr) || !ValidacionUtil.validarDecimalPositivo(precioStr)) {
                    response.sendRedirect("EncomiendaServlet?accion=nuevo&status=error");
                    return;
                }
                
                double pesoKg = Double.parseDouble(pesoStr);
                double precioEnvio = Double.parseDouble(precioStr);

                Integer idVendedor = user.getIdUsuario();

                Encomienda enc = new Encomienda(descripcion, pesoKg, precioEnvio, idViaje, 0, 0);
                boolean exito = encomiendaDAO.registrarEncomienda(
                        enc, dniRemitente, nombreRemitente,
                        dniDestinatario, nombreDestinatario,
                        idVendedor, metodoPago);

                if (exito) {
                    response.sendRedirect("EncomiendaServlet?accion=listar&status=success");
                } else {
                    response.sendRedirect("EncomiendaServlet?accion=nuevo&status=error");
                }
            } catch (NumberFormatException e) {
                response.sendRedirect("EncomiendaServlet?accion=nuevo&status=error");
            }
        }
    }
}
