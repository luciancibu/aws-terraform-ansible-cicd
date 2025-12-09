sudo amazon-linux-extras enable ansible2
sudo yum install ansible -y
sudo dnf update -y
sudo dnf install -y python3 python3-pip
pip3 install --user ansible
echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
source ~/.bashrc