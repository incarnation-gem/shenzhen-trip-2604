#!/bin/zsh
cd "$(dirname "$0")"
V=$(python3 -c "import re; h=open('index.html').read(); m=re.search(r\"vault\.dat\?v='(\d+)'\", h); print(int(m.group(1))+1 if m else 11)")
python3 - "$V" << 'PY'
import sys, os, base64, json, hashlib
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
v = sys.argv[1]
PASSWORD = '200126'
src = open('trip-src.html','rb').read()
salt = os.urandom(16); iv = os.urandom(12)
key = hashlib.pbkdf2_hmac('sha256', PASSWORD.encode(), salt, 120000, dklen=32)
ct = AESGCM(key).encrypt(iv, src, None)
open('vault.dat','w').write(json.dumps({'salt':base64.b64encode(salt).decode(),'iv':base64.b64encode(iv).decode(),'ct':base64.b64encode(ct).decode()}))
h = open('index.html').read()
import re
h = re.sub(r"vault\.dat\?v='\d+'", f"vault.dat?v='{v}'", h)
open('index.html','w').write(h)
print('已重加密，vault 版本 v' + v)
PY
git add -A && git commit -q -m "内容更新并重加密(v$V)" && git push -q && echo "pushed v$V"
