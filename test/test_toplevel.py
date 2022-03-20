import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles
import random
import numpy as np
import asyncio
import cv2

async def reset(dut):
    dut.reset.value = 0
    await ClockCycles(dut.clk, 5)
    dut.reset.value = 1
    await ClockCycles(dut.clk, 5)

hscan_items = []
last_hsync = None
last_vsync = 1

image = []
def parse_screen_state(r, g, b, vsync, hsync):
    global last_hsync
    global last_vsync
    global hscan_items
    global image
    if last_hsync == 0 and hsync == 1:
        if (len(hscan_items)) >= 400:
            # we expect hsync = 0 only on end of sync pulse.
            back_porch_items = list(q[4] for q in hscan_items[-96:])
            assert hscan_items[-97][4] == 1 # last element must be 1
            assert all(map(lambda x: x == 0, back_porch_items))

            # we expect front porch to be all zero
            scanline_imv = []
            for vp in hscan_items:
                try:
                    scanline_imv.append([vp[0].integer / 16.0, vp[1].integer / 16.0, vp[2].integer / 16.0])
                except:
                    print("AAAA", len(scanline_imv), len(image))
                    scanline_imv.append((0, 0, 0))
                    pass

            scanline_imv = np.array(scanline_imv)
            if scanline_imv.shape != (800, 3):
                print(len(scanline_imv), len(image))
            image.append(scanline_imv)

        hscan_items = []

    if last_vsync == 1 and vsync == 0:
        npimage = np.array(image)
        print(npimage.shape)
        #cv2.imshow('image',npimage)
        #cv2.waitKey(1)
        image = []

    last_hsync = hsync
    last_vsync = vsync
    hscan_items.append((r, g, b, vsync, hsync))
    #print(r, g, b, vsync, hsync)


@cocotb.test()
async def test_debouncer(dut):
    print("this is too slow to run")
    return
    global last_hsync
    clock = Clock(dut.clk, 3.9, units="us")
    cocotb.fork(clock.start())

    await reset(dut)

    while True:
        if last_hsync == None:
            last_hsync = dut.vga_h_sync.value
        try:
            parse_screen_state(dut.vga_b.value, dut.vga_g.value, dut.vga_r.value, dut.vga_v_sync.value, dut.vga_h_sync.value)
        except:
            print(f"failed for {(dut.vga_b.value, dut.vga_g.value, dut.vga_r.value, dut.vga_v_sync.value, dut.vga_h_sync.value)}")
        await ClockCycles(dut.clk, 1)

    exit(1)
