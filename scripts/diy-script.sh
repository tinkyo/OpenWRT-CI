# 修改默认IP & 固件名称
#sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate
sed -i "s/hostname='.*'/hostname='Ooya'/g" package/base-files/files/bin/config_generate

# TTYD 免登录
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

# 移除要替换的包
rm -rf feeds/packages/net/mosdns
rm -rf feeds/packages/net/msd_lite
rm -rf feeds/packages/net/alist
rm -rf feeds/luci/applications/luci-app-alist
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/adguardhome
rm -rf feeds/packages/net/ariang
#rm -rf package/emortal/luci-app-athena-led

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# Alist & AdGuardHome & WolPlus & AriaNg & 集客无线AC控制器 & Lucky
git clone --depth=1 https://github.com/sbwml/luci-app-alist package/luci-app-alist
git_sparse_clone main https://github.com/kenzok8/small-package adguardhome luci-app-adguardhome
git_sparse_clone main https://github.com/VIKINGYFY/packages luci-app-wolplus
git_sparse_clone master https://github.com/immortalwrt/packages net/ariang
git clone --depth=1 https://github.com/lwb1978/openwrt-gecoosac package/openwrt-gecoosac
git clone --depth=1 https://github.com/gdy666/luci-app-lucky package/luci-app-lucky
#git clone --depth=1 https://github.com/NONGFAH/luci-app-athena-led package/luci-app-athena-led
#chmod +x package/luci-app-athena-led/root/etc/init.d/athena_led package/luci-app-athena-led/root/usr/sbin/athena-led

git_sparse_clone master https://github.com/vernesong/OpenClash luci-app-openclash

# msd_lite
git clone --depth=1 https://github.com/ximiTech/luci-app-msd_lite package/luci-app-msd_lite
git clone --depth=1 https://github.com/ximiTech/msd_lite package/msd_lite

# MosDNS
git clone --depth=1 https://github.com/sbwml/luci-app-mosdns package/luci-app-mosdns

./scripts/feeds update -a
./scripts/feeds install -a