package controller;

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

@WebServlet(name = "VentaServlet", urlPatterns = {"/VentaServlet"})
public class VentaServlet extends HttpServlet {

    private ViajeDAO viajeDAO = new ViajeDAO();

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

                // 🔥 SOLUCIÓN AQUÍ: Generamos y enviamos la lista inteligente que el ventas.jsp necesita renderizar
                List<model.Asiento> croquis = viajeDAO.generarCroquisDinamico(idViaje);
                request.setAttribute("listaAsientosIntel", croquis);
            }
        } catch (Exception e) {
            System.err.println("Error en VentaServlet GET: " + e.getMessage());
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
        
        // ============================================================
        // ACCIÓN: guardarVenta (SINGLE - una sola venta, legacy)
        // ============================================================
        if ("guardarVenta".equals(accion)) {
            procesarVentaUnica(request, response);
        } 
        // ============================================================
        // ACCIÓN: guardarVentaMulti (MULTIPLE - varios pasajes)
        // ============================================================
        else if ("guardarVentaMulti".equals(accion)) {
            procesarVentaMultiple(request, response);
        }
    }
    
    // =================================================================
    //  PROCESAR VENTA ÚNICA (un solo pasajero en un asiento)
    // =================================================================
    private void procesarVentaUnica(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idViajeParam = request.getParameter("idViaje");
        String numAsientoParam = request.getParameter("numAsiento");
        String precioBoleto = request.getParameter("precioBoleto");
        String dni = request.getParameter("dni");
        String nombrePasajero = request.getParameter("nombrePasajero");
        
        String idOrigen = request.getParameter("idOrigen");
        String idDestino = request.getParameter("idDestino");
        String fecha = request.getParameter("fecha");
        
        String baseRedirect = "VentaServlet?accion=verAsientos&idViaje=" + idViajeParam + 
                              "&idOrigen=" + idOrigen + "&idDestino=" + idDestino + "&fecha=" + fecha;

        if (numAsientoParam == null || numAsientoParam.trim().isEmpty() || idViajeParam == null) {
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
                int idPasajeGenerado = insertarPasaje(con, idViaje, idCliente, numAsiento, precioFinal);
                con.commit();
                response.sendRedirect("pasaje-confirmado.jsp?idPasaje=" + idPasajeGenerado);
            } catch (SQLException ex) {
                con.rollback();
                throw ex;
            }
        } catch (SQLException e) {
            System.err.println("❌ Error en venta única: " + e.getMessage());
            response.sendRedirect(baseRedirect + "&status=error");
        }
    }
    
    // =================================================================
    //  PROCESAR VENTA MÚLTIPLE (varios pasajeros en varios asientos)
    // =================================================================
    private void procesarVentaMultiple(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idViajeParam = request.getParameter("idViaje");
        String idOrigen = request.getParameter("idOrigen");
        String idDestino = request.getParameter("idDestino");
        String fecha = request.getParameter("fecha");
        
        String baseRedirect = "VentaServlet?accion=verAsientos&idViaje=" + idViajeParam + 
                              "&idOrigen=" + idOrigen + "&idDestino=" + idDestino + "&fecha=" + fecha;

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
                    double precioFinal = (precios != null && i < precios.length) 
                        ? Double.parseDouble(precios[i].replace("S/.", "").trim()) : 0.0;
                    String dni = (dnis != null && i < dnis.length) ? dnis[i] : "00000000";
                    String nombrePasajero = (nombres != null && i < nombres.length) ? nombres[i] : "-";
                    
                    String[] nombreApellido = separarNombre(nombrePasajero);
                    
                    int idCliente = buscarOCrearCliente(con, dni, nombreApellido[0], nombreApellido[1]);
                    int idPasaje = insertarPasaje(con, idViaje, idCliente, numAsiento, precioFinal);
                    
                    if (idsGenerados.length() > 0) idsGenerados.append(",");
                    idsGenerados.append(idPasaje);
                }
                
                con.commit();
                System.out.println("====== [OK] " + asientos.length + " PASAJES EMITIDOS ======");
                
                // Redirigir al último pasaje generado (el usuario puede ver los demás en historial)
                String[] ids = idsGenerados.toString().split(",");
                String ultimoId = ids[ids.length - 1];
                response.sendRedirect("pasaje-confirmado.jsp?idPasaje=" + ultimoId + "&multi=" + idsGenerados.toString());
                
            } catch (SQLException ex) {
                con.rollback();
                throw ex;
            }
        } catch (SQLException e) {
            System.err.println("❌ Error en venta múltiple: " + e.getMessage());
            response.sendRedirect(baseRedirect + "&status=error");
        }
    }
    
    // =================================================================
    //  MÉTODOS AUXILIARES
    // =================================================================
    
    private String[] separarNombre(String nombreCompleto) {
        String nombre = nombreCompleto;
        String apellido = "-";
        if (nombreCompleto != null && nombreCompleto.contains(" ")) {
            int espacio = nombreCompleto.indexOf(" ");
            nombre = nombreCompleto.substring(0, espacio);
            apellido = nombreCompleto.substring(espacio + 1);
        }
        return new String[]{nombre, apellido};
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
    
    private int insertarPasaje(Connection con, int idViaje, int idCliente, int numAsiento, double precio) throws SQLException {
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
                if (rs.next()) return rs.getInt(1);
            }
        }
        throw new SQLException("No se pudo insertar el pasaje para asiento " + numAsiento);
    }
}