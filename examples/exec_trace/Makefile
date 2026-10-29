# make ITER=n NAME=...: one image per loop length
NAME ?= trace
ARCH := rv32
LDS  := ../common/ld/riscv_virt.ld
SRCS := main.c
OUT  ?= build
ITER ?= 16
DEFS := -DITER=$(ITER)
include ../common/rules.mk
