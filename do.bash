#!/bin/bash

[[ $1 == '' ]] && echo -e 'Usage: '"$0 <operation> ...\n operation := rproxy | drive | ss-tw | ss-us1 | ss-us5 | ss-us6 | ovpn-tw | www | mail | tm | git | zhixiang | mc | push-httpdb-agent | ddns-wuhan | ddns-us | dl | all" && exit 1

function confirm_alive () {
    local host="$1"
    timeout 4s ping "$host" -c 2
    local ret="$?"
    [[ $ret != 124 ]] && return $ret
    for i in {1..4}; do
        timeout 2s ping "$host" -c 1 && return 0
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
            curl -s https://drive.recolic.net/login | grep 'submit-wrapper' || return $?
            ;;
        ss-tw )
            confirm_alive nohsts.tw1.recolic.org &&
            test_ss base.tw1.recolic.net || return $?
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
            curl -s https://recolic.net/ | grep 'Follow me on github' || return $?
            curl -s https://www.recolic.net/ | grep 'Follow me on github' || return $?
            curl -s -L http://recolic.net/ | grep 'Follow me on github' || return $?
            ;;
        mail )
            test_tcp smtp.recolic.net 25 | grep 220 || return $?
            test_tcp smtp.recolic.net 587 | grep 220 || return $?
            test_tcp imap.recolic.net 143 | grep OK || return $?
            test_tcp imap.recolic.net 993 || return $?
            test_tcp pop3.recolic.net 110 | grep OK || return $?
            test_tcp pop3.recolic.net 995 || return $?

            curl -s https://mail.recolic.net/mail/ | grep 'Welcome to Roundcube' || return $?
            curl http://mail.recolic.net/ -vv 2>&1 | grep 'https://mail.recolic.net/' || return $?
            ;;
        tm )
            curl -s https://tm.recolic.net/ | grep inputButtonCss &&
            curl -s http://tm.recolic.net/ -L | grep inputButtonCss || return $?
            curl -s 'https://tm.recolic.net/addtask?openid=23251fc131e118d07fc9932f3c3de92c&N=30.508914&E=114.40718&key=FUCKYOU' | grep 'invalid key' || return $?
            ;;
        git )
            curl -s https://git.recolic.net/ | grep 'users/sign_in' &&
            curl -s http://git.recolic.net/ -L | grep 'users/sign_in' || return $?
            ;;
        zhixiang )
            grep 'api.anjie-elec.cn' /etc/hosts || echo '123.206.117.183 api.anjie-elec.cn' >> /etc/hosts
            [[ $? != 0 ]] && echo 'Failed to edit hosts file! Unable to perform this test.' > /dev/fd/2 && return 0
            curl -k -X POST -s 'https://api.anjie-elec.cn/api/usewater/Add?accessToken=FUCKYOU' | grep '104871845A503324' || return $?
            ;;
        mc )
            test_tcp mc.recolic.net 25565 || return $?
            ;;
        push-httpdb-agent )
            local r="$RANDOM"
            curl -s "https://git.recolic.net/_r_testing/set/_status_test|$r" &&
            local result=$(curl -s "https://git.recolic.net/_r_testing/get/_status_test") || return $?
            [[ $r = $result ]]
            return $?
            ;;
        ddns-wuhan )
            test_tcp base.ddns1.recolic.net 22 || return $?
            ;;
        ddns-us )
            test_tcp base.ddns2.recolic.net 22 | grep SSH &&
            test_tcp base.ddns2.recolic.net 80 &&
            test_tcp nohsts.ddns2.recolic.org 22 | grep SSH &&
            test_tcp nohsts.ddns2.recolic.org 80 || return $?
            ;;
        dl )
            curl -s -L https://dl.recolic.net/ | grep 'Home page is not provided for this download site' || return $?
            ;;
    esac

    
}
    
if [[ "$1" = all ]]; then
    do_test rproxy &&
    do_test drive &&
    do_test ss-tw &&
    do_test ss-us1 &&
    do_test ss-us5 &&
    do_test ss-us6 &&
    do_test ovpn-tw &&
    do_test www &&
    do_test mail &&
    do_test tm &&
    do_test git &&
    do_test zhixiang &&
    do_test mc &&
    do_test push-httpdb-agent &&
    do_test ddns-wuhan &&
    do_test ddns-us &&
    do_test dl
    exit $?
fi

do_test "$1"
exit $?
