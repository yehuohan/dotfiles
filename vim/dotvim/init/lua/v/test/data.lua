return {
    ['test.rs'] = {
        '\27[?25l\27[2J\27[m\27[38;5;11m\27[1m\27[Hwarning\27[38;5;15m: unused variable: `args`\27[m\r',
        '\27[38;5;14m\27[1m\27[1C-->\27[m\27[1Ctest.rs:3:9\r',
        '\27[38;5;14m\27[1m\27[2C|\r',
        '3\27[m\27[38;5;14m\27[1m\27[1C|\27[m     let args = std::env::args();\r',
        '\27[38;5;14m\27[1m\27[2C|\27[m\27[1C\27[38;5;11m\27[1m\27[8C^^^^\27[m\27[38;5;11m\27[1m\27[1Chelp: if this is intentional, prefix it with an underscore: `_args`\27[m\r',
        '\27[38;5;14m\27[1m\27[2C|\27[m\r',
        '\27[38;5;14m\27[1m\27[2C=\27[38;5;15m\27[1Cnote\27[m: `#[warn(unused_variables)]` on by default\27[9;1H\27]0;C:\\Windows\\SYSTEM32\\cmd.exe\a\27[?25h\27[?25l\27[38;5;11m\27[1mwarning\27[38;5;15m: 1 warning emitted\27[11;1H\27[?25h',
        '\27[m',
        'Hello Rust\r',
    },
}
