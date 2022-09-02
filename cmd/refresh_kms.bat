slmgr.vbs /ckhc
slmgr.vbs /ckms
ipconfig /flushdns
net stop sppsvc && net start sppsvc
slmgr.vbs /ato
slmgr.vbs /skhc
