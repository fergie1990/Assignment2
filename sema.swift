import Foundation

//this structure is used to establish variables
//and the mutexes to be used by both threads
struct sem 
{
	var semval = Int32()
	var error: Int32 = 0
	var semlock = pthread_mutex_t()
	var cond = pthread_cond_t()
}

func initialise(val: Int32) -> sem
{
	var s = sem()
	if s.error != pthread_mutex_init(&s.semlock, nil)
	{
		print("Mutex not initialised")
	}
	//initialising wait condition
	if s.error != pthread_cond_init(&s.cond, nil)
	{
		print("Thread condition not initialised")
	}
	s.semval = val
	return s
}

func destruct(sema: inout sem)
{
	if sema.error != pthread_mutex_destroy(&sema.semlock)
	{
		print("Failed to destroy mutex")
	}
	if sema.error != pthread_cond_destroy(&sema.cond)
	{
		print("Failed to destroy condition variable")
	}
	free(&sema)
}

func procure(sema: inout sem)
{
	//print("produre: ", sema.semval)
	//critical section
	if sema.error != pthread_mutex_lock(&sema.semlock)
	{
		print("Mutex failed to lock")
	}
	while(sema.semval <= 0)
	{
		pthread_cond_wait(&sema.cond, &sema.semlock)
	}
	sema.semval -= 1
	//print("val minus 1: ", sema.semval)
	//end critical section
	if sema.error != pthread_mutex_unlock(&sema.semlock)
	{
		print("Mutex failed to unlock")
	}
}

func vacate(sema: inout sem)
{
	//print("vacate: ", sema.semval)
	//critical section
	if sema.error != pthread_mutex_lock(&sema.semlock)
	{
		print("Mutex failed to lock")
	}
	sema.semval += 1
	//print("val plus 1: ", sema.semval)
	pthread_cond_signal(&sema.cond)
	
	//end critical section
	if sema.error != pthread_mutex_unlock(&sema.semlock)
	{
		print("Mutex failed to unlock")
	}
}