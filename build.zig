const std = @import("std");

const LibportalBuild = struct {
    library: *std.Build.Step.Compile,
    generated_include: std.Build.LazyPath,
    source_include: std.Build.LazyPath,
    libportal_include: std.Build.LazyPath,
};

fn build_static_library(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) LibportalBuild {
    const libportal_source = b.dependency("libportal", .{});

    const public_headers = [_][]const u8{
        "portal.h",
        "portal-helpers.h",
        "account.h",
        "background.h",
        "camera.h",
        "clipboard.h",
        "dynamic-launcher.h",
        "email.h",
        "filechooser.h",
        "inhibit.h",
        "inputcapture.h",
        "inputcapture-zone.h",
        "inputcapture-pointerbarrier.h",
        "location.h",
        "notification.h",
        "openuri.h",
        "parent.h",
        "print.h",
        "remote.h",
        "screenshot.h",
        "session.h",
        "settings.h",
        "spawn.h",
        "trash.h",
        "types.h",
        "updates.h",
        "wallpaper.h",
    };

    const generate_enums_h = b.addSystemCommand(&.{"glib-mkenums"});
    generate_enums_h.addPrefixedFileArg("--template=", libportal_source.path("libportal/portal-enums.h.template"));
    const portal_enums_h = generate_enums_h.addPrefixedOutputFileArg("--output=", "portal-enums.h");

    const generate_enums_c = b.addSystemCommand(&.{"glib-mkenums"});
    generate_enums_c.addPrefixedFileArg("--template=", libportal_source.path("libportal/portal-enums.c.template"));
    const portal_enums_c = generate_enums_c.addPrefixedOutputFileArg("--output=", "portal-enums.c");

    inline for (public_headers) |header| {
        const header_path = libportal_source.path("libportal/" ++ header);
        generate_enums_h.addFileArg(header_path);
        generate_enums_c.addFileArg(header_path);
    }

    const generated_files = b.addWriteFiles();
    _ = generated_files.addCopyFile(portal_enums_h, "portal-enums.h");
    _ = generated_files.addCopyFile(portal_enums_h, "libportal/portal-enums.h");
    const generated = generated_files.getDirectory();

    const config_h = b.addConfigHeader(.{
        .style = .blank,
        .include_path = "config.h",
    }, .{
        .APPDATADIR = "",
        .G_LOG_DOMAIN = "libportal",
        .HAVE_SYS_VFS_H = {},
        .PACKAGE_NAME = "libportal",
        .PKGDATADIR = "",
    });
    config_h.addIdent("XDP_PUBLIC", "__attribute__((visibility(\"default\"))) extern");

    const libportal = b.addLibrary(.{
        .name = "portal",
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });

    const c_flags = &.{
        "-Wno-unused-parameter",
        "-Wno-missing-field-initializers",
    };

    libportal.root_module.addCSourceFiles(.{
        .root = libportal_source.path("libportal"),
        .files = &.{
            "account.c",
            "background.c",
            "camera.c",
            "clipboard.c",
            "dynamic-launcher.c",
            "email.c",
            "filechooser.c",
            "inhibit.c",
            "inputcapture.c",
            "inputcapture-zone.c",
            "inputcapture-pointerbarrier.c",
            "location.c",
            "notification.c",
            "openuri.c",
            "parent.c",
            "portal.c",
            "print.c",
            "remote.c",
            "screenshot.c",
            "session.c",
            "settings.c",
            "spawn.c",
            "trash.c",
            "updates.c",
            "wallpaper.c",
        },
        .flags = c_flags,
    });
    libportal.root_module.addCSourceFile(.{
        .file = portal_enums_c,
        .flags = c_flags,
    });

    libportal.root_module.addIncludePath(generated);
    libportal.root_module.addIncludePath(libportal_source.path(""));
    libportal.root_module.addIncludePath(libportal_source.path("libportal"));
    libportal.root_module.addConfigHeader(config_h);
    libportal.root_module.linkSystemLibrary("gio-unix-2.0", .{
        .use_pkg_config = .force,
    });
    libportal.root_module.linkSystemLibrary("gio-2.0", .{});
    libportal.root_module.linkSystemLibrary("gobject-2.0", .{});
    libportal.root_module.linkSystemLibrary("glib-2.0", .{});

    return .{
        .library = libportal,
        .generated_include = generated,
        .source_include = libportal_source.path(""),
        .libportal_include = libportal_source.path("libportal"),
    };
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const libportal = build_static_library(b, target, optimize);

    const translate_libportal = b.addTranslateC(.{
        .root_source_file = b.path("src/libportal_translate.h"),
        .target = target,
        .optimize = optimize,
    });
    translate_libportal.addIncludePath(libportal.generated_include);
    translate_libportal.addIncludePath(libportal.source_include);
    translate_libportal.addIncludePath(libportal.libportal_include);
    translate_libportal.linkSystemLibrary("gio-2.0", .{});
    translate_libportal.linkSystemLibrary("gobject-2.0", .{});
    translate_libportal.linkSystemLibrary("glib-2.0", .{});
    const libportal_module = translate_libportal.addModule("libportal");

    b.installArtifact(libportal.library);

    // Build example.
    // ----------------------------------------------------------------------------
    const example = b.addExecutable(.{
        .name = "example-libportal",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/example.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    example.root_module.addImport("libportal", libportal_module);
    example.root_module.linkLibrary(libportal.library);

    const run_example = b.addRunArtifact(example);
    const run_step = b.step("run", "Run the hello world example");
    run_step.dependOn(&run_example.step);
    // ----------------------------------------------------------------------------
}
