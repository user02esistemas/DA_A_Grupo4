package controller;

import dao.FidelizacionDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.PuntosCliente;
import model.TransaccionPuntos;
import model.Usuario;

import java.io.IOException;
import java.net.URLEncoder;
import java.util.List;
import java.util.Map;

@WebServlet(name = "FidelizacionServlet", urlPatterns = {"/FidelizacionServlet"})
public class FidelizacionServlet extends HttpServlet {

    private final FidelizacionDAO fidelizacionDAO = new FidelizacionDAO();

    @Override
    public void init() throws ServletException {
        // Inicializar niveles al arrancar el servlet
        fidelizacionDAO.inicializarNiveles();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String accion = request.getParameter("accion");
        if (accion == null) accion = "";

        switch (accion) {
            case "misPuntos" -> verMisPuntos(request, response);
            case "historial" -> verHistorial(request, response);
            case "admin" -> verAdmin(request, response);
            case "buscarCliente" -> buscarCliente(request, response);
            default -> {
                // Redirigir según el rol
                Usuario user = (Usuario) session.getAttribute("usuarioSesion");
                if (user != null && "CLIENTE_WEB".equalsIgnoreCase(user.getRol())) {
                    response.sendRedirect("FidelizacionServlet?accion=misPuntos");
                } else {
                    response.sendRedirect("FidelizacionServlet?accion=admin");
                }
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accion = request.getParameter("accion");

        if ("canjear".equals(accion)) {
            procesarCanje(request, response);
        }
    }

    // ================================================================
    //  VISTA: Mis Puntos (CLIENTE_WEB)
    // ================================================================

    private void verMisPuntos(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Usuario user = (Usuario) session.getAttribute("usuarioSesion");

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Obtener el id_cliente a partir del username (DNI) del usuario
        String dniCliente = user.getUsername();
        PuntosCliente puntos = fidelizacionDAO.obtenerPuntosPorDNI(dniCliente);
        List<TransaccionPuntos> transacciones = null;

        if (puntos != null) {
            transacciones = fidelizacionDAO.listarTransacciones(puntos.getIdCliente(), 20);
        }

        request.setAttribute("puntosCliente", puntos);
        request.setAttribute("transaccionesPuntos", transacciones);
        request.getRequestDispatcher("index.jsp").forward(request, response);
    }

    // ================================================================
    //  VISTA: Historial de puntos del cliente (dentro del index)
    // ================================================================

    private void verHistorial(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Similar a misPuntos pero redirige al index con atributo
        verMisPuntos(request, response);
    }

    // ================================================================
    //  VISTA: Admin - Tablero de fidelización
    // ================================================================

    private void verAdmin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Usuario user = (Usuario) session.getAttribute("usuarioSesion");

        if (user == null || "CLIENTE_WEB".equalsIgnoreCase(user.getRol())) {
            response.sendRedirect("login.jsp");
            return;
        }

        List<PuntosCliente> listaClientes = fidelizacionDAO.listarTodosClientes();
        Map<String, Object> estadisticas = fidelizacionDAO.obtenerEstadisticas();
        List<TransaccionPuntos> transaccionesRecientes = fidelizacionDAO.listarTransaccionesRecientes(10);

        request.setAttribute("listaClientesFidelidad", listaClientes);
        request.setAttribute("estadisticasFidelidad", estadisticas);
        request.setAttribute("transaccionesRecientesFidelidad", transaccionesRecientes);
        request.getRequestDispatcher("fidelizacion-admin.jsp").forward(request, response);
    }

    // ================================================================
    //  ACCIÓN: Buscar cliente (para admin)
    // ================================================================

    private void buscarCliente(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String dni = request.getParameter("dni");
        if (dni != null && !dni.isEmpty()) {
            PuntosCliente puntos = fidelizacionDAO.obtenerPuntosPorDNI(dni);
            request.setAttribute("puntosClienteBuscado", puntos);
        }

        verAdmin(request, response);
    }

    // ================================================================
    //  ACCIÓN: Canjear puntos (CLIENTE_WEB)
    // ================================================================

    private void procesarCanje(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession();
        Usuario user = (Usuario) session.getAttribute("usuarioSesion");

        if (user == null || !"CLIENTE_WEB".equalsIgnoreCase(user.getRol())) {
            response.sendRedirect("login.jsp");
            return;
        }

        String puntosStr = request.getParameter("puntosCanje");
        String dniCliente = user.getUsername();

        try {
            int puntosCanje = Integer.parseInt(puntosStr);
            PuntosCliente pc = fidelizacionDAO.obtenerPuntosPorDNI(dniCliente);

            if (pc == null) {
                response.sendRedirect("FidelizacionServlet?accion=misPuntos&canje=error");
                return;
            }

            Map<String, Object> resultado = fidelizacionDAO.canjearPuntos(pc.getIdCliente(), puntosCanje);

            if ((boolean) resultado.get("exito")) {
                response.sendRedirect("FidelizacionServlet?accion=misPuntos&canje=exito&descuento="
                        + resultado.get("descuento"));
            } else {
                String msg = resultado.get("mensaje") != null
                        ? URLEncoder.encode((String) resultado.get("mensaje"), "UTF-8")
                        : "Error+al+procesar+el+canje";
                response.sendRedirect("FidelizacionServlet?accion=misPuntos&canje=error&msg=" + msg);
            }

        } catch (NumberFormatException e) {
            response.sendRedirect("FidelizacionServlet?accion=misPuntos&canje=error");
        }
    }
}
