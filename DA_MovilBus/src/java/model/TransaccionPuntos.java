package model;

import java.sql.Timestamp;

public class TransaccionPuntos {
    private int idTransaccion;
    private int idCliente;
    private Integer idPasaje; // nullable, asociado a una compra
    private String tipo; // 'ACUMULACION', 'CANJE'
    private int puntos;
    private double montoReferencia;
    private String descripcion;
    private Timestamp fecha;

    public TransaccionPuntos() {}

    public int getIdTransaccion() { return idTransaccion; }
    public void setIdTransaccion(int idTransaccion) { this.idTransaccion = idTransaccion; }

    public int getIdCliente() { return idCliente; }
    public void setIdCliente(int idCliente) { this.idCliente = idCliente; }

    public Integer getIdPasaje() { return idPasaje; }
    public void setIdPasaje(Integer idPasaje) { this.idPasaje = idPasaje; }

    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }

    public int getPuntos() { return puntos; }
    public void setPuntos(int puntos) { this.puntos = puntos; }

    public double getMontoReferencia() { return montoReferencia; }
    public void setMontoReferencia(double montoReferencia) { this.montoReferencia = montoReferencia; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public Timestamp getFecha() { return fecha; }
    public void setFecha(Timestamp fecha) { this.fecha = fecha; }
}
