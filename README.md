# swoole
swoole镜像

### docker-compose.yml 配置
version: '3'
services:
    nginx:
    image: nginx:1.16
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ${APP_DIR}:/var/www/html/:rw
      - ${NGINX_CONFD_DIR}:/etc/nginx/conf.d/:rw
      - ${NGINX_CONF_FILE}:/etc/nginx/nginx.conf:ro
      - ${NGINX_LOG_DIR}:/var/log/nginx/:rw
    restart: always
    networks:
      - default

  php73:
    image: qiuapeng921/easyswoole
    ports:
      - "9501:9501"
    tty: true # 如果不启动服务，需要打开这个让镜像启动
    volumes:
      - ${APP_DIR}:/var/www/html/:rw
      - ${PHP72_PHP_CONF_FILE}:/usr/local/etc/php/php.ini:ro
      - ${PHP72_FPM_CONF_FILE}:/usr/local/etc/php-fpm.d/www.conf:rw
    restart: always
    cap_add:
      - SYS_PTRACE
    networks:
      - default
      
  portainer:
    image: portainer/portainer
    ports:
      - "9000:9000"
    restart: always
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./data/portainer:/data
    networks:
      - default
      
networks:
default:

