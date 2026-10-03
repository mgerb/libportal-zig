# libportal-zig

Zig bindings and static library for [libportal](https://github.com/flatpak/libportal).

## Install

```sh
zig fetch --save git+https://github.com/mgerb/libportal-zig
```

## How to use

```zig
// build.zig
const exe = b.addExecutable(.{
    .name = "main",
    .root_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    }),
});

const libportal = b.dependency("libportal_zig", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("libportal", libportal.module("libportal"));
exe.root_module.linkLibrary(libportal.artifact("portal"));
```

**NOTE:** libportal dynamically links to the following libraries

- libc
- gio
- glib
- gobject

## Run the example

```sh
nix develop -c zig build run
```

## Build the static library

```sh
nix develop -c zig build
```

The archive is written to `zig-out/lib/libportal.a`.
