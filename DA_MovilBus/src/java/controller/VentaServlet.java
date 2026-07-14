package controller;

import dao.ViajeDAO;
import config.ConexionBD;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

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

        // Redirecciona de vuelta al formulario manteniendo los objetos cargados en memoria
        request.getRequestDispatcher("ventas.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String accion = request.getParameter("accion");
        
        if ("guardarVenta".equals(accion)) {
            // Captura de datos del formulario
            String idViajeParam = request.getParameter("idViaje");
            String numAsientoParam = request.getParameter("numAsiento");
            String precioBoleto = request.getParameter("precioBoleto");
            String dni = request.getParameter("dni");
            String nombrePasajero = request.getParameter("nombrePasajero");
            
            // 🛠️ SOLUCIÓN ERROR 2 (GET): Capturamos las variables de retorno para que la URL no esté vacía
            String idOrigen = request.getParameter("idOrigen");
            String idDestino = request.getParameter("idDestino");
            String fecha = request.getParameter("fecha");
            
            // Preparamos la URL base de redirección
            String baseRedirect = "VentaServlet?accion=verAsientos&idViaje=" + idViajeParam + 
                                  "&idOrigen=" + idOrigen + "&idDestino=" + idDestino + "&fecha=" + fecha;

            // Validación defensiva
            if (numAsientoParam == null || numAsientoParam.trim().isEmpty() || idViajeParam == null) {
                response.sendRedirect(baseRedirect + "&status=error");
                return;
            }

            int idViaje = Integer.parseInt(idViajeParam);
            int numAsiento = Integer.parseInt(numAsientoParam);
            double precioFinal = precioBoleto != null ? Double.parseDouble(precioBoleto.replace("S/.", "").trim()) : 0.0;

            // 💡 TIP: Separar el nombre completo en Nombre y Apellido para la BD
            String nombre = nombrePasajero;
            String apellido = "-";
            if (nombrePasajero != null && nombrePasajero.contains(" ")) {
                int espacio = nombrePasajero.indexOf(" ");
                nombre = nombrePasajero.substring(0, espacio);
                apellido = nombrePasajero.substring(espacio + 1);
            }

            // Usamos un bloque try con recursos
            try (Connection con = ConexionBD.getConexion()) {
                
                con.setAutoCommit(false); // 🔥 INICIAMOS TRANSACCIÓN (Si falla el pasaje, no creamos un cliente huérfano)

                try {
                    // ==========================================
                    // PASO 1: BUSCAR O CREAR AL CLIENTE
                    // ==========================================
                    int idCliente = -1;
                    String sqlBuscarCliente = "SELECT id_cliente FROM Cliente WHERE dni = ?";
                    
                    try (PreparedStatement psBusqueda = con.prepareStatement(sqlBuscarCliente)) {
                        psBusqueda.setString(1, dni);
                        try (var rs = psBusqueda.executeQuery()) {
                            if (rs.next()) {
                                idCliente = rs.getInt("id_cliente");
                            }
                        }
                    }

                    // Si no existe, lo creamos
                    if (idCliente == -1) {
                        String sqlCrearCliente = "INSERT INTO Cliente (dni, nombre, apellido) VALUES (?, ?, ?)";
                        // Pedimos que nos devuelva el ID autogenerado
                        try (PreparedStatement psCrear = con.prepareStatement(sqlCrearCliente, PreparedStatement.RETURN_GENERATED_KEYS)) {
                            psCrear.setString(1, dni);
                            psCrear.setString(2, nombre);
                            psCrear.setString(3, apellido);
                            psCrear.executeUpdate();
                            
                            try (var rsKeys = psCrear.getGeneratedKeys()) {
                                if (rsKeys.next()) {
                                    idCliente = rsKeys.getInt(1);
                                }
                            }
                        }
                    }

                    // ==========================================
                    // PASO 2: INSERTAR EL PASAJE (Con el id_cliente)
                    // ==========================================
                    String sqlPasaje = "INSERT INTO Pasaje (id_viaje, id_cliente, id_bus_asiento, precio_pagado, estado, fecha_emision) " +
                                       "VALUES (?, ?, (SELECT id_bus_asiento FROM Bus_Asiento WHERE id_bus = (SELECT id_bus FROM Viaje WHERE id_viaje = ?) AND numero_asiento = ?), ?, 'ACTIVO', GETDATE())";
                    
                    try (PreparedStatement psPasaje = con.prepareStatement(sqlPasaje)) {
                        psPasaje.setInt(1, idViaje);
                        psPasaje.setInt(2, idCliente); // 🛠️ SOLUCIÓN ERROR 1 (NULL)
                        psPasaje.setInt(3, idViaje);   // Usado en la subconsulta
                        psPasaje.setInt(4, numAsiento);
                        psPasaje.setDouble(5, precioFinal);
                        psPasaje.executeUpdate();
                    }

                    con.commit(); // ✅ Confirmamos que todo salió bien
                    System.out.println("====== [OK] PASAJE EMITIDO CON ÉXITO ======");
                    
                    response.sendRedirect(baseRedirect + "&status=success");

                } catch (SQLException ex) {
                    con.rollback(); // ❌ Si algo explota (ej. Asiento ya tomado), deshacemos todo
                    throw ex;
                }
            } catch (SQLException e) {
                System.err.println("❌ Error al guardar el pasaje: " + e.getMessage());
                // Redirigimos usando la URL completa, para evitar el error de "Cannot parse null string"
                response.sendRedirect(baseRedirect + "&status=error");
            }
        }
    }
}