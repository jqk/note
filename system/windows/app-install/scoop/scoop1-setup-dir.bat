c:
cd \
md Scoop
cd Scoop
xcopy %1\scoop\apps apps /E
xcopy %1\scoop\shims shims /E
mklink /d cache %1\scoop\cache
mklink /d buckets %1%\scoop\buckets
dir
