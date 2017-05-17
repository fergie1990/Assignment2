import Foundation

//this structure is used to hold the buffer 
//and initialise the semaphores needed
struct info
{
	var s = initialise(val: 1)
	var n = initialise(val: 1)
	var e = initialise(val: 1)
	var input = String()	
	var error: Int32 = 0
}

//read commands from standard input
func readStdin() -> String
{
	let input: String? = readLine()
	var tmp: String = ""
	//make sure input is not nil before unwrapping
	if input != nil {
	 tmp = input!
 	}
	return tmp
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

//this function is used to print the buffer with the child thread
func print(input: Arg) -> UnsafeMutableRawPointer?
{
	//waits for parent to read stdin
	procure(sema: &i.s)
	//check the structure contains something before unwrapping
	if input != nil 
	{
		let x = input!.load(as: info.self)
		print(x.input)
	}
	//allow the parent continue
	vacate(sema: &i.s)
	vacate(sema: &i.n)
	//waiting for notification that the user has pressed enter
	procure(sema: &i.e)
	print("Child thread is exiting")
	pthread_exit(nil)
}

//***Main***
var i = info()
//obtain all semaphores
procure(sema: &i.s)
procure(sema: &i.n)
procure(sema: &i.e)
//create the thread inside critical section and read stdin
i.error = pthread_create(&t, nil, print, &i)
errorHandler(error: i.error)
i.input = readStdin()
//signal child to use input
vacate(sema: &i.s)
//waiting for child to print buffer
procure(sema: &i.n)
print("Please press Enter")
repeat 
{
	i.input = readStdin()
} while i.input != ""
//allow child to continue
vacate(sema: &i.e)
//waiting for the child to exit
i.error = pthread_join(t, nil)
errorHandler(error: i.error)
print("Child thread is gone")
//clean up semaphores
destruct(sema: &i.s)
destruct(sema: &i.n)
destruct(sema: &i.e)