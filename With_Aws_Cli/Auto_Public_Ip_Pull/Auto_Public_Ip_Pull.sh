#!/bin/bash

# Bu script AWS hesabinda istedigimiz kriterlerde bir ec2 varligi kontrol eder ve bize ec2 yu hazir hale getirir.
# Ec2'nun public ip'sini alir ve otomatik olarak ssh_cnfig dosyasindaki Hostnamede guncelleme yapar. 
# Tekrar duzenlemeye gerek kalmadan ssh baglantisi yapabilir duruma getirir. 

# Degiskenleri burada ayarla.
AWS_REGION="us-east-1"
INSTANCE_NAME="Hard_Work"
ROLE_NAME="Turtle"
# IAM_ROLE_ARN=$(aws iam get-role --role-name $ROLE_NAME --output json | jq -r '.Role | .Arn')
SECURITY_GROUP_NAME="Hard_Work"
SECURITYGROUP_GROUP_NAME=$(aws ec2 describe-security-groups \
  --filters "Name=tag:Name,Values=$SECURITY_GROUP_NAME" \
  --query 'SecurityGroups[0].GroupName' \
  --output text)
KEY_NAME="Turtle"
LATEST_AMI_ALIAS=$(aws ec2 describe-images --owners amazon \
  --filters "Name=name,Values=amzn*" \
  --query 'sort_by(Images, &CreationDate)[].Name' \
  | grep 'kernel-5.10.*x86_64-gp2' | grep -v ecs | tail -1 | sed 's/.*amzn/amzn/')
LATEST_AMI_ID=$(aws ec2 describe-images --owners amazon \
  --filters "Name=name,Values=$LATEST_AMI_ALIAS" \
  --query 'Images | [0].ImageId' \
  --output text)
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=$INSTANCE_NAME" "Name=key-name,Values=$KEY_NAME" \
  --query 'Reservations | sort_by(@, &Instances[0].LaunchTime) | [-1].Instances[0].InstanceId' \
  --output text)

# Fonksiyonlari burada tanimla.
LAUNCH_INSTANCE() {
  INSTANCE_ID=$(aws ec2 run-instances --image-id $LATEST_AMI_ID --instance-type t2.micro \
    --key-name $KEY_NAME --security-groups $SECURITYGROUP_GROUP_NAME \
    --iam-instance-profile Name=$ROLE_NAME \
    --user-data file:///Users/emirhan/Documents/Clarusway/Auto_Public_Ip_Pull/user_data.sh \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" \
    --query "Instances[0].InstanceId" \
    --output text)
}

# Kosullari burada tanimla.
if [[ "$INSTANCE_ID" != "None" ]]; then
  # EC2 örneği bulundu.
  while true;
  do
  INSTANCE_STATUS=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=$INSTANCE_NAME" "Name=key-name,Values=$KEY_NAME" \
    --query "Reservations | sort_by(@, &Instances[0].LaunchTime) | [-1].Instances[0].State.Name" \
    --output text)
  if [[ "$INSTANCE_STATUS" == "running" ]]; then
    # Instance çalışıyor, bilgilendir.
    echo "'$INSTANCE_NAME' adında bir EC2 instance var ve çalışıyor."
    break
  elif [[ "$INSTANCE_STATUS" == "stopped" ]]; then
    # Instance durmuş, başlat ve bilgilendir.
    aws ec2 start-instances --instance-ids $INSTANCE_ID
    echo "'$INSTANCE_NAME' adındaki durmus EC2 instance başlatılıyor..."
    break
  elif [[ "$INSTANCE_STATUS" == "terminated" ]]; then
    # Intance terminate edilmis, yeniden ayaga kaldir ve bilgilendir.
    LAUNCH_INSTANCE
    echo "'$INSTANCE_NAME' adında yeniden bir EC2 instance oluşturuldu. Veriler aliniyor..."
    break
  else
    echo "'$INSTANCE_NAME' adındaki EC2 instance durumu arafta: Durumu '$INSTANCE_STATUS'."
    sleep 10  # 10 saniye bekle ve tekrar kontrol et.
  fi
  done 
else
  # Örnek bulunamazsa veya terminate edildiyse, yeni bir instance ayaga kaldir.
  LAUNCH_INSTANCE
  echo "'$INSTANCE_NAME' adında yeni bir EC2 örneği oluşturuldu. Veriler aliniyor..."
fi


# Halka açık IP gelene kadar bekle.
public_ip=""
while [[ -z "$public_ip" ]]; do
  public_ip=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID \
    --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
  sleep 5
done
# Public IP'yi bir değişkene ata.
TURTLE_PUBLIC_IP="$public_ip"
echo "TURTLE_PUBLIC_IP = $TURTLE_PUBLIC_IP"
# echo $TURTLE_PUBLIC_IP

# ./Auto_Public_Ip_Pull.sh | tee /dev/tty | tail -1 | xargs -I {} sed -i "" -E "/^Host Turtle$/,/^Host / s/HostName .*/HostName {}/" ~/.ssh/config
#     /dev/tty, Unix benzeri işletim sistemlerinde terminal (TTY: teletype) ile ilgili işlemler yapmak için kullanılan özel bir aygıt dosyasını temsil eder.
#     Bu dosya, genellikle kullanıcının terminaline bağlıdır ve standart girdi (stdin) ve standart çıktı (stdout) için bir yol sağlar.
    
#     Kısacası, /dev/tty cihazı, komut satırında veya terminal penceresinde çalışan işlemlerin girdi ve çıktısını doğrudan terminal ekranına iletmek için kullanılır.
#     Bu nedenle, /dev/tty üzerinden yazdırılan veriler kullanıcının terminal ekranında görüntülenir.
#     Bu, komutları çalıştırırken kullanıcıya bilgi ve geri bildirim sağlamak için sıkça kullanılır.

# ./Auto_Public_Ip_Pull.sh | tee >(head -n 2) | tail -1 | xargs -I {} sed -i "" -E "/^Host Turtle$/,/^Host / s/HostName .*/HostName {}/" ~/.ssh/config
# Yukaridaki ikisi terminalde calisiyor. En ustteki ve altaki alias atayinca calisiyor. Ikinci calismiyor. 
# Alttaki kod yukaridaki ip adresini okuyan ekonun silinmesini gerektirdi. Ama Ustteki iki kod da bu sorun yok. Echo dan yorum kaldirilabilir.

# Auto_Public_Ip_Pull.sh | tee /dev/tty | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | cat | xargs -I {} sed -i "" -E "/^Host Turtle$/,/^Host / s/HostName .*/HostName {}/" ~/.ssh/config