import Foundation

//this structure is used to hold the buffer
//and the mutexes to be used by both threads
struct info 
{
	var input = String()
	var error: Int32 = 0
	var readlock = pthread_mutex_t()
	var enterlock = pthread_mutex_t()
	var exitlock = pthread_mutex_t()
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
	if i.error != pthread_mutex_lock(&i.readlock)
	{
		print("Mutex failed to lock")
	}
	//check the structure contains something before unwrapping
	if input != nil 
	{
		let x = input!.load(as: info.self)
		print(x.input)
	}
	if i.error != pthread_mutex_unlock(&i.readlock)
	{
		print("Mutex failed to unlock")
	}
	
	//allow the parent continue
	if i.error != pthread_mutex_unlock(&i.enterlock)
	{
		print("Mutex failed to unlock")
	}
	//waiting for notification that the user has pressed enter
	if i.error != pthread_mutex_lock(&i.exitlock)
	{
		print("Mutex failed to lock")
	}
	print("Child thread is exiting")
	if i.error != pthread_mutex_unlock(&i.exitlock)
	{
		print("Mutex failed to unlock")
	}
	pthread_exit(nil)
}

//***Main***
var i = info()

//initialising all the mutexes needed for future use
if i.error != pthread_mutex_init(&i.readlock, nil)
{
	print("Thread not initialised")
}
if i.error != pthread_mutex_init(&i.enterlock, nil)
{
	print("Thread not initialised")
}
if i.error != pthread_mutex_init(&i.exitlock, nil)
{
	print("Thread not initialised")
}

//locking all the mutexes
if i.error != pthread_mutex_lock(&i.readlock)
{
	print("Mutex failed to lock")
}
if i.error != pthread_mutex_lock(&i.enterlock)
{
	print("Mutex failed to lock")
}
if i.error != pthread_mutex_lock(&i.exitlock)
{
	print("Mutex failed to lock")
}

//create the thread inside readlock and read stdin
if i.error != pthread_create(&t, nil, print, &i)
{
	print("Failed to create thread")
}

i.input = readStdin()
//release readlock for child to use input
if i.error != pthread_mutex_unlock(&i.readlock)
{
	print("Mutex failed to unlock")
}
//waiting for child to print buffer
if i.error != pthread_mutex_lock(&i.enterlock)
{
	print("Mutex failed to lock")
}
print("Please press Enter")
repeat 
{
	i.input = readStdin()
} while i.input != ""
if i.error != pthread_mutex_unlock(&i.enterlock)
{
	print("Mutex failed to unlock")
}
//allows child to continue
if i.error != pthread_mutex_unlock(&i.exitlock)
{
	print("Mutex failed to unlock")
}

//waiting for the child to exit
if i.error != pthread_join(t, nil)
{
	print("pthread join failed")
}
print("Child thread is gone")