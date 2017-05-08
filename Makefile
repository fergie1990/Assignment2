all: sema sync

sync: sync.swift
	mkdir -p bin
	swiftc -o bin/sync sync.swift
	
sema: sema.swift main.swift
	mkdir -p bin
	swiftc -o bin/sema sema.swift main.swift
	
clean:
	rm -rf bin