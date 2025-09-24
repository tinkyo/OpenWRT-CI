# 修改默认IP & 固件名称
sed -i 's/192.168.1.1/192.168.123.251/g' package/base-files/files/bin/config_generate
sed -i "s/hostname='.*'/hostname='Ooya'/g" package/base-files/files/bin/config_generate

# TTYD 免登录
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

# 移除要替换的包
rm -rf feeds/packages/net/mosdns
rm -rf feeds/packages/net/msd_lite
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/adguardhome

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# 集客无线AC控制器 & Lucky
git_sparse_clone main https://github.com/kenzok8/small-package adguardhome luci-app-adguardhome luci-app-openclash luci-app-vlmcsd
git clone --depth=1 https://github.com/lwb1978/openwrt-gecoosac package/openwrt-gecoosac
git clone --depth=1 https://github.com/gdy666/luci-app-lucky package/luci-app-lucky

git clone --depth=1 https://github.com/lmq8267/luci-app-vnt package/luci-app-vnt

# msd_lite
git clone --depth=1 https://github.com/ximiTech/luci-app-msd_lite package/luci-app-msd_lite
git clone --depth=1 https://github.com/ximiTech/msd_lite package/msd_lite

git clone --depth=1 https://github.com/sirpdboy/luci-app-timecontrol package/luci-app-timecontrol
git clone --depth=1 https://github.com/sirpdboy/luci-app-watchdog package/watchdog

# MosDNS
git clone --depth=1 https://github.com/sbwml/luci-app-mosdns package/luci-app-mosdns

# Alist
git clone --depth=1 https://github.com/sbwml/luci-app-alist package/luci-app-alist

./scripts/feeds update -a
./scripts/feeds install -a

make package/openclash/clean
make package/openclash/compile -j$(nproc) V=s
