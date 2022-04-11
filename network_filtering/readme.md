# Port knocking + port forwarding

##
1. Реализована проброска порта nginx на машине centosmachine2 10.10.10.3:80 => 10.10.10.2:8080
2. Реализован port knocking на хосте officemachine 192.168.1.102 на открытие поста 666 SSH
3. Рализован простой firewall на хосте officemachine с политикой DROP на цепочку INPUT
3. В получившейся сети реализован роутинг интернета через машину centos7machine1 10.10.10.1

### Схема стенда
![](https://github.com/Kerosin3/linux_hw/blob/main/network_filtering/pics/diagramm.png)

# Запуск и проверка работы

##
1. Выполнить vagrant up, убедившись что на хост машине открыты 2050-2053 порты, подождать пока ансибл настроит хосты.
2. На машине centos7machine2 в директории /home/vagrant/ лежат скрипты на открытие и закрытие портов на машине officemachine (knock_enable, knock disable)
3. curl http://10.10.10.2:8080 для проверки доступа к проброшенному порту.
* на хосте officemachine почему то происходит долгий перезапуск, если перезагружаться...
