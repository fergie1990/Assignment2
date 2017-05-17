all: random sync

sync: sync.swift
	mkdir -p bin
	swiftc -o bin/sync sync.swift
	
random: sema.swift main.swift
	mkdir -p bin
	swiftc -o bin/random sema.swift main.swift
	
clean:
	rm -rf bin