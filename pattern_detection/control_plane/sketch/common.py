import os

def write_variation_file(dist_dir, var_dict, file_name):
    os.makedirs(dist_dir, exist_ok=True)
    
    fileName = os.path.join(dist_dir, file_name)
    print("write variation to ", fileName)
    with open(fileName, 'w') as file:
        for key, vals in var_dict.items():
            line = key
            for val in vals:
                line = line + " " + str(val)
            line += '\n'
            file.write(line)
            