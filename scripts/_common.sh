#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

timezone=$(timedatectl show --value --property=Timezone)

# REDIS BLOOM INSTALL HELPER 

REDIS_MODULE_DIR="/etc/redis/modules"
REDISBLOOM_SO="$REDIS_MODULE_DIR/redisbloom.so"
REDIS_CONF="/etc/redis/redis.conf"

REDISBLOOM_VERSION="v2.8.17"
REDISBLOOM_URL="https://github.com/RedisBloom/RedisBloom/archive/refs/tags/v2.8.17.tar.gz"
