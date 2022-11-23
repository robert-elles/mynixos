import os
import piexif
from datetime import datetime
import re
import time
import unittest

# root_dir = '/home/robert/nextcloud/Photos/Albums/Azoren'
root_dir = '/home/robert/nextcloud/Photos/'

supported_file_types = {'mp4', '3gp', 'jpg', 'jpeg', 'tif', 'dng', 'mov', 'avi',
                        'nef'}

whatsapp_format_regex = re.compile(r'(IMG|VID)-(\d{8})-WA.*\.(jpe?g|mp4|3gp)')
other_image_format = re.compile(r'IMG_(\d{8})_(\d{6}).jpg')


def get_datetime(filename):
    date_str = filename.split('-')[1]
    return datetime.strptime(date_str, '%Y%m%d')


def parse_date(filename):
    if re.match(whatsapp_format_regex, filename):
        date_str = filename.split('-')[1]
        # return datetime.strptime(date_str, '%Y%m%d').strftime("%Y:%m:%d %H:%M:%S")
        print("Parsing whatsapp format: " + filename)
        return datetime.strptime(date_str, '%Y%m%d')
    else:
        date_str = filename.split('_')
        return datetime.strptime(date_str[1] + date_str[2].split(".")[0], '%Y%m%d%H%M%S')


def is_media_file(filename):
    if "." in filename:
        file_type = filename.split(".")[-1]
        if file_type:
            return file_type.lower() in supported_file_types
    return False


def get_exif(file):
    try:
        return piexif.load(file)
    except ValueError:
        return {'Exif': {piexif.ExifIFD.DateTimeOriginal: None}}


def has_date(exif_dict):
    exif = exif_dict["Exif"]
    if piexif.ExifIFD.DateTimeOriginal not in exif:
        return False
    else:
        date_original = exif[piexif.ExifIFD.DateTimeOriginal]
        if date_original is None:
            return False
    return True


def matches(filename):
    return re.match(whatsapp_format_regex, filename) or re.match(
        other_image_format, filename)


def restore_date_metadata():
    for current_dir, sub_dirs, filenames in os.walk(root_dir):
        for filename in filenames:
            file = os.path.join(current_dir, filename)
            if is_media_file(filename):
                exif_dict = get_exif(file)
                if not has_date(exif_dict):
                    if matches(filename):
                        date = parse_date(filename)
                        if date:
                            print("writing the date: " + file)
                            exif_dict['Exif'][
                                piexif.ExifIFD.DateTimeOriginal] = date
                            exif_bytes = piexif.dump(exif_dict)
                            piexif.insert(exif_bytes, file)
                        else:
                            print("could not determine date: " + file)
                    else:
                        print("does not match: " + filename)


class TestImageOrg(unittest.TestCase):

    def test_matches_hyphen(self):
        filename = 'IMG-20181028-WA.jpg'
        self.assertTrue(matches(filename))

    def test_matches_underscore(self):
        filename = 'IMG_20181028_182327.jpg'
        self.assertTrue(matches(filename))

    def test_parse_date_hypen(self):
        filename = 'IMG-20181028-WA.jpg'
        parsed_date = parse_date(filename)
        self.assertEqual(parsed_date, datetime(2018, 10, 28))

    def test_parse_date_underscore(self):
        filename = 'IMG_20181028_182327.jpg'
        parsed_date = parse_date(filename)
        self.assertEqual(parsed_date, datetime(2018, 10, 28, 18, 23, 27))


if __name__ == '__test__':
    unittest.main(verbosity=2)
elif __name__ == '__main__':
    restore_date_metadata()
