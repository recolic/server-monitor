# datafile generator daemon config

tests = [
        ('./do.bash rproxy', 'Reverse Proxy (China FRP)'),
        ('./do.bash drive', 'Drive'), 
        ('./do.bash v-tw', 'Project V taiwan'), 
        ('./do.bash frp-sg', 'Reverse Proxy (Singapore FRP)'), 
        ('./do.bash ss-iplc', 'Shadowsocks IPLC'), # Both CNIP and JPIP, requires linode to be working.
        ('./do.bash ss-us12', 'ShadowSocks US-12'), 
        ('./do.bash ss-hk2', 'ShadowSocks HK-2'), 
        ('./do.bash ovpn-tw', 'OpenVPN taiwan'), 
        ('./do.bash www', 'Main Website & Blog'), 
        ('./do.bash mail', 'Mail Server'), 
        ('./do.bash tm', 'Teachermate Web Seller'), 
        ('./do.bash git', 'Git'), 
        ('./do.bash zhixiang', 'ZhiXiang Fucker'), 
        ('./do.bash mc', 'Minecraft Server'), 
        ('./do.bash push-httpdb-agent', 'httpdb'), 
        ('./do.bash dl', 'Download Site'), 
        ('./do.bash shortlink', 'Short Link'), 
        ('./do.bash cc-dns', 'recolic.cc DNS'), 
        ('./do.bash home-http', 'Home NAS & DDNS & HTTP'), 
        ('./do.bash domain2ip', 'Domain to IP'), 
        ]
# ('./do.bash ddns-home', 'DDNS home'), 

test_interval = 20 * 60 # 20min

