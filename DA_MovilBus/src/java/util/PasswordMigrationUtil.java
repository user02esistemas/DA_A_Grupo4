package util;

import java.io.FileInputStream;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Utilidad de migración: convierte contraseñas en texto plano a BCrypt.
 * 
 * Ejecutar UNA SOLA VEZ después de implementar BCrypt en el login.
 * Requiere jbcrypt-0.4.jar en el classpath.
 * 
 * Compilar:
 *   javac -cp "../librerias_proyecto/jbcrypt-0.4.jar;../librerias_proyecto/mssql-jdbc-13.4.0.jre11.jar" -d ../build/web/WEB-INF/classes src/java/util/PasswordMigrationUtil.java
 * 
 * Ejecutar (desde el directorio DA_MovilBus):
 *   java -cp "build/web/WEB-INF/classes;../librerias_proyecto/jbcrypt-0.4.jar;../librerias_proyecto/mssql-jdbc-13.4.0.jre11.jar" util.PasswordMigrationUtil
 */
public class PasswordMigrationUtil {

    private static final String DRIVER = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
    private static final String PROPERTIES_PATH = "src/java/config/database.properties";

    public static void main(String[] args) {
        System.out.println("============================================");
        System.out.println("  MIGRADOR DE CONTRASENAS A BCRYPT");
        System.out.println("  MovilBus - Password Migration Utility");
        System.out.println("============================================");
        System.out.println();

        Properties prop = new Properties();
        try (InputStream input = new FileInputStream(PROPERTIES_PATH)) {
            prop.load(input);
        } catch (Exception e) {
            System.err.println("[ERROR] No se pudo leer " + PROPERTIES_PATH + ": " + e.getMessage());
            System.err.println("[INFO]  Asegurate de estar en el directorio raiz del proyecto (DA_MovilBus)");
            return;
        }

        String server = prop.getProperty("db.server");
        String dbName = prop.getProperty("db.name");
        String user = prop.getProperty("db.user");
        String password = prop.getProperty("db.password");

        String url = "jdbc:sqlserver://" + server + ";" 
                   + "databaseName=" + dbName + ";"
                   + "encrypt=true;trustServerCertificate=true;";

        System.out.println("[INFO] Conectando a " + server + " / " + dbName + "...");

        try (Connection con = DriverManager.getConnection(url, user, password)) {
            System.out.println("[OK]   Conexion establecida.");
            System.out.println();

            // 1. Obtener todos los usuarios con sus contraseñas
            String sqlSelect = "SELECT id_usuario, username, password FROM Usuarios ORDER BY id_usuario";
            String sqlUpdate = "UPDATE Usuarios SET password = ? WHERE id_usuario = ?";

            int total = 0;
            int migrados = 0;
            int yaEnBcrypt = 0;

            try (PreparedStatement psSelect = con.prepareStatement(sqlSelect);
                 ResultSet rs = psSelect.executeQuery()) {

                while (rs.next()) {
                    total++;
                    int idUsuario = rs.getInt("id_usuario");
                    String username = rs.getString("username");
                    String storedPassword = rs.getString("password");

                    System.out.printf("[%d] %-20s ", idUsuario, username);

                    if (storedPassword == null || storedPassword.isEmpty()) {
                        System.out.println("[SALTAR] password vacio");
                        continue;
                    }

                    // Detectar si ya es un hash BCrypt (empieza con $2a$, $2b$ o $2y$)
                    if (storedPassword.startsWith("$2a$") || storedPassword.startsWith("$2b$") || storedPassword.startsWith("$2y$")) {
                        System.out.println("[OK]    ya es BCrypt");
                        yaEnBcrypt++;
                        continue;
                    }

                    // Es texto plano → migrar a BCrypt
                    String hashed = org.mindrot.jbcrypt.BCrypt.hashpw(storedPassword, org.mindrot.jbcrypt.BCrypt.gensalt(12));

                    try (PreparedStatement psUpdate = con.prepareStatement(sqlUpdate)) {
                        psUpdate.setString(1, hashed);
                        psUpdate.setInt(2, idUsuario);
                        psUpdate.executeUpdate();
                    }

                    System.out.println("[MIGRADO] (password oculta) -> " + hashed.substring(0, 30) + "...");
                    migrados++;
                }
            }

            System.out.println();
            System.out.println("============================================");
            System.out.println("  RESUMEN");
            System.out.println("  Total usuarios procesados: " + total);
            System.out.println("  Ya en BCrypt:             " + yaEnBcrypt);
            System.out.println("  Migrados a BCrypt:        " + migrados);
            System.out.println("============================================");

            if (migrados > 0) {
                System.out.println();
                System.out.println("[SUCCESS] Migracion completada. Ahora el login deberia funcionar.");
            } else if (yaEnBcrypt == total && total > 0) {
                System.out.println();
                System.out.println("[INFO] Todas las contrasenas ya estaban en BCrypt. El login deberia funcionar.");
                System.out.println("[INFO] Si aun no funciona, verifica la conexion a BD o las credenciales.");
            }

        } catch (SQLException e) {
            System.err.println("[ERROR] Error de BD: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
