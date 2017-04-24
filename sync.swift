import Foundation

//this structure is used to hold the buffer
//and the mutexes to be used by both threads
struct info 
{
	var input = String()
	var readlock = pthread_mutex_t()
	var enterlock = pthread_mutex_t()
	var exitlock = pthread_mutex_t()
	var closelock = pthread_mutex_t()	
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
	pthread_mutex_lock(&i.readlock)
	//check if the structure contains something before unwrapping
	if input != nil 
	{
		let x = input!.load(as: info.self)
		print(x.input)
	}
	
	pthread_mutex_unlock(&i.readlock)
	pthread_mutex_unlock(&i.enterlock)
	
	pthread_mutex_lock(&i.exitlock)
	print("Child thread is exiting")
	pthread_mutex_unlock(&i.exitlock)
	pthread_mutex_unlock(&i.closelock)
	pthread_exit(nil)
}

var i = info()

pthread_mutex_init(&i.readlock, nil)
pthread_mutex_init(&i.enterlock, nil)
pthread_mutex_init(&i.exitlock, nil)
pthread_mutex_init(&i.closelock, nil)

pthread_mutex_lock(&i.readlock)
pthread_mutex_lock(&i.enterlock)
pthread_mutex_lock(&i.exitlock)
pthread_mutex_lock(&i.closelock)

pthread_create(&t, nil, print, &i)
i.input = readStdin()
pthread_mutex_unlock(&i.readlock)

pthread_mutex_lock(&i.enterlock)

print("Please press Enter")
repeat 
{
	i.input = readStdin()
} while i.input != ""
pthread_mutex_unlock(&i.enterlock)
pthread_mutex_unlock(&i.exitlock)

pthread_mutex_lock(&i.closelock)
print("Child thread is gone")
pthread_mutex_unlock(&i.closelock)

sleep(1)