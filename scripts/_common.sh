#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

timezone=$(timedatectl show --value --property=Timezone)

# REDIS BLOOM INSTALL HELPER 
# Fetch latest RedisBloom release tag from GitHub
get_latest_redisbloom_version() {
    curl -s https://api.github.com/repos/RedisBloom/RedisBloom/releases/latest \
        | grep '"tag_name"' \
        | cut -d '"' -f 4
}
