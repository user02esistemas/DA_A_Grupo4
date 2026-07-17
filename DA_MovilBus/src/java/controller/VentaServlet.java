package controller;

import dao.FidelizacionDAO;
import dao.ViajeDAO;
import config.ConexionBD;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import model.Usuario;
import util.ValidacionUtil;

@WebServlet(name = "VentaServlet", urlPatterns = {"/VentaServlet"})
public class VentaServlet extends HttpServlet {

    private ViajeDAO viajeDAO = new ViajeDAO();
    private FidelizacionDAO fidelizacionDAO = new FidelizacionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String accion = request.getParameter("accion");
        if (accion == null) accion = "";

        try {
            if (accion.equals("buscar")) {
                int idOrigen = Integer.parseInt(request.getParameter("idOrigen"));
                int idDestino = Integer.parseInt(request.getParameter("idDestino"));
                String fecha = request.getParameter("fecha");

                List<Map<String, Object>> viajes = viajeDAO.buscarViajesParaVenta(idOrigen, idDestino, fecha);
                request.setAttribute("listaViajesBusqueda", viajes);
                
            } else if (accion.equals("historial")) {
                HttpSession sess = request.getSession(false);
                Usuario userHist = (sess != null) ? (Usuario) sess.getAttribute("usuarioSesion") : null;
                
                if (userHist == null) {
                    response.sendRedirect("login.jsp");
                    return;
                }
                
                String rol = userHist.getRol();
                List<Map<String, Object>> historial = new java.util.ArrayList<>();
                
                if ("ADMINISTRADOR".equalsIgnoreCase(rol) || "VENDEDOR".equalsIgnoreCase(rol)) {
                    // Admin y Vendedor: ven TODAS las ventas
                    // (listarVentasPorVendedor requiere que existan registros en Pago con id_vendedor)
                    historial = viajeDAO.listarVentas();
                } else if ("CLIENTE_WEB".equalsIgnoreCase(rol)) {
                    // Cliente: ve solo sus compras (filtra por DNI/username)
                    historial = viajeDAO.listarVentasPorCliente(userHist.getUsername());
                }
                request.setAttribute("listaVentas", historial);
                request.setAttribute("esHistorialCliente", "CLIENTE_WEB".equalsIgnoreCase(rol));
                
            } else if (accion.equals("verAsientos")) {
                int idViaje = Integer.parseInt(request.getParameter("idViaje"));
                
                // 1. Recargar primero la lista de viajes para que la tabla superior no desaparezca
                int idOrigen = Integer.parseInt(request.getParameter("idOrigen"));
                int idDestino = Integer.parseInt(request.getParameter("idDestino"));
                String fecha = request.getParameter("fecha");
                List<Map<String, Object>> viajes = viajeDAO.buscarViajesParaVenta(idOrigen, idDestino, fecha);
                request.setAttribute("listaViajesBusqueda", viajes);

                // 2. Obtener la capacidad real del bus para calcular la grilla en el JSP
                int capacidad = viajeDAO.obtenerCapacidadBusPorViaje(idViaje);
                request.setAttribute("capacidadBus", capacidad);

                // Generar y enviar la lista de asientos para el croquis en ventas.jsp
                List<model.Asiento> croquis = viajeDAO.generarCroquisDinamico(idViaje);
                request.setAttribute("listaAsientosIntel", croquis);
            }
        } catch (Exception e) {
            System.err.println("Error en VentaServlet GET: " + e.getMessage());
            request.setAttribute("errorMsg", "Ocurrió un error al procesar la solicitud. Por favor, intenta nuevamente.");
        }

        // Determinar a qué página forward según el rol del usuario
        HttpSession sess = request.getSession(false);
        Usuario userFwd = (sess != null) ? (Usuario) sess.getAttribute("usuarioSesion") : null;
        boolean esCliente = (userFwd != null && "CLIENTE_WEB".equalsIgnoreCase(userFwd.getRol()));
        boolean esAnonimo = (userFwd == null);
        
        // Si es historial
        if ("historial".equals(accion)) {
            boolean esCliHist = request.getAttribute("esHistorialCliente") != null 
                && (boolean) request.getAttribute("esHistorialCliente");
            if (esCliHist) {
                // Cliente: ver historial en la landing page
                request.getRequestDispatcher("index.jsp").forward(request, response);
            } else {
                // Admin/Vendedor: ver historial en la intranet
                request.getRequestDispatcher("historial-ventas.jsp").forward(request, response);
            }
        } else if (esCliente || esAnonimo) {
            // Clientes y anónimos ven el flujo de compra en la landing page
            request.getRequestDispatcher("index.jsp").forward(request, response);
        } else {
            // Admin y vendedores usan la intranet
            request.getRequestDispatcher("ventas.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String accion = request.getParameter("accion");
        
        // Accion: guardarVenta (single - una sola venta)
        if ("guardarVenta".equals(accion)) {
            procesarVentaUnica(request, response);
        } 
        // Accion: guardarVentaMulti (multiple - varios pasajes)
        else if ("guardarVentaMulti".equals(accion)) {
            procesarVentaMultiple(request, response);
        }
        // Accion: anularPasaje (solo admin/vendedor)
        else if ("anularPasaje".equals(accion)) {
            procesarAnulacion(request, response);
        }
    }
    
    private void procesarVentaUnica(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idViajeParam = request.getParameter("idViaje");
        String numAsientoParam = request.getParameter("numAsiento");
        String precioBoleto = request.getParameter("precioBoleto");
        String dni = request.getParameter("dni");
        String nombrePasajero = request.getParameter("nombrePasajero");
        String metodoPago = request.getParameter("metodoPago");
        if (metodoPago == null || metodoPago.isEmpty()) metodoPago = "EFECTIVO";
        
        String idOrigen = request.getParameter("idOrigen");
        String idDestino = request.getParameter("idDestino");
        String fecha = request.getParameter("fecha");
        
        String baseRedirect = "VentaServlet?accion=verAsientos&idViaje=" + idViajeParam + 
                              "&idOrigen=" + idOrigen + "&idDestino=" + idDestino + "&fecha=" + fecha;

        // Obtener el vendedor de la sesión (si es admin/vendedor)
        HttpSession sess = request.getSession(false);
        Usuario userVenta = (sess != null) ? (Usuario) sess.getAttribute("usuarioSesion") : null;
        Integer idVendedor = null;
        if (userVenta != null && ("ADMINISTRADOR".equalsIgnoreCase(userVenta.getRol()) 
                || "VENDEDOR".equalsIgnoreCase(userVenta.getRol()))) {
            idVendedor = userVenta.getIdUsuario();
        }

        if (numAsientoParam == null || numAsientoParam.trim().isEmpty() || idViajeParam == null) {
            response.sendRedirect(baseRedirect + "&status=error");
            return;
        }

        // Validar DNI del pasajero
        if (dni == null || !ValidacionUtil.validarDNI(dni)) {
            response.sendRedirect(baseRedirect + "&status=error");
            return;
        }

        // Validar precio positivo
        if (precioBoleto != null && !ValidacionUtil.validarDecimalPositivo(precioBoleto.replace("S/.", "").trim())) {
            response.sendRedirect(baseRedirect + "&status=error");
            return;
        }

        int idViaje = Integer.parseInt(idViajeParam);
        int numAsiento = Integer.parseInt(numAsientoParam);
        double precioFinal = precioBoleto != null ? Double.parseDouble(precioBoleto.replace("S/.", "").trim()) : 0.0;

        String[] nombreApellido = separarNombre(nombrePasajero);

        try (Connection con = ConexionBD.getConexion()) {
            con.setAutoCommit(false);
            try {
                int idCliente = buscarOCrearCliente(con, dni, nombreApellido[0], nombreApellido[1]);
                int idPasajeGenerado = insertarPasaje(con, idViaje, idCliente, numAsiento, precioFinal, idVendedor, metodoPago);
                // Acumular puntos de fidelización
                fidelizacionDAO.acumularPuntosEnTransaccion(con, idCliente, precioFinal, idPasajeGenerado);
                con.commit();
                response.sendRedirect("pasaje-confirmado.jsp?idPasaje=" + idPasajeGenerado);
            } catch (SQLException ex) {
                con.rollback();
                throw ex;
            }
        } catch (SQLException e) {
            System.err.println("Error en venta unica: " + e.getMessage());
            response.sendRedirect(baseRedirect + "&status=error");
        }
    }
    
    private void procesarVentaMultiple(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idViajeParam = request.getParameter("idViaje");
        String idOrigen = request.getParameter("idOrigen");
        String idDestino = request.getParameter("idDestino");
        String fecha = request.getParameter("fecha");
        String metodoPago = request.getParameter("metodoPago");
        if (metodoPago == null || metodoPago.isEmpty()) metodoPago = "EFECTIVO";
        
        String baseRedirect = "VentaServlet?accion=verAsientos&idViaje=" + idViajeParam + 
                              "&idOrigen=" + idOrigen + "&idDestino=" + idDestino + "&fecha=" + fecha;

        // Obtener el vendedor de la sesión (si es admin/vendedor)
        HttpSession sess = request.getSession(false);
        Usuario userVenta = (sess != null) ? (Usuario) sess.getAttribute("usuarioSesion") : null;
        Integer idVendedor = null;
        if (userVenta != null && ("ADMINISTRADOR".equalsIgnoreCase(userVenta.getRol()) 
                || "VENDEDOR".equalsIgnoreCase(userVenta.getRol()))) {
            idVendedor = userVenta.getIdUsuario();
        }

        if (idViajeParam == null || idViajeParam.isEmpty()) {
            response.sendRedirect(baseRedirect + "&status=error");
            return;
        }

        int idViaje = Integer.parseInt(idViajeParam);
        
        // Obtener arrays del formulario
        String[] asientos = request.getParameterValues("numAsiento");
        String[] precios = request.getParameterValues("precioBoleto");
        String[] dnis = request.getParameterValues("dni");
        String[] nombres = request.getParameterValues("nombrePasajero");
        
        // Validar que haya al menos un pasajero
        if (asientos == null || asientos.length == 0) {
            response.sendRedirect(baseRedirect + "&status=error");
            return;
        }

        StringBuilder idsGenerados = new StringBuilder();
        
        try (Connection con = ConexionBD.getConexion()) {
            con.setAutoCommit(false);
            
            try {
                for (int i = 0; i < asientos.length; i++) {
                    int numAsiento = Integer.parseInt(asientos[i]);
                    
                    // Validar precio positivo
                    String precioStr = (precios != null && i < precios.length) ? precios[i].replace("S/.", "").trim() : null;
                    if (!ValidacionUtil.validarDecimalPositivo(precioStr)) {
                        throw new SQLException("Precio inválido para pasajero " + (i+1));
                    }
                    double precioFinal = Double.parseDouble(precioStr);
                    
                    String dni = (dnis != null && i < dnis.length) ? dnis[i] : "00000000";
                    
                    // Validar DNI de cada pasajero (permitir 00000000 para casos especiales de sistema)
                    if (dni != null && !dni.equals("00000000") && !ValidacionUtil.validarDNI(dni)) {
                        throw new SQLException("DNI inválido para pasajero " + (i+1) + ": " + dni);
                    }
                    
                    String nombrePasajero = (nombres != null && i < nombres.length) ? nombres[i] : "-";
                    
                    String[] nombreApellido = separarNombre(nombrePasajero);
                    
                    int idCliente = buscarOCrearCliente(con, dni, nombreApellido[0], nombreApellido[1]);
                    int idPasaje = insertarPasaje(con, idViaje, idCliente, numAsiento, precioFinal, idVendedor, metodoPago);
                    // Acumular puntos de fidelización por cada pasaje
                    fidelizacionDAO.acumularPuntosEnTransaccion(con, idCliente, precioFinal, idPasaje);
                    
                    if (idsGenerados.length() > 0) idsGenerados.append(",");
                    idsGenerados.append(idPasaje);
                }
                
                con.commit();
                System.out.println("[OK] " + asientos.length + " pasajes emitidos");
                
                // Redirigir al último pasaje generado (el usuario puede ver los demás en historial)
                String[] ids = idsGenerados.toString().split(",");
                String ultimoId = ids[ids.length - 1];
                response.sendRedirect("pasaje-confirmado.jsp?idPasaje=" + ultimoId + "&multi=" + idsGenerados.toString());
                
            } catch (SQLException ex) {
                con.rollback();
                throw ex;
            }
        } catch (SQLException e) {
            System.err.println("Error en venta multiple: " + e.getMessage());
            response.sendRedirect(baseRedirect + "&status=error");
        }
    }
    
    /** Anula un pasaje. Solo ADMINISTRADOR y VENDEDOR pueden ejecutar esta accion. */
    private void procesarAnulacion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession sess = request.getSession(false);
        Usuario userAnul = (sess != null) ? (Usuario) sess.getAttribute("usuarioSesion") : null;
        
        // Verificar que sea ADMIN o VENDEDOR
        if (userAnul == null || (!"ADMINISTRADOR".equalsIgnoreCase(userAnul.getRol()) 
                && !"VENDEDOR".equalsIgnoreCase(userAnul.getRol()))) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String idPasajeStr = request.getParameter("idPasaje");
        if (idPasajeStr == null || idPasajeStr.isEmpty()) {
            response.sendRedirect("VentaServlet?accion=historial&status=error");
            return;
        }
        
        try {
            int idPasaje = Integer.parseInt(idPasajeStr);
            boolean exito = viajeDAO.anularPasaje(idPasaje);
            
            if (exito) {
                System.out.println("[OK] Pasaje #" + idPasaje + " anulado");
                response.sendRedirect("VentaServlet?accion=historial&status=anulado");
            } else {
                response.sendRedirect("VentaServlet?accion=historial&status=error");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("VentaServlet?accion=historial&status=error");
        }
    }

    // Metodos auxiliares
    
    private String[] separarNombre(String nombreCompleto) {
        String trimmed = nombreCompleto != null ? nombreCompleto.trim() : "-";
        String nombre = trimmed;
        String apellido = "-";
        if (trimmed.contains(" ")) {
            int espacio = trimmed.indexOf(" ");
            nombre = trimmed.substring(0, espacio);
            apellido = trimmed.substring(espacio + 1).trim();
        }
        return new String[]{nombre, apellido.isEmpty() ? "-" : apellido};
    }
    
    private int buscarOCrearCliente(Connection con, String dni, String nombre, String apellido) throws SQLException {
        String sqlBuscar = "SELECT id_cliente FROM Cliente WHERE dni = ?";
        try (PreparedStatement ps = con.prepareStatement(sqlBuscar)) {
            ps.setString(1, dni);
            try (var rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("id_cliente");
                }
            }
        }
        
        // No existe, crear
        String sqlCrear = "INSERT INTO Cliente (dni, nombre, apellido) VALUES (?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sqlCrear, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, dni);
            ps.setString(2, nombre);
            ps.setString(3, apellido);
            ps.executeUpdate();
            try (var rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        throw new SQLException("No se pudo crear el cliente con DNI: " + dni);
    }
    
    private int insertarPasaje(Connection con, int idViaje, int idCliente, int numAsiento, double precio, Integer idVendedor, String metodoPago) throws SQLException {
        String sql = "INSERT INTO Pasaje (id_viaje, id_cliente, id_bus_asiento, precio_pagado, estado, fecha_emision) " +
                     "OUTPUT INSERTED.id_pasaje " +
                     "VALUES (?, ?, (SELECT id_bus_asiento FROM Bus_Asiento WHERE id_bus = (SELECT id_bus FROM Viaje WHERE id_viaje = ?) AND numero_asiento = ?), ?, 'ACTIVO', GETDATE())";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idViaje);
            ps.setInt(2, idCliente);
            ps.setInt(3, idViaje);
            ps.setInt(4, numAsiento);
            ps.setDouble(5, precio);
            try (var rs = ps.executeQuery()) {
                if (rs.next()) {
                    int idPasaje = rs.getInt(1);
                    String sqlPago = "INSERT INTO Pago (monto_total, metodo_pago, id_pasaje, id_vendedor) VALUES (?, ?, ?, ?)";
                    try (PreparedStatement psPago = con.prepareStatement(sqlPago)) {
                        psPago.setDouble(1, precio);
                        psPago.setString(2, metodoPago);
                        psPago.setInt(3, idPasaje);
                        if (idVendedor != null) {
                            psPago.setInt(4, idVendedor);
                        } else {
                            psPago.setNull(4, java.sql.Types.INTEGER);
                        }
                        psPago.executeUpdate();
                    }
                    return idPasaje;
                }
            }
        }
        throw new SQLException("No se pudo insertar el pasaje para asiento " + numAsiento);
    }
}