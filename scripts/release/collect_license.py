#!/bin/python

import re
import sys
import glob
import os
import zipfile

src_root = os.path.join(os.path.dirname(os.path.realpath(__file__)), '../../')
config_path = os.path.join(src_root, 'Cartfile.resolved')
if not os.path.exists(config_path):
    sys.exit('Cartfile.resolved does not exist.')

lines = open(config_path, 'r').readlines()
cart_licenses = []
for line in lines:
    origin_kind, origin, version = [part.strip() for part in line.split(' ') if part]
    match = re.search(r'/(?P<name>[\w\-]+)(\.json)?"', origin)
    if match and match.group('name'):
        cart_name = match.group('name')
        if origin_kind == 'github':
            paths = glob.glob(os.path.join(src_root, 'Carthage/Checkouts/', cart_name, 'LICENSE*'))
            if paths and len(paths) > 0:
                cart_licenses.append({
                    'cart_name': cart_name,
                    'license_text': open(paths[0], 'r').read()
                })
        elif origin_kind == 'binary':
            binary_path = os.path.join(os.path.expanduser("~"),
                'Library/Caches/org.carthage.CarthageKit/binaries',
                cart_name,
                version.replace('"',''),
                cart_name + '.zip')
            if os.path.exists(binary_path):
                zf = zipfile.ZipFile(binary_path,  'r')
                for zc in zf.infolist():
                    if re.search(r'license', zc.filename, re.IGNORECASE):
                        license_text = zf.read(zc.filename).decode()
                        # print(license_text)
                        cart_licenses.append({
                            'cart_name': cart_name,
                            'license_text': license_text
                        })

print(open(os.path.join(src_root, 'scripts/release/LICENSE-template.md'), 'r').read())

print('## Acknowledgements')
print('This application makes use of the following third party libraries:')

for cart_license in cart_licenses:
    print('\n### {0}\n'.format(cart_license['cart_name']))
    print('```\n{0}\n```'.format(cart_license['license_text']))