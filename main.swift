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
	var p = sem()
	var buffer = [UInt16] ()
	var input: String = ""
	var inputval: Int32 = 0
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

//read commands from standard input
func readStdin() -> String
{
	let input: String? = readLine()
	var tmp: String = ""
	
	if input != nil {
	 tmp = input!
 	}
	return tmp
}

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
	i.n = initialise(val: 0)
	i.e = initialise(val: size)
	i.p = initialise(val: 1)
	return i
}

func clean()
{
	//clean up semaphores
	destruct(sema: &i.s)
	destruct(sema: &i.n)
	destruct(sema: &i.e)
	destruct(sema: &i.p)
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
	while i.input == ""
	{
	}
	while(true)
	{
		procure(sema: &i.p)
		//print("procure p", i.p.semval)
		if i.input == "exit"
		{
			break
		}
		vacate(sema: &i.p)
		//print("vacate p", i.p.semval)
		while i.inputval > 0
		{
			procure(sema: &i.n)
			//sleep(3)
			//print("procure n", i.n.semval)
			procure(sema: &i.s)
			//print("procure s take")
			//sleep(1)
			//take
			let bval = get_buffer()
			print(bval)
			i.inputval -= 1
			// if i.inputval == 0
			// {
			// 	vacate(sema: &i.p)
			// 	print("vacate p", i.p.semval)
			// }
			vacate(sema: &i.s)
			//print("vacate s")
			vacate(sema: &i.e)
			//print("vacate e", i.e.semval)
			//consume
		}
	}
	//print("child exiting")
	pthread_exit(nil)
}

//***Main***
var i = info()
let arguments = CommandLine.arguments
var bs: Int32 = 5
var mfl: Int32 = 0
var inputval: Int32 = 0
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
i.error = pthread_create(&t, nil, consumer, &i)
errorHandler(error: i.error)
while i.input != "exit" 
{
	if i.inputval == 0 
	{
		procure(sema: &i.p)
		//print("procure p", i.p.semval)
		print("please enter the amount of numbers you want to read")
		i.input = readStdin()
		if i.input == "exit"
		{
			vacate(sema: &i.p)
			//print("vacate p", i.p.semval)
			break
		}
		if let j = Int32(i.input) {
			i.inputval = j
			//print("inputval", i.inputval)
		}
		vacate(sema: &i.p)
		//print("vacate p", i.p.semval)
	}
	var rval = readNum(val: i.inputval)
	while(!rval.isEmpty)
	{
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
		//print(i.buffer)
		//print("buffer", i.buffer)
		vacate(sema: &i.s)
		//print("vacate s")
		vacate(sema: &i.n)
		//print("vacate n", i.n.semval)
	}
}
//print("end")
i.error = pthread_join(t, nil)
errorHandler(error: i.error)
clean()