#
# https://github.com/sylikc/pyexiftool
# https://sylikc.github.io/pyexiftool/
#
import os
import re
import traceback
import unittest
from datetime import datetime, timezone, timedelta

from exiftool import ExifToolHelper

from progress import ProgressBar

write_data = True
print_date_candidates = True
root_dir = '/home/robert/nextcloud/Photos/'

video_types = {'mp4', '3gp', 'mov'}
supported_file_types = {'jpg', 'jpeg', 'tif', 'dng', 'nef'}.union(video_types)

et = ExifToolHelper()
date_pattern = re.compile(r"\d{4}:\d{2}:\d{2} \d{2}:\d{2}:\d{2}.?")
alternative_date_keys = {'EXIF:ModifyDate', 'File:FileModifyDate'}

whatsapp_format_regex = re.compile(r'(IMG|VID)-(\d{8})-WA.*\.(jpe?g|mp4|3gp)')
burst_image_format = re.compile(r'(\d{5})IMG_(\d{5})_BURST(\d{14}).?')
# PXL_20220713_091359320.mp4
pxl_format = re.compile(r'PXL_(\d{8})_(\d{9}).?')
# signal-2022-07-27-21-03-10-120-1.jpg
signal_format = re.compile(
    r'signal-\d{4}-\d{2}-\d{2}-\d{2}-\d{2}-\d{2}-\d{3}.?')
# threema-20220909-125017145.jpg
threema_format = re.compile(r'threema-\d{8}-\d{9}\.(jpg|mp4)')
# 2013-06-02 18-7e3193a1.43.52.jpg
f1_image_format = re.compile(r'\d{4}-\d{2}-\d{2} \d{2}-.{8}\.\d{2}\.\d{2}.jpg')
# 2013-05-01 21.00.39.mp4
f2_image_format = re.compile(r'\d{4}-\d{2}-\d{2} \d{2}\.\d{2}\.\d{2}.?')
# VID_20171028_231100.mp4
f3_image_format = re.compile(
    r'(IMG_|VID_|PANO_|MVIMG_|FJIMG_|FJVID_)\d{8}_\d{6}\.(mp4|jpg)')
# 20150806_163213.mp4
f4_image_format = re.compile(r'\d{8}_\d{6}\.(mp4|jpg)')

patterns = [
    whatsapp_format_regex,
    burst_image_format,
    pxl_format,
    signal_format,
    threema_format,
    f1_image_format,
    f2_image_format,
    f3_image_format,
    f4_image_format,
]


def parse_date(filename):
    if whatsapp_format_regex.match(filename):
        date_str = filename.split('-')[1]
        return datetime.strptime(date_str, '%Y%m%d')
    elif burst_image_format.match(filename):
        burst_part = filename.split("_")[2]
        date_str = burst_part[5:19]
        return datetime.strptime(date_str, '%Y%m%d%H%M%S')
    elif f1_image_format.match(filename):  # 2013-06-02 18-7e3193a1.43.52.jpg
        date_parts = filename.split('-')
        time_parts = date_parts[-1].split(".")
        date_str = "".join(date_parts[:3]) + "".join(time_parts[1:3])
        return datetime.strptime(date_str, '%Y%m%d %H%M%S')
    elif pxl_format.match(filename):
        date_parts = filename.split("_")
        date_str = date_parts[1] + date_parts[2][0:9]
        return datetime.strptime(date_str, '%Y%m%d%H%M%S%f')
    elif signal_format.match(filename):
        date_parts = filename.split("-")
        date_str = "".join(date_parts[1:7]) + date_parts[7][:3]
        return datetime.strptime(date_str, '%Y%m%d%H%M%S%f')
    elif threema_format.match(filename):
        return datetime.strptime(filename.split(".")[0],
                                 'threema-%Y%m%d-%H%M%S%f')
    elif f2_image_format.match(filename):
        date_str = filename[:19]
        return datetime.strptime(date_str, '%Y-%m-%d %H.%M.%S')
    elif f3_image_format.match(filename):
        date_parts = filename.split("_")
        date_str = date_parts[1] + date_parts[2][:6]
        return datetime.strptime(date_str, '%Y%m%d%H%M%S')
    elif f4_image_format.match(filename):
        date_str = filename[:15]
        return datetime.strptime(date_str, '%Y%m%d_%H%M%S')
    else:
        raise ValueError("Unsupported format")


def is_supported_file(filename):
    if "." in filename:
        file_type = filename.split(".")[-1]
        if file_type:
            return file_type.lower() in supported_file_types
    return False


def matches(filename):
    matched_pattern = None
    for pattern in patterns:
        if pattern.match(filename):
            if matched_pattern:
                msg = f"Pattern {str(pattern)} and {matched_pattern} mach the same value {filename}"
                raise ValueError(msg)
            else:
                matched_pattern = str(pattern)
    return matched_pattern is not None


def get_type(file):
    if "." in file:
        file_type = file.split(".")[-1]
        if file_type:
            return file_type.lower()
    raise ValueError(f"{file} has no file type ending")


def is_date_info_missing(file):
    meta = et.get_metadata(file)
    if meta:
        if len(meta) > 1:
            raise ValueError(f"{file}'s metadata has more than one array")
        file_type = file.split(".")[-1].lower()
        key = "EXIF:DateTimeOriginal"
        if file_type in video_types:
            key = 'QuickTime:CreateDate'
        if key in meta[0]:
            val = meta[0][key]
            if val and val != '0000:00:00 00:00:00':
                return False
    return True


def write_date(file, date):
    date_str = date.strftime("%Y:%m:%d %H:%M:%S.%f%z")
    print(f"writing: {date_str} -> {file}")
    if write_data:
        key = "EXIF:DateTimeOriginal"
        if get_type(file) in video_types:
            key = "QuickTime:CreateDate"
        et.set_tags(
            [file],
            tags={key: date},
            params=["-P", "-overwrite_original"]
        )


def get_date(file):
    filename = file.split("/")[-1]
    if matches(filename):
        date = parse_date(filename)
        if date:
            return date
    meta = et.get_metadata(file)
    date = None
    alt_key = None
    for m in meta:
        for alt_date_key in alternative_date_keys:
            if alt_date_key in m:
                date_str = m[alt_date_key]
                new_date = parse_date_str(date_str)
                if not date or new_date < date:
                    date = new_date
                    alt_key = alt_date_key
    print(f"File {file}")
    if date:
        print(f'found alternative date {alt_key}: {date}')
    else:
        print("couldn't find suitable date")
    if print_date_candidates:
        print("alternative date candidates are:")
        for m in meta:
            for k, v in m.items():
                if date_pattern.match(str(v)):
                    print(f"{k} = {v}")
    return date


def parse_date_str(date_str):
    date_format = '%Y:%m:%d %H:%M:%S%z'
    date_str = date_str + ("+00:00" if "+" not in date_str else "")
    new_date = datetime.strptime(date_str, date_format)
    return new_date


def total_files():
    cnt = 0
    for current_dir, sub_dirs, filenames in os.walk(root_dir):
        for filename in filenames:
            cnt += 1
    return cnt


def restore_date_metadata():
    pbar = ProgressBar(total_files())
    for current_dir, sub_dirs, filenames in os.walk(root_dir):
        for filename in filenames:
            pbar.progress(filename)
            try:
                analyze_file(current_dir, filename)
            except Exception as e:
                print(f"Error analysing file {os.path.join(current_dir, filename)}: {e}")
                print(traceback.format_exc())


def analyze_file(current_dir, filename):
    file = os.path.join(current_dir, filename)
    if is_supported_file(filename):
        if is_date_info_missing(file):
            date = get_date(file)
            if date:
                write_date(file, date)


class TestImageOrg(unittest.TestCase):

    def test_parse_date_str(self):
        d = parse_date_str("2019:01:28 14:39:07")
        self.assertEqual(d, datetime(2019, 1, 28, 14, 39, 7, tzinfo=timezone.utc))
        d = parse_date_str("2011:09:06 14:00:42+02:00")
        self.assertEqual(d, datetime(2011, 9, 6, 14, 0, 42, 0, timezone(timedelta(seconds=7200))))

    def test_get_date_info(self):
        metadata = et.get_metadata("./video.mp4")
        date_info = metadata[0]['QuickTime:CreateDate']

    def test_print_meta_data(self):
        base = "/home/robert/nextcloud/Photos/"
        file = base + "Albums/Fliegen/Landung Hoch.AVI"
        for d in et.get_metadata(file):
            for k, v in d.items():
                print(f"{k} = {v}")

    def test_exif_tool(self):
        with ExifToolHelper() as et:
            date = datetime.strftime(datetime(2011, 11, 11, 11, 11, 11),
                                     "%Y:%m:%d %H:%M:%S")
            et.set_tags(
                ["./video.mp4"],
                tags={"DateTimeOriginal": date, "CreateDate": date,
                      "ModifyDate": date, "MediaCreateDate": date,
                      "MediaModifyDate": date},
                params=["-P", "-overwrite_original"]
            )
            for d in et.get_metadata("./video.mp4"):
                for k, v in d.items():
                    print(f"{k} = {v}")
            print("------------------------------------------------------")
            for d in et.get_metadata("./planets.jpg"):
                for k, v in d.items():
                    print(f"{k} = {v}")

    def test_multiple_matching_patterns(self):
        patterns.append(whatsapp_format_regex)
        self.assertRaises(ValueError, matches, 'IMG-20181028-WA.jpg')

    def test_match_and_parse(self):
        param_list = [
            ('IMG_20181028_182327.jpg', datetime(2018, 10, 28, 18, 23, 27)),
            ('00000IMG_00000_BURST20190127011008_COVER.jpg',
             datetime(2019, 1, 27, 1, 10, 8)),
            ('00002IMG_00002_BURST20190127011008.jpg',
             datetime(2019, 1, 27, 1, 10, 8)),
            ('IMG-20181028-WA.jpg', datetime(2018, 10, 28)),
            ('PXL_20220713_091359320.mp4',
             datetime(2022, 7, 13, 9, 13, 59, 320000)),
            ('PXL_20210320_024141416.LS.mp4',
             datetime(2021, 3, 20, 2, 41, 41, 416000)),
            ('PXL_20211105_151815472_exported_233.jpg',
             datetime(2021, 11, 5, 15, 18, 15, 472000)),
            ('signal-2021-08-26-15-26-13-764.jpg',
             datetime(2021, 8, 26, 15, 26, 13, 764000)),
            ('signal-2022-07-27-21-03-10-120-1.jpg ',
             datetime(2022, 7, 27, 21, 3, 10, 120000)),
            ('2013-05-01 21.00.39.mp4', datetime(2013, 5, 1, 21, 0, 39)),
            ('2013-05-01 18.22.26.jpg', datetime(2013, 5, 1, 18, 22, 26)),
            ('2013-04-26 18.59.48.JPG', datetime(2013, 4, 26, 18, 59, 48)),
            ('VID_20171028_231100.mp4', datetime(2017, 10, 28, 23, 11, 0)),
            ('PANO_20171108_172445.jpg', datetime(2017, 11, 8, 17, 24, 45)),
            ('20150806_163213.mp4', datetime(2015, 8, 6, 16, 32, 13)),
            ('20131222_080244.jpg', datetime(2013, 12, 22, 8, 2, 44)),
            ('threema-20220909-125017145.jpg',
             datetime(2022, 9, 9, 12, 50, 17, 145000)),
            ('threema-20220909-124912758.mp4',
             datetime(2022, 9, 9, 12, 49, 12, 758000)),
            ('2013-06-02 18-7e3193a1.43.52.jpg',
             datetime(2013, 6, 2, 18, 43, 52)),
            ('MVIMG_20181024_213921.jpg', datetime(2018, 10, 24, 21, 39, 21)),
            ('FJIMG_20191203_164729.jpg', datetime(2019, 12, 3, 16, 47, 29)),
            ('FJVID_20191211_145524.mp4', datetime(2019, 12, 11, 14, 55, 24)),
        ]
        for filename, expected_date in param_list:
            with self.subTest(filename):
                self.assertTrue(matches(filename), filename + " does not match")
                self.assertEqual(parse_date(filename), expected_date,
                                 filename + " does not parse")


if __name__ == '__main__':
    restore_date_metadata()
# elif __name__ == '__test__':
#     unittest.main(verbosity=2)
