package util;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

public class ValidacionUtil {

    // DNI peruano: exactamente 8 dígitos
    private static final Pattern PATRON_DNI = Pattern.compile("\\d{8}");

    // Teléfono Perú: 9 dígitos que empiezan con 9
    private static final Pattern PATRON_TELEFONO = Pattern.compile("9\\d{8}");

    // Teléfono fijo Perú: 7 dígitos (sin código de área)
    private static final Pattern PATRON_TELEFONO_FIJO = Pattern.compile("[1-9]\\d{6}");

    // Teléfono flexible: 7-9 dígitos, permite espacios
    private static final Pattern PATRON_TELEFONO_FLEX = Pattern.compile("[\\d\\s]{6,15}");

    /**
     * Valida que un DNI tenga exactamente 8 dígitos numéricos.
     */
    public static boolean validarDNI(String dni) {
        if (dni == null) return false;
        return PATRON_DNI.matcher(dni.trim()).matches();
    }

    /**
     * Valida un número de teléfono móvil peruano (9 dígitos, empieza con 9).
     * Permite espacios (los elimina automáticamente).
     */
    public static boolean validarTelefonoMovil(String telefono) {
        if (telefono == null) return false;
        String limpio = telefono.replaceAll("\\s+", "");
        return PATRON_TELEFONO.matcher(limpio).matches();
    }

    /**
     * Valida un teléfono de forma flexible (entre 6 y 15 dígitos/espacios).
     */
    public static boolean validarTelefonoFlexible(String telefono) {
        if (telefono == null) return false;
        return PATRON_TELEFONO_FLEX.matcher(telefono.trim()).matches();
    }

    /**
     * Valida que un número entero esté dentro de un rango.
     */
    public static boolean validarEntero(String valor, int min, int max) {
        if (valor == null) return false;
        try {
            int num = Integer.parseInt(valor.trim());
            return num >= min && num <= max;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    /**
     * Valida que un número decimal sea positivo y opcionalmente dentro de un rango.
     */
    public static boolean validarDecimalPositivo(String valor, double min, double max) {
        if (valor == null) return false;
        try {
            double num = Double.parseDouble(valor.trim());
            return num >= min && num <= max;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    /**
     * Valida que un número decimal sea mayor que cero.
     */
    public static boolean validarDecimalPositivo(String valor) {
        return validarDecimalPositivo(valor, 0.01, Double.MAX_VALUE);
    }

    /**
     * Valida que una placa de bus peruana tenga formato XXX-999 (3 letras, guión, 3 dígitos).
     */
    public static boolean validarPlacaBus(String placa) {
        if (placa == null) return false;
        return Pattern.compile("^[A-Za-z]{3}-\\d{3}$").matcher(placa.trim()).matches();
    }

    /**
     * Obtiene mensajes de error de validación de forma acumulativa.
     */
    public static List<String> validarCamposCliente(String dni, String nombre, String apellido,
                                                      String telefono, String email, String password) {
        List<String> errores = new ArrayList<>();

        if (dni != null && !dni.isEmpty() && !validarDNI(dni)) {
            errores.add("El DNI debe tener exactamente 8 dígitos numéricos.");
        }
        if (telefono != null && !telefono.isEmpty() && !validarTelefonoFlexible(telefono)) {
            errores.add("El teléfono debe contener solo dígitos (6-15 caracteres).");
        }
        if (nombre != null && nombre.trim().length() < 2) {
            errores.add("El nombre debe tener al menos 2 caracteres.");
        }
        if (apellido != null && apellido.trim().length() < 2) {
            errores.add("El apellido debe tener al menos 2 caracteres.");
        }
        if (password != null && password.length() < 6) {
            errores.add("La contraseña debe tener al menos 6 caracteres.");
        }

        return errores;
    }
}
