package util;

import org.mindrot.jbcrypt.BCrypt;
import java.io.FileInputStream;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.util.Properties;

/**
 * Actualiza la contraseña del usuario admin a admin123 con BCrypt.
 * 
 * Compilar:
 *   javac -cp "../librerias_proyecto/jbcrypt-0.4.jar;../librerias_proyecto/mssql-jdbc-13.4.0.jre11.jar" -d ../build/web/WEB-INF/classes src/java/util/FixAdminPassword.java
 * 
 * Ejecutar:
 *   java -cp "build/web/WEB-INF/classes;../librerias_proyecto/jbcrypt-0.4.jar;../librerias_proyecto/mssql-jdbc-13.4.0.jre11.jar" util.FixAdminPassword
 */
public class FixAdminPassword {
    public static void main(String[] args) {
        Properties prop = new Properties();
        try (InputStream input = new FileInputStream("src/java/config/database.properties")) {
            prop.load(input);
        } catch (Exception e) {
            System.err.println("Error leyendo properties: " + e.getMessage());
            return;
        }

        String url = "jdbc:sqlserver://" + prop.getProperty("db.server") + ";"
                   + "databaseName=" + prop.getProperty("db.name") + ";"
                   + "encrypt=true;trustServerCertificate=true;";

        String newHash = BCrypt.hashpw("admin123", BCrypt.gensalt(12));
        System.out.println("Nuevo hash: " + newHash);

        try (Connection con = DriverManager.getConnection(url, prop.getProperty("db.user"), prop.getProperty("db.password"));
             PreparedStatement ps = con.prepareStatement("UPDATE Usuarios SET password = ? WHERE username = 'admin'")) {
            ps.setString(1, newHash);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                System.out.println("[OK] Password de admin actualizada a 'admin123' con BCrypt");
            } else {
                System.out.println("[AVISO] No se encontro usuario 'admin' en la BD");
            }
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
}
