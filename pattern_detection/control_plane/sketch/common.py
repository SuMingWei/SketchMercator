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
            
def write_summation_file(dist_dir, var_list, file_name):
    os.makedirs(dist_dir, exist_ok=True)
    
    fileName = os.path.join(dist_dir, file_name)
    print("write varation in summation to ", fileName)
    with open(fileName, 'w') as file:
        line = ""
        for val in var_list:
            line += str(val) + " "
        line += '\n'
        file.write(line)
        
def write_fsd_file(dist_dir, fsd_dict, folder, file_name):
    folder_path = os.path.join(dist_dir, folder)
    os.makedirs(folder_path, exist_ok=True)
    
    tmpFileName = file_name + ".txt"
    fileName = os.path.join(folder_path, tmpFileName)
    print("write fsd to ", fileName)
    with open(fileName, 'w') as file:
        for size, freq in fsd_dict.items():         
            line = str(size) + " " + str(freq) + "\n"
            file.write(line)