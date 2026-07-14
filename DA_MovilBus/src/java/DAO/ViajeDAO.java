package DAO;

import conexion.ConexionBD;
import model.Viaje;
import model.ViajeConductor;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.List;

public class ViajeDAO {

    /**
     * Registra el viaje y todos sus conductores dentro de una sola
     * transacción.
     *
     * Si falla el viaje o cualquiera de los conductores, se ejecuta
     * rollback y no queda ningún registro incompleto.
     *
     * @param viaje Datos principales del viaje.
     * @param conductores Conductores y roles asignados.
     * @return true si toda la operación se guardó correctamente.
     */
    public boolean registrarViajeConConductores(
            Viaje viaje,
            List<ViajeConductor> conductores
    ) {

        if (!validarViaje(viaje)) {
            return false;
        }

        if (!validarConductores(conductores)) {
            return false;
        }

        String sqlViaje = """
                          INSERT INTO Viaje
                              (
                                  fecha_hora_salida,
                                  fecha_hora_llegada_est,
                                  estado,
                                  id_bus,
                                  id_ruta
                              )
                          VALUES (?, ?, ?, ?, ?)
                          """;

        String sqlViajeConductor = """
                                   INSERT INTO Viaje_Conductor
                                       (
                                           id_viaje,
                                           id_conductor,
                                           rol_en_viaje
                                       )
                                   VALUES (?, ?, ?)
                                   """;

        Connection cn = ConexionBD
                .getInstancia()
                .getConexion();

        if (cn == null) {
            System.err.println(
                    "No existe conexión con SQL Server."
            );
            return false;
        }

        boolean autoCommitAnterior = true;

        try {

            autoCommitAnterior = cn.getAutoCommit();

            /*
             * Desde este momento SQL Server no confirmará
             * automáticamente las operaciones.
             */
            cn.setAutoCommit(false);

            int idViajeGenerado;

            /*
             * Primera parte de la transacción:
             * registrar el viaje maestro.
             */
            try (
                    PreparedStatement psViaje
                    = cn.prepareStatement(
                            sqlViaje,
                            Statement.RETURN_GENERATED_KEYS
                    )
            ) {

                psViaje.setTimestamp(
                        1,
                        Timestamp.valueOf(
                                viaje.getFechaHoraSalida()
                        )
                );

                if (viaje.getFechaHoraLlegadaEst() == null) {

                    psViaje.setNull(
                            2,
                            Types.TIMESTAMP
                    );

                } else {

                    psViaje.setTimestamp(
                            2,
                            Timestamp.valueOf(
                                    viaje.getFechaHoraLlegadaEst()
                            )
                    );
                }

                psViaje.setString(
                        3,
                        viaje.getEstado().trim()
                );

                psViaje.setInt(
                        4,
                        viaje.getIdBus()
                );

                psViaje.setInt(
                        5,
                        viaje.getIdRuta()
                );

                int filasInsertadas
                        = psViaje.executeUpdate();

                if (filasInsertadas != 1) {
                    throw new SQLException(
                            "No se pudo registrar el viaje."
                    );
                }

                try (
                        ResultSet clavesGeneradas
                        = psViaje.getGeneratedKeys()
                ) {

                    if (!clavesGeneradas.next()) {
                        throw new SQLException(
                                "No se pudo obtener el id_viaje generado."
                        );
                    }

                    idViajeGenerado
                            = clavesGeneradas.getInt(1);
                }
            }

            /*
             * Segunda parte de la transacción:
             * relacionar el viaje con todos sus conductores.
             */
            try (
                    PreparedStatement psConductor
                    = cn.prepareStatement(
                            sqlViajeConductor
                    )
            ) {

                for (
                        ViajeConductor asignacion
                        : conductores
                ) {

                    psConductor.setInt(
                            1,
                            idViajeGenerado
                    );

                    psConductor.setInt(
                            2,
                            asignacion.getIdConductor()
                    );

                    psConductor.setString(
                            3,
                            asignacion
                                    .getRolEnViaje()
                                    .trim()
                                    .toUpperCase()
                    );

                    psConductor.addBatch();
                }

                int[] resultados
                        = psConductor.executeBatch();

                if (resultados.length
                        != conductores.size()) {

                    throw new SQLException(
                            "No se procesaron todas las "
                            + "asignaciones de conductores."
                    );
                }

                for (int resultado : resultados) {

                    if (resultado
                            == Statement.EXECUTE_FAILED) {

                        throw new SQLException(
                                "Falló la asignación de uno "
                                + "o más conductores."
                        );
                    }
                }
            }

            /*
             * Si el viaje y todas sus asignaciones funcionaron,
             * se confirman definitivamente.
             */
            cn.commit();

            viaje.setIdViaje(idViajeGenerado);

            for (
                    ViajeConductor asignacion
                    : conductores
            ) {
                asignacion.setIdViaje(
                        idViajeGenerado
                );
            }

            System.out.println(
                    "Viaje registrado correctamente con id: "
                    + idViajeGenerado
            );

            System.out.println(
                    "Conductores asignados: "
                    + conductores.size()
            );

            return true;

        } catch (SQLException e) {

            /*
             * Si falla cualquier INSERT, se eliminan también
             * las operaciones anteriores de esta transacción.
             */
            try {

                cn.rollback();

                System.err.println(
                        "Se ejecutó rollback. "
                        + "No se guardó el viaje ni "
                        + "sus conductores."
                );

            } catch (SQLException errorRollback) {

                System.err.println(
                        "Error al ejecutar rollback: "
                        + errorRollback.getMessage()
                );
            }

            System.err.println(
                    "Error al registrar el viaje: "
                    + e.getMessage()
            );

            return false;

        } finally {

            /*
             * Se devuelve la conexión al estado que tenía
             * antes de comenzar la transacción.
             */
            try {

                cn.setAutoCommit(
                        autoCommitAnterior
                );

            } catch (SQLException e) {

                System.err.println(
                        "No se pudo restaurar el autoCommit: "
                        + e.getMessage()
                );
            }
        }
    }

    private boolean validarViaje(Viaje viaje) {

        if (viaje == null) {
            System.err.println(
                    "El viaje no puede ser nulo."
            );
            return false;
        }

        if (viaje.getFechaHoraSalida() == null) {
            System.err.println(
                    "La fecha y hora de salida son obligatorias."
            );
            return false;
        }

        if (
                viaje.getEstado() == null
                || viaje.getEstado().isBlank()
        ) {
            System.err.println(
                    "El estado del viaje es obligatorio."
            );
            return false;
        }

        if (viaje.getIdBus() <= 0) {
            System.err.println(
                    "El id del bus no es válido."
            );
            return false;
        }

        if (viaje.getIdRuta() <= 0) {
            System.err.println(
                    "El id de la ruta no es válido."
            );
            return false;
        }

        return true;
    }

    private boolean validarConductores(
            List<ViajeConductor> conductores
    ) {

        if (
                conductores == null
                || conductores.isEmpty()
        ) {
            System.err.println(
                    "Debe asignarse al menos un conductor."
            );
            return false;
        }

        for (
                ViajeConductor asignacion
                : conductores
        ) {

            if (asignacion == null) {
                System.err.println(
                        "Existe una asignación de conductor nula."
                );
                return false;
            }

            if (asignacion.getIdConductor() <= 0) {
                System.err.println(
                        "Existe un id de conductor no válido."
                );
                return false;
            }

            if (
                    asignacion.getRolEnViaje() == null
                    || asignacion
                            .getRolEnViaje()
                            .isBlank()
            ) {
                System.err.println(
                        "Todo conductor debe tener un rol."
                );
                return false;
            }
        }

        return true;
    }
}