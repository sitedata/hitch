#!/bin/sh
# Test client-verify in frontend = {}

. hitch_test.sh

PORT2=$(expr $LISTENPORT + 23)

cat >hitch.cfg <<EOF
backend = "[hitch-tls.org]:80"
frontend = "[*]:$LISTENPORT"
pem-file = "${CERTSDIR}/default.example.com"

frontend = {
	 host = "*"
	 port = "$PORT2"
	 pem-file = "${CERTSDIR}/site1.example.com"
	 client-verify = required
	 client-verify-ca = "${CERTSDIR}/client-ca.pem"
}
EOF

start_hitch --config=hitch.cfg

HITCH_HOST1=$(hitch_hosts | sed -n 1p)
HITCH_HOST2=$(hitch_hosts | sed -n 2p)

# listen endpoint #1: no client verification configured:
(sleep 1; printf '\n') |
    openssl s_client -connect "$HITCH_HOST1" -prexit


# listen endpoint #2: client-verify configured, requires client cert
! (sleep 1; printf '\n') |
    openssl s_client -connect "$HITCH_HOST2" -prexit

(sleep 1; printf '\n') |
    openssl s_client -connect "$HITCH_HOST2" -prexit -cert "${CERTSDIR}/client-cert01.pem"
