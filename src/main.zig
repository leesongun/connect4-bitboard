const std = @import("std");
const lib = @import("root.zig");

pub fn main() !void {
    var stdout = std.io.getStdOut().writer();

    var current_state: lib.connect4 = lib.initial_state;
    var current_player: u1 = 0;

    while (true) {
        const player_str = "OX"[current_player];
        try stdout.print("Player {c}'s turn. Enter column (1-7): ", .{player_str});
        var buf: [1]u8 = undefined;
        const bytes_read = try std.io.getStdIn().readAll(&buf);

        if (bytes_read == 0) {
            try stdout.print("Error reading input\n", .{});
            continue;
        }

        const input_char = buf[0];

        if (input_char >= '1' and input_char <= '7') {
            const col: u3 = @intCast(input_char - '1');
            current_state = lib.play_column(current_state, col) catch {
                try stdout.print("Invalid move. Column is full.\n", .{});
                continue;
            };
        } else {
            try stdout.print("Invalid input. Please enter a number between 1 and 7.\n", .{});
            continue;
        }

        const board_str = lib.print_board(current_state, player_str, "XO"[current_player]);
        const column_str = lib.print_playable_columns(current_state);
        try stdout.print("{s}{s}\n", .{ board_str, column_str });

        if (lib.check_win(current_state)) {
            try stdout.print("Player {c} wins!\n", .{player_str});
            break;
        }
        if (lib.is_board_full(current_state)) {
            try stdout.print("Draw!\n", .{});
            break;
        }

        current_state = lib.invert_player(current_state);
        current_player ^= 1;
    }
}
