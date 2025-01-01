.section .text
.global divi

divi:
    # 获取a0和a1的指数和尾数
    li x29, 0x7F800000
    and x5, a0, x29  # 获得a0的指数
    and x7, a1, x29  # 获得a1的指数
    li x29, 0x007FFFFF
    and x6, a0, x29  # 获得a0的尾数
    and x28, a1, x29 # 获得a1的尾数

    srli x5, x5, 23  # 移动指数到低8位
    srli x7, x7, 23  # 移动指数到低8位

    sub x5, x5, x7   # 新指数 = 指数1 - 指数2 + 偏置 (127)
    addi x5, x5, 127

    # 设置隐藏位
    li x29, 0x00800000
    or x6, x6, x29  # 设置a0的隐藏位
    or x28, x28, x29 # 设置a1的隐藏位

    # 尾数除法使用加减交替法
    mv x30, zero       # 初始化商为0
    mv x31, zero       # 初始化余数为0
    slli x31, x6, 8    # 将被除数左移8位以对齐

    li t0, 24          # 循环次数

div_loop:
    beqz t0, end_divide  # 循环结束
    slli x31, x31, 1     # 余数左移一位
    sltu t1, x31, x28    # 如果余数 < 除数，则跳过减法
    bnez t1, skip_subtract
    sub x31, x31, x28    # 余数 - 除数
    ori x30, x30, 1      # 商加1
skip_subtract:
    slli x30, x30, 1     # 商左移一位
    addi t0, t0, -1      # 循环计数器减1
    j div_loop

end_divide:
    # 清除隐藏位
    li x29, 0x007FFFFF
    and x30, x30, x29

    # 处理符号位
    li x29, 0x80000000
    and x29, x29, a0
    xor x30, x29, a1
    and x29, x29, x30
    or x30, x30, x29

    # 检查溢出
    li x29, 0x000000FF
    bgeu x5, x29, overflow_divide
    slli x5, x5, 23
    or x30, x30, x5
    or a0, x30, x29
    j end_divide_final

overflow_divide:
    li a0, 0x7F800000

end_divide_final:
    ret
