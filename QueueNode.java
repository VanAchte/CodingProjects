/* Author: Conor Van Achte
*  Date: 05/06/2017
*  CSS430
*  Assignment #4
*  
*/
import java.util.Vector;

public class QueueNode {
	//Use a vector for synchronization over an ArrayList
	private Vector<Integer> queue;
    
    //Default constructor
	public QueueNode() {
		queue = new Vector<>();
	}
	//Sleep the calling thread, remove from queue
	public synchronized int sleep() {
        //If queue is empty, try to have the thread wait, else through an exception
        if(queue.isEmpty()) {
            try {
            	wait();
            } catch (InterruptedException e) {
        	    SysLib.out("InterruptedException in sleep");
            }
            // return and remove the sleeping queue number
            return queue.remove(0);
        }
        //sleep call failed, return -1 as a failed message
        return -1;
	}
	//Wake the calling thread, add to the queue
	public synchronized void wakeUp(int tid) {
        queue.add(tid);
        notify();
	}
}