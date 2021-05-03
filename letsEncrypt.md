# Setting up Lets Encrypt

## NEW

```bash
sudo apt install certbot python3-certbot-nginx
```

## OLD

```bash
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update

# For older even setups use python-certbot-nginx
sudo apt-get install python3-certbot-nginx
```

## Check if firewall is enabled

```bash
sudo ufw status
```

## Enable all

```bash
sudo ufw allow 'Nginx Full'
sudo ufw delete allow 'Nginx HTTP'
```

## GET CERT

```bash
sudo certbot --nginx -d example.com -d www.example.com
```
