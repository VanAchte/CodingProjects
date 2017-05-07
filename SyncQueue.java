/* Author: Conor Van Achte
*  Date: 05/06/2017
*  CSS430
*  Assignment #4
*  Description: Monitor base class for the each thread.
*  @QueueNode[] queue: array of QueueNodes which represent each thread runnning
*                      Each node has two methods, one to sleep, and one to wakeUp the thread.
*/

import java.util.*;


public class SyncQueue  {
	QueueNode[] queue;
    
    //Default value for the number of conditions in the array and the default tid number
    private static int DEFAULT_NUM = 10;
    private static int DEFAULT_TID = 0;
    //Default Constructor
    //@int DEFAULT_NUM: default number of conditions
    public SyncQueue() {
    	queue = new QueueNode(DEFAULT_NUM);
    	for(int i = 0; i < DEFAULT_NUM; i++) {
    		queue[i] = new QueueNode();
    	}
    }
    //One parameter constructor
    //Method instantiates the queue array based on the condMax
    //@param condMax sets max amount of threads in the queue array
    public SyncQueue(int condMax) {
    	queue = new QueueNode(condMax);
    	for(int i = 0; i < condMax; i++) {
    		queue[i] = new QueueNode();
    	}
    }
    //Takes in a paramater that is the thread to be put into the queue and slept 
    //@param condition is the thread to be put in the queue and slept
    public int enqueueAndSleep(int condition) {
        // Error handling for invalid conditions
        if(condition >= 0 && !(condition >= queue.length)) {
        	return queueNode[condition].sleep();
        }
        //Invald condition
        return -1;
    }
    //Takes in a parameter and removes from the queue
    //@param condition: thread to be woken up in the queue
    public void dequeueAndWakeup(int condition) {
        if(condition >= 0 && !(condition >= queue.length)) { 
        	queueNode[condition].wakeUp(DEFAULT_TID); // if no second argument, assume tid as 0
        }
        
    }
    //Takes in a parameter and removes from the queue
    //@param condition: thread to be woken up in the queue
    //@parm tid: the calling thread id
    public void dequeueAndWakeup(int condition, int tid) {
        if(condition >= 0 && !(condition >= queue.length)) { 
        	queueNode[condition].wakeUp(tid);
        }
    }

}