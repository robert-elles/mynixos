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
# PXL_20220713_091359320.mp4
pxl_format = re.compile(r'PXL_(\d{8})_(\d{9}).?')


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
    elif re.match(other_image_format, filename):
        date_parts = filename.split('_')
        date_str = date_parts[1] + date_parts[2].split(".")[0]
        return datetime.strptime(date_str, '%Y%m%d%H%M%S')
    else:
        raise ValueError("Unsupported format")


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
                            date_str = date.strftime("%Y:%m:%d %H:%M:%S.%f")
                            print("writing: " + date_str + " -> " + filename)
                            exif_dict['Exif'][
                                piexif.ExifIFD.DateTimeOriginal] = date_str
                            exif_bytes = piexif.dump(exif_dict)
                            # piexif.insert(exif_bytes, file)
                        else:
                            print("could not determine date: " + file)
                    else:
                        print("does not match: " + filename)


class TestImageOrg(unittest.TestCase):

    def test_match_and_parse(self):
        param_list = [
            ('IMG_20181028_182327.jpg', datetime(2018, 10, 28, 18, 23, 27)),
            ('00000IMG_00000_BURST20190127011008_COVER.jpg', datetime(2019, 1, 27, 1, 10, 8)),
            ('00002IMG_00002_BURST20190127011008.jpg', datetime(2019, 1, 27, 1, 10, 8)),
            ('IMG-20181028-WA.jpg', datetime(2018, 10, 28)),
            ('PXL_20220713_091359320.mp4', datetime(2022, 7, 13, 9, 13, 59, 320)),
            ('PXL_20210320_024141416.LS.mp4', datetime(2021, 3, 20, 2, 41, 41, 416)),
            ('PXL_20211105_151815472_exported_233.jpg', datetime(2021, 11, 5, 15, 18, 15, 472)),
            ('signal-2021-08-26-15-26-13-764.jpg', datetime(2021, 8, 26, 15, 26, 12, 764)),
            ('signal-2022-07-27-21-03-10-120-1.jpg ', datetime(2022, 7, 27, 21, 3, 10, 120)),
            ('2013-05-01 21.00.39.mp4', datetime(2013, 5, 1, 21, 0, 39)),
            ('2013-05-01 18.22.26.jpg', datetime(2013, 5, 1, 18, 22, 26)),
            ('2013-04-26 18.59.48.JPG', datetime(2013, 4, 26, 18, 59, 48)),
            ('VID_20171028_231100.mp4', datetime(2017, 10, 28, 23, 11, 0)),
            ('PANO_20171108_172445.jpg', datetime(2017, 11, 8, 17, 24, 45)),
            ('20150806_163213.mp4', datetime(2015, 8, 6, 16, 32, 13)),
            ('20131222_080244.jpg', datetime(2013, 12, 22, 8, 2, 44)),
            ('threema-20220909-125017145.jpg', datetime(2022, 9, 9, 12, 50, 17, 145)),
            ('2013-06-02 18-7e3193a1.43.52.jpg', datetime(2013, 6, 2, 18, 43, 52)),
            ('MVIMG_20181024_213921.jpg', datetime(2018, 10, 24, 21, 39, 21)),
            ('FJIMG_20191203_164729.jpg', datetime(2019, 12, 3, 16, 47, 29)),
        ]
        for filename, expected_date in param_list:
            with self.subTest(filename):
                self.assertTrue(matches(filename), filename + " does not match")
                self.assertEqual(parse_date(filename), expected_date, filename + " does not parse")


if __name__ == '__test__':
    unittest.main(verbosity=2)
elif __name__ == '__main__':
    restore_date_metadata()
