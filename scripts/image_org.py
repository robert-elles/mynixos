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
burst_image_format = re.compile(r'(\d{5})IMG_(\d{5})_BURST(\d{14}).?')


def get_datetime(filename):
    date_str = filename.split('-')[1]
    return datetime.strptime(date_str, '%Y%m%d')


def parse_date(filename):
    if re.match(whatsapp_format_regex, filename):
        date_str = filename.split('-')[1]
        print("Parsing whatsapp format: " + filename)
        return datetime.strptime(date_str, '%Y%m%d')
    elif re.match(burst_image_format, filename):
        burst_part = filename.split("_")[2]
        date_str = burst_part[5:19]
        return datetime.strptime(date_str, '%Y%m%d%H%M%S')
    else:
        date_parts = filename.split('_')
        date_str = date_parts[1] + date_parts[2].split(".")[0]
        return datetime.strptime(date_str, '%Y%m%d%H%M%S')


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
    return re.match(whatsapp_format_regex, filename) \
           or re.match(other_image_format, filename) \
           or re.match(burst_image_format, filename)


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
                                piexif.ExifIFD.DateTimeOriginal] = date.strftime("%Y:%m:%d %H:%M:%S")
                            exif_bytes = piexif.dump(exif_dict)
                            # piexif.insert(exif_bytes, file)
                        else:
                            print("could not determine date: " + file)
                    else:
                        print("does not match: " + filename)


class TestImageOrg(unittest.TestCase):

    def test_match_and_parse(self):
        data = [
            ('PXL_20220713_091359320.mp4', datetime())
            ('signal-2021-08-26-15-26-13-764.jpg', datetime())
            ('signal-2022-07-27-21-03-10-120-1.jpg ', datetime())
            ('2013-05-01 21.00.39.mp4', datetime())
            ('2013-05-01 18.22.26.jpg', datetime())
            ('2013-04-26 18.59.48.JPG', datetime())
            ('VID_20171028_231100.mp4', datetime())
            ('PANO_20171108_172445.jpg', datetime())
            ('20150806_163213.mp4', datetime())
            ('20131222_080244.jpg', datetime())
            ('threema-20220909-125017145.jpg', datetime())
            ('2013-06-02 18-7e3193a1.43.52.jpg', datetime())
            ('MVIMG_20181024_213921.jpg', datetime())
            ('FJIMG_20191203_164729.jpg', datetime())
        ]

    def test_matches_contains_burst(self):
        file1 = '00000IMG_00000_BURST20190127011008_COVER.jpg'
        self.assertTrue(matches(file1))
        file2 = '00002IMG_00002_BURST20190127011008.jpg'
        self.assertTrue(matches(file2))

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

    def test_parse_date_contains_burst(self):
        file1 = '00000IMG_00000_BURST20190127011008_COVER.jpg'
        self.assertEqual(parse_date(file1), datetime(2019, 1, 27, 1, 10, 8))
        file2 = '00002IMG_00002_BURST20190127011008.jpg'
        self.assertEqual(parse_date(file2), datetime(2019, 1, 27, 1, 10, 8))


if __name__ == '__test__':
    unittest.main(verbosity=2)
elif __name__ == '__main__':
    restore_date_metadata()
