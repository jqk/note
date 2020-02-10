c:
cd \
md Scoop
cd Scoop
xcopy \\ssd-win10\vm_share\scoop\apps apps /E
xcopy \\ssd-win10\vm_share\scoop\shims shims /E
mklink /d cache \\ssd-win10\vm_share\scoop\cache
mklink /d buckets \\ssd-win10\vm_share\scoop\buckets