Installation of the application is now complete. First thing you should do is **configure the email sending for your server**. If you use SMTP, you can use the app configuration panel within the YunoHost admin interface. You can also check other possibilities in the documentation available in the upstream loops-server repo (https://github.com/joinloops/loops-server/blob/main/INSTALLATION.md#mail-configuration).

When running on Yunohost 13+ (Trixie) the install script **installs the RedisBloom module globally on the system** to enable the "For You" feed feature. To avoid conflicts with other apps using the RedisBloom module **the module is not removed when uninstalling** Loops. 

When installing Loops on Yunohost 12 (Bookworm) the server still works except for the "For You" feature. 

To remove it from the system, go to /etc/redis/modules and remove the redisbloom.so module. Also remove the line "loadmodule /etc/redis/modules/redisbloom.so" from /etc/redis/redis.conf. Then restart Redis. 
