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
        v-tw )
            return $RETURN_CODE_SERVICE_CLOSE
            curl https://git.recolic.net/vr/test404 -vv 2>&1 | grep 404 || return $?
            ;;
        frp-hk )
            test_tcp proxy.recolic.net 30999 || return $?
            ;;
        ss-us12 )
            test_tcp base.us12.recolic.net 25551 || return $?
            ;;
        ss-hk2 )
            test_tcp base.hk2.recolic.net 25551 || return $?
            ;;
        ss-iplc )
            test_tcp base.cnjp1.recolic.net 25551 || return $?
            test_tcp base.cnjp1.recolic.net 25552 || return $?
            ;;
        ovpn-tw )
            # it's impossible to detect openvpn easily without ta.key and client-certificate
            #     because my server is using udp + tls-auth.
            # There's also something running at another port to obfuse the obfused traffic again
            #     to fight against GFT deep-learning VPN detection.
            # So I can do nothing.....

            # NO icmp required because of traffic obfused as raw IP packet. 
            # test_icmp base.tw1.recolic.net || return $?
            return $RETURN_CODE_SERVICE_CLOSE
            ;;
        www )
            test_icmp recolic.net &&
            test_icmp www.recolic.net &&
            curl -s https://recolic.net/ | grep 'Powered by' || return $?
            curl -s https://www.recolic.net/ | grep 'Powered by' || return $?
            curl -s -L http://recolic.net/ | grep 'Powered by' || return $?
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
        tm )
            return $RETURN_CODE_SERVICE_CLOSE
            test_icmp tm.recolic.net &&
            curl -s https://tm.recolic.net/ | grep inputButtonCss &&
            curl -s http://tm.recolic.net/ -L | grep inputButtonCss || return $?
            curl -s 'https://tm.recolic.net/addtask?openid=23251fc131e118d07fc9932f3c3de92c&N=30.508914&E=114.40718&key=FUCKYOU' | grep 'invalid key' || return $?
            ;;
        git )
            # NO icmp required because of udp2raw
            curl -s https://git.recolic.net/ | grep 'users/sign_in' &&
            curl -s http://git.recolic.net/ -L | grep 'users/sign_in' || return $?
            ;;
        zhixiang )
            return $RETURN_CODE_SERVICE_CLOSE
            grep 'api.anjie-elec.cn' /etc/hosts || echo '123.206.117.183 api.anjie-elec.cn' >> /etc/hosts
            [[ $? != 0 ]] && echo 'Failed to edit hosts file! Unable to perform this test.' > /dev/fd/2 && return 0
            curl -k -X POST -s 'https://api.anjie-elec.cn/api/usewater/Add?accessToken=FUCKYOU' | grep '104871845A503324' || return $?
            ;;
        mc )
            test_tcp mc.recolic.net 25565 || return $?
            ;;
        push-httpdb-agent )
            return $RETURN_CODE_SERVICE_CLOSE
            local r="$RANDOM"
            test_icmp git.recolic.net &&
            curl -s "https://git.recolic.net/_r_testing/set/_status_test|$r" &&
            local result=$(curl -s "https://git.recolic.net/_r_testing/get/_status_test") || return $?
            [[ $r = $result ]]
            return $?
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
    do_test_twice frp-hk &&
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
