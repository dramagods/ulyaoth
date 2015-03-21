buildarch="$(uname -m)"
version=5.0.0

useradd ulyaoth
cd /home/ulyaoth
yum install -y ant
su ulyaoth -c "rpmdev-setuptree"

su ulyaoth -c "wget http://apache.mirrors.spacedump.net/lucene/solr/5.0.0/solr-5.0.0.tgz"
su ulyaoth -c "tar xvf solr-$version.tgz"
rm -rf /home/ulyaoth/solr-$version/examples
rm -rf /home/ulyaoth/solr-$version/docs
rm -rf /home/ulyaoth/solr-$version/bin/init.d
rm -rf /home/ulyaoth/solr-$version/bin/install_solr_service.sh
su ulyaoth -c "tar cvf solr-$version.tar.gz solr-$version/"
su ulyaoth -c "mv solr-$version.tar.gz /home/ulyaoth/rpmbuild/SOURCES/"

cd /home/ulyaoth/rpmbuild/SOURCES/
su ulyaoth -c "wget https://raw.githubusercontent.com/sbagmeijer/ulyaoth/master/Repository/ulyaoth-solr/SOURCES/solr5-log4j.properties"
su ulyaoth -c "wget https://raw.githubusercontent.com/sbagmeijer/ulyaoth/master/Repository/ulyaoth-solr/SOURCES/solr5-solr.init"

cd /home/ulyaoth/rpmbuild/SPECS/
su ulyaoth -c "wget https://raw.githubusercontent.com/sbagmeijer/ulyaoth/master/Repository/ulyaoth-solr/SPECS/ulyaoth-solr5.spec"

if [ "$arch" != "x86_64" ]
then
sed -i '/BuildArch: x86_64/c\BuildArch: '"$buildarch"'' ulyaoth-solr5.spec
fi

su ulyaoth -c "rpmbuild -bb ulyaoth-solr5.spec"
cp /home/ulyaoth/rpmbuild/RPMS/x86_64/* /root/
cp /home/ulyaoth/rpmbuild/RPMS/i686/* /root/
cp /home/ulyaoth/rpmbuild/RPMS/i386/* /root/