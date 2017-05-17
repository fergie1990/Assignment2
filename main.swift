import Foundation

//this structure is used to hold the buffer 
//and initialise the semaphores needed
struct info
{
	var bufferSize = Int32()
	var minFillLevel = Int32() 
	var s = sem()
	var n = sem()
	var e = sem()
	var buffer = [UInt16] ()
	var count: Int = 0
	var error: Int32 = 0
}

//this defines the thread and the type of Arg
//for either macOS or linux/Ubuntu
#if os(macOS)
	var t1: pthread_t? = nil
	var t2: pthread_t? = nil
	typealias Arg = UnsafeMutableRawPointer
#else
	var t1: pthread_t = pthread_t()
	var t2: pthread_t = pthread_t()
	typealias Arg = UnsafeMutableRawPointer?
#endif

func readNum() -> UInt16
{
	var randomNum: UInt16 = 0
	let fd = open("/dev/random", O_RDONLY)
	if fd != -1 
	{
		let size = read(fd, &randomNum, MemoryLayout<UInt16>.size)
		if size != MemoryLayout<UInt16>.size
		{
			print("Read failed with error:", errno)
			exit(EXIT_FAILURE)
		}
	}
	return randomNum
}

func constructor(size: Int32, fill: Int32) -> info
{
	var i = info()
	i.bufferSize = size
	i.minFillLevel = fill
	i.s = initialise(val: 1)
	i.n = initialise(val: 0)
	i.e = initialise(val: size)
	return i
}

func clean()
{
	//clean up semaphores
	destruct(sema: &i.s)
	destruct(sema: &i.n)
	destruct(sema: &i.e)
}

func put_buffer(val: UInt16)
{
	i.buffer.append(val)
}

func get_buffer() -> UInt16
{
	let val = i.buffer.remove(at:0)
	return val
}

//produces a random number and inserts it in the buffer
func producer(input: Arg) -> UnsafeMutableRawPointer?
{
	while(true)
	{
		//produce
		let rval = readNum()
		procure(sema: &i.e)
		//print("procure e")
		procure(sema: &i.s)
		print("append")
		print(rval)
		//append
		put_buffer(val: rval)
		vacate(sema: &i.s)
		//print("vacate s")
		vacate(sema: &i.n)
		//print("vacate n")
		
	}
}

//takes an element from the buffer and prints it
func consumer(input: Arg) -> UnsafeMutableRawPointer?
{
	while(true)
	{
		procure(sema: &i.n)
		//print("procure n")
		procure(sema: &i.s)
		print("take")
		//take
		let bval = get_buffer()
		vacate(sema: &i.s)
		//print("vacate s")
		vacate(sema: &i.e)
		//print("vacate e")
		//consume
		print(bval)
	}
}

//***Main***
var i = constructor(size: 5, fill: 0)
//create the thread inside critical section and read stdin
i.error = pthread_create(&t1, nil, producer, &i)
errorHandler(error: i.error)
i.error = pthread_create(&t2, nil, consumer, &i)
errorHandler(error: i.error)
i.error = pthread_join(t1, nil)
errorHandler(error: i.error)
i.error = pthread_join(t2, nil)
errorHandler(error: i.error)
clean()