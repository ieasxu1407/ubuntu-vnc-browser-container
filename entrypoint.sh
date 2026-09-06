#!/bin/bash
set -ex

RUN_FLUXBOX=${RUN_FLUXBOX:-yes}
RUN_XTERM=${RUN_XTERM:-yes}

# VNC 비밀번호 설정
if [ -n "${VNC_PASSWORD:-}" ]; then
    mkdir -p /root/.vnc

    x11vnc -storepasswd "$VNC_PASSWORD" /root/.vnc/passwd

    chmod 600 /root/.vnc/passwd

    rm -f /app/conf.d/x11vnc.conf

    cat > /app/conf.d/x11vnc-password.conf <<'EOF'
[program:x11vnc]
command=x11vnc -forever -shared -rfbauth /root/.vnc/passwd
autorestart=true
EOF
fi

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
