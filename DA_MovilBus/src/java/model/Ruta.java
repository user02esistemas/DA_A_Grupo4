/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

public class Ruta {

    private int idRuta;
    private int idOrigen;
    private int idDestino;
    private double duracionHoras;
    private double precioBase;


    public Ruta() {
    }


    public Ruta(int idRuta, int idOrigen,
                int idDestino, double duracionHoras,
                double precioBase) {

        this.idRuta = idRuta;
        this.idOrigen = idOrigen;
        this.idDestino = idDestino;
        this.duracionHoras = duracionHoras;
        this.precioBase = precioBase;
    }


    public int getIdRuta() {
        return idRuta;
    }

    public void setIdRuta(int idRuta) {
        this.idRuta = idRuta;
    }


    public int getIdOrigen() {
        return idOrigen;
    }

    public void setIdOrigen(int idOrigen) {
        this.idOrigen = idOrigen;
    }


    public int getIdDestino() {
        return idDestino;
    }

    public void setIdDestino(int idDestino) {
        this.idDestino = idDestino;
    }


    public double getDuracionHoras() {
        return duracionHoras;
    }

    public void setDuracionHoras(double duracionHoras) {
        this.duracionHoras = duracionHoras;
    }


    public double getPrecioBase() {
        return precioBase;
    }

    public void setPrecioBase(double precioBase) {
        this.precioBase = precioBase;
    }
}