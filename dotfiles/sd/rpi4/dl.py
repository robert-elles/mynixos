#!/usr/bin/env python3

import argparse


def filename_from_url(url):
    file_section = url.split('/')[-1]
    return file_section.split('\\')[0]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('url')
    args = parser.parse_args()


if __name__ == '__main__':
    main()


def test_filename_from_url():
    url = " https://www.example.com/some/1406572753/presentation.video.mkv\?st\=bl4G8A35pL0_GVg8mgOL9g\&e\=1675286614"
    assert filename_from_url(url) == 'presentation.video.mkv'
