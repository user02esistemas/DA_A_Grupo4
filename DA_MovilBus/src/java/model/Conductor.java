/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

public class Conductor {

    private int idConductor;
    private String nombre;
    private String apellido;
    private String dni;
    private String licencia;
    private String estado;
    private Integer idUsuario;


    public Conductor() {
    }


    public Conductor(int idConductor, String nombre,
                     String apellido, String dni,
                     String licencia, String estado,
                     Integer idUsuario) {

        this.idConductor = idConductor;
        this.nombre = nombre;
        this.apellido = apellido;
        this.dni = dni;
        this.licencia = licencia;
        this.estado = estado;
        this.idUsuario = idUsuario;
    }


    public int getIdConductor() {
        return idConductor;
    }

    public void setIdConductor(int idConductor) {
        this.idConductor = idConductor;
    }


    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }


    public String getApellido() {
        return apellido;
    }

    public void setApellido(String apellido) {
        this.apellido = apellido;
    }


    public String getDni() {
        return dni;
    }

    public void setDni(String dni) {
        this.dni = dni;
    }


    public String getLicencia() {
        return licencia;
    }

    public void setLicencia(String licencia) {
        this.licencia = licencia;
    }


    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }


    public Integer getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(Integer idUsuario) {
        this.idUsuario = idUsuario;
    }
}