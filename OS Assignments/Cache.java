import java.util.*;

public class Cache {
	private int blockSize = 0;
	private int cacheBlocks = 0;
	Disk memory;
	public Cache(int blockSize, int cacheBlocks) {
        memory = new Disk(cacheBlocks);
	}
	public boolean read(int blockId, byte buffer[]) {
        
	}
	public boolean write(int blockId, byte buffer[]) {

	}
	public void sync() {

	}
	public void flush() {

	}
}