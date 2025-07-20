const std = @import("std");
const Buffer = @import("core/buffer.zig").Buffer;
const Pos = @import("core/buffer.zig").Pos;
const buf_set_text = @import("core/buffer.zig").buf_set_text;
const MarkTree = @import("core/marks.zig").MarkTree;
const HighlightManager = @import("core/marks.zig").HighlightManager;
const Decoration = @import("core/marks.zig").Decoration;
const ExtMarkItem = @import("core/marks.zig").ExtMarkItem;
const HighlightGroup = @import("core/marks.zig").HighlightGroup;

// ANSI color escape codes for terminal output
const RESET = "\x1b[0m";
const BOLD = "\x1b[1m";
const FG_BLUE = "\x1b[38;5;39m";
const FG_GREEN = "\x1b[38;5;71m";
const FG_ORANGE = "\x1b[38;5;208m";

/// Helper function to add a highlight to the buffer.
/// This connects the HighlightManager, the Buffer's MarkTree, and the Namespace.
fn addHighlight(
    alloc: std.mem.Allocator,
    hm: *HighlightManager,
    buf: *Buffer,
    ns_id: u32,
    hl_id: i64,
    start_pos: Pos,
    end_pos: Pos,
) !void {
    // Get the namespace where we'll store the highlight information
    var ns = hm.namespaces.getPtr(ns_id).?;

    // Create a decoration object. This specifies *how* the text is styled.
    // NOTE: In a real app, you'd need a strategy to manage this memory.
    // For this demo, we are leaking it.
    const deco = try alloc.create(Decoration);
    deco.* = .{ .hl_group_id = hl_id, .virt_line = "", .virt_lines = undefined };

    // Insert marks into the buffer's mark tree.
    // This gives us a unique ID for our highlight.
    const mark_id = try buf.mark_tree.insert(start_pos, ns_id, false);
    _ = try buf.mark_tree.insert(end_pos, ns_id, true); // Mark the end of the range

    // Create the external mark item, which links the range, decoration, and IDs.
    // Note: Buffer positions (Pos) are 1-based, while ExtMarkItem rows/cols are 0-based.
    // ExtMarkItem.end_col is exclusive in this model.
    // So if Pos.col for the end is 1-based inclusive, it correctly becomes the 0-based exclusive end index.
    const item = ExtMarkItem{
        .ns_id = ns_id,
        .mark_id = mark_id,
        .row = start_pos.lnum - 1,
        .col = start_pos.col - 1,
        .end_row = end_pos.lnum - 1,
        .end_col = end_pos.col, // This value is the 1-based column AFTER the last highlighted char
        .decoration = deco,
    };

    // Store the complete highlight item in the namespace's hash map.
    try ns.extmarks.put(item.mark_id, item);
}

/// Renders the buffer with highlights to the console.
fn renderBuffer(buf: *const Buffer, hm: *const HighlightManager) !void {
    const writer = std.io.getStdOut().writer();

    // Data structure to manage active highlights on a single line
    const Span = struct {
        start_col: u32,
        end_col: u32,
        hl_group: *const HighlightGroup,
    };

    // Iterate over each line in the buffer
    for (buf.lines.items, 0..) |line, i| {
        const lnum: u32 = @intCast(i + 1);
        var spans = std.ArrayList(Span).init(std.heap.page_allocator);
        defer spans.deinit();

        // Find all highlights that apply to the current line
        var ns_iterator = hm.namespaces.valueIterator();
        while (ns_iterator.next()) |ns| {
            var extmark_iterator = ns.extmarks.valueIterator();
            while (extmark_iterator.next()) |extmark| {
                // Check if the extmark's range includes the current line
                if (extmark.row <= i and extmark.end_row >= i) {
                    const hl_group = hm.highlight_groups.get(extmark.decoration.hl_group_id).?;

                    // Calculate start column for the current line
                    const start_col = if (extmark.row == i) extmark.col else 0;

                    // Calculate end column for the current line
                    // If the highlight ends on this line, use extmark.end_col (0-based exclusive)
                    // Otherwise, highlight to the end of the current line (line.len is 0-based exclusive end)
                    const end_col_raw: u32 = if (extmark.end_row == i) extmark.end_col else @intCast(line.len);

                    // Clamp end_col to the actual length of the line to prevent out-of-bounds access
                    const int_len: u32 = @intCast(line.len);
                    const end_col = @min(end_col_raw, int_len);

                    // Only add span if it's a valid range (start_col < end_col)
                    if (start_col < end_col) {
                        try spans.append(.{
                            .start_col = start_col,
                            .end_col = end_col,
                            .hl_group = &hl_group,
                        });
                    }
                }
            }
        }

        // Sort spans by starting column to render them correctly
        std.sort.block(Span, spans.items, {}, struct {
            // Changed return type from 'bool' to 'std.sort.Order' for idiomatic Zig sorting
            fn compare(context: void, a: Span, b: Span) bool {
                _ = context; // Unused
                if (a.start_col < b.start_col) {
                    return true; // Less than
                } else if (a.start_col > b.start_col) {
                    return false; // Greater than
                } else {
                    return true; // Equal
                }
            }
        }.compare);

        // Render the line with ANSI colors
        try writer.print("{d: >3} │ ", .{lnum});
        var current_col: u32 = 0;
        for (spans.items) |span| {
            // Print text before the current highlight span
            if (span.start_col > current_col) {
                try writer.print("{s}", .{line[current_col..span.start_col]});
            }

            // Apply color and print the highlighted text
            const color = switch (span.hl_group.id) {
                1 => FG_BLUE,
                2 => FG_ORANGE,
                3 => FG_GREEN,
                else => "",
            };
            // Slice is safe here because span.end_col has been clamped
            try writer.print("{s}{s}{s}", .{ BOLD, color, line[span.start_col..span.end_col] });
            try writer.print("{s}", .{RESET});

            current_col = span.end_col;
        }

        // Print any remaining text on the line after the last highlight
        if (current_col < line.len) {
            try writer.print("{s}", .{line[current_col..]});
        }
        try writer.print("\n", .{});
    }
}

pub fn main() !void {
    // 1. SETUP
    const allocator = std.heap.page_allocator;
    var hm = HighlightManager.init(allocator);
    defer hm.deinit();

    var buf = try Buffer.init(allocator);
    defer buf.destroy();

    // 2. SET BUFFER CONTENT
    const code =
        \\// A simple demo function
        \\const sayHello = fn(name: []const u8) void {
        \\    std.debug.print("Hello, {s}!\n", .{name});
        \\};
    ;
    try buf_set_text(buf, code);

    // 3. DEFINE HIGHLIGHTS
    const ns_id = try hm.createNamespace("zig_syntax");

    const keyword_hl_id = try hm.defineHighlightGroup("Keyword", .{
        .fg_color = 0x0000FF,
    });
    const string_hl_id = try hm.defineHighlightGroup("String", .{ .fg_color = 0xFFA500 });
    const comment_hl_id = try hm.defineHighlightGroup("Comment", .{ .fg_color = 0x008000 });

    // 4. ADD HIGHLIGHTS TO BUFFER
    // Remember: Pos is 1-based (lnum, col). For a string of length N,
    // columns are 1 to N. The 'end_pos.col' for addHighlight
    // should be the 1-based column *after* the last character you want to highlight,
    // or equivalently, the length of the substring + start_col - 1.

    // Line 2: "const sayHello = fn(name: []const u8) void {"
    // Length: 44 chars

    // Highlight "const" (length 5)
    // Starts at col 1, ends at col 5. Next col is 6.
    //std.debug.print(comptime fmt: []const u8, args: anytype)
    try addHighlight(allocator, &hm, buf, ns_id, keyword_hl_id, .{ .lnum = 2, .col = 1 }, .{ .lnum = 2, .col = 6 }); // Changed .col=5 to .col=6

    // Highlight "fn" (length 2)
    // Starts at col 18, ends at col 19. Next col is 20.
    try addHighlight(allocator, &hm, buf, ns_id, keyword_hl_id, .{ .lnum = 2, .col = 18 }, .{ .lnum = 2, .col = 19 }); // Corrected to be inclusive of 'n'

    // Highlight "void" (length 4)
    // Starts at col 40, ends at col 43. Next col is 44.
    try addHighlight(allocator, &hm, buf, ns_id, keyword_hl_id, .{ .lnum = 2, .col = 39 }, .{ .lnum = 2, .col = 42 }); // Corrected to be inclusive of 'd'

    // Line 3: "    std.debug.print("Hello, {s}!\n", .{name});"
    // Length: 48 chars
    // The string literal is "Hello, {s}!\n" (14 characters). It starts at column 24.
    // The last character '\n' is at column 24 + 14 - 1 = 37.
    // So the column after it is 38.
    try addHighlight(allocator, &hm, buf, ns_id, keyword_hl_id, .{ .lnum = 3, .col = 9 }, .{ .lnum = 3, .col = 14 }); // Corrected: .col=37 was inclusive, 38 is exclusive end.
    try addHighlight(allocator, &hm, buf, ns_id, string_hl_id, .{ .lnum = 3, .col = 21 }, .{ .lnum = 3, .col = 35 }); // Corrected: .col=37 was inclusive, 38 is exclusive end.

    // Line 1: "// A simple demo function"
    // Length: 25 characters.
    // Starts at col 1, ends at col 25. Next col is 26.
    try addHighlight(allocator, &hm, buf, ns_id, comment_hl_id, .{ .lnum = 1, .col = 1 }, .{ .lnum = 1, .col = 26 }); // Corrected: .col=25 was inclusive, 26 is exclusive end.

    // 5. RENDER THE RESULT
    try renderBuffer(buf, &hm);
}
