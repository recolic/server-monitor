#!/usr/bin/python3

ops = [ 'rproxy', 'drive', 'ss-tw', 'ss-us1', 'ss-us5', 'ss-us6', 'ovpn-tw', 'www', 'mail', 'tm', 'git', 'zhixiang', 'mc', 'push-httpdb-agent', 'ddns-wuhan', 'ddns-us', 'dl' ]
allow_fail = [ 'mc', 'push-httpdb-agent' ]


print('''image: recolic/rserver-monitor

stages:
  - test
''')
for op in ops:
    print('{}:\n  stage: test\n  script: "/do.bash {}"'.format(op, op))
    if op in allow_fail:
        print('  allow_failure: true')
    print()

