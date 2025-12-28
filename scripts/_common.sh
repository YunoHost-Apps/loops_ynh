#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

timezone=$(timedatectl show --value --property=Timezone)

yunohost_is_version_13() {
  yunohost_version="$(yunohost --version 2>/dev/null | awk '/^ version:/ {print $2; exit}')" # Get version number 
  ynh_print_info "Installed version of Yunohost: $yunohost_version"
  if echo "$yunohost_version" | grep -q "^13\."; then # Check if Version 13 is installed (required for redisbloom module is Redis 8.0)
    return 0 # Yes, it's YunoHost 13.x 
  fi 
  return 1 # No, it's not
}
#=================================================
# REDISBLOOM INSTALLER
#=================================================

redisbloom_check_for_install() {
  if redis-cli MODULE LIST 2>/dev/null | grep -q '"bf"'; then
    ynh_print_info "RedisBloom module already installed. Skipping installation"
  else
    redisbloom_installer
  fi
}

redisbloom_installer() {
    ynh_print_info "Installing RedisBloom module for Redis 8.0"

    # Stop Redis before modifying modules
    ynh_systemd_action --service_name=redis --action=stop

    # Ensure dependencies
    ynh_install_app_dependencies python3-pip build-essential cmake

    # Create a temporary working directory
    TMPDIR=$(mktemp -d)

    # Clone RedisBloom 8.0 branch
    git clone --recursive --branch 8.0 https://github.com/redisbloom/redisbloom "$TMPDIR"

    pushd "$TMPDIR/redisbloom"

        # Build the module
        ynh_print_info "Building RedisBloom…"
        make

        # Detect the compiled .so file (architecture‑independent)
        SOFILE="$(find bin -name redisbloom.so | head -n 1)"

        # Fail‑safe: abort if not found
        if [[ -z "$SOFILE" ]]; then
            popd
            ynh_secure_remove --file="$TMPDIR"
            ynh_die "RedisBloom build failed. ERROR: redisbloom.so not found after build. Aborting installation."
        fi

        # Install module
        ynh_print_info "Installing module into /etc/redis/modules/"
        mkdir -p /etc/redis/modules
        cp "$SOFILE" /etc/redis/modules/redisbloom.so

    popd

    # Fix permissions (Redis 8.0 requires +x)
    chmod +x /etc/redis/modules/redisbloom.so
    chmod 755 /etc/redis/modules/redisbloom.so
    chown redis:redis /etc/redis/modules/redisbloom.so 2>/dev/null || true

    # Add loadmodule line to redis.conf if not already present
    if ! grep -q "^[[:space:]]*loadmodule /etc/redis/modules/redisbloom.so" /etc/redis/redis.conf; then
        ynh_print_info "Adding RedisBloom module to redis.conf"
        echo "loadmodule /etc/redis/modules/redisbloom.so" >> /etc/redis/redis.conf
    else
        ynh_print_info "RedisBloom module already present in redis.conf"
    fi

    # Cleanup
    ynh_secure_remove --file="$TMPDIR"

    # Restart Redis
    ynh_systemd_action --service_name=redis --action=restart

    ynh_print_info "RedisBloom installation completed successfully."
}

