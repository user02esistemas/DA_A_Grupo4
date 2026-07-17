package model;

import java.sql.Timestamp;

public class PuntosCliente {
    private int idPuntos;
    private int idCliente;
    private String dniCliente;
    private String nombreCliente;
    private int puntosAcumulados;
    private int puntosCanjeados;
    private int puntosDisponibles; // calculado: acumulados - canjeados
    private int idNivelActual;
    private String nombreNivel;
    private String nivelColor;
    private String nivelIcono;
    private double descuentoNivel;
    private Timestamp fechaUltimaActualizacion;

    public PuntosCliente() {}

    public int getIdPuntos() { return idPuntos; }
    public void setIdPuntos(int idPuntos) { this.idPuntos = idPuntos; }

    public int getIdCliente() { return idCliente; }
    public void setIdCliente(int idCliente) { this.idCliente = idCliente; }

    public String getDniCliente() { return dniCliente; }
    public void setDniCliente(String dniCliente) { this.dniCliente = dniCliente; }

    public String getNombreCliente() { return nombreCliente; }
    public void setNombreCliente(String nombreCliente) { this.nombreCliente = nombreCliente; }

    public int getPuntosAcumulados() { return puntosAcumulados; }
    public void setPuntosAcumulados(int puntosAcumulados) { this.puntosAcumulados = puntosAcumulados; }

    public int getPuntosCanjeados() { return puntosCanjeados; }
    public void setPuntosCanjeados(int puntosCanjeados) { this.puntosCanjeados = puntosCanjeados; }

    public int getPuntosDisponibles() { return puntosAcumulados - puntosCanjeados; }
    public void setPuntosDisponibles(int puntosDisponibles) { this.puntosDisponibles = puntosDisponibles; }

    public int getIdNivelActual() { return idNivelActual; }
    public void setIdNivelActual(int idNivelActual) { this.idNivelActual = idNivelActual; }

    public String getNombreNivel() { return nombreNivel; }
    public void setNombreNivel(String nombreNivel) { this.nombreNivel = nombreNivel; }

    public String getNivelColor() { return nivelColor; }
    public void setNivelColor(String nivelColor) { this.nivelColor = nivelColor; }

    public String getNivelIcono() { return nivelIcono; }
    public void setNivelIcono(String nivelIcono) { this.nivelIcono = nivelIcono; }

    public double getDescuentoNivel() { return descuentoNivel; }
    public void setDescuentoNivel(double descuentoNivel) { this.descuentoNivel = descuentoNivel; }

    public Timestamp getFechaUltimaActualizacion() { return fechaUltimaActualizacion; }
    public void setFechaUltimaActualizacion(Timestamp fechaUltimaActualizacion) { this.fechaUltimaActualizacion = fechaUltimaActualizacion; }

    /** Calcula el procentaje de progreso hacia el siguiente nivel */
    public double getProgresoSiguienteNivel() {
        // Por defecto: Bronce 0-199, Plata 200-499, Oro 500-999, Platino 1000+
        if (puntosAcumulados >= 1000) return 100.0;
        if (puntosAcumulados >= 500) return ((puntosAcumulados - 500) / 500.0) * 100;
        if (puntosAcumulados >= 200) return ((puntosAcumulados - 200) / 300.0) * 100;
        return (puntosAcumulados / 200.0) * 100;
    }

    /** Puntos faltantes para el siguiente nivel */
    public int getPuntosFaltantesSiguienteNivel() {
        if (puntosAcumulados >= 1000) return 0;
        if (puntosAcumulados >= 500) return 1000 - puntosAcumulados;
        if (puntosAcumulados >= 200) return 500 - puntosAcumulados;
        return 200 - puntosAcumulados;
    }

    /** Siguiente nivel */
    public String getSiguienteNivel() {
        if (puntosAcumulados >= 1000) return "★ Platino (Máximo)";
        if (puntosAcumulados >= 500) return "🏆 Platino";
        if (puntosAcumulados >= 200) return "🥇 Oro";
        return "🥈 Plata";
    }
}
