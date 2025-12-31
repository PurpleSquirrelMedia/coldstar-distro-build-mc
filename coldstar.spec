# -*- mode: python ; coding: utf-8 -*-
# PyInstaller spec file for ColdStar
# Creates a standalone executable with all dependencies bundled

import sys
import os
from PyInstaller.utils.hooks import collect_data_files, collect_submodules, collect_dynamic_libs

block_cipher = None

# Collect all submodules for complex packages
hiddenimports = [
    # CFFI backend - CRITICAL
    '_cffi_backend',
    'cffi',
    'cffi.backend_ctypes',

    # Solana
    'solana',
    'solana.rpc',
    'solana.rpc.api',
    'solana.rpc.async_api',
    'solana.rpc.websocket_api',
    'solana._layouts',
    'solana._layouts.vote_instructions',
    'solana.constants',
    'solana.utils',
    'solana.utils.cluster',
    'solana.utils.security_txt',
    'solana.utils.validate',
    'solana.vote_program',

    # Solders
    'solders',
    'solders.token',
    'solders.token.associated',
    'solders.token.state',

    # NaCl
    'nacl',
    'nacl.signing',
    'nacl.public',
    'nacl.secret',
    'nacl.utils',
    'nacl.hash',
    'nacl.hashlib',
    'nacl.bindings',
    'nacl.bindings.crypto_aead',
    'nacl.bindings.crypto_box',
    'nacl.bindings.crypto_generichash',
    'nacl.bindings.crypto_hash',
    'nacl.bindings.crypto_kx',
    'nacl.bindings.crypto_pwhash',
    'nacl.bindings.crypto_scalarmult',
    'nacl.bindings.crypto_secretbox',
    'nacl.bindings.crypto_secretstream',
    'nacl.bindings.crypto_shorthash',
    'nacl.bindings.crypto_sign',
    'nacl.bindings.randombytes',
    'nacl.bindings.sodium_core',
    'nacl.bindings.utils',

    # Rich
    'rich',
    'rich.console',
    'rich.table',
    'rich.panel',
    'rich.progress',
    'rich.bar',
    'rich.diagnose',
    'rich.layout',
    'rich.logging',
    'rich.prompt',

    # Others
    'questionary',
    'questionary.prompts',
    'httpx',
    'httpx._transports',
    'aiofiles',
    'base58',
    'construct',
    'anyio',
    'anyio._backends',
    'anyio._backends._asyncio',
    'websockets',
    'websockets.client',
    'websockets.server',
]

# Add all submodules
hiddenimports += collect_submodules('solana')
hiddenimports += collect_submodules('solders')
hiddenimports += collect_submodules('rich')
hiddenimports += collect_submodules('nacl')
hiddenimports += collect_submodules('cffi')
hiddenimports += collect_submodules('websockets')

# Collect data files
datas = []
datas += collect_data_files('solana')
datas += collect_data_files('solders')
datas += collect_data_files('rich')
datas += collect_data_files('certifi')
datas += collect_data_files('nacl')

# Add our source files
datas += [
    ('src', 'src'),
    ('config.py', '.'),
    ('python_signer_example.py', '.'),
]

# Collect dynamic libraries (critical for cffi/nacl)
binaries = []
binaries += collect_dynamic_libs('nacl')
binaries += collect_dynamic_libs('cffi')

# Add Rust library if it exists
rust_lib_paths = [
    'secure_signer/target/release/libsolana_secure_signer.dylib',
    'secure_signer/target/release/libsolana_secure_signer.so',
    'secure_signer/target/release/solana_secure_signer.dll',
    'libsolana_secure_signer.dylib',
    'libsolana_secure_signer.so',
]
for lib_path in rust_lib_paths:
    if os.path.exists(lib_path):
        binaries.append((lib_path, '.'))

a = Analysis(
    ['main.py'],
    pathex=[],
    binaries=binaries,
    datas=datas,
    hiddenimports=hiddenimports,
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[
        'tkinter',
        'matplotlib',
        'numpy',
        'pandas',
        'scipy',
        'PIL',
        'cv2',
    ],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='coldstar',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=True,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=None,
)
