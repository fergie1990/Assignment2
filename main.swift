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
	var t: pthread_t? = nil
	typealias Arg = UnsafeMutableRawPointer
#else
	var t: pthread_t = pthread_t()
	typealias Arg = UnsafeMutableRawPointer?
#endif

func readNum(val: Int32) -> [UInt16]
{
	var randomNum: UInt16 = 0
	var tmpBuffer = [UInt16]()
	var count: Int32 = 0
	let fd = open("/dev/random", O_RDONLY)
	if fd != -1 
	{
		while count < val 
		{
			let size = read(fd, &randomNum, MemoryLayout<UInt16>.size)
			if size != MemoryLayout<UInt16>.size
			{
				print("Read failed with error:", errno)
				exit(EXIT_FAILURE)
			}
			else
			{
				tmpBuffer.append(randomNum)
			}
			count += 1
		}
	}
	//print("tmpBuffer:", tmpBuffer)
	return tmpBuffer
}

func constructor(size: Int32, fill: Int32) -> info
{
	var i = info()
	i.bufferSize = size
	i.minFillLevel = fill
	i.s = initialise(val: 1)
	i.n = initialise(val: fill)
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

//takes an element from the buffer and prints it
func consumer(input: Arg) -> UnsafeMutableRawPointer?
{
	while(true)
	{
		procure(sema: &i.n)
		sleep(3)
		//print("procure n", i.n.semval)
		procure(sema: &i.s)
		//print("procure s take")
		//sleep(1)
		//take
		let bval = get_buffer()
		print(bval)
		vacate(sema: &i.s)
		//print("vacate s")
		vacate(sema: &i.e)
		//print("vacate e", i.e.semval)
		//consume
		
	}
}

//***Main***
var i = info()
let arguments = CommandLine.arguments
var bs: Int32 = 5
var mfl: Int32 = 0

if arguments.count == 3
{
	if let arg1 = Int32(arguments[1]) {
		bs = arg1
	}
	if let arg2 = Int32(arguments[2]) {
		mfl = arg2
	}
}
else if arguments.count != 1 && arguments.count != 3
{
	print("Incorrect amount of arguments")
	exit(EXIT_FAILURE)
}
i = constructor(size: bs, fill: mfl)

var j: Int32 = 25
var rval = readNum(val: j)
while(!rval.isEmpty)
{
	//create the thread inside critical section and read stdin
	i.error = pthread_create(&t, nil, consumer, &i)
	errorHandler(error: i.error)
	//produce
	procure(sema: &i.e)
	//print("procure e", i.e.semval)
	procure(sema: &i.s)
	//print("procure s append")
	//append
	//sleep(1)
	//print(i.buffer.count)
	if !rval.isEmpty
	{
		put_buffer(val: rval.remove(at:0))
	}
	print(i.buffer)
	//print("buffer", i.buffer)
	vacate(sema: &i.s)
	//print("vacate s")
	vacate(sema: &i.n)
	//print("vacate n", i.n.semval)
}


i.error = pthread_join(t, nil)
errorHandler(error: i.error)
//clean()