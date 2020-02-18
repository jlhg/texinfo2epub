#!/usr/bin/env python
import errno
import os
import shutil
import sys
from os import path
from xml.etree import ElementTree as ET


def main():
    opf_path = sys.argv[1]
    dst_dir = path.dirname(opf_path)
    media_src_dir = sys.argv[2]
    tree = ET.parse(opf_path)

    for item in tree.iterfind('{http://www.idpf.org/2007/opf}manifest/{http://www.idpf.org/2007/opf}item'):
        media_type = item.attrib['media-type']
        if media_type is not None and media_type.startswith('image/'):
            image_path = item.attrib['href']
            image_dir = path.dirname(image_path)
            image_src_path = path.join(media_src_dir, image_path)
            image_dst_dir = path.join(dst_dir, image_dir)
            image_dst_path = path.join(dst_dir, image_path)
            try:
                os.makedirs(image_dst_dir)
            except OSError as exc:
                if exc.errno == errno.EEXIST and path.isdir(image_dst_dir):
                    pass
                else:
                    raise

            shutil.copy(image_src_path, image_dst_path)


if __name__ == '__main__':
    main()
