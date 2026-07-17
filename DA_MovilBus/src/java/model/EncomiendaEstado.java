package model;

import java.sql.Timestamp;

public class EncomiendaEstado {
    private int idEstado;
    private int idEncomienda;
    private String estadoAnterior;
    private String estadoNuevo;
    private Timestamp fechaCambio;
    private String usuarioCambio;
    private String observacion;

    public EncomiendaEstado() {}

    public EncomiendaEstado(int idEncomienda, String estadoAnterior, String estadoNuevo, 
                            String usuarioCambio, String observacion) {
        this.idEncomienda = idEncomienda;
        this.estadoAnterior = estadoAnterior;
        this.estadoNuevo = estadoNuevo;
        this.usuarioCambio = usuarioCambio;
        this.observacion = observacion;
    }

    public int getIdEstado() { return idEstado; }
    public void setIdEstado(int idEstado) { this.idEstado = idEstado; }

    public int getIdEncomienda() { return idEncomienda; }
    public void setIdEncomienda(int idEncomienda) { this.idEncomienda = idEncomienda; }

    public String getEstadoAnterior() { return estadoAnterior; }
    public void setEstadoAnterior(String estadoAnterior) { this.estadoAnterior = estadoAnterior; }

    public String getEstadoNuevo() { return estadoNuevo; }
    public void setEstadoNuevo(String estadoNuevo) { this.estadoNuevo = estadoNuevo; }

    public Timestamp getFechaCambio() { return fechaCambio; }
    public void setFechaCambio(Timestamp fechaCambio) { this.fechaCambio = fechaCambio; }

    public String getUsuarioCambio() { return usuarioCambio; }
    public void setUsuarioCambio(String usuarioCambio) { this.usuarioCambio = usuarioCambio; }

    public String getObservacion() { return observacion; }
    public void setObservacion(String observacion) { this.observacion = observacion; }
}
