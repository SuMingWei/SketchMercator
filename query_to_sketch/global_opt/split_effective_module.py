import json
import argparse
import datetime
import os


# Because "effectiveness of each module" argument on run.py has 2 bruteforce results, 
# we need to split them into separate files
if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input', help='input file', default='effective_module/naive_sketch_selection_run_5.json', required=False)
    parser.add_argument('-o', '--output', help='output directory', default="effective_module/", required=False)
    args = parser.parse_args()

    with open(args.input, 'r') as f:
        js = json.load(f)
        # print(len(js))
        # runs = int((len(js) - 2)/4) # (length - 2 bruteforce) / 4 strawman

        for i in range(2): # 2 bruteforce
            filename = args.input.split('/')[-1][:-5]
            # print(filename)

            tmp = js[i]['name'].split(':')[1]
            if tmp == 'None':
                tmp = js[i]['name'].split(':')[2]
            # print(tmp)

            filename = filename + '_' + tmp
            print(filename)

            ret = []
            # put bruteforce result into result array
            ret.append(js[i])
            # put strawman result into result array
            for j in range(2, len(js)):
                ret.append(js[j])
            
            print('result length:', len(ret))

            if not os.path.exists(args.output):
                os.makedirs(args.output)

            path = args.output + '/' + filename + '.json'
            print(path)
            with open(path, 'w') as out:
                json.dump(ret, out)


            
