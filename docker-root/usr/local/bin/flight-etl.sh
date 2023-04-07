#!/bin/sh
# ./flight-etl.sh start 启动 stop 停止 restart 重启 status 状态
AppName=flight-etl

#JAVA_HOME=/usr/local/jdk/jdk1.8.0_351/bin/java
# JVM参数
JVM_OPTS="-Dname=$AppName -Duser.timezone=Asia/Shanghai -Xms512m -Xmx1024m -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError -XX:+PrintGCDateStamps  -XX:+PrintGCDetails -XX:NewRatio=1 -XX:SurvivorRatio=30 -XX:+UseParallelGC -XX:+UseParallelOldGC"
APP_HOME=/data/flight-imf
LOG_PATH=$APP_HOME/logs/$AppName.log

if [ "$1" = "" ]; then
  echo -e "\033[0;31m 未输入操作名 \033[0m  \033[0;34m {start|stop|restart|status} \033[0m"
  exit 1
fi

if [ "$AppName" = "" ]; then
  echo -e "\033[0;31m 未输入应用名 \033[0m"
  exit 1
fi

start() {
  PID=$(ps -ef | grep java | grep $AppName | grep -v grep | awk '{print $2}')

  if [ x"$PID" != x"" ]; then
    echo "$AppName is running..."
  else
    nohup java $JVM_OPTS -jar $APP_HOME/$AppName.jar >$LOG_PATH 2>&1 &
    echo "Start $AppName success..."
  fi
}

stop() {
  echo "Stop $AppName"

  PID=""
  query() {
    PID=$(ps -ef | grep java | grep $AppName | grep -v grep | awk '{print $2}')
  }

  query
  if [ x"$PID" != x"" ]; then
    kill -TERM $PID
    echo "$AppName (pid:$PID) exiting..."
    while [ x"$PID" != x"" ]; do
      sleep 1
      query
    done
    echo "$AppName exited."
  else
    echo "$AppName already stopped."
  fi
}

restart() {
  stop
  sleep 3
  start
}

status() {
  PID=$(ps -ef | grep java | grep $AppName | grep -v grep | wc -l)
  if [ $PID != 0 ]; then
    echo "$AppName is running..."
  else
    echo "$AppName is not running..."
  fi
}

case $1 in
start)
  start
  ;;
stop)
  stop
  ;;
restart)
  restart
  ;;
status)
  status
  ;;
*) ;;

esac
