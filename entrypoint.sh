#!/bin/bash
set -e

RUN_FLUXBOX=${RUN_FLUXBOX:-yes}
RUN_XTERM=${RUN_XTERM:-yes}

# VNC_PASSWORD가 반드시 있어야 함
if [ -z "${VNC_PASSWORD:-}" ]; then
    echo "ERROR: VNC_PASSWORD is not set!"
    exit 1
fi

# VNC 비밀번호 파일 생성
VNC_PASSFILE="/tmp/.vnc-passwd"

x11vnc -storepasswd "$VNC_PASSWORD" "$VNC_PASSFILE"
chmod 600 "$VNC_PASSFILE"

# 기존 x11vnc 설정 제거
rm -f /app/conf.d/x11vnc.conf
rm -f /app/conf.d/x11vnc-password.conf

# 비밀번호를 사용하는 x11vnc 설정 생성
cat > /app/conf.d/x11vnc.conf <<EOF
[program:x11vnc]
command=x11vnc -forever -shared -rfbauth $VNC_PASSFILE
autorestart=true
EOF

case $RUN_FLUXBOX in
    false|no|n|0)
        rm -f /app/conf.d/fluxbox.conf
        ;;
esac

case $RUN_XTERM in
    false|no|n|0)
        rm -f /app/conf.d/xterm.conf
        ;;
esac

exec supervisord -c /app/supervisord.conf
