import configparser

def read_config_ini(file_path):
    cp = configparser.ConfigParser()
    cp.optionxform = str
    cp.read(file_path)
    return cp
