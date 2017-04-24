all: sync

sync: sync.swift
	mkdir -p bin
	swiftc -o bin/sync sync.swift

clean:
	rm -rf bin