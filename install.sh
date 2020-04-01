
echo "installing..."

set d=`date +%F-%H-%M-%S`

mkdir ~/linux_workspace
cp -R * ~/linux_workspace


files=( .bashrc .bash_aliases .bash_functions )

for i in "${files[@]}"
do
	if [ -f ~/$i ]; then
	   	echo "backing up " $i
		 mv ~/$i ~/linux_workspace/backups/$i.$d
	fi
done
cd ~/
for i in "${files[@]}"
do
	echo "setting up static links "
	ln -s ~/linux_workspace/$i ~/$i
	cat ~/$i
done

echo "done."
