# OSPF based on frr
Задание:
Поднять три виртуалки
Объединить их разными vlan
поднять OSPF между машинами на базе Quagga;
изобразить ассиметричный роутинг;
сделать один из линков "дорогим", но что бы при этом роутинг был симметричным.
##
1. Реализован OSPF между тремя хостами
2. Реализован симметричный роутинг
2. Реализован ассимметричный роутинг
3. Рализован простой firewall на хосте officemachine с политикой DROP на цепочку INPUT
3. В получившейся сети реализован роутинг интернета через машину centos7machine1 10.10.10.1

### Схема стенда
![](https://github.com/Kerosin3/linux_hw/blob/main/ospf/pics/ospf.jpg)

# Запуск и проверка работы

##
1. Выполнить vagrant up, убедившись что на хост машине открыты 2050-2052 порты, <u>установлен пакет netaddr (pip install netaddr)</u>, подождать пока ансибл настроит хосты, осуществить проверку с помощью команд systemctl status frr и ip -c a
2. Для иммитации ассиметричного роутинга установить переменную assymetric: true в файле vm_config_machine1.yml на 20 строчке, выполнить команду vagrant reload machine1
3. Для проверки ассиметричного роутинга использовать команды tcpdump -i enp0s8 icmp и tcpdump -i enp0s10 icmp на хосте machine2, наблюдать ассиметричный роутинг пакетов, установлено rp_filter = 0
4. Для иммитации симметричного роутинга выполнить команду  ansible-playbook -i ansible_config/hosts.yaml special_one.yaml ( устанавливает на хостах 1 и 2 rp_filter = 1 )
5. Для проверки иммитации использовать команду tcpdump -i enp0s10 icpm
*

##
Наличие поднятой OSPF
###
Пинг с machine1 до machine2 работает, ospf поднят.
![](https://github.com/Kerosin3/linux_hw/blob/main/ospf/pics/ospf.png)
![](https://github.com/Kerosin3/linux_hw/blob/main/ospf/pics/main.png)

##
Иммитация ассиметричного роутинга
###
Пакеты с хоста machine1 идут через machine3 на machine2, ответы идут непосредственно к machine1, ассиметрия достигнута.
![](https://github.com/Kerosin3/linux_hw/blob/main/ospf/pics/asym1.png)

##
Имитация симметричного роутинга
###
После установки rp_filter = 1 пакеты от machine 1 идет на machine2 через machine3, однако обратно они так же идут через machine3, симметрия достигнута.
![](https://github.com/Kerosin3/linux_hw/blob/main/ospf/pics/symm.png)
