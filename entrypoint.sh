#!/usr/bin/env bash

UUID=${UUID:-'7888f86c-fbb1-4641-85b5-c541688d9706'}
VLESS_WSPATH=${VLESS_WSPATH:-'/l'}


generate_config() {
  cat > config.json << EOF
{
    "log":{
        "access":"/dev/null",
        "error":"/dev/null",
        "loglevel":"none"
    },
    "inbounds":[
        {
            "port":8080,
            "protocol":"vless",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}",
                        "flow":"xtls-rprx-vision"
                    }
                ],
                "decryption":"none",
                "fallbacks":[
                    {
                        "dest":3001
                    },
                    {
                        "path":"${VLESS_WSPATH}",
                        "dest":3002
                    }
                ]
            },
            "streamSettings":{
                "network":"tcp"
            }
        },
        {
            "port":3001,
            "listen":"127.0.0.1",
            "protocol":"vless",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}"
                    }
                ],
                "decryption":"none"
            },
            "streamSettings":{
                "network":"ws",
                "security":"none"
            }
        },
        {
            "port":3002,
            "listen":"127.0.0.1",
            "protocol":"vless",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}",
                        "level":0
                    }
                ],
                "decryption":"none"
            },
            "streamSettings":{
                "network":"ws",
                "security":"none",
                "wsSettings":{
                    "path":"${VLESS_WSPATH}"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls"
                ],
                "metadataOnly":false
            }
        }
  ],
    "outbounds":[
        {
            "protocol":"freedom"
        },
        {
            "tag": "WARP",
            "protocol": "wireguard",
            "settings": {
                "secretKey": "GAl2z55U2UzNU5FG+LW3kowK+BA/WGMi1dWYwx20pWk=",
                "address": [
                    "172.16.0.2/32",
                    "2606:4700:110:8f0a:fcdb:db2f:3b3:4d49/128"
                ],
                "peers": [
                    {
                        "publicKey": "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=",
                        "endpoint": "engage.cloudflareclient.com:2408"
                    }
                ]
            }
        }
    ],
    "routing": {
        "domainStrategy": "AsIs",
        "rules": [
            {
                "type": "field",
                "domain": [
                    "domain:openai.com",
                    "domain:ai.com"
                ],
                "outboundTag": "WARP"
            }
        ]
    },
    "dns":{
        "servers":[
            "https+local://1.1.1.1/dns-query"
        ]
    }
}
EOF
}

