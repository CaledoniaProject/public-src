import java.io.*;
import java.lang.*;

public class Foo {
    public static void main (String[] args) throws Exception
    {
        Runtime.getRuntime().exec("/bin/ls");
        Runtime.getRuntime().exec("/bin/sleep");
    }
}
