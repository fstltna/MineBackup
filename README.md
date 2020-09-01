# MineBackup backup script for Minetest (1.4)
Creates a backup of your Minetest folder

Official support sites: [Official Github Repo](https://github.com/fstltna/MineBackup) - [Official Forum](https://minecity.online/index.php/forum/backup-script)  - [Official Download Area](https://minecity.online/index.php/downloads/category/5-server-tools)
![Minetest Sample Screen](https://MineCity.online/minetest_demo.png) 

---

1. Edit the settings at the top of minebackup.pl if needed
2. create a cron job like this:

        1 1 * * * /home/mtowner/MineBackup/minebackup.pl

3. This will back up your Minetest installation at 1:01am each day, and keep the last 5 backups.

Also note that this will shut down the Minetest server process before the backup and let it restart after the backup is complete. This is to prevent the world data dump from being corrupted if the files change while they are being backed up. If you dont want this I suggest you don't automatically run the backup but rather run the backup process within "mmc" when you want to run one.

If you need more help visit https://MineCity.online/
