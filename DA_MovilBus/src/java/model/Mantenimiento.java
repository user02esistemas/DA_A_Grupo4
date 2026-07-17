package model;

import java.sql.Timestamp;

public class Mantenimiento {
    private int idMantenimiento;
    private int idBus;
    private String placaBus;
    private String tipoMantenimiento; // 'PREVENTIVO', 'CORRECTIVO'
    private Timestamp fechaInicio;
    private Timestamp fechaFin;
    private String descripcion;
    private int kilometrajeActual;
    private double costo;
    private String estado; // 'PROGRAMADO', 'EN_PROCESO', 'COMPLETADO', 'CANCELADO'
    private Timestamp fechaRegistro;

    public Mantenimiento() {}

    public int getIdMantenimiento() { return idMantenimiento; }
    public void setIdMantenimiento(int idMantenimiento) { this.idMantenimiento = idMantenimiento; }

    public int getIdBus() { return idBus; }
    public void setIdBus(int idBus) { this.idBus = idBus; }

    public String getPlacaBus() { return placaBus; }
    public void setPlacaBus(String placaBus) { this.placaBus = placaBus; }

    public String getTipoMantenimiento() { return tipoMantenimiento; }
    public void setTipoMantenimiento(String tipoMantenimiento) { this.tipoMantenimiento = tipoMantenimiento; }

    public Timestamp getFechaInicio() { return fechaInicio; }
    public void setFechaInicio(Timestamp fechaInicio) { this.fechaInicio = fechaInicio; }

    public Timestamp getFechaFin() { return fechaFin; }
    public void setFechaFin(Timestamp fechaFin) { this.fechaFin = fechaFin; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public int getKilometrajeActual() { return kilometrajeActual; }
    public void setKilometrajeActual(int kilometrajeActual) { this.kilometrajeActual = kilometrajeActual; }

    public double getCosto() { return costo; }
    public void setCosto(double costo) { this.costo = costo; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public Timestamp getFechaRegistro() { return fechaRegistro; }
    public void setFechaRegistro(Timestamp fechaRegistro) { this.fechaRegistro = fechaRegistro; }
}
