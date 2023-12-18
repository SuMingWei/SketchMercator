import os

f = open(os.path.join("compile9.sh"), "w+")

# for row in [2]:
#     for level in [1, 2, 3]:
# for row in [3, 5]:
#     for level in range(1, 11):
for row in [3]:
    for level in [8]:
        folder_name = "p416_original_univmon_row_%d_level_%02d_one" % (row, level)
        f.write("cd %s\n" % folder_name)
        f.write("$HW_HOME/compile.sh 9\n")
        f.write("cp -r $SDE/build/p4-build/%s/tofino/%s/pipe/logs .\n" % (folder_name, folder_name))
        f.write("cd ..\n")
        f.write("\n")
    f.write("\n")
f.close()

os.system("chmod u+x compile9.sh")
