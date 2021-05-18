# MineBackup backup script for Minetest (1.5.2)
Creates a backup of your Minetest folder

Official support sites: [Official Github Repo](https://github.com/fstltna/MineBackup) - [Official Forum](https://minecity.online/index.php/forum/backup-script)  - [Official Download Area](https://minecity.online/index.php/downloads/category/5-server-tools)
![Minetest Sample Screen](https://MineCity.online/minetest_demo.png) 

---

1. Edit the settings at the top of minebackup.pl if needed
2. Edit the entries in backups.rc
3. create a cron job like this:

        crontab -e
        1 1 * * SUN /home/mtowner/MineBackup/minebackup.pl warn

3. This will back up your Minetest installation at 1:01am each week, and keep the last 5 backups. It will warn the users 5 minutes (change the backups.rc file if you want a different delay).

4. Download the "go" language file with:
	
        pushd /tmp
        wget https://dl.google.com/go/go1.15.2.linux-amd64.tar.gz
        sudo tar -xvf go1.15.2.linux-amd64.tar.gz
        sudo mv go /usr/local
        popd

5. Edit your **~/.bashrc** file and add these entrys:

        export GOROOT=/usr/local/go
        export GOPATH=$HOME/go
        export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

6. Edit the **irccat/irccat.json** to set your IRC info.

7. For the last step we set the irccat process to start at boot.

        crontab -e
        @reboot /home/mtowner/MineBackup/startirccat

8. Log out and back in, just to be sure everything is set up...

Note that this will shut down the Minetest server process before the backup and let it restart after the backup is complete. This is to prevent the world data dump from being corrupted if the files change while they are being backed up. If you dont want this I suggest you use the "warn" option as above so people are warned the server is going to come down. You can also use the backup process within "mmc" when you want to run immediately.

If you need more help visit https://MineCity.online/ and join our Discord server at https://discord.gg/Bd4Xw9c.

