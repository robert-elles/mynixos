import os

root_dir = '/home/robert/nextcloud/Photos/Albums/Azoren'

for current_dir, sub_dirs, filenames in os.walk(root_dir):
    for file in filenames:
        print(os.path.join(current_dir, file))
    for sub_dir in sub_dirs:
        print(os.path.join(current_dir, sub_dir))
