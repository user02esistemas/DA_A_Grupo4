package config;

import java.sql.Connection;
import java.sql.SQLException;

public class PruebaConexion {
    
    public static void main(String[] args) {
        System.out.println(">>> Iniciando prueba de conexión con SQL Server...");
        
        // 1. Intentamos obtener la instancia única de conexión
        Connection cn = ConexionBD.getConexion();
        
        // 2. Evaluamos el resultado de la conexión
        if (cn != null) {
            System.out.println(">>> ¡ÉXITO! La aplicación se conectó correctamente a MovilBusDB.");
            
            try {
                // Imprimimos información adicional para confirmar que no esté cerrada
                System.out.println(">>> Estado de la conexión: " + (!cn.isClosed() ? "ACTIVA" : "CERRADA"));
                
                // 3. Cerramos la conexión después de la prueba
                ConexionBD.cerrarConexion();
                
            } catch (SQLException e) {
                System.err.println(">>> Error al verificar el estado de la conexión: " + e.getMessage());
            }
        } else {
            System.err.println(">>> [FALLO] No se pudo establecer la conexión.");
            System.err.println(">>> Verificaciones recomendadas:");
            System.err.println("    1. ¿El archivo 'database.properties' tiene las credenciales correctas?");
            System.err.println("    2. ¿El servicio de SQL Server está corriendo en tu PC?");
            System.err.println("    3. ¿El puerto 1433 está habilitado para conexiones TCP/IP en SQL Server?");
        }
    }
}