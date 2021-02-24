f=assert(io.open("luac.out","wb"))
assert(f:write(string.dump(assert(loadfile("l2_data")))))
assert(f:close())

