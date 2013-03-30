@echo off
for %%f in (*.mp3) do (  mp3packer.exe -z -u --keep-ok out "%%f"  )