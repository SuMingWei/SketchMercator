import plot.plot_common as pc
# import importlib
# importlib.reload(pc)

out = "../workload_manage/sensitivity/output"

output = {}
for i in range(2, 3):
    filename = "workload_%d.pkl" % i
    output[filename] = pc.data_read(out, filename)

ret_dict = {}
for k, v in output.items():
    print(k)
    if k != "workload_2.pkl":
        continue
    output_dict = v

    ret = pc.data_parse_breakdown(output_dict["gd"]["bf"]["bf"], output_dict["o5"])
    ret_dict[k] = ret

