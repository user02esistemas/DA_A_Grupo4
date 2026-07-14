package model;

public class ViajeConductor {

    private int idViajeConductor;
    private int idViaje;
    private int idConductor;
    private String rolEnViaje;

    public ViajeConductor() {
    }

    public ViajeConductor(
            int idViajeConductor,
            int idViaje,
            int idConductor,
            String rolEnViaje
    ) {
        this.idViajeConductor = idViajeConductor;
        this.idViaje = idViaje;
        this.idConductor = idConductor;
        this.rolEnViaje = rolEnViaje;
    }

    public ViajeConductor(
            int idConductor,
            String rolEnViaje
    ) {
        this.idConductor = idConductor;
        this.rolEnViaje = rolEnViaje;
    }

    public int getIdViajeConductor() {
        return idViajeConductor;
    }

    public void setIdViajeConductor(
            int idViajeConductor
    ) {
        this.idViajeConductor = idViajeConductor;
    }

    public int getIdViaje() {
        return idViaje;
    }

    public void setIdViaje(int idViaje) {
        this.idViaje = idViaje;
    }

    public int getIdConductor() {
        return idConductor;
    }

    public void setIdConductor(int idConductor) {
        this.idConductor = idConductor;
    }

    public String getRolEnViaje() {
        return rolEnViaje;
    }

    public void setRolEnViaje(String rolEnViaje) {
        this.rolEnViaje = rolEnViaje;
    }
}