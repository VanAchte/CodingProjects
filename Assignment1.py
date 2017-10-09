import os
import glob

rootDir = "\\Users\\Owner\\Documents\\Music";

def getNumTracks(rootDir):
    totalTracks = 0
    for root, dirs, files in os.walk(rootDir):
        for file in files:
            if file.endswith(".ogg"):
                #print(os.path.join(root, file))
                totalTracks += 1
    return totalTracks


# If path exists, start traversing
if os.path.exists(rootDir):
    print(os.path.exists(rootDir))
    print(os.listdir(rootDir))
    totalTracks = getNumTracks(rootDir)
    print("Total Tracks:", totalTracks)
    print("")
    totalTracks = 0
    for dirname, dirnames, filenames in os.walk(rootDir):
        # print path to all subdirectories first.
        for subdirname in dirnames:
            print(os.path.join(dirname, subdirname))
            print ("subdirname", subdirname)
            print("dirname", dirname)

        # print path to all filenames.
        #for filename in filenames:
         #   print(os.path.join(dirname, filename))
          #  totalTracks += 1

    #print("Total Tracks:",totalTracks)







