echo -e "\033[32m 欢迎使用BoxXt提供的小白一键搭建 Xray Reality 脚本 \033[0m"
echo "检查是否包含git环境"

if ! [ -x "$(command -v git)" ]; then
  echo '没有git环境, 正在安装git...' >&2
  sudo apt update
  sudo apt install git -y
fi
echo 'git已经安装完成'

echo '拉取singbox'
git clone https://github.com/SagerNet/sing-box
cd sing-box
git switch dev-next
echo "检查及自动安装go环境"
if ! [ -x "$(command -v go)" ]; then
curl -Lo go.tar.gz https://go.dev/dl/go1.20.1.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go.tar.gz
rm go.tar.gz
fi
echo 'go环境已经安装完成'

echo "安装singbox"
./release/local/install.sh

echo "拉取初始singbox配置文件"
curl -o config.json https://raw.githubusercontent.com/BoxXt/installReality/main/config.json && mv config.json /usr/local/etc/sing-box/config.json
curl -o meta.yaml https://raw.githubusercontent.com/BoxXt/installReality/main/meta.yaml && mv meta.yaml /usr/local/etc/sing-box/meta.yaml


echo "启动singbox用于安装reality"
echo "\033[32m 生成密钥对,生成之后请保存好你的密钥对 \033[0m"
result=`sing-box generate reality-keypair`
echo "\033[31m $result \033[0m" 
echo -n "是否已经保存好你的密钥对?[y/n]"
read name
echo -n "\033[32m 请输入你刚刚保存的密钥对中的私钥（PrivateKey）: \033[0m"
read pkey
echo -n "\033[32m 请输入你刚刚保存的密钥对中的公钥（Pubilckey）: \033[0m"
read pukey
sed -in "s/pkey/$pkey/g" /usr/local/etc/sing-box/config.json

echo "生成uuid"
uuid=`sing-box generate uuid`
echo $uuid
sed -in "s/puuid/$uuid/g" /usr/local/etc/sing-box/config.json

echo "安装openssl"
sudo apt-get update && sudo apt-get install openssl
shortid=`openssl rand -hex 4`
echo "随机生成short_id"
echo $shortid
sed -in "s/pshortid/$shortid/g" /usr/local/etc/sing-box/config.json

echo "完成配置，启动singbox"

systemctl start sing-box

echo "以下是支持reality的meta客户端所需要的配置信息："
echo "\033[31m servername: www.microsoft.com \033[0m"
echo "\033[31m flow: xtls-rprx-vision \033[0m"
echo "\033[31m uuid: $uuid \033[0m"
echo "\033[31m $result \033[0m"
echo "\033[31m short_id: $shortid \033[0m"

sed -in "s/pukey/$pukey/g" /usr/local/etc/sing-box/meta.yaml
sed -in "s/pshortid/$shortid/g" /usr/local/etc/sing-box/meta.yaml
sed -in "s/puuid/$uuid/g" /usr/local/etc/sing-box/meta.yaml
echo "\033[32m 以下是你的meta客户端所需要的可用示例配置文件： \033[0m"
cat /usr/local/etc/sing-box/meta.yaml
echo "完成搭建"





