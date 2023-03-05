#!/bin/bash

git clone --depth 1 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon

# change repository to github
sed -i 's|git.openwrt.org/feed/packages.git|github.com/openwrt/packages.git|g' feeds.conf.default
sed -i 's|git.openwrt.org/project/luci.git|github.com/openwrt/luci.git|g' feeds.conf.default
sed -i 's|git.openwrt.org/feed/routing.git|github.com/openwrt/routing.git|g' feeds.conf.default
sed -i 's|git.openwrt.org/feed/telephony.git|github.com/openwrt/telephony.git|g' feeds.conf.default
