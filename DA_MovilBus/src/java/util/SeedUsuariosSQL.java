package util;

import org.mindrot.jbcrypt.BCrypt;

/**
 * Genera un script SQL INSERT con contraseñas hasheadas en BCrypt.
 * 
 * Compilar:
 *   javac -cp "../librerias_proyecto/jbcrypt-0.4.jar" -d ../build/web/WEB-INF/classes src/java/util/SeedUsuariosSQL.java
 * 
 * Ejecutar (redirigir salida a archivo SQL):
 *   java -cp "build/web/WEB-INF/classes;../librerias_proyecto/jbcrypt-0.4.jar" util.SeedUsuariosSQL
 */
public class SeedUsuariosSQL {
    
    // Datos de usuarios semilla
    private static final String[][] USUARIOS = {
        {"admin",       "admin123",    "Admin",    "Principal", "1"}, // ADMINISTRADOR
        {"vendedor1",   "123456",      "Carlos",   "Garcia",    "2"}, // VENDEDOR
        {"vendedor2",   "123456",      "Maria",    "Lopez",     "2"}, // VENDEDOR
        {"vendedor3",   "123456",      "Juan",     "Perez",     "2"}, // VENDEDOR
        {"cliente1",    "cliente123",  "Pedro",    "Ramirez",   "3"}, // CLIENTE_WEB
        {"cliente2",    "cliente123",  "Ana",      "Torres",    "3"}, // CLIENTE_WEB
    };

    public static void main(String[] args) {
        System.out.println("-- ==============================================");
        System.out.println("-- SCRIPT DE USUARIOS SEMILLA CON BCRYPT");
        System.out.println("-- Generado el: " + new java.util.Date().toString());
        System.out.println("-- ==============================================");
        System.out.println();
        System.out.println("USE MovilBusDB;");
        System.out.println("GO");
        System.out.println();
        
        for (String[] u : USUARIOS) {
            String username = u[0];
            String plainPassword = u[1];
            String nombre = u[2];
            String apellido = u[3];
            String idRol = u[4];
            
            String hash = BCrypt.hashpw(plainPassword, BCrypt.gensalt(12));
            
            System.out.println("-- Usuario: " + username + " / password: " + plainPassword);
            System.out.println("INSERT INTO Usuarios (username, password, nombre, apellido, id_rol, estado)");
            System.out.println("VALUES ('" + username + "', '" + hash + "', '" + nombre + "', '" + apellido + "', " + idRol + ", 'ACTIVO');");
            System.out.println("GO");
            System.out.println();
        }
        
        System.out.println("-- ==============================================");
        System.out.println("-- FIN DEL SCRIPT");
        System.out.println("-- ==============================================");
    }
}
