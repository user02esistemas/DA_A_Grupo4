package util;

/**
 * Utilidad para escapar texto plano en contextos HTML y JavaScript,
 * previniendo ataques XSS (Cross-Site Scripting).
 * 
 * Uso en JSPs:
 *   <%= EscapeUtil.escHtml(request.getParameter("msg")) %>
 * 
 * Uso en JavaScript embebido:
 *   var msg = '<%= EscapeUtil.escJs(userInput) %>';
 */
public class EscapeUtil {

    /**
     * Escapa un string para contexto HTML (atributos o cuerpo HTML).
     * Convierte: & → &amp;  < → &lt;  > → &gt;  " → &quot;  ' → &#39;
     */
    public static String escHtml(String input) {
        if (input == null || input.isEmpty()) {
            return "";
        }
        StringBuilder sb = new StringBuilder(input.length());
        for (int i = 0; i < input.length(); i++) {
            char c = input.charAt(i);
            switch (c) {
                case '&':  sb.append("&amp;");  break;
                case '<':  sb.append("&lt;");   break;
                case '>':  sb.append("&gt;");   break;
                case '"':  sb.append("&quot;"); break;
                case '\'': sb.append("&#39;");  break;
                default:   sb.append(c);
            }
        }
        return sb.toString();
    }

    /**
     * Escapa un string para contexto JavaScript (valor entre comillas simples).
     * Convierte: \ → \\  ' → \'  " → \&quot;  \n → \\n  \r → \\r  < → \x3C
     */
    public static String escJs(String input) {
        if (input == null || input.isEmpty()) {
            return "";
        }
        StringBuilder sb = new StringBuilder(input.length() * 2);
        for (int i = 0; i < input.length(); i++) {
            char c = input.charAt(i);
            switch (c) {
                case '\\': sb.append("\\\\"); break;
                case '\'': sb.append("\\'");  break;
                case '"':  sb.append("\\\""); break;
                case '\n': sb.append("\\n");  break;
                case '\r': sb.append("\\r");  break;
                case '\t': sb.append("\\t");  break;
                case '<':  sb.append("\\x3C"); break;
                case '>':  sb.append("\\x3E"); break;
                default:
                    if (c < 0x20) {
                        sb.append(String.format("\\x%02X", (int) c));
                    } else {
                        sb.append(c);
                    }
            }
        }
        return sb.toString();
    }

    /**
     * Escapa un número para HTML (simplemente lo convierte a string sin formato).
     */
    public static String escHtml(Number input) {
        return input != null ? input.toString() : "0";
    }

    /**
     * Alias corto para escHtml().
     */
    public static String h(String input) {
        return escHtml(input);
    }
}
