import java.io.*;

import javax.naming.*;

public class client {
    public void main(String[] args) {
        Context ctx = new InitialContext();
        ctx.lookup("ldap://127.0.0.1:1099/a");
    }
}