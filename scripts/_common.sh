#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

timezone=$(timedatectl show --value --property=Timezone)

# REDIS BLOOM INSTALL HELPER 
REDIS_MODULE_DIR="/etc/redis/modules"
REDISBLOOM_SO="$REDIS_MODULE_DIR/redisbloom.so"
REDIS_CONF="/etc/redis/redis.conf"

get_arch() {
    case "$(dpkg --print-architecture)" in
        amd64) echo "x86_64" ;;
        arm64) echo "arm64v8" ;;
        armhf) echo "armv7" ;;
        *) echo "unsupported" ;;
    esac
}

get_latest_redisbloom_release() {
    curl -fsSL \
        https://api.github.com/repos/RedisBloom/RedisBloom/releases/latest \
        | grep '"tag_name"' \
        | cut -d '"' -f 4
}
