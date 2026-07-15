package util;

import java.util.ArrayList;
import java.util.List;

/**
 * Genera plantillas de asientos según servicio, capacidad y pisos de MovilBus.
 * Patrón 3 columnas (2 izq + 1 der solitaria con recargo):
 *   Fila par:    1  2 | 3
 *   Fila impar:  5  4 | 6
 */
public class AsientoLayoutUtil {

    public static class PlantillaAsiento {
        public int numeroAsiento;
        public int piso;
        public int fila;
        public int columna;
        public int idTipoAsiento;
        public String posicion;
        public double recargoUbicacion;

        public PlantillaAsiento(int numero, int piso, int fila, int columna,
                                int idTipo, String posicion, double recargo) {
            this.numeroAsiento = numero;
            this.piso = piso;
            this.fila = fila;
            this.columna = columna;
            this.idTipoAsiento = idTipo;
            this.posicion = posicion;
            this.recargoUbicacion = recargo;
        }
    }

    public static List<PlantillaAsiento> generarPlantilla(int idServicio, int capacidad, int pisos) {
        List<PlantillaAsiento> lista = new ArrayList<>();

        if (idServicio == 3 && capacidad == 32 && pisos == 2) {
            // PREMIER 32: P1=12 (160°), P2=20 (180°)
            llenarPiso3Columnas(lista, 1, 12, 2, 7.00, 1);
            llenarPiso3Columnas(lista, 2, 20, 3, 7.00, 13);
        } else if (idServicio == 2 && capacidad == 43 && pisos == 2) {
            // PRESIDENCIAL 43: P1=15 (160°), P2=28 (180°)
            llenarPiso3Columnas(lista, 1, 15, 2, 7.00, 1);
            llenarPiso3Columnas(lista, 2, 28, 3, 7.00, 16);
        } else if (idServicio == 2 && capacidad == 43 && pisos == 1) {
            llenarPiso3Columnas(lista, 1, 43, 2, 7.00, 1);
        } else if (idServicio == 1 && capacidad == 37 && pisos == 1) {
            // EJECUTIVO VIP 37: 15 VIP 160° + 22 Regular 140°, 4 columnas
            llenarPiso4Columnas(lista, 1, 37, 1, 15, 2, 1);
        } else if (idServicio == 1 && capacidad == 60 && pisos == 2) {
            // EJECUTIVO VIP 60: P1=12 (3 cols, 160°), P2=48 (4 cols, 140°)
            llenarPiso3Columnas(lista, 1, 12, 2, 0.00, 1);
            llenarPiso4Columnas(lista, 2, 48, 1, 48, 1, 13);
        } else if (idServicio == 1 && capacidad == 32 && pisos == 1) {
            llenarPiso4Columnas(lista, 1, 32, 1, 8, 2, 1);
        } else if (idServicio == 1 && capacidad == 32 && pisos == 2) {
            // EJECUTIVO VIP 32/2: P1=12 (4 cols, Cama Vip 160°), P2=20 (4 cols, Regular 140°)
            llenarPiso4Columnas(lista, 1, 12, 2, 12, 2, 1);
            llenarPiso4Columnas(lista, 2, 20, 1, 20, 1, 13);
        } else if (pisos == 1 && (idServicio == 2 || idServicio == 3)) {
            llenarPiso3Columnas(lista, 1, capacidad, idServicio == 2 ? 2 : 2, 7.00, 1);
        } else if (pisos == 2 && (idServicio == 2 || idServicio == 3)) {
            int piso1 = capacidad / 3;
            int piso2 = capacidad - piso1;
            llenarPiso3Columnas(lista, 1, piso1, 2, 7.00, 1);
            llenarPiso3Columnas(lista, 2, piso2, 3, 7.00, piso1 + 1);
        } else {
            llenarPiso4Columnas(lista, 1, capacidad, 1, capacidad, 1, 1);
        }

        return lista;
    }

    /** Retorna 3 para Presidencial/Premier o pisos con 3 cols; 4 para Ejecutivo VIP estándar */
    public static int obtenerColumnasGrid(String nombreServicio, int capacidad, int pisos) {
        if ("EJECUTIVO VIP".equalsIgnoreCase(nombreServicio)) {
            if ((capacidad == 60 || capacidad == 32) && pisos == 2) return 4; // piso 2 usa 4 cols
            return 4;
        }
        return 3;
    }

    public static int obtenerColumnasGridPiso(String nombreServicio, int capacidad, int pisos, int piso) {
        if ("EJECUTIVO VIP".equalsIgnoreCase(nombreServicio)) {
            if (capacidad == 60 && pisos == 2 && piso == 1) return 3;
            if (capacidad == 32 && pisos == 2 && piso == 1) return 4; // 32/2: P1 también usa 4 cols
            return 4;
        }
        return 3;
    }

    private static void llenarPiso3Columnas(List<PlantillaAsiento> lista, int piso, int cantidad,
                                            int idTipo, double recargoSolo, int numeroInicio) {
        int current = numeroInicio;
        int fila = 1;
        int colocados = 0;

        while (colocados < cantidad) {
            int n1, n2, n3;
            if ((fila - 1) % 2 == 0) {
                n1 = current;
                n2 = current + 1;
                n3 = current + 2;
            } else {
                n1 = current + 1;
                n2 = current;
                n3 = current + 2;
            }

            if (colocados < cantidad) {
                lista.add(new PlantillaAsiento(n1, piso, fila, 1, idTipo, "IZQ_VENTANA", 0.00));
                colocados++;
            }
            if (colocados < cantidad) {
                lista.add(new PlantillaAsiento(n2, piso, fila, 2, idTipo, "IZQ_PASILLO", 0.00));
                colocados++;
            }
            if (colocados < cantidad) {
                lista.add(new PlantillaAsiento(n3, piso, fila, 3, idTipo, "DER_VENTANA", recargoSolo));
                colocados++;
            }

            current += 3;
            fila++;
        }
    }

    private static void llenarPiso4Columnas(List<PlantillaAsiento> lista, int piso, int cantidad,
                                            int idTipoDefault, int cantidadTipoPremium, int idTipoPremium,
                                            int numeroInicio) {
        int numero = numeroInicio;
        int fila = 1;
        int col = 1;

        for (int i = 0; i < cantidad; i++) {
            int idTipo = (numero - numeroInicio < cantidadTipoPremium) ? idTipoPremium : idTipoDefault;
            String pos = (col == 1 || col == 4) ? "VENTANA" : "PASILLO";
            lista.add(new PlantillaAsiento(numero, piso, fila, col, idTipo, pos, 0.00));
            numero++;
            col++;
            if (col > 4) {
                col = 1;
                fila++;
            }
        }
    }
}
