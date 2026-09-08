#!/bin/bash
banner() {
    clear

    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║   ██████╗ ██╗██╗  ██╗███████╗██╗      ██████╗ ███████╗     ║"
    echo "║   ██╔══██╗██║╚██╗██╔╝██╔════╝██║     ██╔═══██╗██╔════╝     ║"
    echo "║   ██████╔╝██║ ╚███╔╝ █████╗  ██║     ██║   ██║███████╗     ║"
    echo "║   ██╔═══╝ ██║ ██╔██╗ ██╔══╝  ██║     ██║   ██║╚════██║     ║"
    echo "║   ██║     ██║██╔╝ ██╗███████╗███████╗╚██████╔╝███████║     ║"
    echo "║   ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝ ╚═════╝ ╚══════╝     ║"
    echo "║                                                            ║"
    echo "║              E V O L U T I O N   X                         ║"
    echo "║              Automated Release Builder                     ║"
    echo "║                                                            ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "║  Build      : bp4a-user                                    ║"
    echo "║  Branch     : sixteen-qpr2                                 ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
}


banner;

echo "============================================="
echo "    cleaning up previous local manifests    "
echo "============================================="

rm -rf .repo/local_manifests;
rm -rf out/soong/.intermediates/system/sepolicy;


echo ""
echo "====================="
echo "      repo init      "
echo "====================="

repo init -u https://github.com/PixelOS-AOSP/android_manifest.git -b sixteen-qpr2 --depth=1 --git-lfs;
git clone https://github.com/marcmyworld/chenfeng_manifest.git -b lineage-23.2 --depth=1 .repo/local_manifests;


echo ""
echo "==================="
echo "     repo sync     "
echo "==================="

/opt/crave/resync.sh;

export BUILD_USERNAME=marc
export BUILD_HOSTNAME=foss

rm -rf build/soong/fsgen;


echo ""
echo "===================="
echo "   starting build  "
echo "===================="

source build/envsetup.sh;
export WITH_GMS=true
breakfast chenfeng;
m pixelos -j$(nproc --all);


echo ""
echo "=========================================="
echo "      uploading to sharing platforms      "
echo "=========================================="

ZIP=$(find out/target/product/chenfeng -maxdepth 1 -type f -name "*.zip" | head -n 1)

if [ -n "$ZIP" ]; then
    echo "Uploading: $ZIP..."
    wget https://raw.githubusercontent.com/marcmyworld/chenfeng/refs/heads/main/tools/upload_util.sh
    chmod +x upload_util.sh
    ./upload_util.sh "$ZIP"
else
    echo "No ROM ZIP found in artifacts!"
    exit 1
fi
