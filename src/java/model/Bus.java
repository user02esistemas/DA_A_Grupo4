package model;

public class Bus {
    private int idBus;
    private String placa;
    private String marca;
    private String modelo;
    private int capacidadAsientos;
    private int cantidadPisos;
    private String estado; // 'ACTIVO', 'MANTENIMIENTO', 'INACTIVO'
    private int idServicio; // NUEVO: Relación con la tabla Servicio
    private String nombreServicio; // NUEVO: Para guardar el nombre legible del servicio (ej. 'PREMIER')

    // Constructor vacío (JavaBean)
    public Bus() {
    }

    // Constructor completo para listar u obtener datos (Actualizado con Servicio)
    public Bus(int idBus, String placa, String marca, String modelo, int capacidadAsientos, int cantidadPisos, String estado, int idServicio, String nombreServicio) {
        this.idBus = idBus;
        this.placa = placa;
        this.marca = marca;
        this.modelo = modelo;
        this.capacidadAsientos = capacidadAsientos;
        this.cantidadPisos = cantidadPisos;
        this.estado = estado;
        this.idServicio = idServicio;
        this.nombreServicio = nombreServicio;
    }

    // Constructor sin ID (Para inserciones en BD - Actualizado con idServicio)
    public Bus(String placa, String marca, String modelo, int capacidadAsientos, int cantidadPisos, String estado, int idServicio) {
        this.placa = placa;
        this.marca = marca;
        this.modelo = modelo;
        this.capacidadAsientos = capacidadAsientos;
        this.cantidadPisos = cantidadPisos;
        this.estado = estado;
        this.idServicio = idServicio;
    }

    // Métodos Getters y Setters
    public int getIdBus() { return idBus; }
    public void setIdBus(int idBus) { this.idBus = idBus; }

    public String getPlaca() { return placa; }
    public void setPlaca(String placa) { this.placa = placa; }

    public String getMarca() { return marca; }
    public void setMarca(String marca) { this.marca = marca; }

    public String getModelo() { return modelo; }
    public void setModelo(String modelo) { this.modelo = modelo; }

    public int getCapacidadAsientos() { return capacidadAsientos; }
    public void setCapacidadAsientos(int capacidadAsientos) { this.capacidadAsientos = capacidadAsientos; }

    public int getCantidadPisos() { return cantidadPisos; }
    public void setCantidadPisos(int cantidadPisos) { this.cantidadPisos = cantidadPisos; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public int getIdServicio() { return idServicio; }
    public void setIdServicio(int idServicio) { this.idServicio = idServicio; }

    public String getNombreServicio() { return nombreServicio; }
    public void setNombreServicio(String nombreServicio) { this.nombreServicio = nombreServicio; }
}