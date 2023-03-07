param($vm, $iconfile);
#param? more like params.


$cmd = '"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm $vm --iconfile $iconfile';
iex "& $cmd";
