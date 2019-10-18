#!/bin/bash

[[ $1 == '' ]] && echo -e 'Usage: '"$0 <operation> ...\n operation := rproxy | drive | v-tw | v-hk | frp-hk | ss-us1 | ss-us5 | ss-us6 | ovpn-tw | www | mail | tm | git | zhixiang | mc | push-httpdb-agent | ddns-wuhan | rocket | dl | shortlink | org-dns | home-http | all" && exit 1

[[ $(id -u) = 0 ]] && ping_fld="-f"

function confirm_alive () {
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

function test_ss () {
    # I can not publish password here so...
    confirm_alive "$1"
    test_tcp "$1" 25551
    return $?
}

function do_test () {
    echo "Testing >> $1" > /dev/fd/2
    case "$1" in
        rproxy )
            confirm_alive proxy.recolic.net &&
            test_tcp proxy.recolic.net 22 | grep -a SSH || return $?
            ;;
        drive )
            confirm_alive drive.recolic.net &&
            curl -s https://drive.recolic.net:444/index.php/login | grep 'submit-wrapper' || return $?
            ;;
        v-tw )
            curl https://git.recolic.net/vr/test -vv 2>&1 | grep 404 || return $?
            ;;
        v-hk )
            test_tcp base.hk1.recolic.net 443 || return $?
            ;;
        frp-hk )
            test_tcp base.hk1.recolic.net 30999 || return $?
            ;;
        ss-us1 )
            test_ss base.us1.recolic.net || return $?
            ;;
        ss-us5 )
            test_ss base.us5.recolic.net || return $?
            ;;
        ss-us6 )
            test_ss base.us6.recolic.net || return $?
            ;;
        ovpn-tw )
            # it's impossible to detect openvpn easily without ta.key and client-certificate
            #     because my server is using udp + tls-auth.
            # There's also something running at another port to obfuse the obfused traffic again
            #     to fight against GFT deep-learning VPN detection.
            # So I can do nothing.....
            confirm_alive base.tw1.recolic.net || return $?
            ;;
        www )
            confirm_alive recolic.net &&
            confirm_alive www.recolic.net &&
            curl -s https://recolic.net/ | grep 'Powered by' || return $?
            curl -s https://www.recolic.net/ | grep 'Powered by' || return $?
            curl -s -L http://recolic.net/ | grep 'Powered by' || return $?
            ;;
        mail )
            confirm_alive smtp.recolic.net &&
            confirm_alive imap.recolic.net &&
            confirm_alive mail.recolic.net &&
            confirm_alive pop3.recolic.net || return $?

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
            confirm_alive tm.recolic.net &&
            curl -s https://tm.recolic.net/ | grep inputButtonCss &&
            curl -s http://tm.recolic.net/ -L | grep inputButtonCss || return $?
            curl -s 'https://tm.recolic.net/addtask?openid=23251fc131e118d07fc9932f3c3de92c&N=30.508914&E=114.40718&key=FUCKYOU' | grep 'invalid key' || return $?
            ;;
        git )
            confirm_alive git.recolic.net &&
            curl -s https://git.recolic.net/ | grep 'users/sign_in' &&
            curl -s http://git.recolic.net/ -L | grep 'users/sign_in' || return $?
            ;;
        zhixiang )
            grep 'api.anjie-elec.cn' /etc/hosts || echo '123.206.117.183 api.anjie-elec.cn' >> /etc/hosts
            [[ $? != 0 ]] && echo 'Failed to edit hosts file! Unable to perform this test.' > /dev/fd/2 && return 0
            curl -k -X POST -s 'https://api.anjie-elec.cn/api/usewater/Add?accessToken=FUCKYOU' | grep '104871845A503324' || return $?
            ;;
        mc )
            confirm_alive mc.recolic.net &&
            test_tcp mc.recolic.net 25565 || return $?
            ;;
        push-httpdb-agent )
            local r="$RANDOM"
            confirm_alive git.recolic.net &&
            curl -s "https://git.recolic.net/_r_testing/set/_status_test|$r" &&
            local result=$(curl -s "https://git.recolic.net/_r_testing/get/_status_test") || return $?
            [[ $r = $result ]]
            return $?
            ;;
        ddns-wuhan )
            confirm_alive base.ddns1.recolic.net &&
            test_tcp base.ddns1.recolic.net 22 || return $?
            ;;
        #ddns-us )
        #    test_tcp base.ddns2.recolic.net 22 | grep SSH &&
        #    test_tcp base.ddns2.recolic.net 80 &&
        #    test_tcp nohsts.ddns2.recolic.org 22 | grep SSH &&
        #    test_tcp nohsts.ddns2.recolic.org 80 || return $?
        #    ;;
        dl )
            confirm_alive dl.recolic.net &&
            curl -s -L https://dl.recolic.net/ | grep 'Home page is not provided for this download site' || return $?
            ;;
        shortlink )
            confirm_alive recolic.net &&
            curl -s 'https://recolic.net/go/index.php' --data 'target=https%3A%2F%2Fwww.google.com&name=google&super=' | grep Success || return $?
            ;;
        rocket )
            confirm_alive rocket.recolic.net &&
            curl -s https://rocket.recolic.net:444/api/info | grep 'success":true' || return $?
            ;;
        org-dns )
            confirm_alive www.recolic.org &&
            curl -s https://recolic.org/ || return $?
            ;;
        home-http )
            confirm_alive home.cnm.cool &&
            curl -s http://home.cnm.cool/ || return $?
            ;;
    esac

    return 0
}

function do_test_twice () {
    do_test "$1" || do_test "$1"
    return $?
}
    
if [[ "$1" = all ]]; then
    do_test_twice rproxy &&
    do_test_twice drive &&
    do_test_twice v-tw &&
    do_test_twice v-hk &&
    do_test_twice frp-hk &&
    do_test_twice ss-us1 &&
    do_test_twice ss-us5 &&
    do_test_twice ss-us6 &&
    do_test_twice ovpn-tw &&
    do_test_twice www &&
    do_test_twice mail &&
    do_test_twice tm &&
    do_test_twice git &&
    do_test_twice zhixiang &&
    do_test_twice mc &&
    do_test_twice push-httpdb-agent &&
    do_test_twice ddns-wuhan &&
    do_test_twice rocket &&
    do_test_twice shortlink &&
    do_test_twice dl &&
    do_test_twice org-dns &&
    do_test_twice home-http
    exit $?
fi

do_test_twice "$1"
exit $?
