/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package DAO;

import conexion.ConexionBD;
import model.Conductor;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

public class ConductorDAO {

    // LISTAR CONDUCTORES
    public ArrayList<Conductor> listarConductores() {

        ArrayList<Conductor> lista = new ArrayList<>();

        String sql
                = "SELECT id_conductor, nombre, apellido, dni, "
                + "licencia, estado, id_usuario "
                + "FROM Conductores";

        try {

            Connection cn = ConexionBD
                    .getInstancia()
                    .getConexion();

            PreparedStatement ps = cn.prepareStatement(sql);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                Conductor conductor = new Conductor();

                conductor.setIdConductor(
                        rs.getInt("id_conductor")
                );

                conductor.setNombre(
                        rs.getString("nombre")
                );

                conductor.setApellido(
                        rs.getString("apellido")
                );

                conductor.setDni(
                        rs.getString("dni")
                );

                conductor.setLicencia(
                        rs.getString("licencia")
                );

                conductor.setEstado(
                        rs.getString("estado")
                );

                conductor.setIdUsuario(
                        rs.getObject("id_usuario", Integer.class)
                );

                lista.add(conductor);

            }

        } catch (Exception e) {

            System.out.println(
                    "Error al listar conductores: "
                    + e.getMessage()
            );

        }

        return lista;

    }

    // INSERTAR CONDUCTOR
    public boolean insertarConductor(Conductor conductor) {

        String sql
                = "INSERT INTO Conductores "
                + "(nombre, apellido, dni, licencia, estado, id_usuario) "
                + "VALUES (?, ?, ?, ?, ?, ?)";

        try {

            Connection cn = ConexionBD
                    .getInstancia()
                    .getConexion();

            PreparedStatement ps
                    = cn.prepareStatement(sql);

            ps.setString(1, conductor.getNombre());

            ps.setString(2, conductor.getApellido());

            ps.setString(3, conductor.getDni());

            ps.setString(4, conductor.getLicencia());

            ps.setString(5, conductor.getEstado());

            if (conductor.getIdUsuario() != null) {

                ps.setInt(6, conductor.getIdUsuario());

            } else {

                ps.setNull(6, java.sql.Types.INTEGER);

            }

            ps.executeUpdate();

            return true;

        } catch (Exception e) {

            System.out.println(
                    "Error al insertar conductor: "
                    + e.getMessage()
            );

            return false;

        }

    }

    // ACTUALIZAR DISPONIBILIDAD
    public boolean actualizarEstado(int idConductor, String estado) {

        String sql
                = "UPDATE Conductores "
                + "SET estado=? "
                + "WHERE id_conductor=?";

        try {

            Connection cn
                    = ConexionBD
                            .getInstancia()
                            .getConexion();

            PreparedStatement ps
                    = cn.prepareStatement(sql);

            ps.setString(1, estado);

            ps.setInt(2, idConductor);

            ps.executeUpdate();

            return true;

        } catch (Exception e) {

            System.out.println(
                    "Error al actualizar estado: "
                    + e.getMessage()
            );

            return false;

        }

    }

}
