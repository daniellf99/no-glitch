const std = @import("std");

const BMPHeader = struct {
    signature: []const u8 = "BM",
    file_size: u32,
    reserved: u32 = 0,
    offset: u32 = 54,
};

const InfoHeader = struct {
    header_size: u32 = 40,
    width: u32,
    height: u32,
    planes: u16,
    bits_per_pixel: u16,
    compression: u32 = 0,
    image_size: u32,
    x_pixels_per_m: u32,
    y_pixels_per_m: u32,
    colors_used: u32 = 0,
    colors_important: u32 = 0,
};

const ColorTableColor = struct {
    red: u8,
    green: u8,
    blue: u8,
    reserved: u8,
};

const ColorTable = struct {
    colors: []ColorTableColor,
};

const Pixel = struct {
    red: u8 = 0,
    green: u8 = 0,
    blue: u8 = 0,
};

const BMPFile = struct {
    header: BMPHeader,
    info_header: InfoHeader,
    color_table: ColorTable,
    data: [][]u8,
};

pub fn writeBMP(comptime height: usize, comptime width: usize, data: *const [height][width]Pixel) !void {
    _ = data;
    const file = try std.fs.cwd().createFile(
        "out.bmp",
        .{ .read = true, .truncate = true }
    );
    defer file.close();

    // Recompute
    const data_size = 16;

    const header_size = 14;
    const info_header_size = 40;
    const total_header_size = header_size + info_header_size;
    const total_file_size = total_header_size + data_size;

    // -- HEADER --
    // Magic number
    try file.writeAll("BM");
    // File size
    try file.writer().writeInt(u32, total_file_size, std.builtin.Endian.little);
    // Reserved
    try file.writer().writeInt(u32, 0, std.builtin.Endian.little);
    // Offset
    try file.writer().writeInt(u32, total_header_size, std.builtin.Endian.little);
    
    // -- Info --
    // Header size
    try file.writer().writeInt(u32, info_header_size, std.builtin.Endian.little);
    // Width
    try file.writer().writeInt(u32, width, std.builtin.Endian.little);
    // Height
    try file.writer().writeInt(u32, height, std.builtin.Endian.little);
    // Planes
    try file.writer().writeInt(u16, 1, std.builtin.Endian.little);
    // bpp
    try file.writer().writeInt(u16, 24, std.builtin.Endian.little);
    // Compression
    try file.writer().writeInt(u32, 0, std.builtin.Endian.little);
    // Data size
    try file.writer().writeInt(u32, data_size, std.builtin.Endian.little);
    // X PpM
    try file.writer().writeInt(u32, 2835, std.builtin.Endian.little);
    // Y PpM
    try file.writer().writeInt(u32, 2835, std.builtin.Endian.little);
    // Colors
    try file.writer().writeInt(u32, 0, std.builtin.Endian.little);
    // Imp. Colors
    try file.writer().writeInt(u32, 0, std.builtin.Endian.little);

    // Calculate padding size in bytes
    // Padding = Width * RGB Pixel size in bytes
    const padding = (width * 3) % 4;
    const total_width = width + padding;
    const allocator = std.heap.page_allocator;
    const raster_data = try allocator.alloc([total_width]u8, height);
    defer allocator.free(raster_data);

    for (0..height) |i| {
        const row = try allocator.alloc(u8, total_width);
        defer allocator.free(row);

        raster_data[i] = row;
    }

    // For line in pixel matrix
    // for (data) |pixel_row| {
    //     for (pixel_row) |pixel| {
            
    //     }
        
    //     // Add padding
    //     for (0..padding) |j| {
    //         raster_data[i][j]
    //     }
    // }
    // Write line
    // Add padding
    // next

    // -- Start of pixel array --
    // Line 1
    try file.writer().writeInt(u8, 0, std.builtin.Endian.little);
    try file.writer().writeInt(u8, 0, std.builtin.Endian.little);
    try file.writer().writeInt(u8, 0xFF, std.builtin.Endian.little);

    try file.writer().writeInt(u8, 0xFF, std.builtin.Endian.little);
    try file.writer().writeInt(u8, 0xFF, std.builtin.Endian.little);
    try file.writer().writeInt(u8, 0xFF, std.builtin.Endian.little);

    // Padding
    try file.writer().writeInt(u8, 0x00, std.builtin.Endian.little);
    try file.writer().writeInt(u8, 0x00, std.builtin.Endian.little);

    // Line 2
    try file.writer().writeInt(u8, 0xFF, std.builtin.Endian.little);
    try file.writer().writeInt(u8, 0, std.builtin.Endian.little);
    try file.writer().writeInt(u8, 0, std.builtin.Endian.little);
    
    try file.writer().writeInt(u8, 0, std.builtin.Endian.little);
    try file.writer().writeInt(u8, 0xFF, std.builtin.Endian.little);
    try file.writer().writeInt(u8, 0, std.builtin.Endian.little);

    // Padding
    try file.writer().writeInt(u8, 0, std.builtin.Endian.little);
    try file.writer().writeInt(u8, 0, std.builtin.Endian.little);
}

pub fn main() !void {
    const data = [2][2]Pixel{
        [2]Pixel{ Pixel{.red = 255}, Pixel{.red = 255, .green = 255, .blue = 255} },
        [2]Pixel{ Pixel{.blue = 255}, Pixel{.green = 255}},
    };

    try writeBMP(2, 2, &data);
}
