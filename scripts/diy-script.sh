# 修改默认IP & 固件名称
sed -i 's/192.168.1.1/192.168.123.251/g' package/base-files/files/bin/config_generate
sed -i "s/hostname='.*'/hostname='Ooya'/g" package/base-files/files/bin/config_generate

# TTYD 免登录
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

# 移除要替换的包
rm -rf feeds/packages/net/mosdns
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

git_sparse_clone master https://github.com/vernesong/OpenClash luci-app-openclash
git clone --depth=1 https://github.com/sbwml/luci-app-mosdns package/luci-app-mosdns
git clone --depth=1 https://github.com/gdy666/luci-app-lucky package/luci-app-lucky
git clone --depth=1 https://github.com/lmq8267/luci-app-vnt package/luci-app-vnt
git clone --depth=1 https://github.com/kongfl888/luci-app-adguardhome package/luci-app-adguardhome
git_sparse_clone main https://github.com/sirpdboy/luci-app-ddns-go ddns-go luci-app-ddns-go
git_sparse_clone main https://github.com/VIKINGYFY/packages luci-app-wolplus

./scripts/feeds update -a
./scripts/feeds install -a