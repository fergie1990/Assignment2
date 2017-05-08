import Foundation

//this structure is used to hold the buffer
//and the mutexes to be used by both threads
// struct info 
// {
// 	var input = String()
// 	var error: Int32 = 0	
// }

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
	//print("test")
	procure(sema: &s)
	//print("test2")
	//check the structure contains something before unwrapping
	if input != nil 
	{
		let x = input!.load(as: sem.self)
		print(x.input)
	}
	
	//allow the parent continue
	vacate(sema: &s)
	/*
	//waiting for notification that the user has pressed enter
	*/
	pthread_exit(nil)
}

//***Main***
//var i = info()
var s = initialise(val: 1)
var n = initialise(val: 1)

procure(sema: &s)
//create the thread inside readlock and read stdin
if s.error != pthread_create(&t, nil, print, &s)
{
	print("Failed to create thread")
}

s.input = readStdin()
//release readlock for child to use input
vacate(sema: &s)

/*
//waiting for child to print buffer

print("Please press Enter")
repeat 
{
	i.input = readStdin()
} while i.input != ""

//allows child to continue
*/
//waiting for the child to exit
if s.error != pthread_join(t, nil)
{
	print("pthread join failed")
}
print("Child thread is gone")
