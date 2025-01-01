.section .text
.global multiply

multiply:
    # 获取a0和a1的指数和尾数
    li x29, 0x7F800000
    and x5, a0, x29  # 获得a0的指数
    and x7, a1, x29  # 获得a1的指数
    li x29, 0x007FFFFF
    and x6, a0, x29  # 获得a0的尾数
    and x28, a1, x29 # 获得a1的尾数

    srli x5, x5, 23  # 移动指数到低8位
    srli x7, x7, 23  # 移动指数到低8位

    add x5, x5, x7   # 新指数 = 指数1 + 指数2 - 偏置 (127)
    addi x5, x5, -127

    # 设置隐藏位
    li x29, 0x00800000
    or x6, x6, x29  # 设置a0的隐藏位
    or x28, x28, x29 # 设置a1的隐藏位

    # 尾数相乘
    mulh x30, x6, x28  # 高32位结果
    mul x6, x6, x28     # 低32位结果

    slli x30, x30, 1  # 左移一位以对齐
    srli x6, x6, 23   # 右移23位以对齐
    or x6, x6, x30    # 合并高32位和低32位

    # 规格化
    bltz x6, normalize_multiply  # 如果结果小于0，则需要规格化
    j shift_multiply

normalize_multiply:
    slli x6, x6, 1  # 左移一位
    addi x5, x5, -1 # 减少指数
    bltz x6, normalize_multiply

shift_multiply:
    # 清除隐藏位
    li x29, 0x007FFFFF
    and x6, x6, x29

    # 处理符号位
    li x29, 0x80000000
    and x29, x29, a0
    xor x30, x29, a1
    and x29, x29, x30
    or x6, x6, x29

    # 检查溢出
    li x29, 0x000000FF
    bgeu x5, x29, overflow_multiply
    slli x5, x5, 23
    or x6, x6, x5
    or a0, x6, x29
    j end_multiply

overflow_multiply:
    li a0, 0x7F800000

end_multiply:
    ret
