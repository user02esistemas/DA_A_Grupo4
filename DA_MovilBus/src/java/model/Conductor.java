package model;

public class Conductor {
    private int idConductor;
    private String dni;
    private String nombre;
    private String apellido;
    private String nroLicencia;
    private String estado; // 'DISPONIBLE', 'ASIGNADO', 'LICENCIA'

    public Conductor() {}

    public Conductor(int idConductor, String dni, String nombre, String apellido, String nroLicencia, String estado) {
        this.idConductor = idConductor;
        this.dni = dni;
        this.nombre = nombre;
        this.apellido = apellido;
        this.nroLicencia = nroLicencia;
        this.estado = estado;
    }

    // Getters y Setters
    public int getIdConductor() { return idConductor; }
    public void setIdConductor(int idConductor) { this.idConductor = idConductor; }
    public String getDni() { return dni; }
    public void setDni(String dni) { this.dni = dni; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public String getApellido() { return apellido; }
    public void setApellido(String apellido) { this.apellido = apellido; }
    public String getNroLicencia() { return nroLicencia; }
    public void setNroLicencia(String nroLicencia) { this.nroLicencia = nroLicencia; }
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
}
