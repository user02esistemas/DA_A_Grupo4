package config;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class ConexionBD {
    
    private static Connection con = null;
    private static final String DRIVER = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
    
    private ConexionBD() {}
    
    public static Connection getConexion() {
        try {
            if (con == null || con.isClosed()) {
                Properties prop = new Properties();
                
                try (InputStream input = ConexionBD.class.getResourceAsStream("/config/database.properties")) {
                    if (input == null) {
                        throw new RuntimeException("No se encontró el archivo 'database.properties' en config/");
                    }
                    
                    prop.load(input);
                    Class.forName(DRIVER);
                    
                    String url = "jdbc:sqlserver://" + prop.getProperty("db.server") + ";"
                            + "databaseName=" + prop.getProperty("db.name") + ";"
                            + "encrypt=true;trustServerCertificate=true;";
                    
                    String usr = prop.getProperty("db.user");
                    String pwd = prop.getProperty("db.password");
                    
                    con = DriverManager.getConnection(url, usr, pwd);
                    System.out.println("[OK] Conexion exitosa a MovilBusDB");
                    
                } catch (IOException e) {
                    throw new RuntimeException("Error al leer el archivo de propiedades", e);
                } catch (ClassNotFoundException e) {
                    throw new RuntimeException("No se encontró el driver JDBC", e);
                }
            }
            return con;
        } catch (SQLException ex) {
            throw new RuntimeException("Error al conectar con SQL Server", ex);
        }
    }
    
    public static void cerrarConexion() {
        try {
            if (con != null && !con.isClosed()) {
                con.close();
                System.out.println("[Info] Conexion cerrada");
            }
        } catch (SQLException e) {
            System.err.println("Error al cerrar la conexion: " + e.getMessage());
        }
    }
}
/*
movilbus
32 2 pisos 12 asientos
1,2,5,4,7,8,11,10 son para la izq primer piso y 3,6,9,12 para la der primer piso cama 160º primer piso y 13,14,17,16,19,18,22,21,22,24,25,27,28,31,30 son parte izq del segundo piso y 15,23,26,29,32 parte der segundo piso todo 180ª

precios
cama160º 115 lado izq primer piso, 121 lado derecho primer piso
180ª 145 lado izq segundo piso, 152 lado der segundo piso


regular 140ª
37 cama 160º y regular 140ª


otro bus de solo 1 piso de 37 asientos este esta masomenos ordenado, va procedual 1,2,3,4,5,6,7,8,9,....37, en el caso hay 2 tipos de asiento 160º y 140º 
160º son los primeros 15 asientos los multiplos de 1,2,4,5,7,8,10,11,13,14 izq precio 115, asientos 3,6,9,12,15 lado derecho precio 121 soles

para la segunda parte del asiento 16 - 37, precio 90, donde son dos filas izq y dos filas derecha, es precedual asi que el orden deria 16,17 izq 18,19 der,20,21 izq,22,23 der, y asi sucesivamente hasta q no hay asientos,

otro bus de 43 asientos

dos esquemos izq y der, izq tiene 2 filas y der solo 1, 


estoy viendo un patron de comportamiento donde cada asiento par esta al lado del pasillo en la parte del la izq, xq procedual seria como izq 29,30 der 31, y vuelve 32 , 33, pero en este caso esta izq 29,30 der 31, regresa izq 33,32


ahora hay otro bus de 60 asientos generales y el primer piso esta repartido en 12 asientos y el segundo piso estan los demas, el diseño de este bus es, primer piso 2 filas lado izq, 1 fila lado der; segundo piso 2 filas izq 2 filas der, y estoy viendo que, en segundo piso, empeiza 13,14 izq; 16,15 der,17,18 izq, donde los numero no pares son del lado de la ventana
*/