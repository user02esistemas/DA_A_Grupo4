package model;

public class BusAsiento {

    private int idBusAsiento;
    private int idBus;
    private int numeroAsiento;
    private int piso;
    private int fila;
    private int columna;
    private String lado;
    private int idTipoAsiento;

    public BusAsiento() {
    }

    public BusAsiento(
            int idBusAsiento,
            int idBus,
            int numeroAsiento,
            int piso,
            int fila,
            int columna,
            String lado,
            int idTipoAsiento
    ) {
        this.idBusAsiento = idBusAsiento;
        this.idBus = idBus;
        this.numeroAsiento = numeroAsiento;
        this.piso = piso;
        this.fila = fila;
        this.columna = columna;
        this.lado = lado;
        this.idTipoAsiento = idTipoAsiento;
    }

    public BusAsiento(
            int idBus,
            int numeroAsiento,
            int piso,
            int fila,
            int columna,
            String lado,
            int idTipoAsiento
    ) {
        this.idBus = idBus;
        this.numeroAsiento = numeroAsiento;
        this.piso = piso;
        this.fila = fila;
        this.columna = columna;
        this.lado = lado;
        this.idTipoAsiento = idTipoAsiento;
    }

    public int getIdBusAsiento() {
        return idBusAsiento;
    }

    public void setIdBusAsiento(int idBusAsiento) {
        this.idBusAsiento = idBusAsiento;
    }

    public int getIdBus() {
        return idBus;
    }

    public void setIdBus(int idBus) {
        this.idBus = idBus;
    }

    public int getNumeroAsiento() {
        return numeroAsiento;
    }

    public void setNumeroAsiento(int numeroAsiento) {
        this.numeroAsiento = numeroAsiento;
    }

    public int getPiso() {
        return piso;
    }

    public void setPiso(int piso) {
        this.piso = piso;
    }

    public int getFila() {
        return fila;
    }

    public void setFila(int fila) {
        this.fila = fila;
    }

    public int getColumna() {
        return columna;
    }

    public void setColumna(int columna) {
        this.columna = columna;
    }

    public String getLado() {
        return lado;
    }

    public void setLado(String lado) {
        this.lado = lado;
    }

    public int getIdTipoAsiento() {
        return idTipoAsiento;
    }

    public void setIdTipoAsiento(int idTipoAsiento) {
        this.idTipoAsiento = idTipoAsiento;
    }
}