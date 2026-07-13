<%-- 
    Document   : index
    Created on : 13 jul. 2026, 12:04:33 a. m.
    Author     : gatit
--%>

<%@page import="java.sql.Connection"%>
<%@page import="com.movilbus.config.ConexionBD"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Prueba de Conexión - MovilBus</title>
        <style>
            body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
            .badge { padding: 15px; font-size: 1.2em; font-weight: bold; border-radius: 5px; display: inline-block; }
            .success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
            .error { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        </style>
    </head>
    <body>
        <h2>Sistema de Transportes MovilBusWeb</h2>
        <p>Verificando el estado del Bloque 1 (Conexión Base de Datos)...</p>

        <%
            // Intentamos invocar tu Singleton desde la vista
            Connection cn = ConexionBD.getInstancia().getConexion();
            if (cn != null) {
        %>
            <div class="badge success">
                ¡CONEXIÓN EXITOSA! El proyecto se enlazó correctamente con MovilBusDB en SQL Server.
            </div>
        <%
            } else {
        %>
            <div class="badge error">
                ERROR DE CONEXIÓN. Revisa que el servicio de SQL Server esté corriendo o tus credenciales.
            </div>
        <%
            }
        %>
    </body>
</html>