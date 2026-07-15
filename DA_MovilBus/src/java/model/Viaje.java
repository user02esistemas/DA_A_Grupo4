package model;

import java.sql.Timestamp;

public class Viaje {
    private int idViaje;
    private int idRuta;
    private int idBus;
    private Timestamp fechaHora; // Fecha y Hora de Salida
    private Timestamp fechaHoraLlegadaEstimada; // NUEVO: Fecha y hora de llegada estimada
    private String estado; // 'PROGRAMADO', 'EN_RUTA', 'FINALIZADO', 'CANCELADO'

    public Viaje() {}

    // Constructor sin ID (Ideal para inserciones)
    public Viaje(int idRuta, int idBus, Timestamp fechaHora, Timestamp fechaHoraLlegadaEstimada, String estado) {
        this.idRuta = idRuta;
        this.idBus = idBus;
        this.fechaHora = fechaHora;
        this.fechaHoraLlegadaEstimada = fechaHoraLlegadaEstimada;
        this.estado = estado;
    }

    // Constructor completo para consultas
    public Viaje(int idViaje, int idRuta, int idBus, Timestamp fechaHora, Timestamp fechaHoraLlegadaEstimada, String estado) {
        this.idViaje = idViaje;
        this.idRuta = idRuta;
        this.idBus = idBus;
        this.fechaHora = fechaHora;
        this.fechaHoraLlegadaEstimada = fechaHoraLlegadaEstimada;
        this.estado = estado;
    }

    // Getters y Setters
    public int getIdViaje() { return idViaje; }
    public void setIdViaje(int idViaje) { this.idViaje = idViaje; }

    public int getIdRuta() { return idRuta; }
    public void setIdRuta(int idRuta) { this.idRuta = idRuta; }

    public int getIdBus() { return idBus; }
    public void setIdBus(int idBus) { this.idBus = idBus; }

    public Timestamp getFechaHora() { return fechaHora; }
    public void setFechaHora(Timestamp fechaHora) { this.fechaHora = fechaHora; }

    public Timestamp getFechaHoraLlegadaEstimada() { return fechaHoraLlegadaEstimada; }
    public void setFechaHoraLlegadaEstimada(Timestamp fechaHoraLlegadaEstimada) { this.fechaHoraLlegadaEstimada = fechaHoraLlegadaEstimada; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
}