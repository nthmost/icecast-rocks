sudo apt install liquidsoap

# Verify liquidsoap user details
id liquidsoap

# Make sure liquidsoap has proper home directory and shell
sudo usermod -d /home/liquidsoap -s /bin/bash liquidsoap

sudo mkdir -p /home/liquidsoap
sudo chown liquidsoap:liquidsoap /home/liquidsoap
