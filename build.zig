// IMPORT STANDARD LIBRARY
const std = @import("std");

// DO NOT EDIT THIS LINE
pub const version = "0.0.0";

// =====================================================================

// INFO

// This is an Structured Build Script with Zig Version 0.14.1 for
// C++ and C

//
//
// ========== Include Directorys ==========

// Source Code Directory
// The Directory which contains your written code files
pub const source_code_directory = "src";

// Path to other C++ or C+ Librarys
// Just them inside the List
pub const included_directorys = [_][]const u8{
    // "include",
    // "external/libfoo/include",
};

//
//
// ========== Programm Entry Point ==========

// Entry File
// The File with your main function
// The File must be in the source_code_directofy
const entry_file_tmp = "main.cpp";

// Language of the Entry File
// Change to c, if you use C
pub const entry_file_lang = "cpp";

//
//
// ========== Language Features ==========

// Version of the C++ Standard Library
pub const cpp_lang_version = "-std=c++17";
// Version of the C Standard Library
pub const c_lang_version = "-std=c11";

//
//
// ========== Testing ==========

// Name of the Tests Folder, where test code is stored
pub const test_folder = "test";

// Name of the Main File for the Tests
// File must be in the Test Directory
const test_entry_file_tmp = "test.cpp";

// Name of the Test Executable
pub const test_binary_name = "test_zig-with-c-and-cpp";

//
//
// ========== Exorting ==========

// Name of the Export Executable
pub const export_binary_name = "zig-with-c-and-cpp";

// Compiler Optimisation
// Set to true for export builds and false for Debug builds
pub const optimize_target = true;

//
//
// ==========================================================
//
// Credit Shadowdara
//
// LICENSE:
//
// IF YOUR PROJECT IS EITHER COMMERCIAL OR NOT OPEN SOURCE,
// CREDIT IS REQUIRED VIA MIT LICENSE
//
// IF NOT, NO CREDIT IS REQUIRED BUT WOULD BE APPRECIATED!
//
// ==========================================================
//
//

// Add Paths
pub const entry_file = comptimeConcat(source_code_directory, "/", entry_file_tmp);
pub const test_entry_file = comptimeConcat(test_folder, "/", test_entry_file_tmp);

//
// Source Code Functions
//

// add 3 Strings together
fn comptimeConcat(a: []const u8, b: []const u8, c: []const u8) []const u8 {
    return a ++ b ++ c;
}

// Get Lang for the entry File
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

// Build Function for the Executable
pub fn build(b: *std.Build) void {
    std.debug.print("Zig Build Script Version: {s}\n\n", .{version});

    const target = b.standardTargetOptions(.{});

    // Change to ReleaseFast for Export Builds
    const optimize = if (optimize_target) b.standardOptimizeOption(.{}) else b.ReleaseFast;

    // Collect all C++ Files in source Directory
    const cpp_files = collectCppFiles(b, source_code_directory) catch unreachable;
    // Collect all C Files in source Directory
    const c_files = collectCFiles(b, source_code_directory) catch unreachable;

    //
    //
    // Export Executable
    //
    //
    const exe = b.addExecutable(.{
        // Name of the export binary
        .name = export_binary_name,

        .target = target,
        .optimize = optimize,

        // Use null when the main function is either in C or C++
        .root_source_file = null,
    });

    // Add an C++ Source File
    exe.addCSourceFiles(.{
        .files = &.{entry_file},
        // Version of the Standard Library
        .flags = &.{getEntryFileLang()},
    });

    // Add C++ Source Files
    exe.addCSourceFiles(.{
        .files = cpp_files,
        // Version of the Standard Library
        .flags = &.{cpp_lang_version},
    });

    // Add C Source Files
    exe.addCSourceFiles(.{
        .files = c_files,
        // Version of the Standard Library
        .flags = &.{c_lang_version},
    });

    // Add Library Directories
    for (included_directorys) |path| {
        exe.addIncludePath(b.path(path));
    }

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

    //
    //
    // Building and Running the Testprogramm
    //
    //
    const tests = b.addExecutable(.{
        // Executable Name
        .name = test_binary_name,

        .target = target,
        .optimize = optimize,

        .root_source_file = null,
    });

    // Add Entry File for the Test Run
    tests.addCSourceFiles(.{
        .files = &.{test_entry_file},
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

    // Add Library Directories
    for (included_directorys) |path| {
        tests.addIncludePath(b.path(path));
    }

    // Add C and C++ Standard Library to the tests
    tests.linkLibC();
    tests.linkLibCpp();

    //
    //
    //

    const run_tests = b.addRunArtifact(tests);
    b.step("test", "Build and run tests").dependOn(&run_tests.step);

    // Run Tests after the Build
    b.getInstallStep().dependOn(&run_tests.step);

    std.debug.print("Build Script End\n\n", .{});
}

//
//
//
//
//
// TODO
//
// add option for including directories, like librarys
// -> feature need to be tested
//
// add option to although include zig files to the build
//
