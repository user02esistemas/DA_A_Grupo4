package model;

import java.sql.Timestamp;

public class CitaEncomienda {
    private int idCita;
    private int idCliente;       // FK → Cliente (quien agenda)
    private int idOrigen;        // FK → Ciudades
    private int idDestino;       // FK → Ciudades
    private String descripcion;
    private double pesoEstimado;
    private String fechaPreferida; // Date como string (YYYY-MM-DD) desde el form
    private String horaPreferida;  // Hora (HH:mm)
    private String estado;       // 'PENDIENTE', 'CONFIRMADA', 'CANCELADA', 'COMPLETADA'
    private Timestamp fechaRegistro;
    private String observaciones;

    // Campos adicionales para la vista
    private String nombreCliente;
    private String dniCliente;
    private String telefonoCliente;
    private String nombreOrigen;
    private String nombreDestino;

    public CitaEncomienda() {}

    // Getters y Setters
    public int getIdCita() { return idCita; }
    public void setIdCita(int idCita) { this.idCita = idCita; }

    public int getIdCliente() { return idCliente; }
    public void setIdCliente(int idCliente) { this.idCliente = idCliente; }

    public int getIdOrigen() { return idOrigen; }
    public void setIdOrigen(int idOrigen) { this.idOrigen = idOrigen; }

    public int getIdDestino() { return idDestino; }
    public void setIdDestino(int idDestino) { this.idDestino = idDestino; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public double getPesoEstimado() { return pesoEstimado; }
    public void setPesoEstimado(double pesoEstimado) { this.pesoEstimado = pesoEstimado; }

    public String getFechaPreferida() { return fechaPreferida; }
    public void setFechaPreferida(String fechaPreferida) { this.fechaPreferida = fechaPreferida; }

    public String getHoraPreferida() { return horaPreferida; }
    public void setHoraPreferida(String horaPreferida) { this.horaPreferida = horaPreferida; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public Timestamp getFechaRegistro() { return fechaRegistro; }
    public void setFechaRegistro(Timestamp fechaRegistro) { this.fechaRegistro = fechaRegistro; }

    public String getObservaciones() { return observaciones; }
    public void setObservaciones(String observaciones) { this.observaciones = observaciones; }

    // Campos de vista
    public String getNombreCliente() { return nombreCliente; }
    public void setNombreCliente(String nombreCliente) { this.nombreCliente = nombreCliente; }

    public String getDniCliente() { return dniCliente; }
    public void setDniCliente(String dniCliente) { this.dniCliente = dniCliente; }

    public String getTelefonoCliente() { return telefonoCliente; }
    public void setTelefonoCliente(String telefonoCliente) { this.telefonoCliente = telefonoCliente; }

    public String getNombreOrigen() { return nombreOrigen; }
    public void setNombreOrigen(String nombreOrigen) { this.nombreOrigen = nombreOrigen; }

    public String getNombreDestino() { return nombreDestino; }
    public void setNombreDestino(String nombreDestino) { this.nombreDestino = nombreDestino; }
}
