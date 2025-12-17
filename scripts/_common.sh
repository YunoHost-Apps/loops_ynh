#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

timezone=$(timedatectl show --value --property=Timezone)

#=================================================
# YUNOHOST VERSION HELPERS
#=================================================

ynh_get_yunohost_major_version() {
    yunohost --version | awk '{print $3}' | cut -d. -f1
}

#=================================================
# REDIS BLOOM INSTALLER
#=================================================

ynh_install_redisbloom() {
 # Check for yunohost version, only major 12 and lower need the redisbloom patch. Version 13 (Trixie) comes with redis-stack installed
 VERSIONCHECK="$(ynh_get_yunohost_major_version)"

 if [ "$VERSIONCHECK" -ge 13 ]; then
    ynh_print_info "YunoHost ${VERSIONCHECK} detected — skipping RedisBloom install"
    return 0
 fi
 REDIS_MODULE_DIR="/etc/redis/modules"
 REDISBLOOM_SO="$REDIS_MODULE_DIR/redisbloom.so"
 REDIS_CONF="/etc/redis/redis.conf"

 REDISBLOOM_VERSION="v2.8.17"
 REDISBLOOM_REPO="https://github.com/RedisBloom/RedisBloom.git"

 #-------------------------------------------------
 # Skip if already installed and registered
 #-------------------------------------------------
 if [ -f "$REDISBLOOM_SO" ] && grep -q '^loadmodule .*redisbloom\.so' "$REDIS_CONF"; then
    ynh_print_info "RedisBloom already installed, skipping rebuild"
    return 0
 fi

 ynh_print_info "Getting RedisBloom to work"

 ynh_systemctl --service=redis-server --action=stop

 mkdir -p "$REDIS_MODULE_DIR"

 tmpdir="$(mktemp -d)"

 ynh_setup_source --dest_dir="$tmpdir" --source_id="redisbloom" || ynh_die "Failed to clone RedisBloom"

 cp "$tmpdir/redisbloom.so" "$REDISBLOOM_SO"
 chmod 755 "$REDISBLOOM_SO"

 if ! grep -q "redisbloom.so" "$REDIS_CONF"; then
    ynh_print_info "Registering RedisBloom module globally"
    echo "loadmodule $REDISBLOOM_SO" >> "$REDIS_CONF"
 fi

 ynh_print_info "Restarting Redis service"
 ynh_systemctl --service=redis-server --action=restart

 ynh_safe_rm "$tmpdir"

 ynh_print_info "RedisBloom built and installed globally"

 ynh_die "Just for debugging purposes"
}
