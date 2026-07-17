package model;

public class NivelFidelidad {
    private int idNivel;
    private String nombreNivel; // BRONCE, PLATA, ORO, PLATINO
    private int puntosDesde;
    private Integer puntosHasta; // null para el último nivel
    private double descuentoPorcentaje;
    private String colorHex;
    private String icono;

    public NivelFidelidad() {}

    public int getIdNivel() { return idNivel; }
    public void setIdNivel(int idNivel) { this.idNivel = idNivel; }

    public String getNombreNivel() { return nombreNivel; }
    public void setNombreNivel(String nombreNivel) { this.nombreNivel = nombreNivel; }

    public int getPuntosDesde() { return puntosDesde; }
    public void setPuntosDesde(int puntosDesde) { this.puntosDesde = puntosDesde; }

    public Integer getPuntosHasta() { return puntosHasta; }
    public void setPuntosHasta(Integer puntosHasta) { this.puntosHasta = puntosHasta; }

    public double getDescuentoPorcentaje() { return descuentoPorcentaje; }
    public void setDescuentoPorcentaje(double descuentoPorcentaje) { this.descuentoPorcentaje = descuentoPorcentaje; }

    public String getColorHex() { return colorHex; }
    public void setColorHex(String colorHex) { this.colorHex = colorHex; }

    public String getIcono() { return icono; }
    public void setIcono(String icono) { this.icono = icono; }
}
