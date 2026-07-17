package controller;

import dao.ReporteDAO;
import dao.RutaDAO;
import dao.UsuarioDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;
import model.Usuario;

@WebServlet(name = "ReporteServlet", urlPatterns = {"/ReporteServlet"})
public class ReporteServlet extends HttpServlet {

    private final ReporteDAO reporteDAO = new ReporteDAO();

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
        if (accion == null) accion = "ventas";
        
        // Cargar datos para filtros (rutas, vendedores)
        cargarDatosFiltros(request);

        try {
            switch (accion) {
                case "ventas" -> procesarReporteVentas(request, response);
                case "viajes" -> procesarReporteViajes(request, response);
                case "encomiendas" -> procesarReporteEncomiendas(request, response);
                case "exportarCSV" -> exportarCSV(request, response);
                default -> request.getRequestDispatcher("reportes.jsp").forward(request, response);
            }
        } catch (Exception e) {
            System.err.println("Error en ReporteServlet: " + e.getMessage());
            request.setAttribute("errorMsg", "Error al generar el reporte: " + e.getMessage());
            request.getRequestDispatcher("reportes.jsp").forward(request, response);
        }
    }

    private void cargarDatosFiltros(HttpServletRequest request) {
        RutaDAO rutaDAO = new RutaDAO();
        UsuarioDAO userDAO = new UsuarioDAO();
        request.setAttribute("listaRutas", rutaDAO.listarRutas());
        request.setAttribute("listaVendedores", userDAO.listarVendedores());
    }

    private void procesarReporteVentas(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fechaDesde = request.getParameter("fechaDesde");
        String fechaHasta = request.getParameter("fechaHasta");
        String idVendedorStr = request.getParameter("idVendedor");
        String idRutaStr = request.getParameter("idRuta");

        Integer idVendedor = (idVendedorStr != null && !idVendedorStr.isEmpty()) ? Integer.parseInt(idVendedorStr) : null;
        Integer idRuta = (idRutaStr != null && !idRutaStr.isEmpty()) ? Integer.parseInt(idRutaStr) : null;

        List<Map<String, Object>> resultados = reporteDAO.reporteVentas(fechaDesde, fechaHasta, idVendedor, idRuta);

        double totalIngresos = 0;
        int totalPasajes = resultados.size();
        for (Map<String, Object> v : resultados) {
            totalIngresos += (Double) v.getOrDefault("precioPagado", 0.0);
        }

        request.setAttribute("resultados", resultados);
        request.setAttribute("tipoReporte", "ventas");
        request.setAttribute("totalIngresos", totalIngresos);
        request.setAttribute("totalPasajes", totalPasajes);
        request.setAttribute("fechaDesde", fechaDesde);
        request.setAttribute("fechaHasta", fechaHasta);
        request.setAttribute("idVendedorSel", idVendedor);
        request.setAttribute("idRutaSel", idRuta);
        request.getRequestDispatcher("reportes.jsp").forward(request, response);
    }

    private void procesarReporteViajes(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fechaDesde = request.getParameter("fechaDesde");
        String fechaHasta = request.getParameter("fechaHasta");
        String idRutaStr = request.getParameter("idRuta");
        String estado = request.getParameter("estado");

        Integer idRuta = (idRutaStr != null && !idRutaStr.isEmpty()) ? Integer.parseInt(idRutaStr) : null;

        List<Map<String, Object>> resultados = reporteDAO.reporteViajes(fechaDesde, fechaHasta, idRuta, estado);

        request.setAttribute("resultados", resultados);
        request.setAttribute("tipoReporte", "viajes");
        request.setAttribute("fechaDesde", fechaDesde);
        request.setAttribute("fechaHasta", fechaHasta);
        request.setAttribute("idRutaSel", idRuta);
        request.setAttribute("estadoSel", estado);
        request.getRequestDispatcher("reportes.jsp").forward(request, response);
    }

    private void procesarReporteEncomiendas(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fechaDesde = request.getParameter("fechaDesde");
        String fechaHasta = request.getParameter("fechaHasta");
        String estado = request.getParameter("estado");

        List<Map<String, Object>> resultados = reporteDAO.reporteEncomiendas(fechaDesde, fechaHasta, estado);

        request.setAttribute("resultados", resultados);
        request.setAttribute("tipoReporte", "encomiendas");
        request.setAttribute("fechaDesde", fechaDesde);
        request.setAttribute("fechaHasta", fechaHasta);
        request.setAttribute("estadoSel", estado);
        request.getRequestDispatcher("reportes.jsp").forward(request, response);
    }

    private void exportarCSV(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String tipo = request.getParameter("tipo");
        if (tipo == null) tipo = "ventas";

        String fechaDesde = request.getParameter("fechaDesde");
        String fechaHasta = request.getParameter("fechaHasta");
        String idVendedorStr = request.getParameter("idVendedor");
        String idRutaStr = request.getParameter("idRuta");
        String estado = request.getParameter("estado");

        Integer idVendedor = (idVendedorStr != null && !idVendedorStr.isEmpty()) ? Integer.parseInt(idVendedorStr) : null;
        Integer idRuta = (idRutaStr != null && !idRutaStr.isEmpty()) ? Integer.parseInt(idRutaStr) : null;

        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=reporte_" + tipo + "_" 
                + new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date()) + ".csv");

        PrintWriter out = response.getWriter();
        out.write('\uFEFF'); // BOM UTF-8 para Excel

        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");

        switch (tipo) {
            case "ventas" -> exportarVentasCSV(out, fechaDesde, fechaHasta, idVendedor, idRuta, sdf);
            case "viajes" -> exportarViajesCSV(out, fechaDesde, fechaHasta, idRuta, estado, sdf);
            case "encomiendas" -> exportarEncomiendasCSV(out, fechaDesde, fechaHasta, estado, sdf);
        }
    }

    private void exportarVentasCSV(PrintWriter out, String fd, String fh, Integer idVend, Integer idRuta, SimpleDateFormat sdf) {
        out.println("REPORTE DE VENTAS - MovilBus");
        out.println("Fecha generacion: " + sdf.format(new Date()));
        if (fd != null) out.println("Desde: " + fd);
        if (fh != null) out.println("Hasta: " + fh);
        out.println();

        List<Map<String, Object>> datos = reporteDAO.reporteVentas(fd, fh, idVend, idRuta);
        out.println("# Pasaje,Fecha Emision,Pasajero,DNI,Origen,Destino,Bus,Servicio,Asiento,Piso,Tipo Asiento,Precio Pagado,Metodo Pago,Vendedor,Estado");

        for (Map<String, Object> v : datos) {
            out.print(v.getOrDefault("idPasaje", "") + ",");
            out.print(formatCSV(sdf.format((Date) v.getOrDefault("fechaEmision", new Date()))) + ",");
            out.print(formatCSV((String) v.getOrDefault("nombreCliente", "")) + ",");
            out.print(formatCSV((String) v.getOrDefault("dniCliente", "")) + ",");
            out.print(formatCSV((String) v.getOrDefault("origen", "")) + ",");
            out.print(formatCSV((String) v.getOrDefault("destino", "")) + ",");
            out.print(formatCSV((String) v.getOrDefault("placa", "")) + ",");
            out.print(formatCSV((String) v.getOrDefault("nombreServicio", "")) + ",");
            out.print(v.getOrDefault("numeroAsiento", "") + ",");
            out.print(v.getOrDefault("piso", "") + ",");
            out.print(formatCSV((String) v.getOrDefault("tipoAsiento", "")) + ",");
            out.print("S/ " + String.format("%.2f", v.getOrDefault("precioPagado", 0.0)) + ",");
            out.print(formatCSV((String) v.getOrDefault("metodoPago", "")) + ",");
            out.print(formatCSV((String) v.getOrDefault("vendedor", "")) + ",");
            out.println(formatCSV((String) v.getOrDefault("estadoPasaje", "")));
        }

        out.println();
        double total = datos.stream().mapToDouble(v -> (Double) v.getOrDefault("precioPagado", 0.0)).sum();
        out.println("Total Pasajes:," + datos.size());
        out.println("Total Ingresos:,\"S/ " + String.format("%.2f", total) + "\"");
    }

    private void exportarViajesCSV(PrintWriter out, String fd, String fh, Integer idRuta, String estado, SimpleDateFormat sdf) {
        out.println("REPORTE DE VIAJES - MovilBus");
        out.println("Fecha generacion: " + sdf.format(new Date()));
        if (fd != null) out.println("Desde: " + fd);
        if (fh != null) out.println("Hasta: " + fh);
        out.println();

        List<Map<String, Object>> datos = reporteDAO.reporteViajes(fd, fh, idRuta, estado);
        out.println("# Viaje,Fecha Salida,Fecha Llegada,Origen,Destino,Bus,Marca,Servicio,Capacidad,Ocupados,% Ocupacion,Estado");

        for (Map<String, Object> v : datos) {
            int ocup = (int) v.getOrDefault("ocupados", 0);
            int cap = (int) v.getOrDefault("capacidad", 1);
            double pct = cap > 0 ? (double) ocup / cap * 100 : 0;

            out.print(v.getOrDefault("idViaje", "") + ",");
            out.print(formatCSV(sdf.format((Date) v.getOrDefault("fechaHoraSalida", new Date()))) + ",");
            out.print(formatCSV(sdf.format((Date) v.getOrDefault("fechaLlegada", new Date()))) + ",");
            out.print(formatCSV((String) v.getOrDefault("origen", "")) + ",");
            out.print(formatCSV((String) v.getOrDefault("destino", "")) + ",");
            out.print(formatCSV((String) v.getOrDefault("placa", "")) + ",");
            out.print(formatCSV((String) v.getOrDefault("marca", "")) + ",");
            out.print(formatCSV((String) v.getOrDefault("servicio", "")) + ",");
            out.print(cap + ",");
            out.print(ocup + ",");
            out.print(String.format("%.1f%%", pct) + ",");
            out.println(formatCSV((String) v.getOrDefault("estado", "")));
        }
    }

    private void exportarEncomiendasCSV(PrintWriter out, String fd, String fh, String estado, SimpleDateFormat sdf) {
        out.println("REPORTE DE ENCOMIENDAS - MovilBus");
        out.println("Fecha generacion: " + sdf.format(new Date()));
        if (fd != null) out.println("Desde: " + fd);
        if (fh != null) out.println("Hasta: " + fh);
        out.println();

        List<Map<String, Object>> datos = reporteDAO.reporteEncomiendas(fd, fh, estado);
        out.println("# Encomienda,Fecha,Descripcion,Peso (Kg),Origen,Destino,Remitente,Destinatario,Costo Envio,Metodo Pago,Vendedor,Estado");

        for (Map<String, Object> e : datos) {
            out.print(e.getOrDefault("idEncomienda", "") + ",");
            out.print(formatCSV(sdf.format((Date) e.getOrDefault("fechaEnvio", new Date()))) + ",");
            out.print(formatCSV((String) e.getOrDefault("descripcion", "")) + ",");
            out.print(String.format("%.1f", e.getOrDefault("pesoKg", 0.0)) + ",");
            out.print(formatCSV((String) e.getOrDefault("origen", "")) + ",");
            out.print(formatCSV((String) e.getOrDefault("destino", "")) + ",");
            out.print(formatCSV((String) e.getOrDefault("nombreRemitente", "")) + ",");
            out.print(formatCSV((String) e.getOrDefault("nombreDestinatario", "")) + ",");
            out.print("S/ " + String.format("%.2f", e.getOrDefault("precioEnvio", 0.0)) + ",");
            out.print(formatCSV((String) e.getOrDefault("metodoPago", "")) + ",");
            out.print(formatCSV((String) e.getOrDefault("vendedor", "")) + ",");
            out.println(formatCSV((String) e.getOrDefault("estado", "")));
        }

        double total = datos.stream().mapToDouble(v -> (Double) v.getOrDefault("precioEnvio", 0.0)).sum();
        out.println();
        out.println("Total Encomiendas:," + datos.size());
        out.println("Total Ingresos:,\"S/ " + String.format("%.2f", total) + "\"");
    }

    private String formatCSV(String value) {
        if (value == null) return "\"\"";
        return "\"" + value.replace("\"", "\"\"") + "\"";
    }
}
