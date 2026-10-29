# Two builds from one source: make ARCH=rv32 / ARCH=rv64 (example.sh builds both)
ARCH ?= rv32
NAME := uart_$(ARCH)
LDS  := ../common/ld/riscv_virt.ld
SRCS := main.c
OUT  ?= build
include ../common/rules.mk
