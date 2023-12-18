import os

def hun_mkdir(path):
    if not os.path.isdir(path):
        os.makedirs(path)
