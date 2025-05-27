How to write a patch!

1) Copy the patched program into `/tmp/`
```console
cp -r <src> /tmp/src_patched
```

2) Copy the original program into `/tmp/`
```console
cp -r <src> /tmp/src_original
```

3) Make a diff between original program and the patched one, like:
```console
cd /tmp/
diff -Naur src_original/ src_patched/ > mypatch.patch
```

4) Save the patch in the project
```console
mv /tmp/mypatch.patch <VTYPE_PROJECT_FOLDER>/spec_cpu/patch/
```

5) Add the patch command to `apply_pathes.sh`
```console
cd <src to patch>
patch -p1 < mypatch.patch
```

