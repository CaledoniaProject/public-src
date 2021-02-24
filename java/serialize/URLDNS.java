import java.io.*;
import java.lang.reflect.Field;
import java.net.URL;
import java.util.HashMap;

public class Foo {
    public static void main (String[] args) throws Exception
    {
        HashMap<URL, String> hashMap = new HashMap<URL, String>();     
        URL url = new URL("http://www.baidu.com");
        Field hashCode = Class.forName("java.net.URL").getDeclaredField("hashCode");
        hashCode.setAccessible(true);
        hashCode.set(url, 0xdeadbeef);

        hashMap.put(url, "123");
        hashCode.set(url, -1); 

        // 读写测试
        ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream("out.bin"));
        oos.writeObject(hashMap);

        ObjectInputStream ois = new ObjectInputStream(new FileInputStream("out.bin"));
        ois.readObject();
    }
}

