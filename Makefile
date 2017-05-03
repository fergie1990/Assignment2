all: sema sync

sync: sync.swift
	mkdir -p bin
	swiftc -o bin/sync sync.swift
	
sema: sema.swift
	mkdir -p bin
	swiftc -o bin/sema sema.swift

clean:
	rm -rf bin