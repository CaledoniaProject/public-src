# 使用ctree接口枚举动态的memcpy调用
# https://hex-rays.com/blog/plugin-focus-hrdevhelper/

import ida_name, ida_hexrays, ida_funcs

class memcpy_finder_t(ida_hexrays.ctree_visitor_t):
    def __init__(self):
        ida_hexrays.ctree_visitor_t.__init__(self, ida_hexrays.CV_FAST)

    def _process(self, i):
        # find function calls but with the following
        # restrictions in place:
        # - the called function's symbolic name must contain 'memcpy'
        # - the call's number of arguments must be three
        # - the call's 3rd argument must not be an explicit number
        found = (i.op is ida_hexrays.cot_call and
            i.x.op is ida_hexrays.cot_obj and
            "memcpy" in ida_name.get_name(i.x.obj_ea) and
            len(i.a) == 3 and
            i.a[2].op is not ida_hexrays.cot_num)

        # once found, print address of current item's address
        # (whose item code happens to be cot_call)
        if found:
            print("memcpy() found at %x" % i.ea)
        return 0

    # process expressions
    def visit_expr(self, e):
        return self._process(e)
        
    # for the sake of completeness, also process statements
    def visit_insn(self, i):
        return self._process(i)

# process all of the IDA database's functions
for i in range(ida_funcs.get_func_qty()):
    # get 'func_t' structure
    f = ida_funcs.getn_func(i)
    if f:
        # get cfunc_t structure
        cfunc = ida_hexrays.decompile(f)
        if cfunc:
            # run the visitor class
            mf = memcpy_finder_t()
            mf.apply_to(cfunc.body, None)