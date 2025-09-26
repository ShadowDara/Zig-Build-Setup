const std = @import("std");

// =====================================================================

// INFO

// This is an Structured Build Script with Zig Version 0.14.1 for
// C++ and C

// Source Code Directory
// The Directory which contains your written code files
pub const source_code_directory = "src";

// Compiler Optimisation
// Set to true for export builds and false for Debug builds
pub const optimize_target = true;

// Entry File
// The File with your main function
pub const entry_file = "main.cpp";

// Language of the Entry File
// Change to c, if you use C
pub const entry_file_lang = "cpp";

// Name of the Export Executable
pub const export_binary_name = "zig-with-c-and-cpp";

// Name of the Test Executable
pub const test_binary_name = "test_zig-with-c-and-cpp";

// Version of the C++ Standard Library
pub const cpp_lang_version = "-std=c++17";
// Version of the C Standard Library
pub const c_lang_version = "-std=c11";

// =====================================================================
//
//
//

// Source Code Functions

fn getEntryFileLang() []const u8 {
    if (std.mem.eql(u8, entry_file_lang, "cpp")) {
        return cpp_lang_version;
    } else {
        return c_lang_version;
    }
}

// Function to Collect all C++ Files
fn collectCppFiles(b: *std.Build, dir_path: []const u8) ![]const []const u8 {
    const allocator = b.allocator;
    var file_list = std.ArrayList([]const u8).init(allocator);

    const dir = try std.fs.cwd().openDir(dir_path, .{ .iterate = true });
    var walker = try dir.walk(allocator);

    while (try walker.next()) |entry| {
        if (entry.kind == .file and
            std.mem.endsWith(u8, entry.path, ".cpp") and
            !std.mem.eql(u8, entry.path, entry_file))
        {
            try file_list.append(b.pathJoin(&.{ dir_path, entry.path }));
        }
    }

    return file_list.toOwnedSlice();
}

// Function to Collect all C Files
fn collectCFiles(b: *std.Build, dir_path: []const u8) ![]const []const u8 {
    const allocator = b.allocator;
    var file_list = std.ArrayList([]const u8).init(allocator);

    const dir = try std.fs.cwd().openDir(dir_path, .{ .iterate = true });
    var walker = try dir.walk(allocator);

    while (try walker.next()) |entry| {
        if (entry.kind == .file and
            std.mem.endsWith(u8, entry.path, ".c") and
            !std.mem.eql(u8, entry.path, entry_file))
        {
            try file_list.append(b.pathJoin(&.{ dir_path, entry.path }));
        }
    }

    return file_list.toOwnedSlice();
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    // Change to ReleaseFast for Export Builds
    const optimize = if (optimize_target) b.standardOptimizeOption(.{}) else b.ReleaseFast;

    const exe = b.addExecutable(.{
        // Name of the export binary
        .name = export_binary_name,

        .target = target,
        .optimize = optimize,

        // Use null when the main function is either in C or C++
        .root_source_file = null,
    });

    // Collect all C++ Files in source Directory
    const cpp_files = collectCppFiles(b, source_code_directory) catch unreachable;
    // Collect all C Files in source Directory
    const c_files = collectCFiles(b, source_code_directory) catch unreachable;

    // Add an C++ Source File
    exe.addCSourceFiles(.{
        .files = &.{entry_file},
        // Version of the Standard Library
        .flags = &.{getEntryFileLang()},
    });

    // Add C++ Source Files
    exe.addCSourceFiles(.{
        .files = cpp_files,
        .flags = &.{cpp_lang_version},
    });

    // Add C Source Files
    exe.addCSourceFiles(.{
        .files = c_files,
        .flags = &.{c_lang_version},
    });

    // Link Standard Library for C
    exe.linkLibC();

    // Link Standard Library for C++
    exe.linkLibCpp();

    // include src Path
    exe.addIncludePath(b.path(source_code_directory));

    b.installArtifact(exe);

    // to run the programm
    const run_cmd = b.addRunArtifact(exe);
    const run_step = b.step("run", "Build and execute the programm");
    run_step.dependOn(&run_cmd.step);

    // Building and Running the Testprogramm
    const tests = b.addExecutable(.{
        // Executable Name
        .name = test_binary_name,

        .target = target,
        .optimize = optimize,

        .root_source_file = null,
    });

    // Add Entry File for the Test Run
    tests.addCSourceFiles(.{
        .files = &.{entry_file},
        // Version of the Standard Library
        .flags = &.{getEntryFileLang()},
    });

    // Add C++ Files to the Test Binary
    tests.addCSourceFiles(.{
        .files = cpp_files,
        // Version of the Standard Library
        .flags = &.{cpp_lang_version},
    });

    // Add C Files to the Test Binary
    tests.addCSourceFiles(.{
        .files = c_files,
        // Version of the Standard Library
        .flags = &.{c_lang_version},
    });

    // Add C and C++ Standard Library to the tests
    tests.linkLibC();
    tests.linkLibCpp();

    const run_tests = b.addRunArtifact(tests);
    b.step("test", "Build and run tests").dependOn(&run_tests.step);

    // Run Tests after the Build
    b.getInstallStep().dependOn(&run_tests.step);
}
