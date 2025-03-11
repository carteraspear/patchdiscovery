import paramiko

# define ip n creds
ip_address = "192.168.1.0"
username = "something"
password = "something"

# setup ssh client
def check_patches_via_ssh():
    try:
        # create ssh client instance
        ssh = paramiko.SSHClient()
        # add servers host key for first time
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        
        # connect to the device with ssh
        ssh.connect(ip_address, username=username, password=password)
        
        # run commands to check for patches
        stdin, stdout, stderr = ssh.exec_command('check_for_patches')  # Replace with actual command
        
        # get output
        patches = stdout.read().decode()
        if patches:
            print("Available patches:")
            print(patches)
        else:
            print("No patches available.")
        
        # close ssh connection
        ssh.close()
    
    except Exception as e:
        print(f"Error checking patches via SSH: {e}")

# run the script
if __name__ == "__main__":
    check_patches_via_ssh()
