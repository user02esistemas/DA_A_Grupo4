/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author Risco
 */
public class Ruta {
    private int idRuta;
    private String origen;
    private String destino;
    private double precioBase;

    public Ruta() {}
    public Ruta(int idRuta, String origen, String destino, double precioBase) {
        this.idRuta = idRuta;
        this.origen = origen;
        this.destino = destino;
        this.precioBase = precioBase;
    }

    // Getters y Setters
    public int getIdRuta() { return idRuta; }
    public void setIdRuta(int idRuta) { this.idRuta = idRuta; }
    public String getOrigen() { return origen; }
    public void setOrigen(String origen) { this.origen = origen; }
    public String getDestino() { return destino; }
    public void setDestino(String destino) { this.destino = destino; }
    public double getPrecioBase() { return precioBase; }
    public void setPrecioBase(double precioBase) { this.precioBase = precioBase; }
}
