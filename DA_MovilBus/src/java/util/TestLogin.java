package util;

import java.io.FileInputStream;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Properties;

/**
 * Verifica que las contraseñas en la BD coincidan con BCrypt.
 * Prueba específicamente admin/admin123 y vendedor1/123456.
 * 
 * Compilar:
 *   javac -cp "../librerias_proyecto/jbcrypt-0.4.jar;../librerias_proyecto/mssql-jdbc-13.4.0.jre11.jar" -d ../build/web/WEB-INF/classes src/java/util/TestLogin.java
 * 
 * Ejecutar (desde DA_MovilBus):
 *   java -cp "build/web/WEB-INF/classes;../librerias_proyecto/jbcrypt-0.4.jar;../librerias_proyecto/mssql-jdbc-13.4.0.jre11.jar" util.TestLogin
 */
public class TestLogin {

    private static final String DRIVER = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
    private static final String PROPERTIES_PATH = "src/java/config/database.properties";

    // Pares usuario/contraseña a probar
    private static final String[][] TEST_USERS = {
        {"admin",     "admin123"},
        {"vendedor1", "123456"},
        {"vendedor2", "123456"},
        {"admin",     "123456"},     // fallo deliberado para probar
    };

    public static void main(String[] args) {
        System.out.println("============================================");
        System.out.println("  VERIFICADOR DE LOGIN - BCrypt");
        System.out.println("============================================");

        Properties prop = new Properties();
        try (InputStream input = new FileInputStream(PROPERTIES_PATH)) {
            prop.load(input);
        } catch (Exception e) {
            System.err.println("[ERROR] No se pudo leer " + PROPERTIES_PATH);
            e.printStackTrace();
            return;
        }

        String url = "jdbc:sqlserver://" + prop.getProperty("db.server") + ";"
                   + "databaseName=" + prop.getProperty("db.name") + ";"
                   + "encrypt=true;trustServerCertificate=true;";

        try (Connection con = DriverManager.getConnection(url, prop.getProperty("db.user"), prop.getProperty("db.password"))) {
            System.out.println("[OK] Conectado a la BD\n");

            for (String[] test : TEST_USERS) {
                String username = test[0];
                String password = test[1];

                String sql = "SELECT u.id_usuario, u.username, u.password, u.estado, r.nombre_rol " +
                             "FROM Usuarios u INNER JOIN Roles r ON u.id_rol = r.id_rol " +
                             "WHERE u.username = ?";

                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setString(1, username);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            String storedHash = rs.getString("password");
                            String estado = rs.getString("estado");
                            String rol = rs.getString("nombre_rol");

                            System.out.println("--- " + username + " / " + password + " ---");
                            System.out.println("  Estado: " + estado);
                            System.out.println("  Rol: " + rol);

                            if (!"ACTIVO".equals(estado)) {
                                System.out.println("  [FALLA] Usuario INACTIVO!");
                            } else if (storedHash == null || storedHash.isEmpty()) {
                                System.out.println("  [FALLA] Password vacio en BD!");
                            } else if (storedHash.startsWith("$2a$") || storedHash.startsWith("$2b$") || storedHash.startsWith("$2y$")) {
                                boolean verifica = org.mindrot.jbcrypt.BCrypt.checkpw(password, storedHash);
                                if (verifica) {
                                    System.out.println("  [OK] BCrypt OK - Login EXITOSO!");
                                } else {
                                    System.out.println("  [FALLA] BCrypt no coincide! (password incorrecta o hash corrupto)");
                                    System.out.println("  Hash: " + storedHash);
                                }
                            } else {
                                // Texto plano
                                boolean plainMatch = password.equals(storedHash);
                                if (plainMatch) {
                                    System.out.println("  [AVISO] Password en TEXTO PLANO! Coincide pero no es BCrypt.");
                                } else {
                                    System.out.println("  [FALLA] Password en texto plano y no coincide!");
                                    System.out.println("  Almacenado: '" + storedHash + "'");
                                }
                            }
                        } else {
                            System.out.println("--- " + username + " ---");
                            System.out.println("  [FALLA] Usuario NO EXISTE en la BD!");
                        }
                    }
                }
                System.out.println();
            }

        } catch (Exception e) {
            System.err.println("[ERROR] " + e.getMessage());
            e.printStackTrace();
        }
    }
}
