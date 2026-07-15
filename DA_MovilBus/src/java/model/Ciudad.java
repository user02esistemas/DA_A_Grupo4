package model;

public class Ciudad {
    private int idCiudad;
    private String nombre;
    private String departamento;
    private String estado;

    public Ciudad() {}

    public Ciudad(int idCiudad, String nombre, String departamento, String estado) {
        this.idCiudad = idCiudad;
        this.nombre = nombre;
        this.departamento = departamento;
        this.estado = estado;
    }

    public Ciudad(String nombre, String departamento, String estado) {
        this.nombre = nombre;
        this.departamento = departamento;
        this.estado = estado;
    }

    public int getIdCiudad() { return idCiudad; }
    public void setIdCiudad(int idCiudad) { this.idCiudad = idCiudad; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public String getDepartamento() { return departamento; }
    public void setDepartamento(String departamento) { this.departamento = departamento; }
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
}
