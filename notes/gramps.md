
rsync -rvht ~/Library/Application\ Support/gramps/grampsdb/322b11e0-b651-49b6-b4a4-a53577da0904 leopard:~/gramps/  

On Leopard:

sudo systemctl stop podman-gramps-web

sudo rsync -rvha --delete /fastdata/grampsweb/ /data2/grampsweb/             

sudo rsync -rvht ~/gramps/322b11e0-b651-49b6-b4a4-a53577da0904/ /fastdata/grampsweb/db/322b11e0-b651-49b6-b4a4-a53577da0904/

sudo systemctl start podman-gramps-web
