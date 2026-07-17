package controller;

import dao.NotificacionDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Map;

import model.Usuario;

@WebServlet(name = "NotificacionServlet", urlPatterns = {"/NotificacionServlet"})
public class NotificacionServlet extends HttpServlet {

    private final NotificacionDAO notificacionDAO = new NotificacionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuarioSesion") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\": \"No autenticado\"}");
            return;
        }

        Usuario user = (Usuario) session.getAttribute("usuarioSesion");
        String rol = user.getRol();
        
        // Solo admin y vendedor ven notificaciones
        if ("CLIENTE_WEB".equalsIgnoreCase(rol)) {
            response.setContentType("application/json");
            response.getWriter().write("{\"total\": 0, \"notificaciones\": []}");
            return;
        }

        String accion = request.getParameter("accion");
        if (accion == null) accion = "listar";

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            if ("contar".equals(accion)) {
                // Solo devolver el conteo (mas rapido)
                int total = notificacionDAO.contarNotificaciones();
                response.getWriter().write("{\"total\": " + total + "}");
                
            } else {
                // Devolver lista completa
                List<Map<String, Object>> notificaciones = notificacionDAO.obtenerNotificaciones();
                StringBuilder json = new StringBuilder();
                json.append("{\"total\": ").append(notificaciones.size()).append(", \"notificaciones\": [");
                
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                
                for (int i = 0; i < notificaciones.size(); i++) {
                    Map<String, Object> n = notificaciones.get(i);
                    if (i > 0) json.append(",");
                    
                    json.append("{");
                    json.append("\"id\": \"").append(escapeJson((String) n.get("id"))).append("\",");
                    json.append("\"tipo\": \"").append(escapeJson((String) n.get("tipo"))).append("\",");
                    json.append("\"mensaje\": \"").append(escapeJson((String) n.get("mensaje"))).append("\",");
                    json.append("\"icono\": \"").append(escapeJson((String) n.get("icono"))).append("\",");
                    json.append("\"color\": \"").append(escapeJson((String) n.get("color"))).append("\",");
                    json.append("\"link\": \"").append(escapeJson((String) n.get("link"))).append("\"");
                    json.append("}");
                }
                
                json.append("]}");
                response.getWriter().write(json.toString());
            }
        } catch (Exception e) {
            System.err.println("Error en NotificacionServlet: " + e.getMessage());
            response.getWriter().write("{\"total\": 0, \"notificaciones\": [], \"error\": \"" 
                + escapeJson(e.getMessage()) + "\"}");
        }
    }

    private String escapeJson(String value) {
        if (value == null) return "";
        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
