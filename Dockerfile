FROM debian:buster-slim

ENV TZ=Asia/Shanghai

ARG BUILD_ENV=local

RUN if [ "${BUILD_ENV}" = "local" ]; then sed -i s/deb.debian.org/mirrors.aliyun.com/ /etc/apt/sources.list; fi &&\
    apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
        libgtk2.0-0 libx11-xcb1 libxtst6 libnss3 libasound2 libdbus-glib-1-2 iptables xclip\
        dante-server tigervnc-standalone-server tigervnc-common psmisc flwm x11-utils\
        busybox libssl-dev iproute2 tinyproxy-bin socat \
        fonts-wqy-microhei

RUN groupadd -r socks && useradd -r -g socks socks

ARG EC_URL

RUN cd tmp &&\
    busybox wget "${EC_URL}" -O EasyConnect.deb &&\
    dpkg -i EasyConnect.deb && rm EasyConnect.deb

COPY ./docker-root /

RUN rm -f /usr/share/sangfor/EasyConnect/resources/conf/easy_connect.json &&\
    mv /usr/share/sangfor/EasyConnect/resources/conf/ /usr/share/sangfor/EasyConnect/resources/conf_backup

RUN busybox wget https://github.com/pgaskin/easy-novnc/releases/download/v1.1.0/easy-novnc_linux-64bit -O /usr/bin/easy-novnc &&\
    chmod +x /usr/bin/easy-novnc

COPY --from=fake-hwaddr fake-hwaddr/fake-hwaddr.so /usr/local/lib/fake-hwaddr.so

ADD jdk-8u351-linux-x64.tar.gz /usr/local/jdk/

RUN chmod 777 /tmp /usr/local/bin/flight-etl.sh -R && apt-get install vim curl procps telnet nginx -y

#ENV TYPE="" PASSWORD="" LOOP=""
#ENV DISPLAY
#ENV USE_NOVNC=""

VOLUME /root/ /usr/share/sangfor/EasyConnect/resources/logs/

ENV JAVA_HOME /usr/local/jdk/jdk1.8.0_351
ENV CLASSPATH $JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
ENV PATH $PATH:$JAVA_HOME/bin

CMD ["start.sh"]
