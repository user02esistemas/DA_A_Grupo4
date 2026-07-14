/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package DAO;

import conexion.ConexionBD;
import model.Bus;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

public class BusDAO {

    // LISTAR BUSES
    public ArrayList<Bus> listarBuses() {

        ArrayList<Bus> lista = new ArrayList<>();

        String sql
                = "SELECT id_bus, placa, modelo, capacidad, anio, estado "
                + "FROM Bus";

        try {

            Connection cn = ConexionBD
                    .getInstancia()
                    .getConexion();

            PreparedStatement ps = cn.prepareStatement(sql);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                Bus bus = new Bus();

                bus.setIdBus(
                        rs.getInt("id_bus")
                );

                bus.setPlaca(
                        rs.getString("placa")
                );

                bus.setModelo(
                        rs.getString("modelo")
                );

                bus.setCapacidad(
                        rs.getInt("capacidad")
                );

                bus.setAnio(
                        rs.getInt("anio")
                );

                bus.setEstado(
                        rs.getString("estado")
                );

                lista.add(bus);

            }

        } catch (Exception e) {

            System.out.println(
                    "Error al listar buses: "
                    + e.getMessage()
            );

        }

        return lista;

    }

    // INSERTAR BUS
    public boolean insertarBus(Bus bus) {

        String sql
                = "INSERT INTO Bus "
                + "(placa, modelo, capacidad, anio, estado) "
                + "VALUES (?, ?, ?, ?, ?)";

        try {

            Connection cn = ConexionBD
                    .getInstancia()
                    .getConexion();

            PreparedStatement ps = cn.prepareStatement(sql);

            ps.setString(1, bus.getPlaca());

            ps.setString(2, bus.getModelo());

            ps.setInt(3, bus.getCapacidad());

            ps.setInt(4, bus.getAnio());

            ps.setString(5, bus.getEstado());

            ps.executeUpdate();

            return true;

        } catch (Exception e) {

            System.out.println(
                    "Error al insertar bus: "
                    + e.getMessage()
            );

            return false;

        }

    }

    // ACTUALIZAR BUS
    public boolean actualizarBus(Bus bus) {

        String sql
                = "UPDATE Bus SET "
                + "placa=?, "
                + "modelo=?, "
                + "capacidad=?, "
                + "anio=?, "
                + "estado=? "
                + "WHERE id_bus=?";

        try {

            Connection cn = ConexionBD
                    .getInstancia()
                    .getConexion();

            PreparedStatement ps = cn.prepareStatement(sql);

            ps.setString(1, bus.getPlaca());

            ps.setString(2, bus.getModelo());

            ps.setInt(3, bus.getCapacidad());

            ps.setInt(4, bus.getAnio());

            ps.setString(5, bus.getEstado());

            ps.setInt(6, bus.getIdBus());

            ps.executeUpdate();

            return true;

        } catch (Exception e) {

            System.out.println(
                    "Error al actualizar bus: "
                    + e.getMessage()
            );

            return false;

        }

    }

}
