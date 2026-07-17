package util;

import org.mindrot.jbcrypt.BCrypt;

public class PasswordUtil {

    public static String hashPassword(String password) {
        if (password == null || password.isEmpty()) {
            throw new IllegalArgumentException("Password no puede estar vacia");
        }
        return BCrypt.hashpw(password, BCrypt.gensalt(12));
    }

    public static boolean verificarPassword(String password, String storedHash) {
        if (password == null || storedHash == null || storedHash.isEmpty()) {
            return false;
        }
        try {
            return BCrypt.checkpw(password, storedHash);
        } catch (Exception e) {
            return false;
        }
    }
}
