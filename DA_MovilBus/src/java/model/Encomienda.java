package model;

import java.sql.Timestamp;public class Encomienda {
    private int idEncomienda;
    private String descripcionContenido;
    private double pesoKg;
    private double precioEnvio;
    private String estado; // 'REGISTRADO', 'EN VIAJE', 'ENTREGADO', 'ANULADO'
    private Timestamp fechaEnvio;
    private Timestamp fechaEntregaReal;
    
    // Relaciones
    private int idViaje;
    private int idRemitente;
    private int idDestinatario;
    
    // Datos adicionales (para mostrar en vistas)
    private String origen;
    private String destino;
    private String fechaHoraSalida;
    private String placaBus;
    private String nombreRemitente;
    private String dniRemitente;
    private String nombreDestinatario;
    private String dniDestinatario;

    public Encomienda() {}

    // Constructor completo para inserción
    public Encomienda(String descripcionContenido, double pesoKg, double precioEnvio, 
                      int idViaje, int idRemitente, int idDestinatario) {
        this.descripcionContenido = descripcionContenido;
        this.pesoKg = pesoKg;
        this.precioEnvio = precioEnvio;
        this.estado = "REGISTRADO";
        this.idViaje = idViaje;
        this.idRemitente = idRemitente;
        this.idDestinatario = idDestinatario;
    }

    // Getters y Setters
    public int getIdEncomienda() { return idEncomienda; }
    public void setIdEncomienda(int idEncomienda) { this.idEncomienda = idEncomienda; }

    public String getDescripcionContenido() { return descripcionContenido; }
    public void setDescripcionContenido(String descripcionContenido) { this.descripcionContenido = descripcionContenido; }

    public double getPesoKg() { return pesoKg; }
    public void setPesoKg(double pesoKg) { this.pesoKg = pesoKg; }

    public double getPrecioEnvio() { return precioEnvio; }
    public void setPrecioEnvio(double precioEnvio) { this.precioEnvio = precioEnvio; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public Timestamp getFechaEnvio() { return fechaEnvio; }
    public void setFechaEnvio(Timestamp fechaEnvio) { this.fechaEnvio = fechaEnvio; }

    public Timestamp getFechaEntregaReal() { return fechaEntregaReal; }
    public void setFechaEntregaReal(Timestamp fechaEntregaReal) { this.fechaEntregaReal = fechaEntregaReal; }

    public int getIdViaje() { return idViaje; }
    public void setIdViaje(int idViaje) { this.idViaje = idViaje; }

    public int getIdRemitente() { return idRemitente; }
    public void setIdRemitente(int idRemitente) { this.idRemitente = idRemitente; }

    public int getIdDestinatario() { return idDestinatario; }
    public void setIdDestinatario(int idDestinatario) { this.idDestinatario = idDestinatario; }

    // Getters y Setters para datos adicionales de la vista
    public String getOrigen() { return origen; }
    public void setOrigen(String origen) { this.origen = origen; }

    public String getDestino() { return destino; }
    public void setDestino(String destino) { this.destino = destino; }

    public String getFechaHoraSalida() { return fechaHoraSalida; }
    public void setFechaHoraSalida(String fechaHoraSalida) { this.fechaHoraSalida = fechaHoraSalida; }

    public String getPlacaBus() { return placaBus; }
    public void setPlacaBus(String placaBus) { this.placaBus = placaBus; }

    public String getNombreRemitente() { return nombreRemitente; }
    public void setNombreRemitente(String nombreRemitente) { this.nombreRemitente = nombreRemitente; }

    public String getDniRemitente() { return dniRemitente; }
    public void setDniRemitente(String dniRemitente) { this.dniRemitente = dniRemitente; }

    public String getNombreDestinatario() { return nombreDestinatario; }
    public void setNombreDestinatario(String nombreDestinatario) { this.nombreDestinatario = nombreDestinatario; }

    public String getDniDestinatario() { return dniDestinatario; }
    public void setDniDestinatario(String dniDestinatario) { this.dniDestinatario = dniDestinatario; }
}
