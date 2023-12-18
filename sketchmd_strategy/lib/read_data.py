from python_lib.pkl_saver import PklSaver

def data_read(out, filename):
    print(f"[load output] {out} {filename}")
    out_saver = PklSaver(out, filename)
    if out_saver.file_exist():
        output_dict = out_saver.load()
        # for k, v in output_dict.items():
        #     print(k, len(v))
        print("[success]")
    else:
        print("No output file, exit")
        exit(1)
    return output_dict
