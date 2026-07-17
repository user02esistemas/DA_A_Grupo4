package conexion;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * @deprecated Usar {@link config.ConexionBD} en su lugar.
 * Esta clase usa credenciales hardcodeadas (localhost:1433) 
 * y no lee del archivo database.properties.
 * Ningun DAO del sistema la utiliza actualmente.
 */
@Deprecated
public class ConexionBD {
    
    private static ConexionBD instancia;
    private Connection conexion;
    
    private final String url = "jdbc:sqlserver://localhost:1433;databaseName=MovilBusDB;encrypt=true;trustServerCertificate=true;";
    private final String usuario = "sa";
    private final String password = "dba";

    private ConexionBD() {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            System.err.println("Error: No se encontró el driver JDBC de SQL Server: " + e.getMessage());
        }
    }

    public static synchronized ConexionBD getInstancia() {
        if (instancia == null) {
            instancia = new ConexionBD();
        }
        return instancia;
    }

    public Connection getConexion() {
        try {
            if (conexion == null || conexion.isClosed()) {
                conexion = DriverManager.getConnection(url, usuario, password);
                System.out.println("¡Conexión establecida con éxito a MovilBusDB!");
            }
        } catch (SQLException e) {
            System.err.println("Error crítico al conectar con SQL Server (verifica credenciales o red): " + e.getMessage());
        }
        return conexion;
    }
}