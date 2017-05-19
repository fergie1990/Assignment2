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

//checks if a string is numeric
extension String 
{
    var isInt: Bool 
		{
        return Int(self) != nil
    }
}

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

//reads the specified amount of random numbers
//and returns them in an array
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
	close(fd)
	return tmpBuffer
}

//initialise values based on command line arguments
func constructor(size: Int32, fill: Int32) -> info
{
	var i = info()
	i.bufferSize = size
	if fill == 1 || fill == 0
	{
		i.minFillLevel = 0
	} 
	else 
	{
	i.minFillLevel = (fill * -1) + 1
	}
	//ensure mutual exclusion when accessign the buffer
	i.s = initialise(val: 1)
	//ensure min fill level is respected
	i.n = initialise(val: i.minFillLevel)
	//ensure max buffer size is respected
	i.e = initialise(val: size)
	//ensure sync between theads when detecting exit command
	i.p = initialise(val: 1)
	return i
}

//cleans up semaphores
func clean()
{
	destruct(sema: &i.s)
	destruct(sema: &i.n)
	destruct(sema: &i.e)
	destruct(sema: &i.p)
}

//puts one value on the end of the buffer
func put_buffer(val: UInt16)
{
	i.buffer.append(val)
}

//takes one value off the front of the buffer
func get_buffer() -> UInt16
{
	let val = i.buffer.remove(at:0)
	return val
}

//takes an element from the buffer and prints it
func consumer(input: Arg) -> UnsafeMutableRawPointer?
{
	//waiting for user input
	while i.input == ""
	{
	}
	while(true)
	{
		//checking for exit command
		procure(sema: &i.p)
		if i.input == "exit"
		{
			break
		}
		vacate(sema: &i.p)
		//only print the amount specified by the user
		while i.inputval > 0
		{
			procure(sema: &i.n)
			procure(sema: &i.s)
			//get the value from the buffer
			let bval = get_buffer()
			//convert to hex and print
			let hex: String = String(bval, radix: 16)
			print("Ox", hex)
			i.inputval -= 1
			vacate(sema: &i.s)
			vacate(sema: &i.e)
		}
	}
	pthread_exit(nil)
}

//***Main***
//*Producer*
var i = info()
let arguments = CommandLine.arguments
var bs: Int32 = 5
var mfl: Int32 = 0
var inputval: Int32 = 0
//change the default values if CommandLine arguments are used
if arguments.count != 1 && arguments.count != 3
{
	print("Incorrect amount of arguments")
	exit(EXIT_FAILURE)
}
else if arguments.count == 3
{
	if arguments[1].isInt && arguments[2].isInt
	{
		print("test1")
		if let arg1 = Int32(arguments[1])
	 	{
			bs = arg1
		}
		if let arg2 = Int32(arguments[2]) 
		{
			mfl = arg2
		}
	}
	else
	{
		print("Please enter two integers")
		exit(EXIT_FAILURE)
	}
}
i = constructor(size: bs, fill: mfl)
i.error = pthread_create(&t, nil, consumer, &i)
errorHandler(error: i.error)
while i.input != "exit" 
{
	if i.inputval == 0 
	{
		procure(sema: &i.p)
		print("please enter a value or 'exit'")
		i.input = readStdin()
		if i.input == "exit"
		{
			vacate(sema: &i.p)
			break
		}
		if let j = Int32(i.input) {
			i.inputval = j
		}
		vacate(sema: &i.p)
	}
	//put random numbers in temp array
	var rval = readNum(val: i.inputval)
	//produce numbers on the buffer until specified amount is reached
	while(!rval.isEmpty)
	{
		procure(sema: &i.e)
		procure(sema: &i.s)
		put_buffer(val: rval.remove(at:0))
		vacate(sema: &i.s)
		vacate(sema: &i.n)
	}
}
i.error = pthread_join(t, nil)
errorHandler(error: i.error)
clean()