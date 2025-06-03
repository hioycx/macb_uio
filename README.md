# macb_uio
macb_uio module of dpdk

Supported Chipsets and NICs:

Phytium Ethernet interface cdns,phytium-gem-1.0

Phytium Ethernet interface cdns,phytium-gem-2.0

Preparations：

1.Download and compile the macb_uio driver, then load the driver:

git clone https://github.com/hioycx/macb_uio.git

cd macb_uio && make

modprobe uio

insmod ./macb_uio.ko

2.Bind the network interface to the macb_uio driver:

./dpdk-pdevbind.sh --bind macb_uio <网卡id>
