Ansible / Nginx / Flask / MariaDB – Notes

Documentation links:
https://docs.ansible.com/projects/ansible/latest/reference_appendices/YAMLSyntax.html
https://docs.ansible.com/projects/ansible/2.9/modules/modules_by_category.html
https://docs.ansible.com/projects/ansible/latest/collections/community/mysql/index.html


- Ansible on Ubuntu:
  -> Install:
    sudo apt update
    sudo apt install software-properties-common
    sudo add-apt-repository --yes --update ppa:ansible/ansible
    sudo apt install ansible -y


- Ansible on Amazon Linux:
    sudo yum install nano vim git ansible zip unzip git -y
    sudo yum install -y
    sudo dnf update -y
    sudo dnf install -y python3 python3-pip
    pip3 install --no-cache-dir ansible
    echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
    source ~/.bashrc


  -> sudo -i
      - /etc/ansible/ansible.cfg -> inside it we have to run this command:
        ansible-config init --disabled -t all > ansible.cfg
      - then uncomment 'host_key_checking' in the new generated ansible.cfg and set it to False
      - chmod 400 client.pem
      - ansible node -m ping -i inventory     (now it should work)


- On CentOS machine to find a package we can use: 
  (context: when I tried to create a table in MariaDB I had some errors, then I logged in to the EC2 instance and ran the command below to see the dependencies. Also these dependencies are mentioned in the documentation above for each module: https://docs.ansible.com/projects/ansible/2.9/modules/modules_by_category.html)
    yum search python | grep -i mysql


- MySQL community module installation (link above: https://docs.ansible.com/projects/ansible/latest/collections/community/mysql/index.html  --> mysql_db module): 
    ansible-galaxy collection install community.mysql


- Logs:
    sudo touch /var/log/ansible.log
    sudo chown ubuntu:ubuntu /var/log/ansible.log


- Tree format:
    sudo apt install tree -y
    Example command:
      tree exercise14


- Roles:  
    doc: https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_reuse_roles.html
    mkdir roles && cd roles
    ansible-galaxy init post-install    -> this command will create the tree ready to use for our app


- When I need to copy the tasks from playbook.yaml to the specific location in the role tree, to remove the spaces from the beginning of the line I can use this command in vim:
    %s/~    //  
  -> this command will replace the 4 spaces between the '~' and '/' characters with nothing, so the whole line will be shifted to the left by 4 positions. Why 4? Because I pressed the space key 4 times between '~' and '/'.


- AWS / Amazon collection:
    ansible-galaxy collection install amazon.aws



==================================================
Debug notes
==================================================


NGINX:  -> on RedHat in this case

IMPORTANT -> after every modification I have to run:
    sudo nginx -t
    sudo systemctl reload nginx


  nginx -v                                  -> check if it is installed
    if it is not installed, install it with:
      sudo dnf install -y nginx
      sudo systemctl enable nginx
      sudo systemctl start nginx

  sudo systemctl status nginx               -> service status, it should be running
  sudo ss -tulnp | grep :80                 -> check if it listens on port 80


  Config files:
    /etc/nginx/nginx.conf                   -> user, global settings etc.
    /etc/nginx/conf.d/                      -> for sites/virtual hosts
    /etc/nginx/conf.d/default.conf          -> domains, ports, proxy_pass, ssl, web app etc.


  Static files:
    /usr/share/nginx/html/  e.g. -> /usr/share/nginx/html/index.html


  Logs:
    /var/log/nginx/access.log
    /var/log/nginx/error.log


  Install nano:
    sudo dnf install -y nano -> RHEL 8 & RHEL 9
    sudo yum install -y nano -> RHEL 7


  Test from NGINX EC2 to Flask EC2:
    curl http://172.31.2.79:5000/view      -> tests if Nginx EC2 can reach the Flask EC2 directly


  SELinux:
    sudo setsebool -P httpd_can_network_connect 1
    # -> Allows Nginx (httpd) to make outbound network connections to other servers.
    # -> This permanently fixes the "Permission denied" 502 error caused by SELinux.

    getsebool httpd_can_network_connect
    # -> Should return: httpd_can_network_connect --> on



FLASK:  -> on Debian in this case

  After every modification run:
    sudo systemctl restart flask
    sudo systemctl status flask   -> check status



  Debug commands:
    sudo systemctl status flask.service                 -> checks the status of the Flask service (running, failed, restart loop, etc.)
    sudo journalctl -u flask.service                    -> displays the logs of the Flask service
    sudo systemctl cat flask.service                    -> shows the exact command (ExecStart) used to start the Flask application
    tail -100 flask.trace                               -> shows the last 100 lines from the strace debug file generated for Flask
    sudo journalctl -u flask.service -n 50 --no-pager   -> shows the last 50 log entries for the flask.service unit


  App locations:
    /opt/flask_app/app.py             -> for virtual env deployment
    /etc/systemd/system/flask.service -> systemd service file
    Note:
      /root/app.py                    -> running Flask from root user (not recommended)


  Network / DB connectivity tools:
    sudo apt update
    sudo apt install -y netcat-openbsd            -> installs the netcat tool, used to test if a TCP port is reachable on a remote server
    nc -zv 172.31.1.47 3306                       -> tests if the MariaDB port (3306) is open and accepting connections


  MariaDB manual connection:
    mariadb -h 172.31.6.248 -u <DB_USER> -p       -> tries to connect manually to the MariaDB server
    mariadb -h 172.31.1.47 -u cvuser -p


  From NGINX side:
    curl http://172.31.2.79:5000/view              -> tests if Nginx EC2 can reach the Flask EC2 directly.



MARIADB:
  sudo systemctl status mariadb                 -> checks whether the MariaDB service is running on the database server
  sudo ufw status                               -> shows if the firewall is enabled and whether port 3306 is allowed
  sudo iptables -L -n                           -> shows low-level firewall rules that may block port 3306

  Install MariaDB:
    sudo apt update
    sudo apt install -y mariadb-server mariadb-client     -> Debian / Ubuntu
    sudo dnf install -y mariadb-server                    -> RHEL / CentOS
    sudo systemctl enable mariadb
    sudo systemctl start mariadb


  Secure installation:
    sudo mysql_secure_installation
    -> set root password
    -> remove anonymous users
    -> disallow remote root login
    -> remove test database
    -> reload privilege tables


  MariaDB config files:
    /etc/mysql/my.cnf
    /etc/mysql/mariadb.conf.d/50-server.cnf
    /etc/my.cnf                                   -> RHEL / CentOS


  Allow remote connections:
    Edit:
      bind-address = 0.0.0.0
    Then restart:
      sudo systemctl restart mariadb


  Create database and user:
    sudo mariadb

    CREATE DATABASE mydb;
    CREATE USER 'cvuser'@'%' IDENTIFIED BY 'password';
    GRANT ALL PRIVILEGES ON mydb.* TO 'cvuser'@'%';
    FLUSH PRIVILEGES;


  Check users and privileges:
    SELECT user, host FROM mysql.user;
    SHOW GRANTS FOR 'cvuser'@'%';


  Test from another machine:
    nc -zv <DB_IP> 3306                          -> tests if port 3306 is reachable
    mariadb -h <DB_IP> -u cvuser -p              -> manual connection test


  Logs:
    /var/log/mysql/error.log                    -> Debian / Ubuntu
    /var/log/mariadb/mariadb.log                -> RHEL / CentOS
    journalctl -u mariadb --no-pager -n 50


  Debug when MariaDB does NOT start:
    sudo systemctl restart mariadb
    sudo systemctl status mariadb
    sudo journalctl -xeu mariadb


  Check listening port:
    sudo ss -tulnp | grep 3306
    sudo netstat -tulnp | grep 3306


  Firewall allow MariaDB:
    sudo ufw allow 3306/tcp
    sudo firewall-cmd --add-port=3306/tcp --permanent
    sudo firewall-cmd --reload  