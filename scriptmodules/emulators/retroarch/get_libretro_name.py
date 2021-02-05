#!/usr/bin/env python3
import ctypes
import sys
import os.path

class RetroSystemInfo(ctypes.Structure):
    _fields_ = [
        ("library_name", ctypes.c_char_p),
        ("library_version", ctypes.c_char_p),
        ("valid_extensions", ctypes.c_char_p),
        ("need_fullpath", ctypes.c_bool),
        ("block_extract", ctypes.c_bool)
        ]

retro_info = RetroSystemInfo(b'', b'', b'', False, False)

if sys.argv[1:]:
    if not os.path.isfile(sys.argv[1]):
        print('File not found', file=sys.stderr)
        sys.exit(1)

    core_file_name = sys.argv[1]
    try:
        core_file = ctypes.cdll.LoadLibrary(core_file_name)
        core_file.retro_get_system_info(ctypes.byref(retro_info))
        print(retro_info.library_name.decode('LATIN1'));
    except Exception as e:
        print('Cannot load DSO ' + str(e), file=sys.stderr )
        sys.exit(2)
