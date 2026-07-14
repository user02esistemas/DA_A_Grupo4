package model;

import java.time.LocalDateTime;

public class Viaje {

    private int idViaje;
    private LocalDateTime fechaHoraSalida;
    private LocalDateTime fechaHoraLlegadaEst;
    private String estado;
    private int idBus;
    private int idRuta;

    public Viaje() {
    }

    public Viaje(
            int idViaje,
            LocalDateTime fechaHoraSalida,
            LocalDateTime fechaHoraLlegadaEst,
            String estado,
            int idBus,
            int idRuta
    ) {
        this.idViaje = idViaje;
        this.fechaHoraSalida = fechaHoraSalida;
        this.fechaHoraLlegadaEst = fechaHoraLlegadaEst;
        this.estado = estado;
        this.idBus = idBus;
        this.idRuta = idRuta;
    }

    public Viaje(
            LocalDateTime fechaHoraSalida,
            LocalDateTime fechaHoraLlegadaEst,
            String estado,
            int idBus,
            int idRuta
    ) {
        this.fechaHoraSalida = fechaHoraSalida;
        this.fechaHoraLlegadaEst = fechaHoraLlegadaEst;
        this.estado = estado;
        this.idBus = idBus;
        this.idRuta = idRuta;
    }

    public int getIdViaje() {
        return idViaje;
    }

    public void setIdViaje(int idViaje) {
        this.idViaje = idViaje;
    }

    public LocalDateTime getFechaHoraSalida() {
        return fechaHoraSalida;
    }

    public void setFechaHoraSalida(
            LocalDateTime fechaHoraSalida
    ) {
        this.fechaHoraSalida = fechaHoraSalida;
    }

    public LocalDateTime getFechaHoraLlegadaEst() {
        return fechaHoraLlegadaEst;
    }

    public void setFechaHoraLlegadaEst(
            LocalDateTime fechaHoraLlegadaEst
    ) {
        this.fechaHoraLlegadaEst = fechaHoraLlegadaEst;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public int getIdBus() {
        return idBus;
    }

    public void setIdBus(int idBus) {
        this.idBus = idBus;
    }

    public int getIdRuta() {
        return idRuta;
    }

    public void setIdRuta(int idRuta) {
        this.idRuta = idRuta;
    }
}