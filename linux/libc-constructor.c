// 使用 _init 会冲突，自定义属性不会
void __attribute__ ((constructor)) setup ()
{
    puts ("started");
}

