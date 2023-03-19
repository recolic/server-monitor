#!/bin/bash

[[ $1 == '' ]] && echo -e 'Usage: '"$0 <operation> ...\n operation := ... | all" && exit 1

[[ $(id -u) = 0 ]] && ping_fld="-f"

[[ _$RETURN_CODE_SERVICE_CLOSE = _ ]] && RETURN_CODE_SERVICE_CLOSE=91

function test_icmp () {
    local host="$1"
    timeout 4s ping "$host" -c 1
    local ret="$?"
    [[ $ret != 124 ]] && [[ $ret != 2 ]] && return $ret
    for i in {1..4}; do
        timeout 12s ping "$host" -c 1 $ping_fld && return 0
        sleep 1
    done
    return 124
}

function test_tcp () {
    local host="$1"
    local port="$2"
    echo "Testing $host:$port ..." > /dev/fd/2
    timeout 3s nc "$host" "$port"
    local ret=$?
    [[ $ret = 124 ]] && return 0 || return $ret
}


function do_test () {
    echo "Testing >> $1" > /dev/fd/2
    case "$1" in
        rproxy )
            return $RETURN_CODE_SERVICE_CLOSE
            test_icmp proxy.recolic.net &&
            test_tcp proxy.recolic.net 22 | grep -a SSH || return $?
            ;;
        drive )
            # NO icmp required because of udp2raw
            curl -s https://drive.recolic.net/login | grep 'drive.recolic.' || return $?
            ;;
        drive2 )
            curl -s https://drive2.recolic.net/login | grep 'Recolic Cloud' || return $?
            ;;
        frp-sg )
            test_tcp proxy.recolic.net 30999 || return $?
            ;;
        frp-cdn )
            test_tcp proxy-cdn.recolic.net 30999 || return $?
            ;;
        comm100 )
            curl -s -L https://www.comm100.pw/ | grep Comm100 || return $?
            ;;
        www )
            test_icmp recolic.net &&
            test_icmp www.recolic.net &&
            curl -s "https://recolic.net/api/echo.php?KEEPALIVE" | grep KEEPALIVE || return $?
            curl -s "https://www.recolic.net/api/echo.php?KEEPALIVE" | grep KEEPALIVE || return $?
            curl -s -L "http://www.recolic.net/api/echo.php?KEEPALIVE" | grep KEEPALIVE || return $?
            ;;
        mail )
            test_icmp smtp.recolic.net &&
            test_icmp imap.recolic.net &&
            test_icmp mail.recolic.net &&
            test_icmp pop3.recolic.net || return $?

            # Fucking DigitalOcean
            if test_tcp smtp-mail.outlook.com 25 | grep 220; then
                test_tcp smtp.recolic.net 25 | grep 220 || return $?
            fi
            test_tcp smtp.recolic.net 587  || return $?
            if test_tcp imap-mail.outlook.com 143 | grep OK; then
                test_tcp imap.recolic.net 143 | grep OK || return $?
            fi
            test_tcp imap.recolic.net 993 || return $?
            if test_tcp pop3.live.com 110 | grep OK; then
                test_tcp pop3.recolic.net 110 | grep OK || return $?
            fi
            test_tcp pop3.recolic.net 995 || return $?

            curl -s https://mail.recolic.net/mail/ | grep 'Welcome to Roundcube' || return $?
            curl http://mail.recolic.net/ -vv 2>&1 | grep 'https://mail.recolic.net/' || return $?
            ;;
        git )
            # NO icmp required because of udp2raw
            curl -s https://git.recolic.net/ | grep 'users/sign_in' &&
            curl -s http://git.recolic.net/ -L | grep 'users/sign_in' || return $?
            ;;
        mc )
            test_tcp mc.recolic.net 25565 || return $?
            ;;
        ddns-home )
            # NO icmp required.
            test_tcp base.ddns1.recolic.net 22 | grep -a SSH || return $?
            ;;
        dl )
            test_icmp dl.recolic.net &&
            curl -s -L https://dl.recolic.net/ | grep 'Home page is not provided for this download site' || return $?
            ;;
        shortlink )
            test_icmp recolic.net &&
            curl -s 'https://recolic.net/go/index.php' --data 'target=https%3A%2F%2Fwww.google.com&name=google&super=' | grep Success || return $?
            ;;
        rocket )
            return $RETURN_CODE_SERVICE_CLOSE
            test_icmp rocket.recolic.net &&
            curl -s https://rocket.recolic.net:444/api/info | grep 'success":true' || return $?
            ;;
        cc-dns )
            test_icmp www.recolic.cc &&
            curl -s https://recolic.cc/ || return $?
            ;;
        home-http )
            # NO icmp required.
            curl -L https://recolic.net/hms.php | grep betterlisting || return $?
            ;;
        domain2ip )
            dig +short 1.1.1.1.ip.recolic.cc | grep 1.1.1.1 || return $?
            ;;
        * )
            echo PROGRAMMING ERROR: NO TARGET "$1" available. 
            return 1
    esac

    return 0
}

function do_test_twice () {
    do_test "$1" || do_test "$1" || do_test "$1"
    return $?
}
    
if [[ "$1" = all ]]; then
    do_test_twice rproxy &&
    do_test_twice drive &&
    do_test_twice v-tw &&
    do_test_twice frp-sg &&
    do_test_twice ss-us12 &&
    do_test_twice ss-hk2 &&
    do_test_twice ss-iplc &&
    do_test_twice ovpn-tw &&
    do_test_twice www &&
    do_test_twice mail &&
    do_test_twice tm &&
    do_test_twice git &&
    do_test_twice zhixiang &&
    do_test_twice mc &&
    do_test_twice push-httpdb-agent &&
    do_test_twice ddns-home &&
    do_test_twice shortlink &&
    do_test_twice dl &&
    do_test_twice cc-dns &&
    do_test_twice home-http &&
    do_test_twice domain2ip
    exit $?
fi

do_test_twice "$1"
exit $?
