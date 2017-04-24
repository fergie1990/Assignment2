# Assignment2

When there is no syncronization between the threads, the child thread does not wait for the parent thread to fill the buffer before trying to print the buffer. This is because they are running concurrently on separate processors. This issue can be resolved using mutexes.

Using a single mutex is not possible because the child needs to complete printing the buffer before it allows the parent to continue. The olny way to do this is to lock the parent from running that code until after the child has printed the buffer using a second mutex.
The two mutex implementation seams to be a reliable solution.

The third mutex is neccessary for the final implementation. I believe that a foruth mutex is needed to allow for full syncronization between the two threads and the order of tasks they need to complete.