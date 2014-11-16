#git clone -b v3.0.8 https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git oldKernel

#delete previously generated files
rm -rf temp
mkdir temp
rm -rf newKernel/

#clean Kernel source folders to maximize equivalency
cd Kernel && make mrproper
cd oldKernel && make mrproper

#list contents of folders with full path
ls -R $PWD/Kernel/ | awk '
/:$/&&f{s=$0;f=0}
/:$/&&!f{sub(/:$/,"");s=$0;f=1;next}
NF&&f{ print s"/"$0 }'> temp/devKernel.list
ls -R $PWD/oldKernel/ | awk '
/:$/&&f{s=$0;f=0}
/:$/&&!f{sub(/:$/,"");s=$0;f=1;next}
NF&&f{ print s"/"$0 }' > temp/oldKernel.list

#format lists for comparison
cd temp
sort devKernel.list --output=devKernel.list
sed -i "s/Kernel/newKernel/g" devKernel.list
sort oldKernel.list --output=oldKernel.list
sed -i "s/oldKernel/newKernel/g" oldKernel.list

#strip superflous data
#ls -Rd $PWD/Kernel/* > temp/devKernel.list
#ls -Rd $PWD/oldKernel/* > temp/oldKernel.list
echo $PWD
#sed -i "s/$PWD//g" #temp/devKernel.list
#sed -i "s/$PWD//g" #temp/oldKernel.list

#generate removal list
sed -i "s/oldKernel/newKernel/g" temp/remove.list
sed -i "s/Kernel/newKernel/g" temp/remove.list
comm -13 temp/devKernel.list temp/oldKernel.list > temp/remove.list
cd ..

#generate newKernel folder
rsync -a oldKernel newKernel --exclude oldKernel/.git

#Remove all files not common to both kernels in newKernel folder
#rm <(echo temp/remove.list)

#generate patch from Kernel and newKernel diff
diff -uNr ./Kernel ./newKernel > temp/patchdevicefile

