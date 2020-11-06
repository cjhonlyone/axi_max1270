# ip

source ./generate_ip.tcl

ip_create axi_max1270

ip_files axi_max1270 [list \
  "Max1270_Phy.v" \
  "Max1270_AXIL_Reg.v" \
  "Max1270_Top.v"]
  # "../lib/axis_async_fifo.tcl"]

ip_properties_lite axi_max1270


add_bus "s_axil" "slave" \
    "xilinx.com:interface:aximm_rtl:1.0" \
    "xilinx.com:interface:aximm:1.0" \
    { \
        {"s_axil_awvalid" "AWVALID"} \
        {"s_axil_awaddr" "AWADDR"} \
        {"s_axil_awprot" "AWPROT"} \
        {"s_axil_awready" "AWREADY"} \
        {"s_axil_wvalid" "WVALID"} \
        {"s_axil_wdata" "WDATA"} \
        {"s_axil_wstrb" "WSTRB"} \
        {"s_axil_wready" "WREADY"} \
        {"s_axil_bvalid" "BVALID"} \
        {"s_axil_bresp" "BRESP"} \
        {"s_axil_bready" "BREADY"} \
        {"s_axil_arvalid" "ARVALID"} \
        {"s_axil_araddr" "ARADDR"} \
        {"s_axil_arprot" "ARPROT"} \
        {"s_axil_arready" "ARREADY"} \
        {"s_axil_rvalid" "RVALID"} \
        {"s_axil_rdata" "RDATA"} \
        {"s_axil_rresp" "RRESP"} \
        {"s_axil_rready" "RREADY"} \
    }

ipx::infer_bus_interface s_axil_clk xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interface s_axil_rst xilinx.com:signal:reset_rtl:1.0 [ipx::current_core]

ipx::add_memory_map {s_axil} [ipx::current_core]
set_property slave_memory_map_ref {s_axil} [ipx::get_bus_interfaces s_axil -of_objects [ipx::current_core]]

set range 65536

ipx::add_address_block {axi_lite} [ipx::get_memory_maps s_axil -of_objects [ipx::current_core]]
set_property range $range [ipx::get_address_blocks axi_lite \
  -of_objects [ipx::get_memory_maps s_axil -of_objects [ipx::current_core]]]

ipx::add_bus_parameter ASSOCIATED_BUSIF [ipx::get_bus_interfaces s_axil_clk \
  -of_objects [ipx::current_core]]
set_property value s_axil [ipx::get_bus_parameters ASSOCIATED_BUSIF \
  -of_objects [ipx::get_bus_interfaces s_axil_clk \
  -of_objects [ipx::current_core]]]

ipx::save_core [ipx::current_core]

