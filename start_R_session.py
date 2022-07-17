import socket
import subprocess
import os

#----- Info and inputs
# For helpful docker commands see:
# http://ropenscilabs.github.io/r-docker-tutorial/

# Edit as needed
docker_img = "jpalm070/wmh-actig:v0"
env = "WMHactig"
#-----

hostname = socket.gethostname() 
IP = socket.gethostbyname(hostname)
local_dir = os.getcwd()

print(f"""
####################################################
 
 Running image {docker_img}...

 Paste the following address into the browser:
 http://{IP}:8787

 Username: {env}
 Password: {env}

####################################################
""")

# With password
# docker_cmd = f"""docker run --rm -p 8787:8787 -e USER={env} -e PASSWORD={env} -e ROOT=TRUE \
# -v {local_dir}:/home/{env} {docker_img}"""

# Without password
docker_cmd = f"""docker run --rm -p 8787:8787 -e DISABLE_AUTH=true -e ROOT=TRUE \
-v {local_dir}:/home/{env} {docker_img}"""

docker_run = os.system(docker_cmd)
