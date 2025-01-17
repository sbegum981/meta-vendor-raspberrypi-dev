SRC_URI:remove = "git://github.com/Evilpaul/RPi-config.git;protocol=git;branch=master"
SRC_URI += "git://github.com/Evilpaul/RPi-config.git;protocol=https;branch=master"

# RDK specific changes

DISABLE_OVERSCAN = "1"
DISABLE_SPLASH = "1"
BOOT_DELAY = "0"

# gpu mem config for 512 MB RAM and others respectively
GPU_MEM_256 = "128"
GPU_MEM_512 = "196"
GPU_MEM_1024 = "396"

# switch RPI to turbo mode
ARM_FREQ = "1000"
CORE_FREQ = "500"
SDRAM_FREQ = "500"
OVER_VOLTAGE = "6"

do_deploy:append:raspberrypi4() {
# Fix to enable both the HDMI ports in case of raspberry pi 4
# Force both hdmi mode to 720p@60Hz
    sed -i '/#hdmi_group=/ c\[HDMI:0]\
 hdmi_group=1\
[HDMI:1]\
 hdmi_group=1' ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
    sed -i '/#hdmi_mode=/ c\[HDMI:0]\
 hdmi_mode=4\
[HDMI:1]\
 hdmi_mode=4' ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
}

do_deploy:append() {
    echo "dtoverlay=lirc-rpi" >> ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
    # fix to enable audio from 4.4 kernel
    sed -i '/#dtparam=audio=/ c\dtparam=audio=on' ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt

    # Make the hdmi_force_hotplug configurable. To config this flag, adding the ENABLE_HDMI_FORCE_HOTPLUG env variable to the local.conf file.
    if [ -n "${ENABLE_HDMI_FORCE_HOTPLUG}" ]; then
        sed -i '/#hdmi_force_hotplug/ c\hdmi_force_hotplug=${ENABLE_HDMI_FORCE_HOTPLUG}' ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
    fi

    # Force hdmi mode to 720p@60Hz
    sed -i '/#hdmi_group=/ c\hdmi_group=1' ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
    sed -i '/#hdmi_mode=/ c\hdmi_mode=4' ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt

    sed -i '/#disable_splash=/ c\disable_splash=1' ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
    sed -i '/#boot_delay=/ c\boot_delay=0' ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
}

do_deploy:append_hybrid() {
    do_deploy_rdk_config
}

do_deploy:append:client() {
    do_deploy_rdk_config
}

do_deploy:append_ipclient() {
    do_deploy_rdk_config
}

do_deploy_rdk_config() {
    sed -i '/#gpu_freq=/ c\gpu_freq=500' ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt

   if [ "${@bb.utils.contains("DISTRO_FEATURES", "refapp", "yes", "no", d)}" = "no" ]; then
       sed -i '/gpu_mem_1024=/ c\gpu_mem_1024=64' ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
   fi
}

do_deploy:append_camera() {
    echo "# for sound over HDMI" >> ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
    echo "hdmi_drive=2" >> ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
}
