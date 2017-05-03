import Foundation

//this structure is used to establish variables
//and the mutexes to be used by both threads
struct sem 
{
	var semval: Int32 = 1
	var error: Int32 = 0
	var semlock = pthread_mutex_t()
	var cond = pthread_cond_t()
}

func initialise(val: Int32) -> sem
{
	var s = sem()
	s.semval = val
	return s
}

func destruct()
{
	if s.error != pthread_mutex_destroy(&s.semlock)
	{
		print("Failed to destroy mutex")
	}
	if s.error != pthread_cond_destroy(&s.cond)
	{
		print("Failed to destroy condition variable")
	}
	free(&s)
}

func procure(semaphore: sem)
{
	//critical section
	if s.error != pthread_mutex_lock(&s.semlock)
	{
		print("Mutex failed to lock")
	}
	while(s.semval <= 0)
	{
		pthread_cond_wait(&s.cond, &s.semlock)
	}
	s.semval -= 1
	//end critical section
	if s.error != pthread_mutex_unlock(&s.semlock)
	{
		print("Mutex failed to unlock")
	}
}

func vacate(semaphore: sem)
{
	//critical section
	if s.error != pthread_mutex_lock(&s.semlock)
	{
		print("Mutex failed to lock")
	}
	s.semval += 1
	pthread_cond_signal(&s.cond)
	
	//end critical section
	if s.error != pthread_mutex_unlock(&s.semlock)
	{
		print("Mutex failed to unlock")
	}
}

var s: sem = initialise(val: 1)
//initialising the mutex
if s.error != pthread_mutex_init(&s.semlock, nil)
{
	print("Mutex not initialised")
}
//initialising wait condition
if s.error != pthread_cond_init(&s.cond, nil)
{
	print("Thread condition not initialised")
}