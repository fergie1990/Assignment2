import Foundation

struct info 
{
	var input = String()
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

#if os(macOS)
	var t: pthread_t? = nil
	typealias Arg = UnsafeMutableRawPointer
#else
	var t: pthread_t = pthread_t()
	typealias Arg = UnsafeMutableRawPointer?
#endif

func print(input: Arg) -> UnsafeMutableRawPointer?
{
	if input != nil 
	{
		let x = input!.load(as: info.self)
		print(x.input)
	}
	pthread_exit(nil)
}

var i = info()
i.input = readStdin()
pthread_create(&t, nil, print, &i)
sleep(1)