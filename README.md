# testVerilogIgorsConfig
A test repo for trying out Igor Freire's dev container setup.

https://igorfreire.com.br/blog/

I made some modifications so I could the container to run as vscode.
## Using as an Installable Framework

This repository can be added as a **git submodule** in another Verilog project and
then installed into the parent directory via `make install`.

1. In your main project run:

```sh
git submodule add <url-to-this-repo> tools/verilog-framework
```

2. Enter the submodule and invoke the install target (optionally override
   `INSTALL_DIR` if you want a different destination):

```sh
cd tools/verilog-framework
make install            # copies files to parent directory
# or
make install INSTALL_DIR=/path/to/your/project
```

The `install` target uses `rsync` to mirror the framework files while skipping
`.git` metadata and transient build artifacts (`*.out`, `*.vcd`, etc.).

Once installed, you can adapt the `Makefile` and sources in your top-level
project as needed.

### Removing the Framework

If you ever want to undo the installation use the new `uninstall` target. It
relies on a small record file placed in the install directory called
`.verilog_framework_installed` (created by `make install`). To remove the files
that were copied earlier run:

```sh
cd tools/verilog-framework  # or wherever the submodule lives
make uninstall             # respects INSTALL_DIR like the install rule
```

This will delete each top‑level item listed in the record and then remove the
record itself. If the record file is missing, the command will abort with an
error message so it won’t accidentally wipe unrelated files.
