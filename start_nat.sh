INTERFACE_IN=$1
INTERFACE_OUT=$2

if [ -z $INTERFACE_IN ]; then
	echo $0 "<ineterface_in>" "<interface_out>"
	exit
fi

if [ -z $INTERFACE_OUT ]; then
	echo $0 "<ineterface_in>" "<interface_out>"
	exit
fi

#IP_ADDR=`ip a show $INTERFACE_OUT | grep 'inet ' | awk '{print $2}'`

echo "Interface in --> "$INTERFACE_IN
echo "Interface out --> "$INTERFACE_OUT
echo "Addr interface out = "$INTERFACE_OUT $IP_ADDR

echo 1 > /proc/sys/net/ipv4/ip_forward

iptables -F
iptables -F -t nat
iptables -F -t mangle
iptables -X
iptables -t nat -X
iptables -t mangle -X

# Разрешаем сразу всё
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# Разрешаем доступ из внутренней сети наружу
iptables -A FORWARD -i $INTERFACE_IN -o $INTERFACE_OUT -j ACCEPT

# Разрешаем доступ снаружи во внутреннюю сеть
iptables -A FORWARD -i $INTERFACE_OUT -o $INTERFACE_IN -j ACCEPT

# Маскарадинг
iptables -t nat -A POSTROUTING -o $INTERFACE_OUT -j MASQUERADE

if [ $? -eq 0 ]; then
	echo "Success!"
else
	echo "Error!"
fi
