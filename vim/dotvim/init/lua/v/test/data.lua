-- stylua: ignore start
return {
    ['test.rs'] = {
        [=[[?25l[2J[m[38;5;11m[1m[Hwarning[38;5;15m: unused variable: `args`[m]=] .. '\r',
        [=[[38;5;14m[1m[1C-->[m[1Ctest.rs:3:9]=] .. '\r',
        [=[[38;5;14m[1m[2C|]=] .. '\r',
        [=[3[m[38;5;14m[1m[1C|[m     let args = std::env::args();]=] .. '\r',
        [=[[38;5;14m[1m[2C|[m[1C[38;5;11m[1m[8C^^^^[m[38;5;11m[1m[1Chelp: if this is intentional, prefix it with an underscore: `_args`[m]=] .. '\r',
        [=[[38;5;14m[1m[2C|[m]=] .. '\r',
        [=[[38;5;14m[1m[2C=[38;5;15m[1Cnote[m: `#[warn(unused_variables)]` on by default[9;1H]0;C:\Windows\SYSTEM32\cmd.exe[?25h[?25l[38;5;11m[1mwarning[38;5;15m: 1 warning emitted[11;1H[?25h]=],
        [=[[m]=],
        [=[Hello Rust]=] .. '\r',
        [=['']=],
    },
}
-- stylua: ignore end
