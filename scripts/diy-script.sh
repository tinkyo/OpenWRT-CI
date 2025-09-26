# 修改默认IP & 固件名称
sed -i 's/192.168.1.1/192.168.123.251/g' package/base-files/files/bin/config_generate
sed -i "s/hostname='.*'/hostname='Ooya'/g" package/base-files/files/bin/config_generate

# TTYD 免登录
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

# 移除要替换的包
rm -rf feeds/packages/net/msd_lite
rm -rf feeds/packages/net/mosdns
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/adguardhome
rm -rf feeds/packages/lang/rust

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

git_sparse_clone master https://github.com/vernesong/OpenClash luci-app-openclash
git_sparse_clone main https://github.com/kenzok8/small-package adguardhome luci-app-adguardhome
git_sparse_clone main https://github.com/sirpdboy/luci-app-ddns-go ddns-go luci-app-ddns-go
git clone --depth=1 https://github.com/lmq8267/luci-app-vnt package/luci-app-vnt
git clone --depth=1 https://github.com/animegasan/luci-app-wolplus package/luci-app-wolplus

# MosDNS
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang
rm -rf feeds/packages/net/v2ray-geodata
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# Alist
git clone --depth=1 https://github.com/sbwml/luci-app-alist package/luci-app-alist

./scripts/feeds update -a
./scripts/feeds install -a