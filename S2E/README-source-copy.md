# S2E Source Snapshot

Source: `/home/sjz/S2E/` (resolves to `/data/sjz/S2E-home/`).
Destination: `/data3/sjz/AE/S2E/`.

This is an independent source copy, including the current working-tree edits,
untracked plugin source files, repository metadata, S2E core/plugins, QEMU,
guest/kernel sources, build scripts, both s2e-env source checkouts, and local
C/C++ helper sources. `s2e/source/` retains the original repo layout.

Build/install directories, the Python virtual environment and packaging cache,
locally generated QEMU files, locally compiled helper executables, guest images,
experiment projects/results, and the generated activation script are excluded.
The exclusion lists are stored beside this note. Upstream source assets remain
with their repositories. No build, installation, or environment activation was
performed, and the original S2E installation was not modified.

The existing MySQL batch continues to use its original S2E installation. Before
using this new source tree, build it and create a separate virtual environment,
activation script, guest images, and project configuration for the new location.
