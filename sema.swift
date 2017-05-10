import Foundation

//this structure is used to establish variables
//and the mutexes to be used by the semaphore
struct sem 
{
	var semval = Int32()
	var error: Int32 = 0
	var semlock = pthread_mutex_t()
	var cond = pthread_cond_t()
}
//takes the return value from a function and prints
//the error code if one occurs
func errorHandler(error: Int32)
{
	if error != 0 
	{
		print("Program failed with error: ", error)	
		exit(EXIT_FAILURE)
	}
	return
}
//initialises the semaphore with the input 
//value, the mutex and the cond variable
func initialise(val: Int32) -> sem
{
	var s = sem()
	s.error = pthread_mutex_init(&s.semlock, nil)
	errorHandler(error: s.error)
	s.error = pthread_cond_init(&s.cond, nil)
	errorHandler(error: s.error)
	s.semval = val
	return s
}
//destroys the mutexes and cond variables used
func destruct(sema: inout sem)
{
	sema.error = pthread_mutex_destroy(&sema.semlock)
	errorHandler(error: sema.error)
	sema.error = pthread_cond_destroy(&sema.cond)
	errorHandler(error: sema.error)
}
//obtains the semaphore
func procure(sema: inout sem)
{
	//critical section
	sema.error = pthread_mutex_lock(&sema.semlock)
	errorHandler(error: sema.error)
	while(sema.semval <= 0)
	{
		sema.error = pthread_cond_wait(&sema.cond, &sema.semlock)
		errorHandler(error: sema.error)
	}
	sema.semval -= 1
	//end critical section
	sema.error = pthread_mutex_unlock(&sema.semlock)
	errorHandler(error: sema.error)
}
//releases the semaphore
func vacate(sema: inout sem)
{
	//critical section
	sema.error = pthread_mutex_lock(&sema.semlock)
	errorHandler(error: sema.error)
	sema.semval += 1
	sema.error = pthread_cond_signal(&sema.cond)
	errorHandler(error: sema.error)
	//end critical section
	sema.error = pthread_mutex_unlock(&sema.semlock)
	errorHandler(error: sema.error)
}