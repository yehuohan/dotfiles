-- stylua: ignore start
return {
    {
        {
            '\27[2J\27[1m\27[93m\27[49m\27[Hwarning\27]0;C:\\Windows\\SYSTEM32\\cmd.exe\a\27[?25h\27[25l\27[m\27[1m\27[93m\27[Hwarning\27[97m: unused variable: `args`\27[m\27[52X\r',
            ' \27[1m\27[96m--> \27[mtest.rs:3:9\27[68X\r',
            '  \27[1m\27[96m|\27[m\27[81X\27[1m\27[96m\r',
            '3\27[m \27[1m\27[96m|\27[m     let args = std::env::args();\27[48X\r',
            '  \27[1m\27[96m| \27[m        \27[1m\27[93m^^^^\27[m \27[1m\27[93mhelp: if this is intentional, prefix it with an underscore: `_args`\27[m\r',
            '  \27[1m\27[96m|\27[m\27[81X\r',
            '  \27[1m\27[96m= \27[97mnote\27[m: `#[warn(unused_variables)]` on by default\27[33X\27[9;1H\27[?25h'
        },
        { '\27[1m\27[93mwarning' },
        { '\27[25l\27[m\27[1m\27[97m: 1 warning emitted\27[11;1H\27[?25h' },
        { '\27[mHello Rust\r', '' },
        { '' },
    },
}
-- stylua: ignore end
