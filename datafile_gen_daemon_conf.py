# datafile generator daemon config

tests = [
        ('./do.bash frp-sg', '[proxy.] Reverse Proxy (Singapore FRP)'), 
        ('./do.bash frp-cdn', '[proxy-cdn.] Reverse Proxy (Seattle FRP)'), 
        ('./do.bash www', '[www.] Main Website & Blog'), 
        ('./do.bash mail', '[mail.] Mail Server'), 
        ('./do.bash git', '[git.] Git'), 
        ('./do.bash drive', '[drive.] NextCloud WebDrive'), 
        ('./do.bash drive2', '[drive2.] WebDrive2'), 
        ('./do.bash dl', '[dl.] Download Site'), 
        ('./do.bash mc', '[mc.] Minecraft Server'), 
        ('./do.bash shortlink', 'Short Link'), 
        ('./do.bash cc-dns', 'recolic.cc DNS'), 
        ('./do.bash home-http', 'Home NAS & DDNS & HTTP'), 
        ('./do.bash domain2ip', 'Domain to IP'), 
        ('./do.bash comm100', 'COMM100 Subscription'), 
        ]
# ('./do.bash ddns-home', 'DDNS home'), 

test_interval = 20 * 60 # 20min

