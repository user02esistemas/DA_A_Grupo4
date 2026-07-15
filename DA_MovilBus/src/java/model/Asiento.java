package model;

public class Asiento {
    private int idBusAsiento; // NUEVO: Mapeo de la PK id_bus_asiento
    private int idBus;        // NUEVO: Bus al que pertenece
    private int numeroAsiento;
    private int piso;
    private int fila;         // NUEVO: Fila física en el bus
    private int columna;      // NUEVO: Columna física en el bus (1 a 4)
    private String posicion;  // "IZQ_VENTANA", "IZQ_PASILLO", etc.
    private String tipoAsiento; // "Semi Cama 140°", "Cama Vip 160°", "Full Flat 180°"
    private double precio;
    private double recargoUbicacion; // NUEVO: Ej. S/ 7.00 extra por fila solitaria
    private boolean ocupado;

    // Constructor vacío
    public Asiento() {}

    // Constructor lleno (Actualizado para el nuevo esquema)
    public Asiento(int idBusAsiento, int idBus, int numeroAsiento, int piso, int fila, int columna, String posicion, String tipoAsiento, double precio, double recargoUbicacion, boolean ocupado) {
        this.idBusAsiento = idBusAsiento;
        this.idBus = idBus;
        this.numeroAsiento = numeroAsiento;
        this.piso = piso;
        this.fila = fila;
        this.columna = columna;
        this.posicion = posicion;
        this.tipoAsiento = tipoAsiento;
        this.precio = precio;
        this.recargoUbicacion = recargoUbicacion;
        this.ocupado = ocupado;
    }
    public Asiento(int numeroAsiento, int piso, String posicion, String tipoAsiento, double precio, boolean ocupado) {
        this.numeroAsiento = numeroAsiento;
        this.piso = piso;
        this.posicion = posicion;
        this.tipoAsiento = tipoAsiento;
        this.precio = precio;
        this.ocupado = ocupado;

        // Inicializamos por defecto los campos de base de datos que no se calculan en el croquis básico
        this.idBusAsiento = 0;
        this.idBus = 0;
        this.fila = 0;
        this.columna = 0;
        this.recargoUbicacion = 0.0;
    }
    

    // Getters y Setters
    public int getIdBusAsiento() { return idBusAsiento; }
    public void setIdBusAsiento(int idBusAsiento) { this.idBusAsiento = idBusAsiento; }

    public int getIdBus() { return idBus; }
    public void setIdBus(int idBus) { this.idBus = idBus; }

    public int getNumeroAsiento() { return numeroAsiento; }
    public void setNumeroAsiento(int numeroAsiento) { this.numeroAsiento = numeroAsiento; }

    public int getPiso() { return piso; }
    public void setPiso(int piso) { this.piso = piso; }

    public int getFila() { return fila; }
    public void setFila(int fila) { this.fila = fila; }

    public int getColumna() { return columna; }
    public void setColumna(int columna) { this.columna = columna; }

    public String getPosicion() { return posicion; }
    public void setPosicion(String posicion) { this.posicion = posicion; }

    public String getTipoAsiento() { return tipoAsiento; }
    public void setTipoAsiento(String tipoAsiento) { this.tipoAsiento = tipoAsiento; }

    public double getPrecio() { return precio; }
    public void setPrecio(double precio) { this.precio = precio; }

    public double getRecargoUbicacion() { return recargoUbicacion; }
    public void setRecargoUbicacion(double recargoUbicacion) { this.recargoUbicacion = recargoUbicacion; }

    public boolean isEstadoOcupado() { return ocupado; }
    public void setOcupado(boolean ocupado) { this.ocupado = ocupado; }
}