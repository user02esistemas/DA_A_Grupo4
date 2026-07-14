/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package DAO;

import conexion.ConexionBD;
import model.Usuario;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class UsuarioDAO {

    public Usuario validarLogin(String username, String password) {

        Usuario usuario = null;

        String sql
                = "SELECT id_usuario, username, password_hash, id_rol "
                + "FROM Usuarios "
                + "WHERE username=? AND password_hash=?";

        try {

            Connection cn = ConexionBD
                    .getInstancia()
                    .getConexion();

            PreparedStatement ps = cn.prepareStatement(sql);

            ps.setString(1, username);
            ps.setString(2, password);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                usuario = new Usuario();

                usuario.setIdUsuario(
                        rs.getInt("id_usuario")
                );

                usuario.setUsername(
                        rs.getString("username")
                );

                usuario.setPasswordHash(
                        rs.getString("password_hash")
                );

                usuario.setIdRol(
                        rs.getInt("id_rol")
                );

            }

        } catch (Exception e) {

            System.out.println(
                    "Error al validar usuario: "
                    + e.getMessage()
            );

        }

        return usuario;

    }

}
