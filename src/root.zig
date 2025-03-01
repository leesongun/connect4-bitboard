pub const connect4 = u49;

const mul: connect4 = 0b0000001_0000001_0000001_0000001_0000001_0000001_0000001;
pub const initial_state: connect4 = mul << 6;

pub fn play_column(c: connect4, column: u3) !connect4 {
    const d = c & (~@as(connect4, 0) << (7 * @as(u6, column)));
    return play_place(c, d & -%d);
}

pub fn play_place(c: connect4, p: connect4) !connect4 {
    if (p & mul != 0) return error.ColumnFull;
    return c | (p >> 1);
}

pub fn invert_player(c: connect4) connect4 {
    return (mul - 1) -% c;
}

pub fn playable_places(c: connect4) connect4 {
    return c & invert_player(c) & ~mul;
}

//pext?
pub fn unplayable_columns(c: connect4) u7 {
    return @truncate(((c & mul) *% 0o1010101010101) >> 36);
}

pub fn playable_columns(c: connect4) u7 {
    return ~unplayable_columns(c);
}

pub fn check_win(c: connect4) bool {
    var a: @Vector(4, connect4) = @splat(c & (c - mul));
    a &= a >> .{ 1, 6, 7, 8 };
    a &= a >> .{ 2, 12, 14, 16 };
    return @reduce(.Or, a) != 0;
}

pub fn is_board_full(c: connect4) bool {
    return c & mul == mul;
}

pub fn print_board(c: connect4, player: u8, opponent: u8) [48]u8 {
    const a = c & (c - mul);
    const b = ~(c | (c - mul));
    var rtn: [48]u8 = "       \n".* ** 6;
    inline for (0..6) |i| {
        inline for (0..7) |j| {
            const k = 2 << (i + (7 * j));
            const l = (i * 8) + j;
            if (a & k != 0) rtn[l] = player;
            if (b & k != 0) rtn[l] = opponent;
        }
    }
    return rtn;
}

pub fn print_playable_columns(c: connect4) [7]u8 {
    var rtn: [7]u8 = "1234567".*;
    var x = unplayable_columns(c);
    while (x != 0) {
        rtn[@ctz(x & -%x)] = ' ';
        x &= x - 1;
    }
    return rtn;
}
