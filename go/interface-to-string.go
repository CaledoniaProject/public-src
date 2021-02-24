func dump(args *[]interface{}) {
    value := reflect.ValueOf(*args).Index(0)
    str := value.Interface().(string)
    fmt.Println(str)
}
